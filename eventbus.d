/* Invisible Vector Library
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License ONLY.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
module iv.eventbus /*is aliced*/;
private:

import core.time : MonoTime;
import std.datetime : Clock, SysTime;

import iv.alice;
import iv.weakref;


// ////////////////////////////////////////////////////////////////////////// //
///WARNING! changing this is NOT thread-safe!
///         you should set this up at program startup and don't touch after that
__gshared void delegate (const(char)[] msg) ebusLogError;


/// objects should implement this interface to make sinking/bubbling work.
/// if this interface is not implemented, targeted message will be dropped on the floor.
public interface EventTarget {
  /// this should return parent object or null
  abstract @property Object eventbusParent ();
  /// this will be called on sinking and bubbling
  abstract void eventbusOnEvent (Event evt);
}


// ////////////////////////////////////////////////////////////////////////// //
/** note that when event reached it's destination, it will be switched to bubbling
  * phase before calling the appropriate event handler. */
public class Event {
public:
  /// propagation flags
  enum PFlags : ubyte {
    Eaten     = 1U<<0, /// event is processed, but not cancelled
    Cancelled = 1U<<1, /// event is cancelled (it may be *both* processed and cancelled!)
    Bubbling  = 1U<<2, /// event is in bubbling phase
    Posted    = 1U<<7, /// event is posted
  }
  protected Object osource; /// event source, can be null
  protected Object odest; /// event destination, can be null for broadcast events
  protected ubyte flags; /// see PFlags
  protected SysTime etime; /// emiting time

  this () { etime = Clock.currTime; } ///
  this (Object asrc) { etime = Clock.currTime; osource = asrc; } ///
  this (Object asrc, Object adest) { etime = Clock.currTime; osource = asrc; odest = adest; } ///

  /// post event: put it into queue to process at next iteration.
  final void post () { this.postpone(0); }

  /// schedule event to be processed later (after `msecs` msecs passed)
  final void later (int msecs) { this.postpone(msecs); }

final pure nothrow @safe @nogc:
  void eat () { pragma(inline, true); flags |= PFlags.Eaten; } /// "eat" event (set "eaten" flag)
  void cancel () { pragma(inline, true); flags |= PFlags.Cancelled; } /// "cancel" event (set "cancelled" flag)

  inout(Object) source () inout { pragma(inline, true); return osource; } /// source object
  inout(Object) dest () inout { pragma(inline, true); return odest; } /// destination object
  inout(SysTime) time () inout { pragma(inline, true); return etime; } /// emitting time

const @property:
  bool eaten () { pragma(inline, true); return ((flags&PFlags.Eaten) != 0); } ///
  bool cancelled () { pragma(inline, true); return ((flags&PFlags.Cancelled) != 0); } ///
  bool processed () { pragma(inline, true); return ((flags&(PFlags.Eaten|PFlags.Cancelled)) != 0); } ///
  bool posted () { pragma(inline, true); return ((flags&PFlags.Posted) != 0); } ///
  bool sinking () { pragma(inline, true); return ((flags&PFlags.Bubbling) == 0); } ///
  bool bubbling () { pragma(inline, true); return ((flags&PFlags.Bubbling) != 0); } ///
}


// ////////////////////////////////////////////////////////////////////////// //
/** register listener for all events (both targeted and not, and for anonymous too).
 * returns event id that can be used to remove listener. */
public uint addEventListener(E:Event) (void delegate (E evt) dg, bool oneshot=false) {
  return addEventListener!E(null, dg, oneshot);
}

/** register event listener for *source* object `obj`.
 * returns event id that can be used to remove listener. */
