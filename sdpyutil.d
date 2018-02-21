/* Written by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
 * Understanding is not required. Only obedience.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
module iv.sdpyutil /*is aliced*/;

import arsd.color;
import arsd.simpledisplay;
import iv.alice;

//version = krc_debug;


// ////////////////////////////////////////////////////////////////////////// //
public bool sdpyHasXShm () {
  static if (UsingSimpledisplayX11) {
    __gshared int xshmAvailable = -1;
    if (xshmAvailable < 0) {
      int i1, i2, i3;
      xshmAvailable = (XQueryExtension(XDisplayConnection.get(), "MIT-SHM", &i1, &i2, &i3) != 0 ? 1 : 0);
    }
    return (xshmAvailable > 0);
  } else {
    return false;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/// get desktop number for the given window; -1: unknown
public int getWindowDesktop (SimpleWindow sw) {
  static if (UsingSimpledisplayX11) {
    import core.stdc.config;
    if (sw is null || sw.closed) return -1;
    auto dpy = sw.impl.display;
    auto xwin = sw.impl.window;
    auto atomWTF = GetAtom!("_NET_WM_DESKTOP", true)(dpy);
    Atom aType;
    int format;
    c_ulong itemCount;
    c_ulong bytesAfter;
    void* propRes;
    int desktop = -1;
    auto status = XGetWindowProperty(dpy, xwin, atomWTF, 0, 1, /*False*/0, AnyPropertyType, &aType, &format, &itemCount, &bytesAfter, &propRes);
    if (status >= Success) {
      if (propRes !is null) {
        if (itemCount > 0 && format == 32) desktop = *cast(int*)propRes;
        XFree(propRes);
      }
    }
    return desktop;
  } else {
    return -1;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/// switch to desktop with the given window
public void switchToWindowDesktop(bool doflush=true) (SimpleWindow sw) {
  static if (UsingSimpledisplayX11) {
    if (sw is null || sw.closed) return;
    auto desktop = sw.getWindowDesktop();
    if (desktop < 0) return;
    auto dpy = sw.impl.display;
    XEvent e;
    e.xclient.type = EventType.ClientMessage;
    e.xclient.serial = 0;
    e.xclient.send_event = 1/*True*/;
    e.xclient.message_type = GetAtom!("_NET_CURRENT_DESKTOP", true)(dpy);
    e.xclient.window = RootWindow(dpy, DefaultScreen(dpy));
    e.xclient.format = 32;
    e.xclient.data.l[0] = desktop;
    XSendEvent(dpy, RootWindow(dpy, DefaultScreen(dpy)), false, EventMask.SubstructureRedirectMask|EventMask.SubstructureNotifyMask, &e);
    static if (doflush) flushGui();
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/// switch to the given window
public void switchToWindow(string src="normal") (SimpleWindow sw) if (src == "normal" || src == "pager") {
  static if (UsingSimpledisplayX11) {
    if (sw is null || sw.closed) return;
    switchToWindowDesktop!false(sw);
    auto dpy = sw.impl.display;
    auto xwin = sw.impl.window;
    XEvent e;
    e.xclient.type = EventType.ClientMessage;
    e.xclient.serial = 0;
    e.xclient.send_event = 1/*True*/;
    e.xclient.message_type = GetAtom!("_NET_ACTIVE_WINDOW", true)(dpy);
    e.xclient.window = xwin;
    e.xclient.format = 32;
    static if (src == "pager") {
      e.xclient.data.l[0] = 2; // pretend to be a pager
    } else {
      e.xclient.data.l[0] = 1; // application request
    }
    XSendEvent(dpy, RootWindow(dpy, DefaultScreen(dpy)), false, EventMask.SubstructureRedirectMask|EventMask.SubstructureNotifyMask, &e);
    flushGui();
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/// Get global window coordinates and size. This can be used to show various notifications.
void getWindowRect (SimpleWindow sw, out int x, out int y, out int width, out int height) {
  static if (UsingSimpledisplayX11) {
    if (sw is null || sw.closed) { width = 1; height = 1; return; } // 1: just in case
    Window dummyw;
    //XWindowAttributes xwa;
    //XGetWindowAttributes(dpy, nativeHandle, &xwa);
    //XTranslateCoordinates(dpy, nativeHandle, RootWindow(dpy, DefaultScreen(dpy)), xwa.x, xwa.y, &x, &y, &dummyw);
    XTranslateCoordinates(sw.impl.display, sw.impl.window, RootWindow(sw.impl.display, DefaultScreen(sw.impl.display)), x, y, &x, &y, &dummyw);
    width = sw.width;
    height = sw.height;
  } else {
    assert(0, "iv.sdpyutil: getWindowRect() -- not for windoze yet");
  }
}


// ////////////////////////////////////////////////////////////////////////// //
public void getWorkAreaRect (out int x, out int y, out int width, out int height) {
  static if (UsingSimpledisplayX11) {
    import core.stdc.config;
    width = 800;
    height = 600;
    auto dpy = XDisplayConnection.get;
    if (dpy is null) return;
    auto root = RootWindow(dpy, DefaultScreen(dpy));
    auto atomWTF = GetAtom!("_NET_WORKAREA", true)(dpy);
    Atom aType;
    int format;
    c_ulong itemCount;
    c_ulong bytesAfter;
    int* propRes;
    auto status = XGetWindowProperty(dpy, root, atomWTF, 0, 4, /*False*/0, AnyPropertyType, &aType, &format, &itemCount, &bytesAfter, cast(void**)&propRes);
    if (status >= Success) {
      if (propRes !is null) {
        x = propRes[0];
        y = propRes[1];
        width = propRes[2];
        height = propRes[3];
        XFree(propRes);
      }
    }
  } else {
    width = 800;
    height = 600;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
enum _NET_WM_MOVERESIZE_SIZE_TOPLEFT = 0;
enum _NET_WM_MOVERESIZE_SIZE_TOP = 1;
enum _NET_WM_MOVERESIZE_SIZE_TOPRIGHT = 2;
enum _NET_WM_MOVERESIZE_SIZE_RIGHT = 3;
enum _NET_WM_MOVERESIZE_SIZE_BOTTOMRIGHT = 4;
enum _NET_WM_MOVERESIZE_SIZE_BOTTOM = 5;
enum _NET_WM_MOVERESIZE_SIZE_BOTTOMLEFT = 6;
enum _NET_WM_MOVERESIZE_SIZE_LEFT = 7;
enum _NET_WM_MOVERESIZE_MOVE = 8; /* movement only */
enum _NET_WM_MOVERESIZE_SIZE_KEYBOARD = 9; /* size via keyboard */
enum _NET_WM_MOVERESIZE_MOVE_KEYBOARD = 10; /* move via keyboard */
enum _NET_WM_MOVERESIZE_CANCEL = 11; /* cancel operation */


public void wmInitiateMoving (SimpleWindow sw, int localx, int localy) {
  static if (UsingSimpledisplayX11) {
    if (sw is null || sw.closed || sw.hidden) return;
    Window dummyw;
    auto dpy = sw.impl.display;
    auto xwin = sw.impl.window;
    auto root = RootWindow(dpy, DefaultScreen(dpy));
    // convert local to global
    //{ import core.stdc.stdio; printf("local: %d,%d\n", localx, localy); }
    XTranslateCoordinates(dpy, xwin, root, localx, localy, &localx, &localy, &dummyw);
    //{ import core.stdc.stdio; printf("global: %d,%d\n", localx, localy); }
    // send event
    XEvent e;
    e.xclient.type = EventType.ClientMessage;
    e.xclient.serial = 0;
    e.xclient.send_event = 1/*True*/;
    e.xclient.message_type = GetAtom!("_NET_WM_MOVERESIZE", true)(dpy);
    e.xclient.window = xwin;
    e.xclient.format = 32;
    e.xclient.data.l[0] = localx; // root_x
    e.xclient.data.l[1] = localy; // root_y
    e.xclient.data.l[2] = _NET_WM_MOVERESIZE_MOVE;
    e.xclient.data.l[3] = 0; // left button
    e.xclient.data.l[4] = 1; // application request
    XSendEvent(dpy, root, false, EventMask.SubstructureRedirectMask|EventMask.SubstructureNotifyMask, &e);
    flushGui();
  }
}


public void wmCancelMoving (SimpleWindow sw, int localx, int localy) {
  static if (UsingSimpledisplayX11) {
    if (sw is null || sw.closed || sw.hidden) return;
    Window dummyw;
    auto dpy = sw.impl.display;
    auto xwin = sw.impl.window;
    auto root = RootWindow(dpy, DefaultScreen(dpy));
    // convert local to global
    XTranslateCoordinates(dpy, xwin, root, localx, localy, &localx, &localy, &dummyw);
    // send event
    XEvent e;
    e.xclient.type = EventType.ClientMessage;
    e.xclient.serial = 0;
    e.xclient.send_event = 1/*True*/;
    e.xclient.message_type = GetAtom!("_NET_WM_MOVERESIZE", true)(dpy);
    e.xclient.window = xwin;
    e.xclient.format = 32;
    e.xclient.data.l[0] = localx; // root_x
    e.xclient.data.l[1] = localy; // root_y
    e.xclient.data.l[2] = _NET_WM_MOVERESIZE_CANCEL;
    e.xclient.data.l[3] = 0; // left button
    e.xclient.data.l[4] = 1; // application request
    XSendEvent(dpy, root, false, EventMask.SubstructureRedirectMask|EventMask.SubstructureNotifyMask, &e);
    flushGui();
  }
}


// ////////////////////////////////////////////////////////////////////////// //
public struct XRefCounted(T) if (is(T == struct)) {
private:
  usize intrp__;

private:
  static void doIncRef (usize ox) nothrow @trusted @nogc {
    pragma(inline, true);
    if (ox) {
      *cast(uint*)(ox-uint.sizeof) += 1;
      version(krc_debug) { import core.stdc.stdio : printf; printf("doIncRef for 0x%08x (%u)\n", cast(uint)ox, *cast(uint*)(ox-uint.sizeof)); }
    }
  }

  static void doDecRef() (ref usize ox) {
    if (ox) {
      version(krc_debug) { import core.stdc.stdio : printf; printf("doDecRef for 0x%08x (%u)\n", cast(uint)ox, *cast(uint*)(ox-uint.sizeof)); }
      if ((*cast(uint*)(ox-uint.sizeof) -= 1) == 0) {
        // kill and free
        scope(exit) {
          import core.stdc.stdlib : free;
          import core.memory : GC;

          version(krc_debug) { import core.stdc.stdio : printf; printf("CG CLEANUP FOR WRAPPER 0x%08x\n", cast(uint)ox); }
          version(krc_debug) import core.stdc.stdio : printf;
          void* mem = cast(void*)ox;
          version(krc_debug) { import core.stdc.stdio : printf; printf("DESTROYING WRAPPER 0x%08x\n", cast(uint)mem); }
          enum instSize = T.sizeof;
          auto pbm = __traits(getPointerBitmap, T);
          version(krc_debug) printf("[%.*s]: size=%u (%u) (%u)\n", cast(uint)T.stringof.length, T.stringof.ptr, cast(uint)pbm[0], cast(uint)instSize, cast(uint)(pbm[0]/usize.sizeof));
          immutable(ubyte)* p = cast(immutable(ubyte)*)(pbm.ptr+1);
          usize bitnum = 0;
          immutable end = pbm[0]/usize.sizeof;
          while (bitnum < end) {
            if (p[bitnum/8]&(1U<<(bitnum%8))) {
              usize len = 1;
              while (bitnum+len < end && (p[(bitnum+len)/8]&(1U<<((bitnum+len)%8))) != 0) ++len;
              version(krc_debug) printf("  #%u (%u)\n", cast(uint)(bitnum*usize.sizeof), cast(uint)len);
              GC.removeRange((cast(usize*)mem)+bitnum);
              bitnum += len;
            } else {
              ++bitnum;
            }
          }

          free(cast(void*)(ox-uint.sizeof));
          ox = 0;
        }
        (*cast(T*)ox).destroy;
      }
    }
  }

public:
  this(A...) (auto ref A args) {
    intrp__ = newOx!T(args);
  }

  this() (auto ref typeof(this) src) nothrow @trusted @nogc {
    intrp__ = src.intrp__;
    doIncRef(intrp__);
  }

  ~this () { doDecRef(intrp__); }

  this (this) nothrow @trusted @nogc { doIncRef(intrp__); }

  void opAssign() (typeof(this) src) {
    if (!intrp__ && !src.intrp__) return;
    version(krc_debug) { import core.stdc.stdio : printf; printf("***OPASSIGN(0x%08x -> 0x%08x)\n", cast(void*)src.intrp__, cast(void*)intrp__); }
    if (intrp__) {
      // assigning to non-empty
      if (src.intrp__) {
        // both streams are active
        if (intrp__ == src.intrp__) return; // nothing to do
        auto oldo = intrp__;
        auto newo = src.intrp__;
        // first increase rc for new object
        doIncRef(newo);
        // replace object for this
        intrp__ = newo;
        // release old object
        doDecRef(oldo);
      } else {
        // just close this one
        scope(exit) intrp__ = 0;
        doDecRef(intrp__);
      }
    } else if (src.intrp__) {
      // this is empty, but other is not; easy deal
      intrp__ = src.intrp__;
      doIncRef(intrp__);
    }
  }

  usize toHash () const pure nothrow @safe @nogc { pragma(inline, true); return intrp__; } // yeah, so simple
  bool opEquals() (auto ref typeof(this) s) const { pragma(inline, true); return (intrp__ == s.intrp__); }

  @property bool hasObject () const pure nothrow @trusted @nogc { pragma(inline, true); return (intrp__ != 0); }

  @property inout(T)* intr_ () inout pure nothrow @trusted @nogc { pragma(inline, true); return cast(typeof(return))intrp__; }

  // hack!
  static if (__traits(compiles, ((){T s; bool v = s.valid;}))) {
    @property bool valid () const nothrow @trusted @nogc { pragma(inline, true); return (intrp__ ? intr_.valid : false); }
  }

  alias intr_ this;

static private:
  usize newOx (CT, A...) (auto ref A args) if (is(CT == struct)) {
    import core.exception : onOutOfMemoryErrorNoGC;
    import core.memory : GC;
    import core.stdc.stdlib : malloc, free;
    import core.stdc.string : memset;
    import std.conv : emplace;
    enum instSize = CT.sizeof;
    // let's hope that malloc() aligns returned memory right
    auto memx = malloc(instSize+uint.sizeof);
    if (memx is null) onOutOfMemoryErrorNoGC(); // oops
    scope(failure) free(memx);
    memset(memx, 0, instSize+uint.sizeof);
    *cast(uint*)memx = 1;
    auto mem = memx+uint.sizeof;
    emplace!CT(mem[0..instSize], args);

    version(krc_debug) import core.stdc.stdio : printf;
    auto pbm = __traits(getPointerBitmap, CT);
    version(krc_debug) printf("[%.*s]: size=%u (%u) (%u)\n", cast(uint)CT.stringof.length, CT.stringof.ptr, cast(uint)pbm[0], cast(uint)instSize, cast(uint)(pbm[0]/usize.sizeof));
    immutable(ubyte)* p = cast(immutable(ubyte)*)(pbm.ptr+1);
    usize bitnum = 0;
    immutable end = pbm[0]/usize.sizeof;
    while (bitnum < end) {
      if (p[bitnum/8]&(1U<<(bitnum%8))) {
        usize len = 1;
        while (bitnum+len < end && (p[(bitnum+len)/8]&(1U<<((bitnum+len)%8))) != 0) ++len;
        version(krc_debug) printf("  #%u (%u)\n", cast(uint)(bitnum*usize.sizeof), cast(uint)len);
        GC.addRange((cast(usize*)mem)+bitnum, usize.sizeof*len);
        bitnum += len;
      } else {
        ++bitnum;
      }
    }
    version(krc_debug) { import core.stdc.stdio : printf; printf("CREATED WRAPPER 0x%08x\n", mem); }
    return cast(usize)mem;
  }
}


static if (UsingSimpledisplayX11) {
// ////////////////////////////////////////////////////////////////////////// //
// for X11 we will keep all XShm-allocated images in this list, so we can free 'em on connection closing.
// we'll use glibc malloc()/free(), 'cause `unregisterImage()` can be called from object dtor.
private struct XShmSeg {
private:
  __gshared usize headp = 0, tailp = 0;

  static @property XShmSeg* head () nothrow @trusted @nogc { pragma(inline, true); return cast(XShmSeg*)headp; }
  static @property void head (XShmSeg* v) nothrow @trusted @nogc { pragma(inline, true); headp = cast(usize)v; }

  static @property XShmSeg* tail () nothrow @trusted @nogc { pragma(inline, true); return cast(XShmSeg*)tailp; }
  static @property void tail (XShmSeg* v) nothrow @trusted @nogc { pragma(inline, true); tailp = cast(usize)v; }

private:
  usize segp; // XShmSegmentInfo*; hide it from GC
  usize prevp; // next link; hide it from GC
  usize nextp; // next link; hide it from GC

private:
  @property bool valid () const pure nothrow @trusted @nogc { pragma(inline, true); return (segp != 0); }

  @property XShmSeg* next () pure nothrow @trusted @nogc { pragma(inline, true); return cast(XShmSeg*)nextp; }
  @property void next (XShmSeg* v) pure nothrow @trusted @nogc { pragma(inline, true); nextp = cast(usize)v; }

  @property XShmSeg* prev () pure nothrow @trusted @nogc { pragma(inline, true); return cast(XShmSeg*)prevp; }
  @property void prev (XShmSeg* v) pure nothrow @trusted @nogc { pragma(inline, true); prevp = cast(usize)v; }

  @property XShmSegmentInfo* seg () pure nothrow @trusted @nogc { pragma(inline, true); return cast(XShmSegmentInfo*)segp; }
  @property void seg (XShmSegmentInfo* v) pure nothrow @trusted @nogc { pragma(inline, true); segp = cast(usize)v; }

static:
  XShmSeg* alloc () nothrow @trusted @nogc {
    import core.stdc.stdlib : malloc, free;
    XShmSeg* res = cast(XShmSeg*)malloc(XShmSeg.sizeof);
    if (res !is null) {
      res.seg = cast(XShmSegmentInfo*)malloc(XShmSegmentInfo.sizeof);
      if (res.seg is null) { free(res); return null; }
      res.prev = tail;
      res.next = null;
      if (tail !is null) tail.next = res; else { assert(head is null); head = res; }
      tail = res;
    }
    return res;
  }

  void free (XShmSeg* seg, bool unregister) {
    if (seg !is null) {
      //{ import core.stdc.stdio; printf("00: freeing...\n"); }
      import core.stdc.stdlib : free;
      if (seg.prev !is null) seg.prev.next = seg.next; else { assert(head is seg); head = head.next; if (head !is null) head.prev = null; }
      if (seg.next !is null) seg.next.prev = seg.prev; else { assert(tail is seg); tail = tail.prev; if (tail !is null) tail.next = null; }
      if (seg.seg) {
        if (unregister) {
          //{ import core.stdc.stdio; printf("00: freeing-unreg...\n"); }
          shmdt(seg.seg.shmaddr);
          shmctl(seg.seg.shmid, IPC_RMID, null);
        }
        free(seg.seg);
      }
      free(seg);
    }
  }

  void freeList () {
    import core.stdc.stdlib : free;
    while (head !is null) {
      //{ import core.stdc.stdio; printf("01: freeing...\n"); }
      if (head.seg) {
        //{ import core.stdc.stdio; printf("01: freeing-unreg...\n"); }
        shmdt(head.seg.shmaddr);
        shmctl(head.seg.shmid, IPC_RMID, null);
        free(head.seg);
      }
      auto p = head;
      head = head.next;
      free(p);
    }
    tail = null;
  }

  shared static ~this () { freeList(); }
}
}


// ////////////////////////////////////////////////////////////////////////// //
public alias XImageTC = XRefCounted!XlibImageTC;

public struct XlibImageTC {
  static if (UsingSimpledisplayX11) {
    private bool thisIsXShm;
    private union {
      XImage handle;
      XImage* handleshm;
    }
    private XShmSeg* shminfo;

    @disable this (this);

    this (MemoryImage img, bool xshm=false) {
      if (img is null || img.width < 1 || img.height < 1) throw new Exception("can't create xlib image from empty MemoryImage");
      create(img.width, img.height, img, xshm);
    }

    this (int wdt, int hgt, bool xshm=false) {
      if (wdt < 1 || hgt < 1) throw new Exception("invalid xlib image");
      create(wdt, hgt, null, xshm);
    }

    this (int wdt, int hgt, MemoryImage aimg, bool xshm=false) {
      if (wdt < 1 || hgt < 1) throw new Exception("invalid xlib image");
      create(wdt, hgt, aimg, xshm);
    }

    ~this () { dispose(); }

    @property bool valid () const pure nothrow @trusted @nogc { pragma(inline, true); return (thisIsXShm ? handleshm !is null : handle.data !is null); }
    @property bool xshm () const pure nothrow @trusted @nogc { pragma(inline, true); return thisIsXShm; }

    @property int width () const pure nothrow @trusted @nogc { pragma(inline, true); return (thisIsXShm ? handleshm.width : handle.width); }
    @property int height () const pure nothrow @trusted @nogc { pragma(inline, true); return (thisIsXShm ? handleshm.height : handle.height); }

    inout(uint)* data () inout nothrow @trusted @nogc { pragma(inline, true); return cast(typeof(return))(thisIsXShm ? handleshm.data : handle.data); }

    void setup (MemoryImage aimg, bool xshm=false) {
      dispose();
      if (aimg is null || aimg.width < 1 || aimg.height < 1) throw new Exception("can't create xlib image from empty MemoryImage");
      create(aimg.width, aimg.height, aimg, xshm);
    }

    void setup (int wdt, int hgt, MemoryImage aimg=null, bool xshm=false) {
      dispose();
      if (wdt < 1 || hgt < 1) throw new Exception("invalid xlib image");
      create(wdt, hgt, aimg, xshm);
    }

    TrueColorImage getAsTC () {
      if (!valid) return null;
      auto tc = new TrueColorImage(width, height);
      scope(failure) delete tc;
      auto sc = cast(const(uint)*)data;
      auto dc = tc.imageData.colors.ptr;
      foreach (immutable dy; 0..height) {
        foreach (immutable dx; 0..width) {
          *dc++ = img2c(*sc++);
        }
      }
      return tc;
    }

    private void create (int width, int height, MemoryImage ximg, bool xshm) {
      import core.stdc.stdlib : malloc, free;
      if (xshm && !sdpyHasXShm) xshm = false;
      thisIsXShm = xshm;
      if (xshm) {
        auto dpy = XDisplayConnection.get();
        if (dpy is null) throw new Exception("can't create XShmImage");

        shminfo = XShmSeg.alloc();
        if (shminfo is null) throw new Exception("can't create XShmImage");
        bool registered = false;
        scope(failure) { XShmSeg.free(shminfo, registered); shminfo = null; }

        handleshm = XShmCreateImage(dpy, DefaultVisual(dpy, DefaultScreen(dpy)), 24, ImageFormat.ZPixmap, null, shminfo.seg, width, height);
        if (handleshm is null) throw new Exception("can't create XShmImage");
        assert(handleshm.bytes_per_line == 4*width);

        shminfo.seg.shmid = shmget(IPC_PRIVATE, handleshm.bytes_per_line*height, IPC_CREAT|511 /* 0777 */);
        assert(shminfo.seg.shmid >= 0);
        registered = true;
        handleshm.data = shminfo.seg.shmaddr = cast(ubyte*)shmat(shminfo.seg.shmid, null, 0);
        assert(handleshm.data != cast(ubyte*)-1);

        auto rawData = cast(uint*)handleshm.data;
        if (ximg is null || ximg.width < width || ximg.height < height) rawData[0..width*height] = 0;
        if (ximg !is null && ximg.width > 0 && ximg.height > 0) {
          foreach (immutable int y; 0..height) {
            foreach (immutable int x; 0..width) {
              rawData[y*width+x] = c2img(ximg.getPixel(x, y));
            }
          }
        }

        shminfo.seg.readOnly = 0;
        XShmAttach(dpy, shminfo.seg);
      } else {
        auto rawData = cast(uint*)malloc(width*height*4);
        scope(failure) free(rawData);
        if (ximg is null || ximg.width < width || ximg.height < height) rawData[0..width*height] = 0;
        if (ximg !is null && ximg.width > 0 && ximg.height > 0) {
          foreach (immutable int y; 0..height) {
            foreach (immutable int x; 0..width) {
              rawData[y*width+x] = c2img(ximg.getPixel(x, y));
            }
          }
        }
        //handle = XCreateImage(dpy, DefaultVisual(dpy, screen), 24/*bpp*/, ImageFormat.ZPixmap, 0/*offset*/, cast(ubyte*)rawData, width, height, 8/*FIXME*/, 4*width); // padding, bytes per line
        handle.width = width;
        handle.height = height;
        handle.xoffset = 0;
        handle.format = ImageFormat.ZPixmap;
        handle.data = rawData;
        handle.byte_order = 0;
        handle.bitmap_unit = 32;
        handle.bitmap_bit_order = 0;
        handle.bitmap_pad = 8;
        handle.depth = 24;
        handle.bytes_per_line = 0;
        handle.bits_per_pixel = 32; // THIS MATTERS!
        handle.red_mask = 0x00ff0000;
        handle.green_mask = 0x0000ff00;
        handle.blue_mask = 0x000000ff;
        XInitImage(&handle);
      }
    }

    void dispose () {
      if (thisIsXShm) {
        if (auto dpy = XDisplayConnection.get()) XShmDetach(dpy, shminfo.seg);
        XDestroyImage(handleshm);
        //shmdt(shminfo.seg.shmaddr);
        //shmctl(shminfo.seg.shmid, IPC_RMID, null);
        XShmSeg.free(shminfo, true);
        shminfo = null;
        handleshm = null;
      } else {
        if (handle.data !is null) {
          import core.stdc.stdlib : free;
          if (handle.data !is null) free(handle.data);
          handle = XImage.init;
        }
      }
    }

    void putPixel (int x, int y, Color c) nothrow @trusted @nogc {
      pragma(inline, true);
      if (valid && x >= 0 && y >= 0 && x < width && y < height) {
        data[y*width+x] = c2img(c);
      }
    }

    Color getPixel (int x, int y, Color c) nothrow @trusted @nogc {
      pragma(inline, true);
      return (valid && x >= 0 && y >= 0 && x < width && y < height ? img2c(data[y*width+x]) : Color.transparent);
    }

    uint* row (int y) nothrow @trusted @nogc {
      pragma(inline, true);
      return (valid && y >= 0 && y < height ? data+y*width : null);
    }

    // blit to window buffer
    void blitAt (SimpleWindow w, int destx, int desty) { blitRect(w, destx, desty, 0, 0, width, height); }

    // blit to window buffer
    void blitRect (SimpleWindow w, int destx, int desty, int sx0, int sy0, int swdt, int shgt) {
      if (w is null || !valid || w.closed) return;
      if (thisIsXShm) {
        XShmPutImage(w.impl.display, cast(Drawable)w.impl.buffer, w.impl.gc, handleshm, sx0, sy0, destx, desty, swdt, shgt, 0);
      } else {
        XPutImage(w.impl.display, cast(Drawable)w.impl.buffer, w.impl.gc, &handle, sx0, sy0, destx, desty, swdt, shgt);
      }
    }

    // blit to window
    void blitAtWin (SimpleWindow w, int destx, int desty) { blitRectWin(w, destx, desty, 0, 0, width, height); }

    // blit to window
    void blitRectWin (SimpleWindow w, int destx, int desty, int sx0, int sy0, int swdt, int shgt) {
      if (w is null || !valid || w.closed) return;
      if (thisIsXShm) {
        XShmPutImage(w.impl.display, cast(Drawable)w.impl.window, w.impl.gc, handleshm, sx0, sy0, destx, desty, swdt, shgt, 0);
      } else {
        XPutImage(w.impl.display, cast(Drawable)w.impl.window, w.impl.gc, &handle, sx0, sy0, destx, desty, swdt, shgt);
      }
    }
  }

static:
  public ubyte icR (uint c) pure nothrow @safe @nogc { pragma(inline, true); return ((c>>16)&0xff); }
  public ubyte icG (uint c) pure nothrow @safe @nogc { pragma(inline, true); return ((c>>8)&0xff); }
  public ubyte icB (uint c) pure nothrow @safe @nogc { pragma(inline, true); return (c&0xff); }
  public ubyte icA (uint c) pure nothrow @safe @nogc { pragma(inline, true); return ((c>>24)&0xff); }

  public uint icRGB (int r, int g, int b) pure nothrow @safe @nogc {
    pragma(inline, true);
    return (Color.clampToByte(r)<<16)|(Color.clampToByte(g)<<8)|Color.clampToByte(b);
  }

  public uint icRGBA (int r, int g, int b, int a) pure nothrow @safe @nogc {
    pragma(inline, true);
    return (Color.clampToByte(a)<<24)|(Color.clampToByte(r)<<16)|(Color.clampToByte(g)<<8)|Color.clampToByte(b);
  }

  public uint c2img (in Color c) pure nothrow @safe @nogc {
    pragma(inline, true);
    return
      ((c.asUint&0xff)<<16)|
      (c.asUint&0x00ff00U)|
      ((c.asUint>>16)&0xff);
  }

  public uint c2imgA (in Color c) pure nothrow @safe @nogc {
    pragma(inline, true);
    return
      ((c.asUint&0xff)<<16)|
      (c.asUint&0xff_00ff00U)|
      ((c.asUint>>16)&0xff);
  }

  public uint c2img (uint c) pure nothrow @safe @nogc {
    pragma(inline, true);
    return
      ((c&0xff)<<16)|
      (c&0x00ff00)|
      ((c>>16)&0xff);
  }

  public uint c2imgA (uint c) pure nothrow @safe @nogc {
    pragma(inline, true);
    return
      ((c&0xff)<<16)|
      (c&0xff_00ff00)|
      ((c>>16)&0xff);
  }

  public Color img2c (uint clr) pure nothrow @safe @nogc {
    pragma(inline, true);
    return Color((clr>>16)&0xff, (clr>>8)&0xff, clr&0xff);
  }

  public Color img2cA (uint clr) pure nothrow @safe @nogc {
    pragma(inline, true);
    return Color((clr>>16)&0xff, (clr>>8)&0xff, clr&0xff, (clr>>24)&0xff);
  }
}


// ////////////////////////////////////////////////////////////////////////// //
static if (UsingSimpledisplayX11) {

public alias XPixmap = XRefCounted!XlibPixmap;

public struct XlibPixmap {
  Pixmap xpm;
  private int mWidth, mHeight;

  this (SimpleWindow w) {}

  this (SimpleWindow w, int wdt, int hgt) { setup(w, wdt, hgt); }
  this (SimpleWindow w, ref XlibImageTC xtc) { setup(w, xtc); }
  this (SimpleWindow w, XImageTC xtc) { if (!xtc.hasObject) throw new Exception("can't create pixmap from empty object"); setup(w, *xtc.intr_); }

  this (SimpleWindow w, ref XlibPixmap xpm) { setup(w, xpm); }
  this (SimpleWindow w, XPixmap xpm) { if (!xpm.hasObject) throw new Exception("can't create pixmap from empty object"); setup(w, *xpm.intr_); }

  @disable this (this);

  ~this () { dispose(); }

  @property bool valid () const pure nothrow @trusted @nogc { pragma(inline, true); return (xpm != 0); }

  @property int width () const pure nothrow @trusted @nogc { pragma(inline, true); return mWidth; }
  @property int height () const pure nothrow @trusted @nogc { pragma(inline, true); return mHeight; }

  void copyFromWinBuf (SimpleWindow w) {
    if (w is null || w.closed) throw new Exception("can't copy pixmap without window");
    if (!valid || mWidth != w.width || mHeight != w.height) {
      dispose();
      xpm = XCreatePixmap(w.impl.display, cast(Drawable)w.impl.window, w.width, w.height, 24);
      mWidth = w.width;
      mHeight = w.height;
    }
    XCopyArea(w.impl.display, cast(Drawable)w.impl.buffer, cast(Drawable)xpm, w.impl.gc, 0, 0, mWidth, mHeight, 0, 0);
  }

  void copyFrom (SimpleWindow w, ref XlibPixmap axpm) {
    if (!valid) return;
    if (!axpm.valid) return;
    if (w is null || w.closed) throw new Exception("can't copy pixmap without window");
    XCopyArea(w.impl.display, cast(Drawable)axpm.xpm, cast(Drawable)xpm, w.impl.gc, 0, 0, axpm.width, axpm.height, 0, 0);
  }

  void copyFrom (SimpleWindow w, XPixmap axpm) {
    if (!axpm.hasObject) return;
    copyFrom(w, *axpm.intr_);
  }

  void setup (SimpleWindow w, int wdt, int hgt) {
    dispose();
    if (w is null || w.closed) throw new Exception("can't create pixmap without window");
    if (wdt < 1) wdt = 1;
    if (hgt < 1) hgt = 1;
    if (wdt > 16384) wdt = 16384;
    if (hgt > 16384) hgt = 16384;
    xpm = XCreatePixmap(w.impl.display, cast(Drawable)w.impl.window, wdt, hgt, 24);
    mWidth = wdt;
    mHeight = hgt;
  }

  void setup (SimpleWindow w, XPixmap xpm) {
    if (!xpm.hasObject) throw new Exception("can't create pixmap from empty xlib image");
    setup(w, *xpm.intr_);
  }

  void setup (SimpleWindow w, ref XlibPixmap axpm) {
    if (!axpm.valid) throw new Exception("can't create pixmap from empty xlib pixmap");
    dispose();
    if (w is null || w.closed) throw new Exception("can't create pixmap without window");
    int wdt = axpm.width;
    int hgt = axpm.height;
    if (wdt < 1) wdt = 1;
    if (hgt < 1) hgt = 1;
    if (wdt > 16384) wdt = 16384;
    if (hgt > 16384) hgt = 16384;
    xpm = XCreatePixmap(w.impl.display, cast(Drawable)w.impl.window, wdt, hgt, 24);
    XCopyArea(w.impl.display, cast(Drawable)axpm.xpm, cast(Drawable)xpm, w.impl.gc, 0, 0, wdt, hgt, 0, 0);
    mWidth = wdt;
    mHeight = hgt;
  }

  void setup (SimpleWindow w, XImageTC xtc) {
    if (!xtc.hasObject) throw new Exception("can't create pixmap from empty xlib image");
    setup(w, *xtc.intr_);
  }

  void setup (SimpleWindow w, ref XlibImageTC xtc) {
    if (!xtc.valid) throw new Exception("can't create pixmap from empty xlib image");
    dispose();
    if (w is null || w.closed) throw new Exception("can't create pixmap without window");
    int wdt = xtc.width;
    int hgt = xtc.height;
    if (wdt < 1) wdt = 1;
    if (hgt < 1) hgt = 1;
    if (wdt > 16384) wdt = 16384;
    if (hgt > 16384) hgt = 16384;
    xpm = XCreatePixmap(w.impl.display, cast(Drawable)w.impl.window, wdt, hgt, 24);
    // source x, source y
    if (xtc.thisIsXShm) {
      XShmPutImage(w.impl.display, cast(Drawable)xpm, w.impl.gc, xtc.handleshm, 0, 0, 0, 0, wdt, hgt, 0);
    } else {
      XPutImage(w.impl.display, cast(Drawable)xpm, w.impl.gc, &xtc.handle, 0, 0, 0, 0, wdt, hgt);
    }
    mWidth = wdt;
    mHeight = hgt;
  }

  void dispose () {
    if (xpm) {
      XFreePixmap(XDisplayConnection.get(), xpm);
      xpm = 0;
    }
    mWidth = mHeight = 0;
  }

  // blit to window buffer
  void blitAt (SimpleWindow w, int x, int y) {
    blitRect(w, x, y, 0, 0, width, height);
  }

  // blit to window buffer
  void blitRect (SimpleWindow w, int destx, int desty, int sx0, int sy0, int swdt, int shgt) {
    if (w is null || !xpm || w.closed) return;
    XCopyArea(w.impl.display, cast(Drawable)xpm, cast(Drawable)w.impl.buffer, w.impl.gc, sx0, sy0, swdt, shgt, destx, desty);
  }

  // blit to window buffer
  void blitAtWin (SimpleWindow w, int x, int y) {
    blitRectWin(w, x, y, 0, 0, width, height);
  }

  // blit to window buffer
  void blitRectWin (SimpleWindow w, int destx, int desty, int sx0, int sy0, int swdt, int shgt) {
    if (w is null || !xpm || w.closed) return;
    XCopyArea(w.impl.display, cast(Drawable)xpm, cast(Drawable)w.impl.window, w.impl.gc, sx0, sy0, swdt, shgt, destx, desty);
  }
}

// ////////////////////////////////////////////////////////////////////////// //
}


void sdpyNormalizeArrowKeys(bool domods=true) (ref KeyEvent event) {
  static if (domods) {
    switch (event.key) {
      case Key.Ctrl_r: event.key = Key.Ctrl; return;
      case Key.Shift_r: event.key = Key.Shift; return;
      case Key.Alt_r: event.key = Key.Alt; return;
      case Key.Windows_r: event.key = Key.Windows; return;
      default:
    }
  }
  if ((event.modifierState&ModifierState.numLock) == 0) {
    switch (event.key) {
      case Key.PadEnter: event.key = Key.Enter; return;
      case Key.Pad1: event.key = Key.End; return;
      case Key.Pad2: event.key = Key.Down; return;
      case Key.Pad3: event.key = Key.PageDown; return;
      case Key.Pad4: event.key = Key.Left; return;
      //case Key.Pad5: event.key = Key.; return;
      case Key.Pad6: event.key = Key.Right; return;
      case Key.Pad7: event.key = Key.Home; return;
      case Key.Pad8: event.key = Key.Up; return;
      case Key.Pad9: event.key = Key.PageUp; return;
      case Key.Pad0: event.key = Key.Insert; return;
      default:
    }
  }
}


/+
// ////////////////////////////////////////////////////////////////////////// //
// this mixin can be used to alphablend two `uint` colors
// `colu32name` is variable that holds color to blend,
// `destu32name` is variable that holds "current" color (from surface, for example)
// alpha value of `destu32name` doesn't matter
// alpha value of `colu32name` means: 255 for replace color, 0 for keep `destu32name` (was reversed)
private enum ColorBlendMixinStr(string colu32name, string destu32name) = "{
  immutable uint a_tmp_ = (256-(255-(("~colu32name~")>>24)))&(-(1-(((255-(("~colu32name~")>>24))+1)>>8))); // to not loose bits, but 255 should become 0
  immutable uint dc_tmp_ = ("~destu32name~")&0xffffff;
  immutable uint srb_tmp_ = (("~colu32name~")&0xff00ff);
  immutable uint sg_tmp_ = (("~colu32name~")&0x00ff00);
  immutable uint drb_tmp_ = (dc_tmp_&0xff00ff);
  immutable uint dg_tmp_ = (dc_tmp_&0x00ff00);
  immutable uint orb_tmp_ = (drb_tmp_+(((srb_tmp_-drb_tmp_)*a_tmp_+0x800080)>>8))&0xff00ff;
  immutable uint og_tmp_ = (dg_tmp_+(((sg_tmp_-dg_tmp_)*a_tmp_+0x008000)>>8))&0x00ff00;
  ("~destu32name~") = (orb_tmp_|og_tmp_)|0xff000000; /*&0xffffff;*/
}";


Color blend (Color dst, Color src) nothrow @trusted @nogc {
  pragma(inline, true);
  mixin(ColorBlendMixinStr!("src.asUint", "dst.asUint"));
  return dst;
}


// the only two requirements: alpha is in high bits, and "0 alpha" means "transparent"
uint blendU32 (uint dst, uint src) nothrow @trusted @nogc {
  pragma(inline, true);
  mixin(ColorBlendMixinStr!("src", "dst"));
  return dst;
}
+/

Color blend (Color dst, Color src) pure nothrow @trusted @nogc { pragma(inline, true); return dst.alphaBlend(src); }
uint blendU32 (uint dst, uint src) pure nothrow @trusted @nogc { pragma(inline, true); mixin(Color.ColorBlendMixinStr!("src", "dst")); return dst; }


// ////////////////////////////////////////////////////////////////////////// //
import iv.gxx.geom;

// some "fastgfx" backend
class SdpyDrawBase {
protected:
  static T abs(T) (T n) pure nothrow @safe @nogc { pragma(inline, true); return (n < 0 ? -n : n); }

public:
  GxSize dim;
  GxRect clip;

protected: // low-level methods; will always be called with valid coords
  // must be overriden
  abstract Color getpix (int x, int y);
  abstract void putpix (int x, int y, Color c);

  // optionals
  void hline (int x, int y, int len, Color c) {
    while (len-- > 0) putpix(x++, y, c);
  }

  void vline (int x, int y, int len, Color c) {
    while (len-- > 0) putpix(x, y++, c);
  }

  void fillrc (int x, int y, int w, int h, Color c) {
    while (h-- > 0) hline(x, y++, w, c);
  }

public:
  this (int awdt, int ahgt) {
    if (awdt < 0) awdt = 0;
    if (ahgt < 0) ahgt = 0;
    dim = GxSize(awdt, ahgt);
    clip = GxRect(dim);
  }

  final @property int width () const pure nothrow @safe @nogc { pragma(inline, true); return dim.width; }
  final @property int height () const pure nothrow @safe @nogc { pragma(inline, true); return dim.height; }

  void cls (Color clr=Color.white) { fillrc(0, 0, dim.width, dim.height, clr); }

  // can return null, yeah
  TrueColorImage getBuffer () { return null; }

final:
  Color getPixel (int x, int y) {
    pragma(inline, true);
    return (x >= 0 && y >= 0 && x < dim.width && y < dim.height && clip.inside(x, y) ? getpix(x, y) : Color.transparent);
  }

  void putPixel (int x, int y, Color c) {
    pragma(inline, true);
    if (x >= 0 && y >= 0 && x < dim.width && y < dim.height && clip.inside(x, y)) putpix(x, y, c);
  }

  void drawHLine (int x, int y, int len, Color c) {
    pragma(inline, true);
    if (GxRect(dim).clipHStripe(x, y, len) && clip.clipHStripe(x, y, len)) hline(x, y, len, c);
  }

  void drawVLine (int x, int y, int len, Color c) {
    pragma(inline, true);
    if (GxRect(dim).clipVStripe(x, y, len) && clip.clipVStripe(x, y, len)) vline(x, y, len, c);
  }

  void fillRect (int x, int y, int w, int h, Color c) {
    pragma(inline, true);
    if (GxRect(dim).clipHVStripes(x, y, w, h) && clip.clipHVStripes(x, y, w, h)) fillrc(x, y, w, h, c);
  }

  void drawRect(bool filled) (int x, int y, int w, int h, Color c) {
    pragma(inline, true);
    static if (filled) {
      if (GxRect(dim).clipHVStripes(x, y, w, h) && clip.clipHVStripes(x, y, w, h)) fillrc(x, y, w, h, c);
    } else {
      hline(x, y, w, c);
      if (h > 1) hline(x, y+h-1, w, c);
      if (h > 2 && w > 2) {
        vline(x+1, y, w-2, c);
        vline(x+1, y+h-1, w-2, c);
      }
    }
  }

  void drawEllipse(bool filled=false) (int x0, int y0, int x1, int y1, Color col) {
    int a = abs(x1-x0), b = abs(y1-y0), b1 = b&1; // values of diameter
    long dx = 4*(1-a)*b*b, dy = 4*(b1+1)*a*a; // error increment
    long err = dx+dy+b1*a*a; // error of 1.step
    int prev_y0 = -1, prev_y1 = -1;
    if (x0 > x1) { x0 = x1; x1 += a; } // if called with swapped points...
    if (y0 > y1) y0 = y1; // ...exchange them
    y0 += (b+1)/2; y1 = y0-b1; // starting pixel
    a *= 8*a; b1 = 8*b*b;
    do {
      long e2;
      if (y0 != prev_y0) {
        static if (filled) {
          drawHLine(x0, y0, x1-x0+1, col);
        } else {
          putPixel(x0, y0, col);
          if (x1 != x0) putPixel(x1, y0, col);
        }
        prev_y0 = y0;
      }
      if (y1 != y0 && y1 != prev_y1) {
        static if (filled) {
          drawHLine(x0, y1, x1-x0+1, col);
        } else {
          putPixel(x0, y1, col);
          if (x1 != x0) putPixel(x1, y1, col);
        }
        prev_y1 = y1;
      }
      e2 = 2*err;
      if (e2 >= dx) { ++x0; --x1; err += dx += b1; } // x step
      if (e2 <= dy) { ++y0; --y1; err += dy += a; }  // y step
    } while (x0 <= x1);
    while (y0-y1 < b) {
      // too early stop of flat ellipses a=1
      putPixel(x0-1, ++y0, col); // complete tip of ellipse
      putPixel(x0-1, --y1, col);
    }
  }

  void drawCircle(bool filled=false) (int cx, int cy, int radius, Color col) {
    if (radius < 1) return;
    int error = -radius, x = radius, y = 0;
    if (radius == 1) { putPixel(cx, cy, col); return; }
    while (x >= y) {
      int last_y = y;
      error += y;
      ++y;
      error += y;
      static if (filled) {
        drawHLine(cx-x, cy+last_y, 2*x+1, col);
      } else {
        putPixel(cx-x, cy+last_y, col);
        if (x != 0) putPixel(cx+x, cy+last_y, col);
      }
      if (x != 0 && last_y != 0) {
        static if (filled) {
          drawHLine(cx-x, cy-last_y, 2*x+1, col);
        } else {
          putPixel(cx-x, cy-last_y, col);
          putPixel(cx+x, cy-last_y, col);
        }
      }
      if (error >= 0) {
        if (x != last_y) {
          static if (filled) {
            drawHLine(cx-last_y, cy+x, 2*last_y+1, col);
            if (last_y != 0 && x != 0) drawHLine(cx-last_y, cy-x, 2*last_y+1, col);
          } else {
            putPixel(cx-last_y, cy+x, col);
            if (last_y != 0 && x != 0) {
              putPixel(cx+last_y, cy+x, col);
              putPixel(cx-last_y, cy-x, col);
              putPixel(cx+last_y, cy-x, col);
            }
          }
        }
        error -= x;
        --x;
        error -= x;
      }
    }
  }

  void drawLineEx(bool lastPoint=true) (int x0, int y0, int x1, int y1, scope void delegate (int x, int y) putPixel) {
    enum swap(string a, string b) = "{int tmp_="~a~";"~a~"="~b~";"~b~"=tmp_;}";

    if (x0 == x1 && y0 == y1) {
      static if (lastPoint) putPixel(x0, y0);
      return;
    }

    // clip rectange
    int wx0 = clip.x0, wy0 = clip.y0, wx1 = clip.x1, wy1 = clip.y1;
    if (wx0 < 0) wx0 = 0; else if (wx0 >= dim.width) wx0 = dim.width-1;
    if (wx1 < 0) wx1 = 0; else if (wx1 >= dim.width) wx1 = dim.width-1;
    if (wy0 < 0) wy0 = 0; else if (wy0 >= dim.height) wy0 = dim.height-1;
    if (wy1 < 0) wy1 = 0; else if (wy1 >= dim.height) wy1 = dim.height-1;
    if (wx0 > wx1 || wy0 > wy1) return;
    // other vars
    int stx, sty; // "steps" for x and y axes
    int dsx, dsy; // "lengthes" for x and y axes
    int dx2, dy2; // "double lengthes" for x and y axes
    int xd, yd; // current coord
    int e; // "error" (as in bresenham algo)
    int rem;
    int term;
    int* d0, d1;
    // horizontal setup
    if (x0 < x1) {
      // from left to right
      if (x0 > wx1 || x1 < wx0) return; // out of screen
      stx = 1; // going right
    } else {
      // from right to left
      if (x1 > wx1 || x0 < wx0) return; // out of screen
      stx = -1; // going left
      x0 = -x0;
      x1 = -x1;
      wx0 = -wx0;
      wx1 = -wx1;
      mixin(swap!("wx0", "wx1"));
    }
    // vertical setup
    if (y0 < y1) {
      // from top to bottom
      if (y0 > wy1 || y1 < wy0) return; // out of screen
      sty = 1; // going down
    } else {
      // from bottom to top
      if (y1 > wy1 || y0 < wy0) return; // out of screen
      sty = -1; // going up
      y0 = -y0;
      y1 = -y1;
      wy0 = -wy0;
      wy1 = -wy1;
      mixin(swap!("wy0", "wy1"));
    }
    dsx = x1-x0;
    dsy = y1-y0;
    if (dsx < dsy) {
      d0 = &yd;
      d1 = &xd;
      mixin(swap!("x0", "y0"));
      mixin(swap!("x1", "y1"));
      mixin(swap!("dsx", "dsy"));
      mixin(swap!("wx0", "wy0"));
      mixin(swap!("wx1", "wy1"));
      mixin(swap!("stx", "sty"));
    } else {
      d0 = &xd;
      d1 = &yd;
    }
    dx2 = 2*dsx;
    dy2 = 2*dsy;
    xd = x0;
    yd = y0;
    e = 2*dsy-dsx;
    term = x1;
    bool xfixed = false;
    if (y0 < wy0) {
      // clip at top
      int temp = dx2*(wy0-y0)-dsx;
      xd += temp/dy2;
      rem = temp%dy2;
      if (xd > wx1) return; // x is moved out of clipping rect, nothing to do
      if (xd+1 >= wx0) {
        yd = wy0;
        e -= rem+dsx;
        if (rem > 0) { ++xd; e += dy2; }
        xfixed = true;
      }
    }
    if (!xfixed && x0 < wx0) {
      // clip at left
      int temp = dy2*(wx0-x0);
      yd += temp/dx2;
      rem = temp%dx2;
      if (yd > wy1 || yd == wy1 && rem >= dsx) return;
      xd = wx0;
      e += rem;
      if (rem >= dsx) { ++yd; e -= dx2; }
    }
    if (y1 > wy1) {
      // clip at bottom
      int temp = dx2*(wy1-y0)+dsx;
      term = x0+temp/dy2;
      rem = temp%dy2;
      if (rem == 0) --term;
    }
    if (term > wx1) term = wx1; // clip at right
    static if (lastPoint) {
      // draw last point
      ++term;
    } else {
      if (term == xd) return; // this is the only point, get out of here
    }
    if (sty == -1) yd = -yd;
    if (stx == -1) { xd = -xd; term = -term; }
    dx2 -= dy2;
    // draw it; `putPixel()` can omit checks
    while (xd != term) {
      putPixel(*d0, *d1);
      // done drawing, move coords
      if (e >= 0) {
        yd += sty;
        e -= dx2;
      } else {
        e += dy2;
      }
      xd += stx;
    }
  }

  void drawLine(bool lastPoint=true) (int x0, int y0, int x1, int y1, Color c) { drawLineEx!lastPoint(x0, y0, x1, y1, (x, y) => putPixel(x, y, c)); }

  // ////////////////////////////////////////////////////////////////////// //
  // plot a limited quadratic Bezier segment
  final void drawQuadBezierSeg (int x0, int y0, int x1, int y1, int x2, int y2, Color fc) {
    int sx = x2-x1, sy = y2-y1;
    long xx = x0-x1, yy = y0-y1, xy; // relative values for checks
    double cur = xx*sy-yy*sx; // curvature
    assert(xx*sx <= 0 && yy*sy <= 0); // sign of gradient must not change
    // begin with longer part
    if (sx*cast(long)sx+sy*cast(long)sy > xx*xx+yy*yy) { x2 = x0; x0 = sx+x1; y2 = y0; y0 = sy+y1; cur = -cur; } // swap P0 P2
    // no straight line
    if (cur != 0) {
      xx += sx; xx *= (sx = x0 < x2 ? 1 : -1); // x step direction
      yy += sy; yy *= (sy = y0 < y2 ? 1 : -1); // y step direction
      xy = 2*xx*yy; xx *= xx; yy *= yy; // differences 2nd degree
      // negated curvature?
      if (cur*sx*sy < 0) { xx = -xx; yy = -yy; xy = -xy; cur = -cur; }
      double dx = 4.0*sy*cur*(x1-x0)+xx-xy; // differences 1st degree
      double dy = 4.0*sx*cur*(y0-y1)+yy-xy;
      xx += xx;
      yy += yy;
      double err = dx+dy+xy; // error 1st step
      do {
        putPixel(x0, y0, fc); // plot curve
        if (x0 == x2 && y0 == y2) return; // last pixel -> curve finished
        y1 = 2*err < dx; // save value for test of y step
        if (2*err > dy) { x0 += sx; dx -= xy; err += dy += yy; } // x step
        if (    y1    ) { y0 += sy; dy -= xy; err += dx += xx; } // y step
      } while (dy < 0 && dx > 0); // gradient negates -> algorithm fails
    }
    drawLine(x0, y0, x2, y2, fc); // plot remaining part to end
  }

  // plot any quadratic Bezier curve
  final void drawQuadBezier (int x0, int y0, int x1, int y1, int x2, int y2, Color fc) {
    import std.math : abs, floor;

    int x = x0-x1, y = y0-y1;
    double t = x0-2*x1+x2;

    // horizontal cut at P4?
    if (cast(long)x*(x2-x1) > 0) {
      // vertical cut at P6 too?
      if (cast(long)y*(y2-y1) > 0) {
        // which first?
        if (abs((y0-2*y1+y2)/t*x) > abs(y)) { x0 = x2; x2 = x+x1; y0 = y2; y2 = y+y1; } // swap points
        // now horizontal cut at P4 comes first
      }
      t = (x0-x1)/t;
      double r = (1-t)*((1-t)*y0+2.0*t*y1)+t*t*y2; // By(t=P4)
      t = (x0*x2-x1*x1)*t/(x0-x1); // gradient dP4/dx=0
      x = cast(int)floor(t+0.5); y = cast(int)floor(r+0.5);
      r = (y1-y0)*(t-x0)/(x1-x0)+y0; // intersect P3 | P0 P1
      drawQuadBezierSeg(x0, y0, x, cast(int)floor(r+0.5), x, y, fc);
      r = (y1-y2)*(t-x2)/(x1-x2)+y2; // intersect P4 | P1 P2
      x0 = x1 = x; y0 = y; y1 = cast(int)floor(r+0.5); // P0 = P4, P1 = P8
    }
    // vertical cut at P6?
    if (cast(long)(y0-y1)*(y2-y1) > 0) {
      t = y0-2*y1+y2; t = (y0-y1)/t;
      double r = (1-t)*((1-t)*x0+2.0*t*x1)+t*t*x2; // Bx(t=P6)
      t = (y0*y2-y1*y1)*t/(y0-y1); // gradient dP6/dy=0
      x = cast(int)floor(r+0.5); y = cast(int)floor(t+0.5);
      r = (x1-x0)*(t-y0)/(y1-y0)+x0; // intersect P6 | P0 P1
      drawQuadBezierSeg(x0, y0, cast(int)floor(r+0.5), y, x, y, fc);
      r = (x1-x2)*(t-y2)/(y1-y2)+x2; // intersect P7 | P1 P2
      x0 = x; x1 = cast(int)floor(r+0.5); y0 = y1 = y; // P0 = P6, P1 = P7
    }
    drawQuadBezierSeg(x0, y0, x1, y1, x2, y2, fc); // remaining part
  }

  // plot a limited rational Bezier segment, squared weight
  final void drawQuadRationalBezierSeg (int x0, int y0, int x1, int y1, int x2, int y2, float w, Color fc) {
    import std.math : floor, sqrt;
    int sx = x2-x1, sy = y2-y1; // relative values for checks
    double dx = x0-x2, dy = y0-y2, xx = x0-x1, yy = y0-y1;
    double xy = xx*sy+yy*sx, cur = xx*sy-yy*sx, err; // curvature
    assert(xx*sx <= 0.0 && yy*sy <= 0.0); // sign of gradient must not change
    if (cur != 0.0 && w > 0.0) { // no straight line
      // begin with longer part
      if (sx*cast(long)sx+sy*cast(long)sy > xx*xx+yy*yy) { x2 = x0; x0 -= cast(int)dx; y2 = y0; y0 -= cast(int)dy; cur = -cur; } // swap P0 P2
      xx = 2.0*(4.0*w*sx*xx+dx*dx); // differences 2nd degree
      yy = 2.0*(4.0*w*sy*yy+dy*dy);
      sx = (x0 < x2 ? 1 : -1); // x step direction
      sy = (y0 < y2 ? 1 : -1); // y step direction
      xy = -2.0*sx*sy*(2.0*w*xy+dx*dy);
      // negated curvature?
      if (cur*sx*sy < 0.0) { xx = -xx; yy = -yy; xy = -xy; cur = -cur; }
      dx = 4.0*w*(x1-x0)*sy*cur+xx/2.0+xy; // differences 1st degree
      dy = 4.0*w*(y0-y1)*sx*cur+yy/2.0+xy;
      if (w < 0.5 && dy > dx) {
        // flat ellipse, algorithm fails
        cur = (w+1.0)/2.0; w = sqrt(w); xy = 1.0/(w+1.0);
        sx = cast(int)floor((x0+2.0*w*x1+x2)*xy/2.0+0.5); // subdivide curve in half
        sy = cast(int)floor((y0+2.0*w*y1+y2)*xy/2.0+0.5);
        dx = floor((w*x1+x0)*xy+0.5); dy = floor((y1*w+y0)*xy+0.5);
        drawQuadRationalBezierSeg(x0, y0, cast(int)dx, cast(int)dy, sx, sy, cur, fc);/* plot separately */
        dx = floor((w*x1+x2)*xy+0.5); dy = floor((y1*w+y2)*xy+0.5);
        drawQuadRationalBezierSeg(sx, sy, cast(int)dx, cast(int)dy, x2, y2, cur, fc);
        return;
      }
      err = dx+dy-xy; // error 1.step
      do {
        putPixel(x0, y0, fc); // plot curve
        if (x0 == x2 && y0 == y2) return; // last pixel -> curve finished
        x1 = 2*err > dy; y1 = 2*(err+yy) < -dy;/* save value for test of x step */
        if (2*err < dx || y1) { y0 += sy; dy += xy; err += dx += xx; }/* y step */
        if (2*err > dx || x1) { x0 += sx; dx += xy; err += dy += yy; }/* x step */
      } while (dy <= xy && dx >= xy); // gradient negates -> algorithm fails
    }
    drawLine(x0, y0, x2, y2, fc); // plot remaining needle to end
  }

  // rectangle enclosing the ellipse, integer rotation angle
  final void drawRotatedEllipseRect (int x0, int y0, int x1, int y1, long zd, Color fc) {
    import std.math : floor, sqrt;
    int xd = x1-x0, yd = y1-y0;
    float w = xd*cast(long)yd;
    if (zd == 0) return drawEllipse(x0, y0, x1, y1, fc); // looks nicer
    if (w != 0.0) w = (w-zd)/(w+w); // squared weight of P1
    assert(w <= 1.0 && w >= 0.0); // limit angle to |zd|<=xd*yd
    // snap xe,ye to int
    xd = cast(int)floor(xd*w+0.5);
    yd = cast(int)floor(yd*w+0.5);
    drawQuadRationalBezierSeg(x0, y0+yd, x0, y0, x0+xd, y0, 1.0-w, fc);
    drawQuadRationalBezierSeg(x0, y0+yd, x0, y1, x1-xd, y1, w, fc);
    drawQuadRationalBezierSeg(x1, y1-yd, x1, y1, x1-xd, y1, 1.0-w, fc);
    drawQuadRationalBezierSeg(x1, y1-yd, x1, y0, x0+xd, y0, w, fc);
  }

  // plot ellipse rotated by angle (radian)
  final void drawRotatedEllipse (int x, int y, int a, int b, float angle, Color fc) {
    import std.math : cos, sin, sqrt;
    float xd = cast(long)a*a, yd = cast(long)b*b;
    float s = sin(angle), zd = (xd-yd)*s; // ellipse rotation
    xd = sqrt(xd-zd*s), yd = sqrt(yd+zd*s); // surrounding rectangle
    a = cast(int)(xd+0.5);
    b = cast(int)(yd+0.5);
    zd = zd*a*b/(xd*yd); // scale to integer
    drawRotatedEllipseRect(x-a, y-b, x+a, y+b, cast(long)(4*zd*cos(angle)), fc);
  }

  // plot limited cubic Bezier segment
  final void drawCubicBezierSeg (int x0, int y0, float x1, float y1, float x2, float y2, int x3, int y3, Color fc) {
    import std.math : abs, floor, sqrt;
    immutable double EP = 0.01;

    int f, fx, fy, leg = 1;
    int sx = (x0 < x3 ? 1 : -1), sy = (y0 < y3 ? 1 : -1); // step direction
    float xc = -abs(x0+x1-x2-x3), xa = xc-4*sx*(x1-x2), xb = sx*(x0-x1-x2+x3);
    float yc = -abs(y0+y1-y2-y3), ya = yc-4*sy*(y1-y2), yb = sy*(y0-y1-y2+y3);
    double ab, ac, bc, cb, xx, xy, yy, dx, dy, ex;
    const(double)* pxy;

    // check for curve restrains
    // slope P0-P1 == P2-P3   and  (P0-P3 == P1-P2      or  no slope change)
    assert((x1-x0)*(x2-x3) < EP && ((x3-x0)*(x1-x2) < EP || xb*xb < xa*xc+EP));
    assert((y1-y0)*(y2-y3) < EP && ((y3-y0)*(y1-y2) < EP || yb*yb < ya*yc+EP));
    // quadratic Bezier
    if (xa == 0 && ya == 0) {
      // new midpoint
      sx = cast(int)floor((3*x1-x0+1)/2);
      sy = cast(int)floor((3*y1-y0+1)/2);
      return drawQuadBezierSeg(x0, y0, sx, sy, x3, y3, fc);
    }
    x1 = (x1-x0)*(x1-x0)+(y1-y0)*(y1-y0)+1; // line lengths
    x2 = (x2-x3)*(x2-x3)+(y2-y3)*(y2-y3)+1;
    do { // loop over both ends
      ab = xa*yb-xb*ya; ac = xa*yc-xc*ya; bc = xb*yc-xc*yb;
      ex = ab*(ab+ac-3*bc)+ac*ac; // P0 part of self-intersection loop?
      f = cast(int)(ex > 0 ? 1 : sqrt(1+1024/x1)); // calculate resolution
      ab *= f; ac *= f; bc *= f; ex *= f*f; // increase resolution
      xy = 9*(ab+ac+bc)/8; cb = 8*(xa-ya);/* init differences of 1st degree */
      dx = 27*(8*ab*(yb*yb-ya*yc)+ex*(ya+2*yb+yc))/64-ya*ya*(xy-ya);
      dy = 27*(8*ab*(xb*xb-xa*xc)-ex*(xa+2*xb+xc))/64-xa*xa*(xy+xa);
      // init differences of 2nd degree
      xx = 3*(3*ab*(3*yb*yb-ya*ya-2*ya*yc)-ya*(3*ac*(ya+yb)+ya*cb))/4;
      yy = 3*(3*ab*(3*xb*xb-xa*xa-2*xa*xc)-xa*(3*ac*(xa+xb)+xa*cb))/4;
      xy = xa*ya*(6*ab+6*ac-3*bc+cb); ac = ya*ya; cb = xa*xa;
      xy = 3*(xy+9*f*(cb*yb*yc-xb*xc*ac)-18*xb*yb*ab)/8;
      if (ex < 0) { // negate values if inside self-intersection loop
        dx = -dx; dy = -dy; xx = -xx; yy = -yy; xy = -xy; ac = -ac; cb = -cb;
      } // init differences of 3rd degree
      ab = 6*ya*ac; ac = -6*xa*ac; bc = 6*ya*cb; cb = -6*xa*cb;
      dx += xy; ex = dx+dy; dy += xy; // error of 1st step
      zzloop: for (pxy = &xy, fx = fy = f; x0 != x3 && y0 != y3; ) {
        putPixel(x0, y0, fc); // plot curve
        do { // move sub-steps of one pixel
          if (dx > *pxy || dy < *pxy) break zzloop; // confusing values
          y1 = 2*ex-dy; // save value for test of y step
          if (2*ex >= dx) { fx--; ex += dx += xx; dy += xy += ac; yy += bc; xx += ab; } // x sub-step
          if (y1 <= 0) { fy--; ex += dy += yy; dx += xy += bc; xx += ac; yy += cb; } // y sub-step
        } while (fx > 0 && fy > 0); // pixel complete?
        if (2*fx <= f) { x0 += sx; fx += f; } // x step
        if (2*fy <= f) { y0 += sy; fy += f; } // y step
        if (pxy == &xy && dx < 0 && dy > 0) pxy = &EP;/* pixel ahead valid */
      }
      xx = x0; x0 = x3; x3 = cast(int)xx; sx = -sx; xb = -xb; // swap legs
      yy = y0; y0 = y3; y3 = cast(int)yy; sy = -sy; yb = -yb; x1 = x2;
    } while (leg--); // try other end
    drawLine(x0, y0, x3, y3, fc); // remaining part in case of cusp or crunode
  }

  // plot any cubic Bezier curve
  final void drawCubicBezier (int x0, int y0, int x1, int y1, int x2, int y2, int x3, int y3, Color fc) {
    import std.math : abs, floor, sqrt;
    int n = 0, i = 0;
    long xc = x0+x1-x2-x3, xa = xc-4*(x1-x2);
    long xb = x0-x1-x2+x3, xd = xb+4*(x1+x2);
    long yc = y0+y1-y2-y3, ya = yc-4*(y1-y2);
    long yb = y0-y1-y2+y3, yd = yb+4*(y1+y2);
    float fx0 = x0, fx1, fx2, fx3, fy0 = y0, fy1, fy2, fy3;
    double t1 = xb*xb-xa*xc, t2;
    double[5] t;
    // sub-divide curve at gradient sign changes
    if (xa == 0) { // horizontal
      if (abs(xc) < 2*abs(xb)) t[n++] = xc/(2.0*xb); // one change
    } else if (t1 > 0.0) { // two changes
      t2 = sqrt(t1);
      t1 = (xb-t2)/xa; if (abs(t1) < 1.0) t[n++] = t1;
      t1 = (xb+t2)/xa; if (abs(t1) < 1.0) t[n++] = t1;
    }
    t1 = yb*yb-ya*yc;
    if (ya == 0) { // vertical
      if (abs(yc) < 2*abs(yb)) t[n++] = yc/(2.0*yb); // one change
    } else if (t1 > 0.0) { // two changes
      t2 = sqrt(t1);
      t1 = (yb-t2)/ya; if (abs(t1) < 1.0) t[n++] = t1;
      t1 = (yb+t2)/ya; if (abs(t1) < 1.0) t[n++] = t1;
    }
    // bubble sort of 4 points
    for (i = 1; i < n; i++) if ((t1 = t[i-1]) > t[i]) { t[i-1] = t[i]; t[i] = t1; i = 0; }
    t1 = -1.0; t[n] = 1.0; // begin / end point
    for (i = 0; i <= n; i++) { // plot each segment separately
      t2 = t[i]; // sub-divide at t[i-1], t[i]
      fx1 = (t1*(t1*xb-2*xc)-t2*(t1*(t1*xa-2*xb)+xc)+xd)/8-fx0;
      fy1 = (t1*(t1*yb-2*yc)-t2*(t1*(t1*ya-2*yb)+yc)+yd)/8-fy0;
      fx2 = (t2*(t2*xb-2*xc)-t1*(t2*(t2*xa-2*xb)+xc)+xd)/8-fx0;
      fy2 = (t2*(t2*yb-2*yc)-t1*(t2*(t2*ya-2*yb)+yc)+yd)/8-fy0;
      fx0 -= fx3 = (t2*(t2*(3*xb-t2*xa)-3*xc)+xd)/8;
      fy0 -= fy3 = (t2*(t2*(3*yb-t2*ya)-3*yc)+yd)/8;
      // scale bounds to int
      x3 = cast(int)floor(fx3+0.5);
      y3 = cast(int)floor(fy3+0.5);
      if (fx0 != 0.0) { fx1 *= fx0 = (x0-x3)/fx0; fx2 *= fx0; }
      if (fy0 != 0.0) { fy1 *= fy0 = (y0-y3)/fy0; fy2 *= fy0; }
      if (x0 != x3 || y0 != y3) drawCubicBezierSeg(x0, y0, x0+fx1, y0+fy1, x0+fx2, y0+fy2, x3, y3, fc); // segment t1 - t2
      x0 = x3; y0 = y3; fx0 = fx3; fy0 = fy3; t1 = t2;
    }
  }

  // ////////////////////////////////////////////////////////////////////////// //
  enum CharWidth = 10, CharHeight = 10;

  void drawChar (int x, int y, char ch, Color c, Color bg=Color.transparent) {
    foreach (immutable dy; 0..10) {
      ushort w = confont10.ptr[ch*10+dy];
      foreach (immutable dx; 0..10) {
        if (w&0x8000) {
          if (c.a != 0) putPixel(x+dx, y+dy, c);
        } else {
          if (bg.a != 0) putPixel(x+dx, y+dy, bg);
        }
        w <<= 1;
      }
    }
  }

  void drawText (int x, int y, const(char)[] text, Color c, Color bg=Color.transparent) {
    foreach (char ch; text) {
      drawChar(x, y, ch, c, bg);
      x += CharWidth;
    }
  }

  void drawTextShadow (int x, int y, const(char)[] text, Color c, Color shadc) {
    drawText(x+1, y+1, text, shadc);
    drawText(x, y, text, c);
  }

  // ////////////////////////////////////////////////////////////////////////// //
  static public __gshared immutable ushort[256*10] confont10 = [
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x3f00,0x4080,0x5280,0x4080,0x5e80,0x4c80,0x2100,0x1e00,
    0x0000,0x0000,0x3f00,0x7f80,0x6d80,0x7f80,0x6180,0x7380,0x3f00,0x1e00,0x0000,0x0000,0x3b80,0x7fc0,0x7fc0,0x7fc0,0x3f80,0x1f00,0x0e00,
    0x0400,0x0000,0x0400,0x0e00,0x1f00,0x3f80,0x7fc0,0x3f80,0x1f00,0x0e00,0x0400,0x0000,0x0000,0x0e00,0x1f00,0x0e00,0x3f80,0x7fc0,0x3580,
    0x0400,0x0e00,0x0000,0x0400,0x0e00,0x1f00,0x3f80,0x7fc0,0x7fc0,0x3580,0x0400,0x0e00,0x0000,0x0000,0x0000,0x0000,0x0c00,0x1e00,0x1e00,
    0x0c00,0x0000,0x0000,0x0000,0xffc0,0xffc0,0xffc0,0xf3c0,0xe1c0,0xe1c0,0xf3c0,0xffc0,0xffc0,0xffc0,0x0000,0x0000,0x1e00,0x3300,0x2100,
    0x2100,0x3300,0x1e00,0x0000,0x0000,0xffc0,0xffc0,0xe1c0,0xccc0,0xdec0,0xdec0,0xccc0,0xe1c0,0xffc0,0xffc0,0x0000,0x0780,0x0380,0x0780,
    0x3e80,0x6600,0x6600,0x6600,0x3c00,0x0000,0x0000,0x1e00,0x3300,0x3300,0x3300,0x1e00,0x0c00,0x3f00,0x0c00,0x0000,0x0400,0x0600,0x0700,
    0x0500,0x0500,0x0400,0x1c00,0x3c00,0x1800,0x0000,0x0000,0x1f80,0x1f80,0x1080,0x1080,0x1180,0x3380,0x7100,0x2000,0x0000,0x0000,0x0c00,
    0x6d80,0x1e00,0x7380,0x7380,0x1e00,0x6d80,0x0c00,0x0000,0x1000,0x1800,0x1c00,0x1e00,0x1f00,0x1e00,0x1c00,0x1800,0x1000,0x0000,0x0100,
    0x0300,0x0700,0x0f00,0x1f00,0x0f00,0x0700,0x0300,0x0100,0x0000,0x0000,0x0c00,0x1e00,0x3f00,0x0c00,0x0c00,0x3f00,0x1e00,0x0c00,0x0000,
    0x0000,0x3300,0x3300,0x3300,0x3300,0x3300,0x0000,0x3300,0x0000,0x0000,0x0000,0x3f80,0x6d80,0x6d80,0x3d80,0x0d80,0x0d80,0x0d80,0x0000,
    0x0000,0x0000,0x1f00,0x3000,0x1f00,0x3180,0x1f00,0x0180,0x1f00,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x7f80,0x7f80,0x7f80,
    0x0000,0x0000,0x0000,0x0c00,0x1e00,0x3f00,0x0c00,0x0c00,0x3f00,0x1e00,0x0c00,0xffc0,0x0000,0x0c00,0x1e00,0x3f00,0x0c00,0x0c00,0x0c00,
    0x0c00,0x0c00,0x0000,0x0000,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x3f00,0x1e00,0x0c00,0x0000,0x0000,0x0000,0x0600,0x0300,0x7f80,0x0300,
    0x0600,0x0000,0x0000,0x0000,0x0000,0x0000,0x1800,0x3000,0x7f80,0x3000,0x1800,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x6000,
    0x6000,0x6000,0x7f80,0x0000,0x0000,0x0000,0x0000,0x1100,0x3180,0x7fc0,0x3180,0x1100,0x0000,0x0000,0x0000,0x0000,0x0000,0x0400,0x0e00,
    0x1f00,0x3f80,0x7fc0,0x0000,0x0000,0x0000,0x0000,0x0000,0x7fc0,0x3f80,0x1f00,0x0e00,0x0400,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0c00,0x1e00,0x1e00,0x0c00,0x0c00,0x0000,0x0c00,0x0000,0x0000,0x0000,0x1b00,
    0x1b00,0x1b00,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x1b00,0x1b00,0x7fc0,0x1b00,0x7fc0,0x1b00,0x1b00,0x0000,0x0000,0x0400,
    0x1f00,0x3580,0x3400,0x1f00,0x0580,0x3580,0x1f00,0x0400,0x0000,0x0000,0x3180,0x3300,0x0600,0x0c00,0x1980,0x3180,0x0000,0x0000,0x0000,
    0x0000,0x1c00,0x3300,0x3300,0x1f80,0x3300,0x3300,0x1d80,0x0000,0x0000,0x0000,0x0e00,0x0c00,0x1800,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0600,0x0c00,0x1800,0x1800,0x1800,0x0c00,0x0600,0x0000,0x0000,0x0000,0x1800,0x0c00,0x0600,0x0600,0x0600,0x0c00,0x1800,
    0x0000,0x0000,0x0000,0x0000,0x3300,0x1e00,0x7f80,0x1e00,0x3300,0x0000,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,0x3f00,0x0c00,0x0c00,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,0x1800,0x0000,0x0000,0x0000,0x0000,0x0000,0x3f00,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,0x0000,0x0000,0x0000,0x0180,0x0300,0x0600,0x0c00,
    0x1800,0x3000,0x6000,0x0000,0x0000,0x0000,0x1f00,0x3380,0x3780,0x3f80,0x3d80,0x3980,0x1f00,0x0000,0x0000,0x0000,0x0c00,0x1c00,0x0c00,
    0x0c00,0x0c00,0x0c00,0x3f00,0x0000,0x0000,0x0000,0x1f00,0x3180,0x0180,0x0f00,0x1800,0x3180,0x3f80,0x0000,0x0000,0x0000,0x1f00,0x3180,
    0x0180,0x0700,0x0180,0x3180,0x1f00,0x0000,0x0000,0x0000,0x0700,0x0f00,0x1b00,0x3300,0x3f80,0x0300,0x0780,0x0000,0x0000,0x0000,0x3f80,
    0x3000,0x3000,0x3f00,0x0180,0x3180,0x1f00,0x0000,0x0000,0x0000,0x0f00,0x1800,0x3000,0x3f00,0x3180,0x3180,0x1f00,0x0000,0x0000,0x0000,
    0x3f80,0x3180,0x0180,0x0300,0x0600,0x0c00,0x0c00,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3180,0x1f00,0x3180,0x3180,0x1f00,0x0000,0x0000,
    0x0000,0x1f00,0x3180,0x3180,0x1f80,0x0180,0x0300,0x1e00,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,0x0000,0x0000,0x0c00,0x0c00,0x0000,
    0x0000,0x0000,0x0000,0x0c00,0x0c00,0x0000,0x0000,0x0c00,0x0c00,0x1800,0x0000,0x0000,0x0300,0x0600,0x0c00,0x1800,0x0c00,0x0600,0x0300,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x3f00,0x0000,0x3f00,0x0000,0x0000,0x0000,0x0000,0x0000,0x1800,0x0c00,0x0600,0x0300,0x0600,0x0c00,
    0x1800,0x0000,0x0000,0x0000,0x1e00,0x3300,0x0300,0x0300,0x0600,0x0c00,0x0000,0x0c00,0x0000,0x0000,0x3f00,0x6180,0x6780,0x6d80,0x6780,
    0x6000,0x3f00,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3180,0x3f80,0x3180,0x3180,0x3180,0x0000,0x0000,0x0000,0x3f00,0x3180,0x3180,0x3f00,
    0x3180,0x3180,0x3f00,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3000,0x3000,0x3000,0x3180,0x1f00,0x0000,0x0000,0x0000,0x3e00,0x3300,0x3180,
    0x3180,0x3180,0x3300,0x3e00,0x0000,0x0000,0x0000,0x3f80,0x3000,0x3000,0x3f00,0x3000,0x3000,0x3f80,0x0000,0x0000,0x0000,0x3f80,0x3000,
    0x3000,0x3f00,0x3000,0x3000,0x3000,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3000,0x3380,0x3180,0x3180,0x1f00,0x0000,0x0000,0x0000,0x3180,
    0x3180,0x3180,0x3f80,0x3180,0x3180,0x3180,0x0000,0x0000,0x0000,0x1e00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x1e00,0x0000,0x0000,0x0000,
    0x0700,0x0300,0x0300,0x0300,0x3300,0x3300,0x1e00,0x0000,0x0000,0x0000,0x3180,0x3180,0x3300,0x3e00,0x3300,0x3180,0x3180,0x0000,0x0000,
    0x0000,0x3000,0x3000,0x3000,0x3000,0x3000,0x3000,0x3f80,0x0000,0x0000,0x0000,0x6180,0x7380,0x7f80,0x6d80,0x6180,0x6180,0x6180,0x0000,
    0x0000,0x0000,0x3180,0x3980,0x3d80,0x3780,0x3380,0x3180,0x3180,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3180,0x3180,0x3180,0x3180,0x1f00,
    0x0000,0x0000,0x0000,0x3f00,0x3180,0x3180,0x3f00,0x3000,0x3000,0x3000,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3180,0x3180,0x3180,0x3380,
    0x1f00,0x0380,0x0000,0x0000,0x3f00,0x3180,0x3180,0x3f00,0x3300,0x3180,0x3180,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3000,0x1f00,0x0180,
    0x3180,0x1f00,0x0000,0x0000,0x0000,0x7f80,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0000,0x0000,0x0000,0x3180,0x3180,0x3180,0x3180,
    0x3180,0x3180,0x1f00,0x0000,0x0000,0x0000,0x3180,0x3180,0x3180,0x3180,0x1b00,0x0e00,0x0400,0x0000,0x0000,0x0000,0x6180,0x6180,0x6180,
    0x6d80,0x7f80,0x7380,0x6180,0x0000,0x0000,0x0000,0x6180,0x3300,0x1e00,0x0c00,0x1e00,0x3300,0x6180,0x0000,0x0000,0x0000,0x6180,0x6180,
    0x3300,0x1e00,0x0c00,0x0c00,0x0c00,0x0000,0x0000,0x0000,0x3f80,0x0300,0x0600,0x0c00,0x1800,0x3000,0x3f80,0x0000,0x0000,0x0000,0x1e00,
    0x1800,0x1800,0x1800,0x1800,0x1800,0x1e00,0x0000,0x0000,0x0000,0x6000,0x3000,0x1800,0x0c00,0x0600,0x0300,0x0000,0x0000,0x0000,0x0000,
    0x1e00,0x0600,0x0600,0x0600,0x0600,0x0600,0x1e00,0x0000,0x0000,0x0000,0x0400,0x0e00,0x1b00,0x3180,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0xffc0,0x0000,0x0000,0x1c00,0x0c00,0x0600,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x1f00,0x0180,0x1f80,0x3180,0x1f80,0x0000,0x0000,0x0000,0x3000,0x3000,0x3f00,0x3180,0x3180,0x3180,0x3f00,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3000,0x3180,0x1f00,0x0000,0x0000,0x0000,0x0180,0x0180,0x1f80,0x3180,0x3180,0x3180,
    0x1f80,0x0000,0x0000,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3f80,0x3000,0x1f00,0x0000,0x0000,0x0000,0x0f00,0x1800,0x1800,0x3e00,0x1800,
    0x1800,0x1800,0x0000,0x0000,0x0000,0x0000,0x0000,0x1f80,0x3180,0x3180,0x3180,0x1f80,0x0180,0x1f00,0x0000,0x3000,0x3000,0x3f00,0x3180,
    0x3180,0x3180,0x3180,0x0000,0x0000,0x0000,0x0c00,0x0000,0x1c00,0x0c00,0x0c00,0x0c00,0x1e00,0x0000,0x0000,0x0000,0x0600,0x0000,0x0e00,
    0x0600,0x0600,0x0600,0x0600,0x0600,0x1c00,0x0000,0x3000,0x3000,0x3180,0x3300,0x3e00,0x3300,0x3180,0x0000,0x0000,0x0000,0x1c00,0x0c00,
    0x0c00,0x0c00,0x0c00,0x0c00,0x0700,0x0000,0x0000,0x0000,0x0000,0x0000,0x3300,0x7f80,0x6d80,0x6d80,0x6180,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x3f00,0x3180,0x3180,0x3180,0x3180,0x0000,0x0000,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3180,0x3180,0x1f00,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x3f00,0x3180,0x3180,0x3f00,0x3000,0x3000,0x0000,0x0000,0x0000,0x0000,0x1f80,0x3180,0x3180,0x1f80,0x0180,0x01c0,0x0000,
    0x0000,0x0000,0x0000,0x3f00,0x3180,0x3000,0x3000,0x3000,0x0000,0x0000,0x0000,0x0000,0x0000,0x1f80,0x3000,0x1f00,0x0180,0x3f00,0x0000,
    0x0000,0x0000,0x1800,0x1800,0x3e00,0x1800,0x1800,0x1800,0x0f00,0x0000,0x0000,0x0000,0x0000,0x0000,0x3180,0x3180,0x3180,0x3180,0x1f80,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x3180,0x3180,0x1b00,0x0e00,0x0400,0x0000,0x0000,0x0000,0x0000,0x0000,0x6180,0x6d80,0x6d80,0x7f80,
    0x3300,0x0000,0x0000,0x0000,0x0000,0x0000,0x3180,0x1b00,0x0e00,0x1b00,0x3180,0x0000,0x0000,0x0000,0x0000,0x0000,0x3180,0x3180,0x3180,
    0x1f80,0x0180,0x1f00,0x0000,0x0000,0x0000,0x0000,0x3f00,0x0600,0x0c00,0x1800,0x3f00,0x0000,0x0000,0x0000,0x0e00,0x1800,0x1800,0x3000,
    0x1800,0x1800,0x0e00,0x0000,0x0000,0x0c00,0x0c00,0x0c00,0x0c00,0x0000,0x0c00,0x0c00,0x0c00,0x0c00,0x0000,0x0000,0x1c00,0x0600,0x0600,
    0x0300,0x0600,0x0600,0x1c00,0x0000,0x0000,0x0000,0x0000,0x0000,0x3800,0x6d80,0x0700,0x0000,0x0000,0x0000,0x0000,0x0000,0x0400,0x0e00,
    0x1b00,0x3180,0x3180,0x3180,0x3f80,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3000,0x3000,0x3000,0x3180,0x1f00,0x0c00,0x1800,0x0000,0x1b00,
    0x0000,0x3180,0x3180,0x3180,0x3180,0x1f80,0x0000,0x0000,0x0600,0x0c00,0x0000,0x1f00,0x3180,0x3f80,0x3000,0x1f00,0x0000,0x0000,0x0e00,
    0x1b00,0x0000,0x1f00,0x0180,0x1f80,0x3180,0x1f80,0x0000,0x0000,0x0000,0x1b00,0x0000,0x1f00,0x0180,0x1f80,0x3180,0x1f80,0x0000,0x0000,
    0x0c00,0x0600,0x0000,0x1f00,0x0180,0x1f80,0x3180,0x1f80,0x0000,0x0000,0x0e00,0x1b00,0x0e00,0x1f00,0x0180,0x1f80,0x3180,0x1f80,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3000,0x3180,0x1f00,0x0c00,0x1800,0x0e00,0x1b00,0x0000,0x1f00,0x3180,0x3f80,0x3000,0x1f00,
    0x0000,0x0000,0x0000,0x1b00,0x0000,0x1f00,0x3180,0x3f80,0x3000,0x1f00,0x0000,0x0000,0x0c00,0x0600,0x0000,0x1f00,0x3180,0x3f80,0x3000,
    0x1f00,0x0000,0x0000,0x0000,0x3600,0x0000,0x1c00,0x0c00,0x0c00,0x0c00,0x1e00,0x0000,0x0000,0x1c00,0x3600,0x0000,0x1c00,0x0c00,0x0c00,
    0x0c00,0x1e00,0x0000,0x0000,0x1800,0x0c00,0x0000,0x1c00,0x0c00,0x0c00,0x0c00,0x1e00,0x0000,0x0000,0x0000,0x1b00,0x0000,0x1f00,0x3180,
    0x3f80,0x3180,0x3180,0x0000,0x0000,0x0e00,0x1b00,0x0e00,0x1f00,0x3180,0x3f80,0x3180,0x3180,0x0000,0x0000,0x0600,0x0c00,0x0000,0x3f80,
    0x3000,0x3f00,0x3000,0x3f80,0x0000,0x0000,0x0000,0x0000,0x0000,0x3b80,0x0ec0,0x3fc0,0x6e00,0x3b80,0x0000,0x0000,0x0000,0x1f80,0x3600,
    0x6600,0x7f80,0x6600,0x6600,0x6780,0x0000,0x0000,0x0e00,0x1b00,0x0000,0x1f00,0x3180,0x3180,0x3180,0x1f00,0x0000,0x0000,0x0000,0x1b00,
    0x0000,0x1f00,0x3180,0x3180,0x3180,0x1f00,0x0000,0x0000,0x0c00,0x0600,0x0000,0x1f00,0x3180,0x3180,0x3180,0x1f00,0x0000,0x0000,0x0e00,
    0x1b00,0x0000,0x3180,0x3180,0x3180,0x3180,0x1f80,0x0000,0x0000,0x0c00,0x0600,0x0000,0x3180,0x3180,0x3180,0x3180,0x1f80,0x0000,0x0000,
    0x0000,0x1b00,0x0000,0x3180,0x3180,0x3180,0x1f80,0x0180,0x1f00,0x0000,0x0000,0x1b00,0x0000,0x1f00,0x3180,0x3180,0x3180,0x1f00,0x0000,
    0x0000,0x0000,0x1b00,0x0000,0x3180,0x3180,0x3180,0x3180,0x1f80,0x0000,0x0000,0x0000,0x0000,0x0400,0x1f00,0x3580,0x3400,0x3580,0x1f00,
    0x0400,0x0000,0x0000,0x0f00,0x1980,0x1800,0x3e00,0x1800,0x1800,0x3000,0x3f80,0x0000,0x0000,0x6180,0x6180,0x3300,0x1e00,0x3f00,0x0c00,
    0x3f00,0x0c00,0x0000,0x0000,0x7f00,0x6180,0x6d80,0x6d80,0x7f00,0x6c00,0x6c00,0x6700,0x0000,0x0000,0x0700,0x0c00,0x0c00,0x1e00,0x0c00,
    0x0c00,0x0c00,0x3800,0x0000,0x0600,0x0c00,0x0000,0x1f00,0x0180,0x1f80,0x3180,0x1f80,0x0000,0x0000,0x0c00,0x1800,0x0000,0x1c00,0x0c00,
    0x0c00,0x0c00,0x1e00,0x0000,0x0000,0x0600,0x0c00,0x0000,0x1f00,0x3180,0x3180,0x3180,0x1f00,0x0000,0x0000,0x0600,0x0c00,0x0000,0x3180,
    0x3180,0x3180,0x3180,0x1f80,0x0000,0x0000,0x1d80,0x3700,0x0000,0x3f00,0x3180,0x3180,0x3180,0x3180,0x0000,0x0000,0x1d80,0x3700,0x0000,
    0x3980,0x3d80,0x3780,0x3380,0x3180,0x0000,0x0000,0x0000,0x1e00,0x0300,0x1f00,0x3300,0x1f00,0x0000,0x0000,0x0000,0x0000,0x0000,0x1e00,
    0x3300,0x3300,0x3300,0x1e00,0x0000,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0000,0x0c00,0x1800,0x3000,0x3000,0x3300,0x1e00,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x3f80,0x3000,0x3000,0x3000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x3f80,0x0180,0x0180,0x0180,0x0000,0x0000,
    0x0000,0x2080,0x2100,0x2200,0x2400,0x0b00,0x1180,0x2300,0x4380,0x0000,0x0000,0x2080,0x2100,0x2200,0x2400,0x0a80,0x1280,0x2380,0x4080,
    0x0000,0x0000,0x0c00,0x0000,0x0c00,0x0c00,0x1e00,0x1e00,0x0c00,0x0000,0x0000,0x0000,0x0000,0x1980,0x3300,0x6600,0x3300,0x1980,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x6600,0x3300,0x1980,0x3300,0x6600,0x0000,0x0000,0x0000,0x2200,0x8880,0x2200,0x8880,0x2200,0x8880,0x2200,
    0x8880,0x2200,0x8880,0x5540,0xaa80,0x5540,0xaa80,0x5540,0xaa80,0x5540,0xaa80,0x5540,0xaa80,0xbb80,0xeec0,0xbb80,0xeec0,0xbb80,0xeec0,
    0xbb80,0xeec0,0xbb80,0xeec0,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0xfc00,
    0xfc00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0xfc00,0xfc00,0x0c00,0x0c00,0xfc00,0xfc00,0x0c00,0x0c00,0x3300,0x3300,0x3300,0x3300,
    0xf300,0xf300,0x3300,0x3300,0x3300,0x3300,0x0000,0x0000,0x0000,0x0000,0xff00,0xff00,0x3300,0x3300,0x3300,0x3300,0x0000,0x0000,0xfc00,
    0xfc00,0x0c00,0x0c00,0xfc00,0xfc00,0x0c00,0x0c00,0x3300,0x3300,0xf300,0xf300,0x0300,0x0300,0xf300,0xf300,0x3300,0x3300,0x3300,0x3300,
    0x3300,0x3300,0x3300,0x3300,0x3300,0x3300,0x3300,0x3300,0x0000,0x0000,0xff00,0xff00,0x0300,0x0300,0xf300,0xf300,0x3300,0x3300,0x3300,
    0x3300,0xf300,0xf300,0x0300,0x0300,0xff00,0xff00,0x0000,0x0000,0x3300,0x3300,0x3300,0x3300,0xff00,0xff00,0x0000,0x0000,0x0000,0x0000,
    0x1800,0x1800,0xf800,0xf800,0x1800,0x1800,0xf800,0xf800,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0xfc00,0xfc00,0x0c00,0x0c00,0x0c00,
    0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0fc0,0x0fc0,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,0x0c00,0x0c00,0xffc0,0xffc0,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0xffc0,0xffc0,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0fc0,0x0fc0,0x0c00,
    0x0c00,0x0c00,0x0c00,0x0000,0x0000,0x0000,0x0000,0xffc0,0xffc0,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,0x0c00,0x0c00,0xffc0,0xffc0,
    0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0fc0,0x0fc0,0x0c00,0x0c00,0x0fc0,0x0fc0,0x0c00,0x0c00,0x3300,0x3300,0x3300,0x3300,0x33c0,
    0x33c0,0x3300,0x3300,0x3300,0x3300,0x3300,0x3300,0x33c0,0x33c0,0x3000,0x3000,0x3fc0,0x3fc0,0x0000,0x0000,0x0000,0x0000,0x3fc0,0x3fc0,
    0x3000,0x3000,0x33c0,0x33c0,0x3300,0x3300,0x3300,0x3300,0xf3c0,0xf3c0,0x0000,0x0000,0xffc0,0xffc0,0x0000,0x0000,0x0000,0x0000,0xffc0,
    0xffc0,0x0000,0x0000,0xf3c0,0xf3c0,0x3300,0x3300,0x3300,0x3300,0x33c0,0x33c0,0x3000,0x3000,0x33c0,0x33c0,0x3300,0x3300,0x0000,0x0000,
    0xffc0,0xffc0,0x0000,0x0000,0xffc0,0xffc0,0x0000,0x0000,0x3300,0x3300,0xf3c0,0xf3c0,0x0000,0x0000,0xf3c0,0xf3c0,0x3300,0x3300,0x0c00,
    0x0c00,0xffc0,0xffc0,0x0000,0x0000,0xffc0,0xffc0,0x0000,0x0000,0x3300,0x3300,0x3300,0x3300,0xffc0,0xffc0,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0xffc0,0xffc0,0x0000,0x0000,0xffc0,0xffc0,0x0c00,0x0c00,0x0000,0x0000,0x0000,0x0000,0xffc0,0xffc0,0x3300,0x3300,0x3300,
    0x3300,0x3300,0x3300,0x3300,0x3300,0x3fc0,0x3fc0,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,0x0fc0,0x0fc0,0x0c00,0x0c00,0x0fc0,0x0fc0,
    0x0000,0x0000,0x0000,0x0000,0x0fc0,0x0fc0,0x0c00,0x0c00,0x0fc0,0x0fc0,0x0c00,0x0c00,0x0000,0x0000,0x0000,0x0000,0x3fc0,0x3fc0,0x3300,
    0x3300,0x3300,0x3300,0x3300,0x3300,0x3300,0x3300,0xf3c0,0xf3c0,0x3300,0x3300,0x3300,0x3300,0x0c00,0x0c00,0xffc0,0xffc0,0x0000,0x0000,
    0xffc0,0xffc0,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0xfc00,0xfc00,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0fc0,
    0x0fc0,0x0c00,0x0c00,0x0c00,0x0c00,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0x0000,0x0000,0x0000,0x0000,
    0x0000,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0xf800,0xf800,0xf800,0xf800,0xf800,0xf800,0xf800,0xf800,0xf800,0xf800,0x07c0,0x07c0,0x07c0,
    0x07c0,0x07c0,0x07c0,0x07c0,0x07c0,0x07c0,0x07c0,0xffc0,0xffc0,0xffc0,0xffc0,0xffc0,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x1d80,0x3700,0x3200,0x3700,0x1d80,0x0000,0x0000,0x0000,0x1e00,0x3300,0x3300,0x3600,0x3300,0x3180,0x3700,0x3000,0x0000,0x0000,
    0x3f80,0x3180,0x3000,0x3000,0x3000,0x3000,0x3000,0x0000,0x0000,0x0000,0x0000,0x7f80,0x3300,0x3300,0x3300,0x3300,0x3300,0x0000,0x0000,
    0x0000,0x3f80,0x1800,0x0c00,0x0600,0x0c00,0x1800,0x3f80,0x0000,0x0000,0x0000,0x0000,0x0000,0x1f80,0x3600,0x3300,0x3300,0x1e00,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x6300,0x6300,0x6700,0x7d80,0x6000,0x6000,0x0000,0x0000,0x0000,0x0000,0x3f00,0x0c00,0x0c00,0x0c00,0x0600,
    0x0000,0x0000,0x0000,0x1e00,0x0c00,0x3f00,0x6d80,0x6d80,0x3f00,0x0c00,0x1e00,0x0000,0x0000,0x1e00,0x3300,0x3300,0x3f00,0x3300,0x3300,
    0x1e00,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3180,0x3180,0x3180,0x1b00,0x3b80,0x0000,0x0000,0x0000,0x1f00,0x0c00,0x0600,0x1f00,0x3180,
    0x3180,0x1f00,0x0000,0x0000,0x0000,0x0000,0x0000,0x3b80,0x66c0,0x64c0,0x6cc0,0x3b80,0x0000,0x0000,0x0000,0x0000,0x0180,0x3f00,0x6780,
    0x6d80,0x7980,0x3f00,0x6000,0x0000,0x0000,0x0000,0x0000,0x1f00,0x3000,0x1e00,0x3000,0x1f00,0x0000,0x0000,0x0000,0x1f00,0x3180,0x3180,
    0x3180,0x3180,0x3180,0x3180,0x0000,0x0000,0x0000,0x0000,0x3f00,0x0000,0x3f00,0x0000,0x3f00,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,
    0x3f00,0x0c00,0x0c00,0x0000,0x3f00,0x0000,0x0000,0x0000,0x0600,0x0c00,0x1800,0x0c00,0x0600,0x0000,0x3f00,0x0000,0x0000,0x0000,0x1800,
    0x0c00,0x0600,0x0c00,0x1800,0x0000,0x3f00,0x0000,0x0000,0x0000,0x0700,0x0d80,0x0d80,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,
    0x0c00,0x0c00,0x0c00,0x0c00,0x0c00,0x6c00,0x6c00,0x3800,0x0000,0x0000,0x0000,0x0c00,0x0000,0x3f00,0x0000,0x0c00,0x0000,0x0000,0x0000,
    0x0000,0x3800,0x6d80,0x0700,0x0000,0x3800,0x6d80,0x0700,0x0000,0x0000,0x0000,0x0e00,0x1b00,0x1b00,0x0e00,0x0000,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x0c00,0x0c00,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0c00,0x0000,0x0000,0x0000,
    0x0000,0x0000,0x0000,0x07c0,0x0600,0x0600,0x6600,0x3600,0x1e00,0x0e00,0x0600,0x0200,0x0000,0x3e00,0x3300,0x3300,0x3300,0x3300,0x0000,
    0x0000,0x0000,0x0000,0x0000,0x1e00,0x0300,0x0e00,0x1800,0x1f00,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x1e00,0x1e00,0x1e00,
    0x1e00,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,
  ];
}


// ////////////////////////////////////////////////////////////////////////// //
final class SdpyDrawSdpyImage : SdpyDrawBase {
private:
  Image vbuf;

protected:
  // must be overriden
  override Color getpix (int x, int y) {
    static if (UsingSimpledisplayX11) {
      pragma(inline, true);
      const(uint)* dp = (cast(const(uint)*)vbuf.getDataPointer)+y*vbuf.width+x;
      return XlibImageTC.img2c(*dp);
    } else {
      return vbuf.getPixel(x, y);
    }
  }

  override void putpix (int x, int y, Color col) {
    static if (UsingSimpledisplayX11) {
      uint* dp = (cast(uint*)vbuf.getDataPointer)+y*vbuf.width+x;
      if (col.a == 255) *dp = XlibImageTC.c2img(col)|0xff_000000; else *dp = blendU32(*dp, XlibImageTC.c2img(col)|(col.a<<24));
    } else {
      vbuf.setPixel(x, y, col);
    }
  }

  // optionals
  override void hline (int x, int y, int len, Color col) {
    static if (UsingSimpledisplayX11) {
      uint* dp = (cast(uint*)vbuf.getDataPointer)+y*vbuf.width+x;
      uint uc = XlibImageTC.c2img(col);
      if (col.a == 255) {
        uc |= 0xff_000000;
        foreach (immutable _; 0..len) *dp++ = uc;
      } else {
        uc |= col.a<<24;
        foreach (immutable _; 0..len) { *dp = blendU32(*dp, uc); ++dp; }
      }
    } else {
      while (len-- > 0) vbuf.setPixel(x++, y, col);
    }
  }

public:
  this (Image img) {
    vbuf = img;
    super(img.width, img.height);
  }

  override TrueColorImage getBuffer () {
    auto img = new TrueColorImage(vbuf.width, vbuf.height);
    static if (UsingSimpledisplayX11) {
      const(uint)* sp = cast(const(uint)*)vbuf.getDataPointer;
      auto dp = img.imageData.colors.ptr;
      foreach (immutable y; 0..vbuf.height) {
        foreach (immutable x; 0..vbuf.width) {
          *dp++ = XlibImageTC.img2c(*sp++);
        }
      }
    } else {
      foreach (immutable y; 0..vbuf.height) {
        foreach (immutable x; 0..vbuf.width) {
          img.setPixel(x, y, vbuf.getPixel(x, y));
        }
      }
    }
    return img;
  }

  final @property Image imagebuf () pure nothrow @safe @nogc { pragma(inline, true); return vbuf; }
}


// ////////////////////////////////////////////////////////////////////////// //
/+
version(linux) final class SdpyDrawVBuf : SdpyDrawBase {
private:
  XImageTC vbuf;

protected:
  // must be overriden
  override Color getpix (int x, int y) {
    pragma(inline, true);
    return XlibImageTC.img2c(vbuf.data[y*vbuf.width+x]);
  }

  override void putpix (int x, int y, Color col) {
    uint* dp = vbuf.data+y*vbuf.width+x;
    if (col.a == 255) *dp = XlibImageTC.c2img(col)|0xff_000000; else *dp = blendU32(*dp, XlibImageTC.c2img(col)|(col.a<<24));
  }

  // optionals
  override void hline (int x, int y, int len, Color col) {
    uint* dp = vbuf.data+y*vbuf.width+x;
    uint uc = XlibImageTC.c2img(col);
    if (col.a == 255) {
      uc |= 0xff_000000;
      foreach (immutable _; 0..len) *dp++ = uc;
    } else {
      uc |= col.a<<24;
      foreach (immutable _; 0..len) { *dp = blendU32(*dp, uc); ++dp; }
    }
  }

public:
  this (XImageTC img) {
    vbuf = img;
    super(img.width, img.height);
  }

  override TrueColorImage getBuffer () {
    auto img = new TrueColorImage(vbuf.width, vbuf.height);
    const(uint)* sp = cast(const(uint)*)vbuf.data;
    auto dp = img.imageData.colors.ptr;
    foreach (immutable y; 0..vbuf.height) {
      foreach (immutable x; 0..vbuf.width) {
        *dp++ = XlibImageTC.img2c(*sp++);
      }
    }
    return img;
  }

  final @property XImageTC imagebuf () pure nothrow @safe @nogc { pragma(inline, true); return vbuf; }

  final void cls (Color clr) {
    import core.stdc.string : memset;
    if (!vbuf.valid) return;
    if (clr.r == 0 && clr.g == 0 && clr.b == 0) {
      memset(vbuf.data, 0, vbuf.width*vbuf.height*uint.sizeof);
    } else {
      drawRect!true(0, 0, vbuf.width, vbuf.height);
    }
  }

  void blitFrom (DFImage src, int x0, int y0, int subalpha=-1, int cx0=0, int cy0=0, int cx1=int.max, int cy1=int.max) {
    if (src is null || !src.valid || !vbuf.valid) return;
    if (cx1 >= vbuf.width) cx1 = vbuf.width-1;
    if (cy1 >= vbuf.height) cy1 = vbuf.height-1;
    if (cx0 < 0) cx0 = 0;
    if (cy0 < 0) cy0 = 0;
    if (cx1 < cx0 || cy1 < cy0 || cx1 < 0 || cy1 < 0 || cx0 >= vbuf.width || cy0 >= vbuf.height) return; // nothing to do here

    void doBlit(bool doSrcAlpha, bool doSubAlpha) (int x, int y, int xofs, int yofs, int wdt, int hgt, int subalpha=0) {
      auto sc = cast(const(uint)*)src.data.ptr;
      auto dc = vbuf.data;
      sc += yofs*src.width+xofs;
      dc += y*vbuf.width+x;
      foreach (immutable dy; 0..hgt) {
        static if (!doSubAlpha && !doSrcAlpha) {
          // fastest path
          import core.stdc.string : memcpy;
          memcpy(dc, sc, wdt*uint.sizeof);
        } else {
          auto scl = sc;
          auto dcl = dc;
          foreach (immutable dx; 0..wdt) {
            static if (doSubAlpha) {
              static assert(!doSrcAlpha);
              *dcl = XlibImageTC.icRGB(
                XlibImageTC.icR(*dcl)+XlibImageTC.icR(*scl)*(255-subalpha)/255,
                XlibImageTC.icG(*dcl)+XlibImageTC.icG(*scl)*(255-subalpha)/255,
                XlibImageTC.icB(*dcl)+XlibImageTC.icB(*scl)*(255-subalpha)/255,
              );
            } else {
              static assert(doSrcAlpha);
              if (XlibImageTC.icA(*scl) == 255) {
                *dcl = *scl;
              } else if (XlibImageTC.icA(*scl)) {
                *dcl = (*dcl).blendU32(*scl);
              }
            }
            ++scl;
            ++dcl;
          }
        }
        sc += src.width;
        dc += vbuf.width;
      }
    }

    int swdt = src.width, shgt = src.height, xofs = 0, yofs = 0, x = x0, y = y0;
    if (!GxRect(cx0, cy0, cx1-cx0+1, cy1-cy0+1).clipHVStripes(x, y, swdt, shgt, &xofs, &yofs)) return; // nothing to do here
    if (!src.hasAlpha && subalpha < 0) {
      doBlit!(false, false)(x, y, xofs, yofs, swdt, shgt);
    } else if (subalpha >= 0) {
      doBlit!(false, true)(x, y, xofs, yofs, swdt, shgt, subalpha);
    } else if (src.hasAlpha) {
      doBlit!(true, false)(x, y, xofs, yofs, swdt, shgt);
    } else {
      assert(0, "wtf?!");
    }
  }

  void blendRect (int x0, int y0, int w, int h, Color clr) {
    if (clr.a == 0 || !vbuf.valid) return;
    if (!GxRect(0, 0, vbuf.width, vbuf.height).clipHVStripes(x0, y0, w, h)) return; // nothing to do here
    auto dc = vbuf.data;
    dc += y0*vbuf.width+x0;
    if (clr.a == 255) {
      uint c = XlibImageTC.c2img(clr);
      foreach (immutable dy; 0..h) {
        auto dcl = dc;
        foreach (immutable dx; 0..w) *dcl++ = c;
        dc += vbuf.width;
      }
    } else {
      uint c = XlibImageTC.icRGBA(clr.r, clr.g, clr.b, clr.a);
      foreach (immutable dy; 0..h) {
        auto dcl = dc;
        foreach (immutable dx; 0..w) {
          *dcl = (*dcl).blendU32(c);
          ++dcl;
        }
        dc += vbuf.width;
      }
    }
  }
}
+/