public uint addEventListener(E:Event) (Object obj, void delegate (E evt) dg, bool oneshot=false) {
  if (dg is null) return 0;
  synchronized (Event.classinfo) {
    if (!oneshot) {
      foreach (ref EventListenerInfo eli; llist) {
        if (typeid(E) == eli.ti && eli.dg is cast(EventListenerInfo.DgType)dg) return eli.id;
      }
    }
    llist ~= EventListenerInfo(obj, typeid(E), cast(EventListenerInfo.DgType)dg, oneshot);
    return lastid;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/// remove event listener with the given id. returns `true` if some listener was removed.
public bool removeEventListener (uint id) {
  synchronized (Event.classinfo) {
    if (id !in usedIds) return false;
    usedIds.remove(id);
    foreach (ref EventListenerInfo eli; llist) {
      if (eli.id == id) {
        needListenerCleanup = true;
        eli.id = 0;
        eli.dg = null;
        eli.dobj = null;
        eli.xsrc = null;
        return true;
      }
    }
    return false;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
enum SBDispatchMixin = q{
  static if (is(typeof(&__traits(getMember, this, "onMyEvent")) == delegate) ||
             is(typeof(&__traits(getMember, this, "onMyEvent")) == function))
  {
    {
      //if (this !is evt.odest) return; // not our
      void doit (TypeInfo_Class ti) {
        import std.traits;
        if (typeid(Event) != ti) doit(ti.base);
        if (evt.processed) return;
        foreach (immutable oidx, /*auto*/ over; __traits(getOverloads, this, "onMyEvent")) {
          alias tt = typeof(over);
          static if (is(ReturnType!tt == void)) {
            alias pars = Parameters!tt;
            static if (pars.length == 1) {
              static if (is(pars[0] : Event)) {
                if (typeid(pars[0]) == ti) {
                  if (auto ev = cast(pars[0])evt) {
                    __traits(getOverloads, this, "onMyEvent")[oidx](ev);
                    return;
                  }
                }
              }
            }
          }
        }
      }
      if (evt !is null && !evt.processed && evt.bubbling && evt.odest is this) {
        doit(typeid(evt));
      }
    }
  }
};


private class ObjDispatcher {
  enum Type { Broadcast, My, Sink, Bubble }
  abstract bool alive ();
  abstract Type type ();
  abstract bool isObject (Object o);
  abstract void dispatch (Event ev);
}


/** this should be called in object ctor to automatically connect event listening methods.
 *
 * valid handler methods:
 *
 * ---------------
 *   void onEvent (EventXXX ev); // will receive any events
 *   void onMyEvent (EventXXX ev); // will receive only events targeted to this object (dest is this), when they sinked
 *   void onSinkEvent (EventXXX ev); // will receive sinking events (but not "my")
 *   void onBubbleEvent (EventXXX ev); // will receive bubbling events (but not "my")
 * ---------------
 */
public void connectListeners(O:Object) (O obj) {
  if (obj is null) return;

  void addListener(ObjDispatcher.Type tp) () {
         static if (tp == ObjDispatcher.Type.Broadcast) enum EvtName = "onEvent";
    else static if (tp == ObjDispatcher.Type.My) enum EvtName = "onMyEvent";
    else static if (tp == ObjDispatcher.Type.Sink) enum EvtName = "onSinkEvent";
    else static if (tp == ObjDispatcher.Type.Bubble) enum EvtName = "onBubbleEvent";
    else static assert(0, "invalid type");

    static if (is(typeof(&__traits(getMember, obj, EvtName)) == delegate) ||
               is(typeof(&__traits(getMember, obj, EvtName)) == function))
    {
      static class ObjDispatcherX(OT, ObjDispatcher.Type tp) : ObjDispatcher {
             static if (tp == ObjDispatcher.Type.Broadcast) enum EvtName = "onEvent";
        else static if (tp == ObjDispatcher.Type.My) enum EvtName = "onMyEvent";
        else static if (tp == ObjDispatcher.Type.Sink) enum EvtName = "onSinkEvent";
        else static if (tp == ObjDispatcher.Type.Bubble) enum EvtName = "onBubbleEvent";
        else static assert(0, "invalid type");
        Weak!OT obj;
        this (OT aobj) { obj = new Weak!OT(aobj); /*obj.onDead = &ebusOnDeadCB;*/ }
        override bool alive () { return !obj.empty; }
        override Type type () { return tp; }
        override bool isObject (Object o) {
          if (o is null || obj.empty) return false;
          return (obj.object is o);
        }
        override void dispatch (Event evt) {
          if (obj.empty) return;
          auto o = obj.object;
          scope(exit) o = null; // for GC
          void doit (TypeInfo_Class ti) {
            import std.traits;
            if (typeid(Event) != ti) doit(ti.base);
            if (evt.processed) return;
            foreach (immutable oidx, /*auto*/ over; __traits(getOverloads, OT, EvtName)) {
              alias tt = typeof(over);
              static if (is(ReturnType!tt == void)) {
                alias pars = Parameters!tt;
                static if (pars.length == 1) {
                  static if (is(pars[0] : Event)) {
                    if (typeid(pars[0]) == ti) {
                      if (auto ev = cast(pars[0])evt) {
                        debug(tuing_eventbus) { import iv.vfs.io; VFile("zevtlog.log", "a").writefln("calling %s for %s 0x%08x (%s)", tp, o.classinfo.name, *cast(void**)&o, evt.classinfo.name); }
                        __traits(getOverloads, o, EvtName)[oidx](ev);
                        return;
                      }
                    }
                  }
                }
              }
            }
          }
          doit(typeid(evt));
        }
      }
      synchronized (Event.classinfo) {
        bool found = false;
        static if (tp == ObjDispatcher.Type.Broadcast) {
          foreach (ref EventListenerInfo eli; llist) {
            if (eli.dobj !is null && eli.dobj.type == tp && eli.dobj.isObject(obj)) { found = true; break; }
          }
        }
        if (!found) {
          debug(tuing_eventbus) { import iv.vfs.io; VFile("zevtlog.log", "a").writefln("added %s for %s 0x%08x", tp, obj.classinfo.name, *cast(void**)&obj); }
          auto dp = new ObjDispatcherX!(O, tp)(obj);
          static if (tp == ObjDispatcher.Type.Broadcast) {
            llist ~= EventListenerInfo(dp);
          } else {
            llistsb ~= EventListenerInfo(dp);
          }
        }
      }
    }
  }

  addListener!(ObjDispatcher.Type.Broadcast)();
  addListener!(ObjDispatcher.Type.My)();
  addListener!(ObjDispatcher.Type.Sink)();
  addListener!(ObjDispatcher.Type.Bubble)();
}


// ////////////////////////////////////////////////////////////////////////// //
private import core.thread : Thread, ThreadID;

private __gshared bool nowProcessing = false;
private __gshared ThreadID peLastTID = 0;


/** process queued events. it is safe to post new events in event handlers.
 *
 * WARNING! this MUST be called only in main processing thread!
 */
public void processEvents () {
  usize left;
  synchronized (Event.classinfo) {
    if (nowProcessing) throw new Exception("recursive calls to `processEvents()` aren't allowed");
    if (peLastTID == 0) {
      peLastTID = Thread.getThis.id;
    } else {
      if (peLastTID != Thread.getThis.id) throw new Exception("calling `processEvents()` from different threads aren't allowed");
    }
    nowProcessing = true;
    cleanupListeners();
    // process only so much events to avoid endless loop
    left = ppevents.length;
  }
  Event evt;
  scope(exit) evt = null;
  if (left > 0) {
    auto tm = MonoTime.currTime;
    while (left-- > 0) {
      synchronized (Event.classinfo) {
        if (tm < ppevents[0].hitTime) break;
        evt = ppevents.ptr[0].evt;
        foreach (immutable c; 1..ppevents.length) ppevents.ptr[c-1] = ppevents.ptr[c];
        ppevents[$-1] = ppevents[0].init;
        ppevents.length -= 1;
        ppevents.assumeSafeAppend;
      }
      try {
        callEventListeners(evt);
      } catch (Exception e) {
        if (ebusLogError !is null) {
          ebusLogError("******** EVENT PROCESSING ERROR: "~e.msg);
          ebusLogError("******** EVENT PROCESSING ERROR: "~e.toString);
        }
      }
    }
  }
  // process only so much events to avoid endless loop
  synchronized (Event.classinfo) left = events.length;
  while (left-- > 0) {
    synchronized (Event.classinfo) {
      evt = events.ptr[0];
      foreach (immutable c; 1..events.length) events.ptr[c-1] = events.ptr[c];
      events[$-1] = null;
      events.length -= 1;
      events.assumeSafeAppend;
    }
    try {
      callEventListeners(evt);
    } catch (Exception e) {
      if (ebusLogError !is null) {
        ebusLogError("******** EVENT PROCESSING ERROR: "~e.msg);
        ebusLogError("******** EVENT PROCESSING ERROR: "~e.toString);
      }
    }
  }
  synchronized (Event.classinfo) {
    cleanupListeners();
    nowProcessing = false;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/// returns milliseconds until next postponed event or -1 if there are none
public int ebusSafeDelay () {
  synchronized (Event.classinfo) {
    if (events.length > 0) return 0; // we have something to process
    if (ppevents.length == 0) return -1;
    auto tm = MonoTime.currTime;
    if (tm >= ppevents[0].hitTime) return 0; // first scheduled event should already be fired
    auto res = cast(int)((ppevents[0].hitTime-tm).total!"msecs");
    return res;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
private:
__gshared bool[uint] usedIds;
__gshared uint lastid;
__gshared bool wrapped = false;


uint getId () {
  if (!wrapped) {
    auto res = ++lastid;
    if (res != 0) { usedIds[res] = true; return res; }
    wrapped = true;
    lastid = 1;
  }
  // wrapped
  foreach (long count; 0..cast(long)uint.max+1) {
    if (lastid !in usedIds) { usedIds[lastid] = true; return lastid; }
    if (++lastid == 0) lastid = 1;
  }
  assert(0, "too many listeners!");
}


struct PostponedEvent {
  Event evt;
  MonoTime hitTime;
}

__gshared Event[] events;
__gshared PostponedEvent[] ppevents;


void postpone (Event evt, int msecs) {
  import core.time : dur;
  if (evt is null) return;
  synchronized (Event.classinfo) {
    if (evt.posted) throw new Exception("can't post already posted event");
    evt.flags |= Event.PFlags.Posted;
    if (msecs <= 0) { events ~= evt; return; }
    auto tm = MonoTime.currTime+dur!"msecs"(msecs);
    ppevents ~= PostponedEvent(evt, tm);
    if (ppevents.length > 1) {
      import std.algorithm : sort;
      ppevents.sort!((in ref i0, in ref i1) => i0.hitTime < i1.hitTime);
    }
  }
}


// ////////////////////////////////////////////////////////////////////////// //
// get druntime dynamic cast function
private extern(C) void* _d_dynamic_cast (Object o, ClassInfo c);


struct EventListenerInfo {
  alias DgType = void delegate (/*Event*/void* e); // actually, `e` is any `Event` subclass; cheater!
  TypeInfo_Class ti;
  DgType dg;
  uint id;
  ObjDispatcher dobj;
  Weak!Object xsrc;
  bool oneshot;
  this (TypeInfo_Class ati, DgType adg, bool aoneshot) {
    id = getId;
    ti = ati;
    dg = adg;
    oneshot = aoneshot;
  }
  this (Object asrc, TypeInfo_Class ati, DgType adg, bool aoneshot) {
    id = getId;
    ti = ati;
    dg = adg;
    if (asrc !is null) {
      xsrc = new Weak!Object(asrc);
      //xsrc.onDead = &ebusOnDeadCB;
    }
    oneshot = aoneshot;
  }
  this (ObjDispatcher adobj) {
    id = getId;
    dobj = adobj;
  }
}

__gshared EventListenerInfo[] llist;
__gshared EventListenerInfo[] llistsb; // sink/bubble
__gshared bool needListenerCleanup = false;
shared bool needListenerCleanupSB = false;


void cleanupListeners () {
  if (needListenerCleanup) {
    needListenerCleanup = false;
    int pos = 0;
    while (pos < llist.length) {
      auto ell = llist.ptr+pos;
      if (ell.id != 0) {
        if (ell.dobj !is null && !ell.dobj.alive) ell.id = 0;
        if (ell.xsrc !is null && ell.xsrc.empty) ell.id = 0;
      }
      if (ell.id == 0) {
        foreach (immutable c; pos+1..llist.length) llist.ptr[c-1] = llist.ptr[c];
        llist[$-1] = EventListenerInfo.init;
        llist.length -= 1;
        llist.assumeSafeAppend;
      } else {
        ++pos;
      }
    }
  }
  import core.atomic : cas;
  if (cas(&needListenerCleanupSB, true, false)) {
    int pos = 0;
    while (pos < llistsb.length) {
      auto ell = llistsb.ptr+pos;
      if (ell.id != 0) {
        if (ell.dobj !is null && !ell.dobj.alive) ell.id = 0;
        if (ell.xsrc !is null && ell.xsrc.empty) ell.id = 0;
      }
      if (ell.id == 0) {
        foreach (immutable c; pos+1..llistsb.length) llistsb.ptr[c-1] = llistsb.ptr[c];
        llistsb[$-1] = EventListenerInfo.init;
        llistsb.length -= 1;
        llistsb.assumeSafeAppend;
      } else {
        ++pos;
      }
    }
  }
}


__gshared Object[] evchain;

void buildEvChain (Object obj) {
  if (evchain.length) { evchain[] = null; evchain.length = 0; evchain.assumeSafeAppend; }
  while (obj !is null) {
    evchain ~= obj;
    if (auto itf = cast(EventTarget)(obj)) {
      obj = itf.eventbusParent();
    } else {
      break;
    }
  }
}


// with evchain
void dispatchSinkBubble (Event evt) {
  void callOnTypeFor (ObjDispatcher.Type type, Object obj) {
    usize llen;
    synchronized (Event.classinfo) llen = llistsb.length;
    foreach (usize idx; 0..llen) {
      ObjDispatcher dobj = null;
      synchronized (Event.classinfo) {
        auto eli = &llistsb[idx];
        if (eli.id == 0) continue;
        if (eli.dobj !is null) {
          if (!eli.dobj.alive) { import core.atomic; atomicStore(needListenerCleanupSB, true); eli.id = 0; eli.dobj = null; eli.xsrc = null; continue; }
          dobj = eli.dobj;
          if (dobj.type != type || !dobj.isObject(obj)) dobj = null;
        }
      }
      if (dobj !is null) {
        dobj.dispatch(evt);
        if (evt.processed) break;
      }
    }
  }

  if (evchain.length != 0) {
    // sinking phase, backward
    foreach_reverse (Object o; evchain[1..$]) {
      callOnTypeFor(ObjDispatcher.Type.Sink, o);
      if (evt.processed) return;
      if (auto itf = cast(EventTarget)o) {
        itf.eventbusOnEvent(evt);
        if (evt.processed) return;
      }
    }
    evt.flags |= Event.PFlags.Bubbling;
    callOnTypeFor(ObjDispatcher.Type.My, evchain[0]);
    if (evt.processed) return;
    if (auto itf = cast(EventTarget)evchain[0]) {
      itf.eventbusOnEvent(evt);
      if (evt.processed) return;
    }
    // bubbling phase, forward
    foreach (Object o; evchain[1..$]) {
      callOnTypeFor(ObjDispatcher.Type.Bubble, o);
      if (evt.processed) return;
      if (auto itf = cast(EventTarget)o) {
        itf.eventbusOnEvent(evt);
        if (evt.processed) return;
      }
    }
  } else {
    if (evt.processed) return;
    evt.flags |= Event.PFlags.Bubbling;
    callOnTypeFor(ObjDispatcher.Type.My, evt.odest);
  }
}


void callEventListeners (Event evt) {
  if (evt is null) return;
  scope(exit) { evt.osource = null; evt.odest = null; }
  if (evt.processed) return;
  debug(tuing_eventbus) {{
    import iv.vfs.io;
    auto fo = VFile("zevtlog.log", "a");
    fo.writef("dispatching %s", evt.classinfo.name);
    if (evt.osource !is null) fo.writef("; src=%s", evt.osource.classinfo.name);
    if (evt.odest !is null) fo.writef("; dest=%s", evt.odest.classinfo.name);
    fo.writeln;
  }}
  // broadcast listeners (they will also catch directed events w/o doing sink/bubble)
  usize llen;
  synchronized (Event.classinfo) llen = llist.length;
  foreach (usize idx; 0..llen) {
    ObjDispatcher dobj = null;
    EventListenerInfo.DgType dg = null;
    TypeInfo_Class ti = null;
    Weak!Object xsrc = null;
    bool oneshot = false;
    synchronized (Event.classinfo) {
      auto eli = &llist[idx];
      if (eli.id == 0) continue;
      xsrc = eli.xsrc;
      if (xsrc !is null && xsrc.empty) { needListenerCleanup = true; eli.id = 0; eli.dobj = null; eli.xsrc = null; continue; }
      if (eli.dobj !is null) {
        if (!eli.dobj.alive) { needListenerCleanup = true; eli.id = 0; eli.dobj = null; eli.xsrc = null; continue; }
        dobj = eli.dobj;
        if (dobj.type != ObjDispatcher.Type.Broadcast) dobj = null;
      } else {
        dg = eli.dg;
        ti = eli.ti;
      }
      oneshot = eli.oneshot;
    }
    if (xsrc !is null) {
      if (xsrc.empty) continue;
      if (xsrc.object !is evt.osource) continue;
    }
    if (dobj !is null) {
      if (oneshot) synchronized (Event.classinfo) { auto eli = &llist[idx]; needListenerCleanup = true; eli.id = 0; eli.dg = null; eli.dobj = null; eli.xsrc = null; }
      dobj.dispatch(evt);
      if (evt.processed) break;
    } else if (dg !is null && ti !is null) {
      auto ecc = _d_dynamic_cast(evt, ti);
      if (ecc !is null) {
        if (oneshot) synchronized (Event.classinfo) { auto eli = &llist[idx]; needListenerCleanup = true; eli.id = 0; eli.dg = null; eli.dobj = null; eli.xsrc = null; }
        dg(ecc);
        if (evt.processed) break;
      }
    }
  }
  if (evt.processed) return;
  // targeted message?
  if (evt.odest !is null) {
    scope(exit) if (evchain.length) { evchain[] = null; evchain.length = 0; evchain.assumeSafeAppend; }
    buildEvChain(evt.odest);
    dispatchSinkBubble(evt);
  }
}


// ////////////////////////////////////////////////////////////////////////// //
version(tuing_ebus_test) {
import iv.vfs.io;

class EventEx : Event { this (Object s, Object d) { super(s, d); } }

class Obj : EventTarget {
  Object parent;

  // this should return parent object or null
  override @property Object eventbusParent () { return parent; }

  // this will be called on sinking and bubbling
  override void eventbusOnEvent (Event evt) {
    writefln("eventbusOnEvent: 0x%08x 0x%08x %s", cast(uint)cast(void*)this, cast(uint)cast(void*)evt.odest, evt.bubbling);
    //mixin(SBDispatchMixin);
  }

  this () {
    this.connectListeners();
    writefln("ctor: 0x%08x", cast(uint)cast(void*)this);
  }

  void onEvent (Event evt) {
    writefln("onEvent: 0x%08x 0x%08x %s", cast(uint)cast(void*)this, cast(uint)cast(void*)evt.odest, evt.bubbling);
  }

  void onMyEvent (Event evt) {
    writefln("onMy: 0x%08x 0x%08x %s", cast(uint)cast(void*)this, cast(uint)cast(void*)evt.odest, evt.bubbling);
  }

  void onMyEvent (EventEx evt) {
    writefln("onMyEx: 0x%08x 0x%08x %s", cast(uint)cast(void*)this, cast(uint)cast(void*)evt.odest, evt.bubbling);
  }

  void onSinkEvent (Event evt) {
    writefln("onSink: 0x%08x 0x%08x %s", cast(uint)cast(void*)this, cast(uint)cast(void*)evt.odest, evt.bubbling);
  }

  void onBubbleEvent (EventEx evt) {
    writefln("onBubble: 0x%08x 0x%08x %s", cast(uint)cast(void*)this, cast(uint)cast(void*)evt.odest, evt.bubbling);
  }
}

class Obj1 : Obj {
  alias onMyEvent = super.onMyEvent;

  this () {
    this.connectListeners();
    super();
    //writefln("ctor: 0x%08x", cast(uint)cast(void*)this);
  }

  override void onMyEvent (EventEx evt) {
    writefln("OVERRIDEN onMyEx: 0x%08x 0x%08x %s", cast(uint)cast(void*)this, cast(uint)cast(void*)evt.odest, evt.bubbling);
    super.onMyEvent(evt);
    writefln("EXITING OVERRIDEN onMyEx: 0x%08x 0x%08x %s", cast(uint)cast(void*)this, cast(uint)cast(void*)evt.odest, evt.bubbling);
  }
}


void main () {
  Object o0 = new Obj;
  Obj o1 = new Obj;
  Obj o2 = new Obj1;
  o1.parent = o0;
  o2.parent = o1;
  addEventListener((Event evt) { writeln("!!! main handler!"); });
  (new Event()).post;
  (new Event(null, o0)).post;
  (new Event(null, o1)).post;
  (new Event(null, o2)).post;
  processEvents();
  writeln("====");
  (new EventEx(null, o2)).post;
  processEvents();
}
}
