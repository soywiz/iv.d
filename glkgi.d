/* coded by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
 * Understanding is not required. Only obedience.
 * Based on Jet-Set Willy, v1.0.1 by <Florent.Guillaume@ens.fr>
 * Linux port and preliminary sound by jmd@dcs.ed.ac.uk
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
/// DO NOT USE YET!
module iv.glkgi;

import core.atomic;
import std.concurrency;

public import arsd.simpledisplay;
//public import arsd.color;
//public import arsd.image;

import iv.bclamp;
public import iv.glcmdcon;
import iv.glbinds;

//version=glkgi_rgba; // default, has priority
//version=glkgi_bgra;

version(BigEndian) static assert(0, "sorry, big-endian platforms aren't supported yet");

version(glkgi_rgba) {
  public enum KGIRGBA = true;
} else version(glkgi_bgra) {
  public enum KGIRGBA = false;
} else {
  public enum KGIRGBA = true;
}

// ////////////////////////////////////////////////////////////////////////// //
// 0:b; 1:g; 2:r; 3: nothing
private __gshared int vbufW = 0, vbufH = 0;
__gshared uint* vbuf; // see KGIRGBA
private __gshared bool blit2x = false;
private enum BlitType { Normal, BlackWhite, Green, Red }
private __gshared int blitType = BlitType.Normal;
private __gshared int blitShine = 0; // adds this to non-black colors
private __gshared SimpleWindow vbwin;
private __gshared uint vbTexId = 0;
private __gshared string kgiTitle;
private __gshared uint vupcounter = 0;
private shared bool updateTexture = true;

private shared bool vWantMotionEvents = false;
private shared bool vWantCharEvents = false;


public @property bool kgiMotionEvents () nothrow @trusted @nogc { pragma(inline, true); return atomicLoad(vWantMotionEvents); } ///
public @property bool kgiCharEvents () nothrow @trusted @nogc { pragma(inline, true); return atomicLoad(vWantCharEvents); } ///

public @property void kgiMotionEvents (bool v) nothrow @trusted @nogc { pragma(inline, true); atomicStore(vWantMotionEvents, v); } ///
public @property void kgiCharEvents (bool v) nothrow @trusted @nogc { pragma(inline, true); atomicStore(vWantCharEvents, v); } ///

public @property int kgiWidth () nothrow @trusted @nogc { pragma(inline, true); return vbufW; }
public @property int kgiHeight () nothrow @trusted @nogc { pragma(inline, true); return vbufH; }


//FIXME! turn this to proper setter
public __gshared bool delegate () onKGICloseRequest;


///
public struct KGIEvent {
  enum Type { None, Key, Mouse, Char, Close }
  Type type = Type.None;
  union {
    KeyEvent k;
    MouseEvent m;
    dchar ch;
  }
@property const pure nothrow @trusted @nogc:
  bool isMouse () { pragma(inline, true); return (type == Type.Mouse); }
  bool isKey () { pragma(inline, true); return (type == Type.Key); }
  bool isChar () { pragma(inline, true); return (type == Type.Char); }
  bool isNone () { pragma(inline, true); return (type == Type.None); }
  bool isClose () { pragma(inline, true); return (type == Type.Close); }
}


private __gshared KGIEvent[] evbuf;
private __gshared uint evbufused;


///
public bool kgiHasEvent () {
  consoleLock();
  scope(exit) consoleUnlock();
  atomicFence();
  if (vupcounter) atomicStore(updateTexture, true); // just in case
  return (evbufused > 0 || vbwin is null); // no vbwin --> always has Quit
}


///
public KGIEvent kgiPeekEvent () {
  consoleLock();
  scope(exit) consoleUnlock();
  atomicFence();
  if (vupcounter) atomicStore(updateTexture, true); // just in case
  if (evbufused > 0) return evbuf[0];
  if (vbwin is null) return KGIEvent(KGIEvent.Type.Close);
  return KGIEvent();
}


///
public KGIEvent kgiGetEvent () {
  import core.thread;
  import core.time;
  atomicFence();
  if (vupcounter) atomicStore(updateTexture, true); // just in case
  for (;;) {
    {
      consoleLock();
      scope(exit) consoleUnlock();
      if (evbufused > 0) {
        auto ev = evbuf[0];
        if (evbufused > 1) {
          import core.stdc.string : memmove;
          memmove(evbuf.ptr, evbuf.ptr+1, KGIEvent.sizeof*(evbufused-1));
        }
        --evbufused;
        evbuf[evbufused].type = KGIEvent.Type.None;
        return ev;
      } else if (vbwin is null) {
        return KGIEvent(KGIEvent.Type.Close);
      }
    }
    Thread.sleep(10.msecs);
  }
}


private void pushEventIntr (ref KGIEvent ev) {
  if (evbufused >= evbuf.length) evbuf.length += 256;
  evbuf[evbufused++] = ev;
}


///
public void kgiPushEvent (KeyEvent e) {
  KGIEvent ev = void;
  ev.type = KGIEvent.Type.Key;
  ev.k = e;
  consoleLock();
  scope(exit) consoleUnlock();
  pushEventIntr(ev);
}

///
public void kgiPushEvent (MouseEvent e) {
  KGIEvent ev = void;
  ev.type = KGIEvent.Type.Mouse;
  ev.m = e;
  consoleLock();
  scope(exit) consoleUnlock();
  pushEventIntr(ev);
}

///
public void kgiPushEvent (dchar ch) {
  KGIEvent ev = void;
  ev.type = KGIEvent.Type.Char;
  ev.ch = ch;
  consoleLock();
  scope(exit) consoleUnlock();
  pushEventIntr(ev);
}


/// remove all keypresses from input queue
void kgiKeyFlush () {
  uint sidx = 0, didx = 0;
  consoleLock();
  scope(exit) consoleUnlock();
  while (sidx < evbufused) {
    if (!evbuf[sidx].isKey) {
      if (sidx != didx) evbuf[didx] = evbuf[sidx];
      ++didx;
    }
    ++sidx;
  }
  evbufused = didx;
}


/// wait for keypress (and eat it)
void kgiWaitKey () {
  for (;;) {
    auto ev = kgiGetEvent();
    if (ev.isClose) {
      consoleLock();
      scope(exit) consoleUnlock();
      evbufused = 1;
      evbuf[0] = ev;
      return;
    }
    if (!ev.isKey) continue;
    if (!ev.k.pressed) continue;
    break;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
public void kgiDeinit () {
  concmd("quit");
}


private void kgiThread (Tid starterTid) {
  try {
    vbwin = new SimpleWindow(vbufW*(blit2x ? 2 : 1), vbufH*(blit2x ? 2 : 1), kgiTitle, OpenGlOptions.yes, Resizablity.fixedSize);
    //vbwin.hideCursor();

    vbwin.redrawOpenGlScene = delegate () {
      glgfxBlit();
      oglDrawConsole();
    };

    vbwin.closeQuery = delegate () {
      if (onKGICloseRequest !is null) try { if (!onKGICloseRequest()) return; } catch (Throwable e) {}
      concmd("quit");
    };

    vbwin.visibleForTheFirstTime = delegate () {
      vbwin.setAsCurrentOpenGlContext();
      /+
      {
        import core.stdc.stdio;
        printf("GL version: %s\n", glGetString(GL_VERSION));
        GLint l, h;
        glGetIntegerv(GL_MAJOR_VERSION, &h);
        glGetIntegerv(GL_MINOR_VERSION, &l);
        printf("version: %d.%d\n", h, l);
        printf("shader version: %s\n", glGetString(GL_SHADING_LANGUAGE_VERSION));
        GLint svcount;
        glGetIntegerv(GL_NUM_SHADING_LANGUAGE_VERSIONS, &svcount);
        if (svcount > 0) {
          printf("%d shader versions supported:\n", svcount);
          foreach (GLuint n; 0..svcount) printf("  %d: %s\n", n, glGetStringi(GL_SHADING_LANGUAGE_VERSION, n));
        }
        /*
        GLint ecount;
        glGetIntegerv(GL_NUM_EXTENSIONS, &ecount);
        if (ecount > 0) {
          printf("%d extensions supported:\n", ecount);
          foreach (GLuint n; 0..ecount) printf("  %d: %s\n", n, glGetStringi(GL_EXTENSIONS, n));
        }
        */
      }
      +/
      // check if we have sufficient shader version here
      /+
      {
        bool found = false;
        GLint svcount;
        glGetIntegerv(GL_NUM_SHADING_LANGUAGE_VERSIONS, &svcount);
        if (svcount > 0) {
          foreach (GLuint n; 0..svcount) {
            import core.stdc.string : strncmp;
            auto v = glGetStringi(GL_SHADING_LANGUAGE_VERSION, n);
            if (v is null) continue;
            if (strncmp(v, "130", 3) != 0) continue;
            if (v[3] > ' ') continue;
            found = true;
            break;
          }
        }
        if (!found) assert(0, "can't find OpenGL GLSL 120");
        {
          auto adr = glGetProcAddress("glTexParameterf");
          if (adr is null) assert(0);
        }
      }
      +/
      glgfxInitTexture();
      oglInitConsole(vbufW, vbufH, (blit2x ? 2 : 1));
      glgfxUpdateTexture();
      vbwin.redrawOpenGlSceneNow();

      send(starterTid, 42);
    };

    bool receiveMessages () {
      bool res = false;
      for (;;) {
        import core.time : Duration;
        auto got = receiveTimeout(
          Duration.zero, // don't wait
          (OwnerTerminated e) {
            //conwriteln("OWNER IS TERMINATED!");
            res = true;
          },
          (Variant v) {
            conwriteln("WARNING: unknown thread message received and ignored: ", v.toString);
          },
        );
        if (!got) break; // no more messages
      }
      return res;
    }

    void processConsoleCommands () {
      consoleLock();
      scope(exit) consoleUnlock();
      conProcessQueue();
    }

    vbwin.eventLoop(1000/60,
      delegate () {
        if (vbwin.closed) return;
        if (isQuitRequested) { vbwin.close(); return; }
        if (receiveMessages()) { vbwin.close(); return; }
        bool oldconvis = isConsoleVisible;
        processConsoleCommands();
        if (atomicLoad(updateTexture) || isConsoleVisible || oldconvis) {
          glgfxUpdateTexture();
          vbwin.redrawOpenGlSceneNow();
        }
      },
      delegate (KeyEvent event) {
        if (vbwin.closed) return;
        if (isQuitRequested) { vbwin.close(); return; }
        if (conKeyEvent(event)) return;
        //if (event.pressed && event.key == Key.Escape) { concmd("quit"); return; }
        kgiPushEvent(event);
      },
      delegate (MouseEvent event) {
        if (vbwin.closed) return;
        if (event.type == MouseEventType.motion && !kgiMotionEvents) return;
        if (blit2x) { event.x /= 2; event.y /= 2; }
        kgiPushEvent(event);
      },
      delegate (dchar ch) {
        if (vbwin.closed) return;
        if (conCharEvent(ch)) return;
        if (ch == '`') concmd("r_console tan");
        if (!kgiCharEvents) return;
        kgiPushEvent(ch);
      },
    );
  } catch (Throwable e) {
    // here, we are dead and fucked (the exact order doesn't matter)
    import core.stdc.stdlib : abort;
    import core.stdc.stdio : fprintf, stderr;
    import core.memory : GC;
    import core.thread;
    GC.disable(); // yeah
    thread_suspendAll(); // stop right here, you criminal scum!
    auto s = e.toString();
    fprintf(stderr, "\n=== FATAL ===\n%.*s\n", cast(uint)s.length, s.ptr);
    abort(); // die, you bitch!
  }
  flushGui();
  vbwin = null;
  /*
  {
    import core.stdc.stdlib : exit;
    exit(0);
  }
  */
  {
    consoleLock();
    scope(exit) consoleUnlock();
    KGIEvent ev;
    ev.type = KGIEvent.Type.Close;
    evbufused = 0;
    pushEventIntr(ev);
  }
}


// ////////////////////////////////////////////////////////////////////////// //
private __gshared Tid kgiTid;
private shared bool kgiThreadStarted = false;


private void startKGIThread () {
  //if (!cas(&kgiThreadStarted, false, true)) assert(0, "render thread already started!");
  kgiTid = spawn(&kgiThread, thisTid);
  setMaxMailboxSize(kgiTid, 1024, OnCrowding.throwException); //FIXME
  // wait for "i'm ready" signal
  receive(
    (int ok) {
      if (ok != 42) assert(0, "wtf?!");
    },
  );
  //conwriteln("rendering thread started");
}


public bool kgiInit (int awdt, int ahgt, string title="KGI Graphics", bool a2x=false) {
  import core.stdc.stdlib : malloc;
  import arsd.simpledisplay;

  if (awdt < 1 || ahgt < 1 || awdt > 4096 || ahgt > 4096) {
    return false;
    //assert(0, "invalid dimensions");
  }

  if (!cas(&kgiThreadStarted, false, true)) return false;

  if (vbwin !is null) assert(0, "double initialization");

  vbuf = cast(typeof(vbuf))malloc(vbuf[0].sizeof*awdt*ahgt);
  if (vbuf is null) assert(0, "KGI: out of memory");
  vbuf[0..awdt*ahgt] = 0;

  vbufW = awdt;
  vbufH = ahgt;
  blit2x = a2x;

  setOpenGLContextVersion(3, 2); // up to GLSL 150
  //openGLContextCompatible = false;

  kgiTitle = title;

  startKGIThread();

  return true;
}


private void glgfxInitTexture () {
  import iv.glbinds;

  if (vbTexId) { glDeleteTextures(1, &vbTexId); vbTexId = 0; }

  enum wrapOpt = GL_REPEAT;
  enum filterOpt = GL_NEAREST; //GL_LINEAR;
  enum ttype = GL_UNSIGNED_BYTE;

  glGenTextures(1, &vbTexId);
  if (vbTexId == 0) assert(0, "can't create cmdcon texture");

  GLint gltextbinding;
  glGetIntegerv(GL_TEXTURE_BINDING_2D, &gltextbinding);
  scope(exit) glBindTexture(GL_TEXTURE_2D, gltextbinding);

  glBindTexture(GL_TEXTURE_2D, vbTexId);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapOpt);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapOpt);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filterOpt);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filterOpt);
  //glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  //glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

  GLfloat[4] bclr = 0.0;
  glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, bclr.ptr);

  static if (KGIRGBA) enum TexType = GL_RGBA; else enum TexType = GL_BGRA;
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, vbufW, vbufH, 0, TexType, GL_UNSIGNED_BYTE, vbuf);
}


private void glgfxUpdateTexture () nothrow @trusted @nogc {
  import iv.glbinds;

  consoleLock();
  scope(exit) consoleUnlock();

  atomicFence();
  vupcounter = 0;

  static if (KGIRGBA) enum TexType = GL_RGBA; else enum TexType = GL_BGRA;
  glTextureSubImage2D(vbTexId, 0, 0/*x*/, 0/*y*/, vbufW, vbufH, TexType, GL_UNSIGNED_BYTE, vbuf);

  atomicStore(updateTexture, false);
}


private void glgfxBlit () nothrow @trusted @nogc {
  import iv.glbinds;

  consoleLock();
  scope(exit) consoleUnlock();

  //if (vbwin is null || vbwin.closed || vbTexId == 0) return;

  /+
  GLint glmatmode;
  GLint gltextbinding;
  GLint oldprg;
  GLint oldfbr, oldfbw;
  GLint[4] glviewport;
  glGetIntegerv(GL_MATRIX_MODE, &glmatmode);
  glGetIntegerv(GL_TEXTURE_BINDING_2D, &gltextbinding);
  glGetIntegerv(GL_VIEWPORT, glviewport.ptr);
  glGetIntegerv(GL_CURRENT_PROGRAM, &oldprg);
  glGetIntegerv(GL_READ_FRAMEBUFFER_BINDING, &oldfbr);
  glGetIntegerv(GL_DRAW_FRAMEBUFFER_BINDING, &oldfbw);
  glMatrixMode(GL_PROJECTION); glPushMatrix();
  glMatrixMode(GL_MODELVIEW); glPushMatrix();
  glMatrixMode(GL_TEXTURE); glPushMatrix();
  glMatrixMode(GL_COLOR); glPushMatrix();
  glPushAttrib(/*GL_ENABLE_BIT|GL_COLOR_BUFFER_BIT|GL_CURRENT_BIT*/GL_ALL_ATTRIB_BITS); // let's play safe
  // restore on exit
  scope(exit) {
    glPopAttrib(/*GL_ENABLE_BIT*/);
    glMatrixMode(GL_PROJECTION); glPopMatrix();
    glMatrixMode(GL_MODELVIEW); glPopMatrix();
    glMatrixMode(GL_TEXTURE); glPopMatrix();
    glMatrixMode(GL_COLOR); glPopMatrix();
    glMatrixMode(glmatmode);
    glBindFramebufferEXT(GL_READ_FRAMEBUFFER_EXT, oldfbr);
    glBindFramebufferEXT(GL_DRAW_FRAMEBUFFER_EXT, oldfbw);
    glBindTexture(GL_TEXTURE_2D, gltextbinding);
    glUseProgram(oldprg);
    glViewport(glviewport.ptr[0], glviewport.ptr[1], glviewport.ptr[2], glviewport.ptr[3]);
  }
  +/

  enum x = 0;
  enum y = 0;
  immutable w = vbufW;
  immutable h = vbufH;

  glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
  glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
  glUseProgram(0);

  glMatrixMode(GL_PROJECTION); // for ortho camera
  glLoadIdentity();
  // left, right, bottom, top, near, far
  glViewport(0, 0, w*(blit2x ? 2 : 1), h*(blit2x ? 2 : 1));
  glOrtho(0, w, h, 0, -1, 1); // top-to-bottom
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glEnable(GL_TEXTURE_2D);
  glDisable(GL_LIGHTING);
  glDisable(GL_DITHER);
  //glDisable(GL_BLEND);
  glDisable(GL_DEPTH_TEST);
  //glEnable(GL_BLEND);
  //glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  //glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glDisable(GL_BLEND);
  glDisable(GL_STENCIL_TEST);

  glColor4f(1, 1, 1, 1);
  glBindTexture(GL_TEXTURE_2D, vbTexId);
  //scope(exit) glBindTexture(GL_TEXTURE_2D, 0);
  glBegin(GL_QUADS);
    glTexCoord2f(0.0f, 0.0f); glVertex2i(x, y); // top-left
    glTexCoord2f(1.0f, 0.0f); glVertex2i(w, y); // top-right
    glTexCoord2f(1.0f, 1.0f); glVertex2i(w, h); // bottom-right
    glTexCoord2f(0.0f, 1.0f); glVertex2i(x, h); // bottom-left
  glEnd();
}


// ////////////////////////////////////////////////////////////////////////// //
alias VColor = uint;

/// vlRGBA struct to ease color components extraction/replacing
align(1) struct vlRGBA {
align(1):
  static if (KGIRGBA) {
    ubyte b, g, r, a;
  } else {
    ubyte r, g, b, a;
  }
}
static assert(vlRGBA.sizeof == VColor.sizeof);


static if (KGIRGBA) {
  enum : VColor {
    vlAShift = 24,
    vlRShift = 0,
    vlGShift = 8,
    vlBShift = 16,
  }
} else {
  enum : VColor {
    vlAShift = 24,
    vlRShift = 16,
    vlGShift = 8,
    vlBShift = 0,
  }
}
static assert(vlAShift == 24, "invalid A position in color"); // alas


enum : VColor {
  vlAMask = 0xffu<<vlAShift,
  vlRMask = 0xffu<<vlRShift,
  vlGMask = 0xffu<<vlGShift,
  vlBMask = 0xffu<<vlBShift,
  vlColorMask = vlRMask|vlGMask|vlBMask,
}


enum VColor Transparent = vlAMask; /// completely transparent pixel color


bool isTransparent(T : VColor) (T col) pure nothrow @safe @nogc {
  pragma(inline, true);
  return ((col&vlAMask) == vlAMask);
}

bool isOpaque(T : VColor) (T col) pure nothrow @safe @nogc {
  pragma(inline, true);
  return ((col&vlAMask) == 0);
}

// a=0: opaque
VColor rgbcol(TR, TG, TB, TA=ubyte) (TR r, TG g, TB b, TA a=0) pure nothrow @safe @nogc
if (__traits(isIntegral, TR) && __traits(isIntegral, TG) && __traits(isIntegral, TB) && __traits(isIntegral, TA)) {
  pragma(inline, true);
  return
    (clampToByte(a)<<vlAShift)|
    (clampToByte(r)<<vlRShift)|
    (clampToByte(g)<<vlGShift)|
    (clampToByte(b)<<vlBShift);
}

alias rgbacol = rgbcol;


// generate some templates (rgbRed, rgbSetRed, etc.)
private enum genRGBGetSet(string cname) =
  "ubyte rgb"~cname~"() (VColor clr) pure nothrow @safe @nogc {\n"~
  "  pragma(inline, true);\n"~
  "  return ((clr>>vl"~cname[0]~"Shift)&0xff);\n"~
  "}\n"~
  "VColor rgbSet"~cname~"(T) (VColor clr, T v) pure nothrow @safe @nogc if (__traits(isIntegral, T)) {\n"~
  "  pragma(inline, true);\n"~
  "  return (clr&~vl"~cname[0]~"Mask)|(clampToByte(v)<<vl"~cname[0]~"Shift);\n"~
  "}\n";

mixin(genRGBGetSet!"Alpha");
mixin(genRGBGetSet!"Red");
mixin(genRGBGetSet!"Green");
mixin(genRGBGetSet!"Blue");


// ////////////////////////////////////////////////////////////////////////// //
nothrow @trusted @nogc:

private void putPixelIntrNoCheck (in int xx, in int yy, in VColor col) {
  pragma(inline, true);
  uint* da = vbuf+yy*vbufW+xx;
  if (col&vlAMask) {
    immutable uint a = 256-(col>>24); // to not loose bits
    immutable uint dc = (*da)&0xffffff;
    immutable uint srb = (col&0xff00ff);
    immutable uint sg = (col&0x00ff00);
    immutable uint drb = (dc&0xff00ff);
    immutable uint dg = (dc&0x00ff00);
    immutable uint orb = (drb+(((srb-drb)*a+0x800080)>>8))&0xff00ff;
    immutable uint og = (dg+(((sg-dg)*a+0x008000)>>8))&0x00ff00;
    *da = orb|og;
  } else {
    *da = col;
  }
}

private void putPixelIntr (int xx, int yy, VColor col) {
  pragma(inline, true);
  if ((col&vlAMask) != vlAMask && xx >= 0 && yy >= 0 && xx < vbufW && yy < vbufH) {
    uint* da = vbuf+yy*vbufW+xx;
    if (col&vlAMask) {
      immutable uint a = 256-(col>>24); // to not loose bits
      immutable uint dc = (*da)&0xffffff;
      immutable uint srb = (col&0xff00ff);
      immutable uint sg = (col&0x00ff00);
      immutable uint drb = (dc&0xff00ff);
      immutable uint dg = (dc&0x00ff00);
      immutable uint orb = (drb+(((srb-drb)*a+0x800080)>>8))&0xff00ff;
      immutable uint og = (dg+(((sg-dg)*a+0x008000)>>8))&0x00ff00;
      *da = orb|og;
    } else {
      *da = col;
    }
  }
}

void putPixel (int xx, int yy, VColor col) {
  pragma(inline, true);
  if ((col&vlAMask) != vlAMask && xx >= 0 && yy >= 0 && xx < vbufW && yy < vbufH) {
    uint* da = vbuf+yy*vbufW+xx;
    if (col&vlAMask) {
      immutable uint a = 256-(col>>24); // to not loose bits
      immutable uint dc = (*da)&0xffffff;
      immutable uint srb = (col&0xff00ff);
      immutable uint sg = (col&0x00ff00);
      immutable uint drb = (dc&0xff00ff);
      immutable uint dg = (dc&0x00ff00);
      immutable uint orb = (drb+(((srb-drb)*a+0x800080)>>8))&0xff00ff;
      immutable uint og = (dg+(((sg-dg)*a+0x008000)>>8))&0x00ff00;
      *da = orb|og;
    } else {
      *da = col;
    }
    atomicFence();
    ++vupcounter;
  }
}

private void setPixelIntr (int xx, int yy, VColor col) {
  pragma(inline, true);
  if (xx >= 0 && yy >= 0 && xx < vbufW && yy < vbufH) {
    uint* da = vbuf+yy*vbufW+xx;
    *da = col;
  }
}

void setPixel (int xx, int yy, VColor col) {
  pragma(inline, true);
  if (xx >= 0 && yy >= 0 && xx < vbufW && yy < vbufH) {
    uint* da = vbuf+yy*vbufW+xx;
    *da = col;
    atomicFence();
    ++vupcounter;
  }
}


VColor getPixel (int xx, int yy) {
  pragma(inline, true);
  return (xx >= 0 && yy >= 0 && xx < vbufW && yy < vbufH ? vbuf[yy*vbufW+xx]&vlColorMask : Transparent);
}


// ////////////////////////////////////////////////////////////////////////// //
void cls (VColor col) {
  vbuf[0..vbufW*vbufH] = col;
  atomicFence();
  ++vupcounter;
}


// ////////////////////////////////////////////////////////////////////////// //
void drawRect (int x, int y, int w, int h, immutable VColor col) {
  if (w < 1 || h < 1) return;
  if (x <= -w || y <= -h || x >= vbufW || y >= vbufH || isTransparent(col)) return;
  if (x < 0) { w += x; x = 0; }
  if (y < 0) { h += y; h = 0; }
  if (x+w >= vbufW) w = vbufW-x;
  if (y+h >= vbufH) h = vbufH-y;
  assert(x >= 0 && y >= 0 && x < vbufW && y < vbufH && w > 0 && h > 0 && x+w <= vbufW && y+h <= vbufH);
  if (isOpaque(col)) {
    uint d = y*vbufW+x;
    vbuf[d..d+w] = col;
    d += vbufW;
    foreach (immutable yy; y+1..y+h-1) {
      vbuf[d] = col;
      vbuf[d+w-1] = col;
      d += vbufW;
    }
    if (h > 1) vbuf[d..d+w] = col;
  } else {
    foreach (immutable yy; y..y+h) {
      putPixelIntr(x, yy, col);
      putPixelIntr(x+w-1, yy, col);
    }
    foreach (immutable xx; x+1..x+w-1) {
      putPixelIntr(xx, y, col);
      if (h > 1) putPixelIntr(xx, y+h-1, col);
    }
  }
  atomicFence();
  ++vupcounter;
}

void fillRect (int x, int y, int w, int h, immutable VColor col) {
  if (w < 1 || h < 1) return;
  if (x <= -w || y <= -h || x >= vbufW || y >= vbufH || isTransparent(col)) return;
  if (x < 0) { w += x; x = 0; }
  if (y < 0) { h += y; h = 0; }
  if (x+w >= vbufW) w = vbufW-x;
  if (y+h >= vbufH) h = vbufH-y;
  assert(x >= 0 && y >= 0 && x < vbufW && y < vbufH && w > 0 && h > 0 && x+w <= vbufW && y+h <= vbufH);
  if (isOpaque(col)) {
    uint d = y*vbufW+x;
    foreach (immutable yy; y..y+h) {
      vbuf[d..d+w] = col;
      d += vbufW;
    }
  } else {
    foreach (immutable yy; y..y+h) {
      foreach (immutable xx; x..x+w) {
        putPixelIntr(xx, yy, col);
      }
    }
  }
  atomicFence();
  ++vupcounter;
}

void hline (int x, int y, int len, immutable VColor col) { drawRect(x, y, len, 1, col); }
void vline (int x, int y, int len, immutable VColor col) { drawRect(x, y, 1, len, col); }


// ////////////////////////////////////////////////////////////////////////// //
void drawLine(bool lastPoint=true) (int x0, int y0, int x1, int y1, immutable VColor col) {
  enum swap(string a, string b) = "{int tmp_="~a~";"~a~"="~b~";"~b~"=tmp_;}";

  if ((col&vlAMask) == vlAMask) return;

  if (x0 == x1 && y0 == y1) {
    static if (lastPoint) putPixel(x0, y0, col);
    return;
  }

  // clip rectange
  int wx0 = 0, wy0 = 0, wx1 = vbufW-1, wy1 = vbufH-1;
  // other vars
  int stx, sty; // "steps" for x and y axes
  int dsx, dsy; // "lengthes" for x and y axes
  int dx2, dy2; // "double lengthes" for x and y axes
  int xd, yd; // current coord
  int e; // "error" (as in bresenham algo)
  int rem;
  int term;
  int *d0, d1;
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
    putPixelIntrNoCheck(*d0, *d1, col);
    // done drawing, move coords
    if (e >= 0) {
      yd += sty;
      e -= dx2;
    } else {
      e += dy2;
    }
    xd += stx;
  }
  atomicFence();
  ++vupcounter;
}


// ////////////////////////////////////////////////////////////////////////// //
private void plot4points() (int cx, int cy, int x, int y, VColor clr) @trusted {
  putPixelIntr(cx+x, cy+y, clr);
  if (x != 0) putPixelIntr(cx-x, cy+y, clr);
  if (y != 0) putPixelIntr(cx+x, cy-y, clr);
  putPixelIntr(cx-x, cy-y, clr);
}


void drawCircle (int cx, int cy, int radius, VColor clr) @trusted {
  if (radius > 0 && !isTransparent(clr)) {
    int error = -radius, x = radius, y = 0;
    if (radius == 1) { putPixelIntr(cx, cy, clr); return; }
    while (x > y) {
      plot4points(cx, cy, x, y, clr);
      plot4points(cx, cy, y, x, clr);
      error += y*2+1;
      ++y;
      if (error >= 0) { --x; error -= x*2; }
    }
    plot4points(cx, cy, x, y, clr);
    atomicFence();
    ++vupcounter;
  }
}

void fillCircle (int cx, int cy, int radius, VColor clr) @trusted {
  if (radius > 0 && !isTransparent(clr)) {
    int error = -radius, x = radius, y = 0;
    if (radius == 1) { putPixelIntr(cx, cy, clr); return; }
    while (x >= y) {
      int last_y = y;
      error += y;
      ++y;
      error += y;
      hline(cx-x, cy+last_y, 2*x+1, clr);
      if (x != 0 && last_y != 0) hline(cx-x, cy-last_y, 2*x+1, clr);
      if (error >= 0) {
        if (x != last_y) {
          hline(cx-last_y, cy+x, 2*last_y+1, clr);
          if (last_y != 0 && x != 0) hline(cx-last_y, cy-x, 2*last_y+1, clr);
        }
        error -= x;
        --x;
        error -= x;
      }
    }
    atomicFence();
    ++vupcounter;
  }
}


void drawEllipse (int x0, int y0, int w, int h, VColor clr) @trusted {
  import std.math : abs;
  if (w == 0 && h == 0) return;
  if (w == 1) { vline(x0, y0, h, clr); return; }
  if (h == 1) { hline(x0, y0, w, clr); return; }
  int x1 = x0+w-1;
  int y1 = y0+h-1;
  int a = abs(x1-x0), b = abs(y1-y0), b1 = b&1; // values of diameter
  long dx = 4*(1-a)*b*b, dy = 4*(b1+1)*a*a; // error increment
  long err = dx+dy+b1*a*a; // error of 1.step
  if (x0 > x1) { x0 = x1; x1 += a; } // if called with swapped points...
  if (y0 > y1) y0 = y1; // ...exchange them
  y0 += (b+1)/2; y1 = y0-b1;  // starting pixel
  a *= 8*a; b1 = 8*b*b;
  do {
    long e2;
    putPixelIntr(x1, y0, clr); //   I. Quadrant
    putPixelIntr(x0, y0, clr); //  II. Quadrant
    putPixelIntr(x0, y1, clr); // III. Quadrant
    putPixelIntr(x1, y1, clr); //  IV. Quadrant
    e2 = 2*err;
    if (e2 >= dx) { ++x0; --x1; err += dx += b1; } // x step
    if (e2 <= dy) { ++y0; --y1; err += dy += a; }  // y step
  } while (x0 <= x1);
  while (y0-y1 < b) {
    // too early stop of flat ellipses a=1
    putPixelIntr(x0-1, ++y0, clr); // complete tip of ellipse
    putPixelIntr(x0-1, --y1, clr);
  }
  atomicFence();
  ++vupcounter;
}

void fillEllipse (int x0, int y0, int w, int h, VColor clr) @trusted {
  import std.math : abs;
  if (w == 0 && h == 0) return;
  if (w == 1) { vline(x0, y0, h, clr); return; }
  if (h == 1) { hline(x0, y0, w, clr); return; }
  int x1 = x0+w-1;
  int y1 = y0+h-1;
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
    if (y0 != prev_y0) { hline(x0, y0, x1-x0+1, clr); prev_y0 = y0; }
    if (y1 != y0 && y1 != prev_y1) { hline(x0, y1, x1-x0+1, clr); prev_y1 = y1; }
    e2 = 2*err;
    if (e2 >= dx) { ++x0; --x1; err += dx += b1; } // x step
    if (e2 <= dy) { ++y0; --y1; err += dy += a; }  // y step
  } while (x0 <= x1);
  while (y0-y1 < b) {
    // too early stop of flat ellipses a=1
    putPixelIntr(x0-1, ++y0, clr); // complete tip of ellipse
    putPixelIntr(x0-1, --y1, clr);
  }
  atomicFence();
  ++vupcounter;
}


// //////////////////////////////////////////////////////////////////////// //
int charWidth(string type="msx") () {
       static if (type == "msx") return 6;
  else static if (type == "dos") return 8;
  else static if (type == "d10") return 10;
  else static assert(0, "invalid font type");
}

int charHeight(string type="msx") () {
       static if (type == "msx") return 8;
  else static if (type == "dos") return 8;
  else static if (type == "d10") return 10;
  else static assert(0, "invalid font type");
}

void drawCharWdt(string type="msx") (int x, int y, int wdt, int shift, char ch, VColor fgcol, VColor bgcol=Transparent) @trusted {
       static if (type == "msx") { alias fontb8 = kgiFont6; enum fwdt = 8; enum fhgt = 8; enum fmask = 0x80; }
  else static if (type == "dos") { alias fontb8 = kgiFont8; enum fwdt = 8; enum fhgt = 8; enum fmask = 0x80; }
  else static if (type == "d10") { alias fontb8 = kgiFont10; enum fwdt = 10; enum fhgt = 10; enum fmask = 0x8000; }
  else static assert(0, "invalid font type");
  size_t pos = ch*fhgt;
  if (wdt < 1 || shift >= fwdt) return;
  if (fgcol == Transparent && bgcol == Transparent) return;
  if (wdt > fwdt) wdt = fwdt;
  if (shift < 0) shift = 0;
  foreach (immutable int dy; 0..fhgt) {
    ushort b = cast(ushort)(fontb8.ptr[pos++]<<shift);
    foreach (immutable int dx; 0..wdt) {
      VColor c = (b&fmask ? fgcol : bgcol);
      putPixelIntr(x+dx, y+dy, c);
      b <<= 1;
    }
  }
  atomicFence();
  ++vupcounter;
}

// outline types
enum : ubyte {
  OutLeft   = 0x01,
  OutRight  = 0x02,
  OutUp     = 0x04,
  OutDown   = 0x08,
  OutLU     = 0x10, // left-up
  OutRU     = 0x20, // right-up
  OutLD     = 0x40, // left-down
  OutRD     = 0x80, // right-down
  OutAll    = 0xff,
}

void drawCharWdtOut(string type="msx") (int x, int y, int wdt, int shift, char ch, VColor fgcol, VColor outcol=Transparent, ubyte ot=0) @trusted {
       static if (type == "msx") { alias fontb8 = kgiFont6; enum fwdt = 8; enum fhgt = 8; enum fmask = 0x80; }
  else static if (type == "dos") { alias fontb8 = kgiFont8; enum fwdt = 8; enum fhgt = 8; enum fmask = 0x80; }
  else static if (type == "d10") { alias fontb8 = kgiFont10; enum fwdt = 10; enum fhgt = 10; enum fmask = 0x8000; }
  else static assert(0, "invalid font type");
  if (fgcol == Transparent && outcol == Transparent) return;
  if (ot == 0 || outcol == Transparent) {
    // no outline? simple draw
    drawCharWdt(x, y, wdt, shift, ch, fgcol, Transparent);
    return;
  }
  size_t pos = ch*fhgt;
  if (wdt < 1 || shift >= fwdt) return;
  if (wdt > 8) wdt = fwdt;
  if (shift < 0) shift = 0;
  ubyte[fhgt+2][fwdt+2] bmp = 0; // char bitmap; 0: empty; 1: char; 2: outline
  foreach (immutable dy; 1..fhgt+1) {
    ushort b = cast(ushort)(fontb8.ptr[pos++]<<shift);
    foreach (immutable dx; 1..wdt+1) {
      if (b&fmask) {
        // put pixel
        bmp[dy][dx] = 1;
        // put outlines
        if ((ot&OutUp) && bmp[dy-1][dx] == 0) bmp[dy-1][dx] = 2;
        if ((ot&OutDown) && bmp[dy+1][dx] == 0) bmp[dy+1][dx] = 2;
        if ((ot&OutLeft) && bmp[dy][dx-1] == 0) bmp[dy][dx-1] = 2;
        if ((ot&OutRight) && bmp[dy][dx+1] == 0) bmp[dy][dx+1] = 2;
        if ((ot&OutLU) && bmp[dy-1][dx-1] == 0) bmp[dy-1][dx-1] = 2;
        if ((ot&OutRU) && bmp[dy-1][dx+1] == 0) bmp[dy-1][dx+1] = 2;
        if ((ot&OutLD) && bmp[dy+1][dx-1] == 0) bmp[dy+1][dx-1] = 2;
        if ((ot&OutRD) && bmp[dy+1][dx+1] == 0) bmp[dy+1][dx+1] = 2;
      }
      b <<= 1;
    }
  }
  // now draw it
  --x;
  --y;
  foreach (immutable int dy; 0..fhgt+2) {
    foreach (immutable int dx; 0..fwdt+2) {
      if (auto t = bmp[dy][dx]) putPixelIntr(x+dx, y+dy, (t == 1 ? fgcol : outcol));
    }
  }
  atomicFence();
  ++vupcounter;
}

void drawChar(string type="msx") (int x, int y, char ch, VColor fgcol, VColor bgcol=Transparent) @trusted {
  drawCharWdt!type(x, y, charWidth!type, 0, ch, fgcol, bgcol);
}

void drawCharOut(string type="msx") (int x, int y, char ch, VColor fgcol, VColor outcol=Transparent, ubyte ot=OutAll) @trusted {
  drawCharWdtOut!type(x, y, charWidth!type, 0, ch, fgcol, outcol, ot);
}

void drawStr(string type="msx") (int x, int y, const(char)[] str, VColor fgcol, VColor bgcol=Transparent) @trusted {
  foreach (immutable char ch; str) {
    drawChar!type(x, y, ch, fgcol, bgcol);
    x += charWidth!type;
  }
}

void drawStrOut(string type="msx") (int x, int y, const(char)[] str, VColor fgcol, VColor outcol=Transparent, ubyte ot=OutAll) @trusted {
  foreach (immutable char ch; str) {
    drawCharOut!type(x, y, ch, fgcol, outcol, ot);
    x += charWidth!type;
  }
}

int strWidth(string type="msx") (const(char)[] str) {
  return cast(int)str.length*charWidth!type;
}

int charWidthProp(string type="msx") (char ch) @trusted pure {
       static if (type == "msx") { alias fontw8 = vlFontPropWidth; }
  else static if (type == "dos") { alias fontw8 = dosFontPropWidth; }
  else static assert(0, "invalid font type");
  return (fontw8.ptr[ch]&0x0f);
}

int strWidthProp(string type="msx") (const(char)[] str) @trusted pure {
       static if (type == "msx") { alias fontw8 = vlFontPropWidth; }
  else static if (type == "dos") { alias fontw8 = dosFontPropWidth; }
  else static assert(0, "invalid font type");
  int wdt = 0;
  foreach (immutable char ch; str) wdt += (fontw8[ch]&0x0f)+1;
  if (wdt > 0) --wdt; // don't count last empty pixel
  return wdt;
}

int drawCharProp(string type="msx") (int x, int y, char ch, VColor fgcol, VColor bgcol=Transparent) @trusted {
       static if (type == "msx") { alias fontw8 = vlFontPropWidth; }
  else static if (type == "dos") { alias fontw8 = dosFontPropWidth; }
  else static assert(0, "invalid font type");
  immutable int wdt = (fontw8[ch]&0x0f);
  drawCharWdt!type(x, y, wdt, fontw8[ch]>>4, ch, fgcol, bgcol);
  return wdt;
}

int drawCharPropOut(string type="msx") (int x, int y, char ch, VColor fgcol, VColor outcol=Transparent, ubyte ot=OutAll) @trusted {
       static if (type == "msx") { alias fontw8 = vlFontPropWidth; }
  else static if (type == "dos") { alias fontw8 = dosFontPropWidth; }
  else static assert(0, "invalid font type");
  immutable int wdt = (fontw8[ch]&0x0f);
  drawCharWdtOut!type(x, y, wdt, fontw8[ch]>>4, ch, fgcol, outcol, ot);
  return wdt;
}

int drawStrProp(string type="msx") (int x, int y, const(char)[] str, VColor fgcol, VColor bgcol=Transparent) @trusted {
  bool vline = false;
  int sx = x;
  foreach (immutable char ch; str) {
    if (vline) {
      if (!isTransparent(bgcol)) {
        foreach (int dy; 0..8) putPixelIntr(x, y+dy, bgcol);
        // no need to advance vupcounter, 'cause `drawCharProp` will do it
        //atomicFence();
        //++vupcounter;
      }
      ++x;
    }
    vline = true;
    x += drawCharProp!type(x, y, ch, fgcol, bgcol);
  }
  return x-sx;
}

int drawStrPropOut(string type="msx") (int x, int y, const(char)[] str, VColor fgcol, VColor outcol=Transparent, ubyte ot=OutAll) @trusted {
  int sx = x;
  foreach (immutable char ch; str) {
    x += drawCharPropOut!type(x, y, ch, fgcol, outcol, ot)+1;
  }
  if (x > sx) --x; // don't count last empty pixel
  return x-sx;
}


// ////////////////////////////////////////////////////////////////////////// //
/** floodfill area; based on Tarry's maze algorithm.
 *
 * fill area with color/pattern. trades memory for speed: doesn't recurse, doesn't allocate.
 * will use "transparency" byte as temporary, and will leave it dirty.
 *
 * NOTES:
 *   neither `isBorder` nor `patColor` will be called with out-of-range coordinates.
 */
void floodFillEx (int x, int y, scope bool delegate (int x, int y) nothrow @nogc isBorder, scope VColor delegate (int x, int y) nothrow @nogc patColor) nothrow @trusted @nogc {
  enum : ubyte {
    DirMask = 0x03,
    Seed = 0x10,
    Scanned = 0x80,
  }

  static ubyte getmark (int x, int y) {
    pragma(inline, true);
    return cast(ubyte)(x >= 0 && y >= 0 && x < vbufW && y < vbufH ? vbuf[y*vbufW+x]>>vlAShift : Scanned);
  }

  static void setmark (int x, int y, ubyte mark) {
    pragma(inline, true);
    if (x >= 0 && y >= 0 && x < vbufW && y < vbufH) vbuf[y*vbufW+x] = (vbuf[y*vbufW+x]&vlColorMask)|(mark<<vlAShift);
  }

  if (x < 0 || y < 0 || x >= vbufW || y >= vbufH) return; // nothing to do
  if (isBorder(x, y)) return; // nothing to do

  //setPixel(x, y, getPixel(x, y)); // set update flag

  // one can mark bounding rectangle with Scanned
  // reset flags
  auto p = vbuf;
  foreach (immutable dy; 0..vbufH) {
    foreach (immutable dx; 0..vbufW) {
      *p &= vlColorMask; // "not visited" mark
      ++p;
    }
  }

  //setmark(x, y, Scanned|Fill|Seed);
  vbuf[y*vbufW+x] = (patColor(x, y)&vlColorMask)|((Scanned|Seed)<<vlAShift);

  ubyte dir = 0; // direction: right, left, up, down
  for (;;) {
    x += (dir == 0 ? 1 : dir == 1 ? -1 : 0);
    y += (dir == 3 ? 1 : dir == 2 ? -1 : 0);
    auto mk = getmark(x, y);
    if (mk == 0) {
      // not yet visited, check for border
      if (isBorder(x, y)) { mk = Scanned; setmark(x, y, Scanned); }
    }
    if ((mk&Scanned) == 0) {
      // not scanned
      //setmark(x, y, Scanned|Fill|dir);
      vbuf[y*vbufW+x] = (patColor(x, y)&vlColorMask)|((Scanned|dir)<<vlAShift);
      if (dir != 1) dir = 0; // make exit direction
    } else {
      // already scanned
      for (;;) {
        x -= (dir == 0 ? 1 : dir == 1 ? -1 : 0);
        y -= (dir == 3 ? 1 : dir == 2 ? -1 : 0);
        mk = getmark(x, y);
        if (mk&Seed) {
          // done, fill pixels (you can set Fill flag and check all pixels here)
          // set update flag
          atomicFence();
          ++vupcounter;
          return;
        }
        ++dir;
        if ((mk&DirMask) == (dir^1)) ++dir; // skip entry-direction
        if (dir <= 3) break; // next pixel
        dir = mk&DirMask;
      }
    }
  }
}


// ////////////////////////////////////////////////////////////////////////// //
public static immutable ubyte[256*8] kgiFont6 = [
/* 0 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 1 */
0b_00111100,
0b_01000010,
0b_10100101,
0b_10000001,
0b_10100101,
0b_10011001,
0b_01000010,
0b_00111100,
/* 2 */
0b_00111100,
0b_01111110,
0b_11011011,
0b_11111111,
0b_11111111,
0b_11011011,
0b_01100110,
0b_00111100,
/* 3 */
0b_01101100,
0b_11111110,
0b_11111110,
0b_11111110,
0b_01111100,
0b_00111000,
0b_00010000,
0b_00000000,
/* 4 */
0b_00010000,
0b_00111000,
0b_01111100,
0b_11111110,
0b_01111100,
0b_00111000,
0b_00010000,
0b_00000000,
/* 5 */
0b_00010000,
0b_00111000,
0b_01010100,
0b_11111110,
0b_01010100,
0b_00010000,
0b_00111000,
0b_00000000,
/* 6 */
0b_00010000,
0b_00111000,
0b_01111100,
0b_11111110,
0b_11111110,
0b_00010000,
0b_00111000,
0b_00000000,
/* 7 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00110000,
0b_00110000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 8 */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11100111,
0b_11100111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 9 */
0b_00111000,
0b_01000100,
0b_10000010,
0b_10000010,
0b_10000010,
0b_01000100,
0b_00111000,
0b_00000000,
/* 10 */
0b_11000111,
0b_10111011,
0b_01111101,
0b_01111101,
0b_01111101,
0b_10111011,
0b_11000111,
0b_11111111,
/* 11 */
0b_00001111,
0b_00000011,
0b_00000101,
0b_01111001,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
/* 12 */
0b_00111000,
0b_01000100,
0b_01000100,
0b_01000100,
0b_00111000,
0b_00010000,
0b_01111100,
0b_00010000,
/* 13 */
0b_00110000,
0b_00101000,
0b_00100100,
0b_00100100,
0b_00101000,
0b_00100000,
0b_11100000,
0b_11000000,
/* 14 */
0b_00111100,
0b_00100100,
0b_00111100,
0b_00100100,
0b_00100100,
0b_11100100,
0b_11011100,
0b_00011000,
/* 15 */
0b_00010000,
0b_01010100,
0b_00111000,
0b_11101110,
0b_00111000,
0b_01010100,
0b_00010000,
0b_00000000,
/* 16 */
0b_00010000,
0b_00010000,
0b_00010000,
0b_01111100,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
/* 17 */
0b_00010000,
0b_00010000,
0b_00010000,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 18 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
/* 19 */
0b_00010000,
0b_00010000,
0b_00010000,
0b_11110000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
/* 20 */
0b_00010000,
0b_00010000,
0b_00010000,
0b_00011111,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
/* 21 */
0b_00010000,
0b_00010000,
0b_00010000,
0b_11111111,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
/* 22 */
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
/* 23 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 24 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00011111,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
/* 25 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_11110000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
/* 26 */
0b_00010000,
0b_00010000,
0b_00010000,
0b_00011111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 27 */
0b_00010000,
0b_00010000,
0b_00010000,
0b_11110000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 28 */
0b_10000001,
0b_01000010,
0b_00100100,
0b_00011000,
0b_00011000,
0b_00100100,
0b_01000010,
0b_10000001,
/* 29 */
0b_00000001,
0b_00000010,
0b_00000100,
0b_00001000,
0b_00010000,
0b_00100000,
0b_01000000,
0b_10000000,
/* 30 */
0b_10000000,
0b_01000000,
0b_00100000,
0b_00010000,
0b_00001000,
0b_00000100,
0b_00000010,
0b_00000001,
/* 31 */
0b_00000000,
0b_00010000,
0b_00010000,
0b_11111111,
0b_00010000,
0b_00010000,
0b_00000000,
0b_00000000,
/* 32 ' ' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 33 '!' */
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
0b_00000000,
0b_00100000,
0b_00000000,
/* 34 '"' */
0b_01010000,
0b_01010000,
0b_01010000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 35 '#' */
0b_01010000,
0b_01010000,
0b_11111000,
0b_01010000,
0b_11111000,
0b_01010000,
0b_01010000,
0b_00000000,
/* 36 '$' */
0b_00100000,
0b_01111000,
0b_10100000,
0b_01110000,
0b_00101000,
0b_11110000,
0b_00100000,
0b_00000000,
/* 37 '%' */
0b_11000000,
0b_11001000,
0b_00010000,
0b_00100000,
0b_01000000,
0b_10011000,
0b_00011000,
0b_00000000,
/* 38 '&' */
0b_01000000,
0b_10100000,
0b_01000000,
0b_10101000,
0b_10010000,
0b_10011000,
0b_01100000,
0b_00000000,
/* 39 ''' */
0b_00010000,
0b_00100000,
0b_01000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 40 '(' */
0b_00010000,
0b_00100000,
0b_01000000,
0b_01000000,
0b_01000000,
0b_00100000,
0b_00010000,
0b_00000000,
/* 41 ')' */
0b_01000000,
0b_00100000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00100000,
0b_01000000,
0b_00000000,
/* 42 '*' */
0b_10001000,
0b_01010000,
0b_00100000,
0b_11111000,
0b_00100000,
0b_01010000,
0b_10001000,
0b_00000000,
/* 43 '+' */
0b_00000000,
0b_00100000,
0b_00100000,
0b_11111000,
0b_00100000,
0b_00100000,
0b_00000000,
0b_00000000,
/* 44 ',' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00100000,
0b_00100000,
0b_01000000,
/* 45 '-' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_01111000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 46 '.' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_01100000,
0b_01100000,
0b_00000000,
/* 47 '/' */
0b_00000000,
0b_00000000,
0b_00001000,
0b_00010000,
0b_00100000,
0b_01000000,
0b_10000000,
0b_00000000,
/* 48 '0' */
0b_01110000,
0b_10001000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 49 '1' */
0b_00100000,
0b_01100000,
0b_10100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_11111000,
0b_00000000,
/* 50 '2' */
0b_01110000,
0b_10001000,
0b_00001000,
0b_00010000,
0b_01100000,
0b_10000000,
0b_11111000,
0b_00000000,
/* 51 '3' */
0b_01110000,
0b_10001000,
0b_00001000,
0b_00110000,
0b_00001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 52 '4' */
0b_00010000,
0b_00110000,
0b_01010000,
0b_10010000,
0b_11111000,
0b_00010000,
0b_00010000,
0b_00000000,
/* 53 '5' */
0b_11111000,
0b_10000000,
0b_11100000,
0b_00010000,
0b_00001000,
0b_00010000,
0b_11100000,
0b_00000000,
/* 54 '6' */
0b_00110000,
0b_01000000,
0b_10000000,
0b_11110000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 55 '7' */
0b_11111000,
0b_10001000,
0b_00010000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 56 '8' */
0b_01110000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 57 '9' */
0b_01110000,
0b_10001000,
0b_10001000,
0b_01111000,
0b_00001000,
0b_00010000,
0b_01100000,
0b_00000000,
/* 58 ':' */
0b_00000000,
0b_00000000,
0b_00100000,
0b_00000000,
0b_00000000,
0b_00100000,
0b_00000000,
0b_00000000,
/* 59 ';' */
0b_00000000,
0b_00000000,
0b_00100000,
0b_00000000,
0b_00000000,
0b_00100000,
0b_00100000,
0b_01000000,
/* 60 '<' */
0b_00011000,
0b_00110000,
0b_01100000,
0b_11000000,
0b_01100000,
0b_00110000,
0b_00011000,
0b_00000000,
/* 61 '=' */
0b_00000000,
0b_00000000,
0b_11111000,
0b_00000000,
0b_11111000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 62 '>' */
0b_11000000,
0b_01100000,
0b_00110000,
0b_00011000,
0b_00110000,
0b_01100000,
0b_11000000,
0b_00000000,
/* 63 '?' */
0b_01110000,
0b_10001000,
0b_00001000,
0b_00010000,
0b_00100000,
0b_00000000,
0b_00100000,
0b_00000000,
/* 64 '@' */
0b_01110000,
0b_10001000,
0b_00001000,
0b_01101000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_00000000,
/* 65 'A' */
0b_00100000,
0b_01010000,
0b_10001000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 66 'B' */
0b_11110000,
0b_01001000,
0b_01001000,
0b_01110000,
0b_01001000,
0b_01001000,
0b_11110000,
0b_00000000,
/* 67 'C' */
0b_00110000,
0b_01001000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_01001000,
0b_00110000,
0b_00000000,
/* 68 'D' */
0b_11100000,
0b_01010000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_01010000,
0b_11100000,
0b_00000000,
/* 69 'E' */
0b_11111000,
0b_10000000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_11111000,
0b_00000000,
/* 70 'F' */
0b_11111000,
0b_10000000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 71 'G' */
0b_01110000,
0b_10001000,
0b_10000000,
0b_10111000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 72 'H' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 73 'I' */
0b_01110000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 74 'J' */
0b_00111000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_10010000,
0b_10010000,
0b_01100000,
0b_00000000,
/* 75 'K' */
0b_10001000,
0b_10010000,
0b_10100000,
0b_11000000,
0b_10100000,
0b_10010000,
0b_10001000,
0b_00000000,
/* 76 'L' */
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_11111000,
0b_00000000,
/* 77 'M' */
0b_10001000,
0b_11011000,
0b_10101000,
0b_10101000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 78 'N' */
0b_10001000,
0b_11001000,
0b_11001000,
0b_10101000,
0b_10011000,
0b_10011000,
0b_10001000,
0b_00000000,
/* 79 'O' */
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 80 'P' */
0b_11110000,
0b_10001000,
0b_10001000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 81 'Q' */
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10101000,
0b_10010000,
0b_01101000,
0b_00000000,
/* 82 'R' */
0b_11110000,
0b_10001000,
0b_10001000,
0b_11110000,
0b_10100000,
0b_10010000,
0b_10001000,
0b_00000000,
/* 83 'S' */
0b_01110000,
0b_10001000,
0b_10000000,
0b_01110000,
0b_00001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 84 'T' */
0b_11111000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 85 'U' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 86 'V' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01010000,
0b_01010000,
0b_00100000,
0b_00000000,
/* 87 'W' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_10101000,
0b_10101000,
0b_11011000,
0b_10001000,
0b_00000000,
/* 88 'X' */
0b_10001000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01010000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 89 'Y' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 90 'Z' */
0b_11111000,
0b_00001000,
0b_00010000,
0b_00100000,
0b_01000000,
0b_10000000,
0b_11111000,
0b_00000000,
/* 91 '[' */
0b_01110000,
0b_01000000,
0b_01000000,
0b_01000000,
0b_01000000,
0b_01000000,
0b_01110000,
0b_00000000,
/* 92 '\' */
0b_00000000,
0b_00000000,
0b_10000000,
0b_01000000,
0b_00100000,
0b_00010000,
0b_00001000,
0b_00000000,
/* 93 ']' */
0b_01110000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_01110000,
0b_00000000,
/* 94 '^' */
0b_00100000,
0b_01010000,
0b_10001000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 95 '_' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111000,
0b_00000000,
/* 96 '`' */
0b_01000000,
0b_00100000,
0b_00010000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 97 'a' */
0b_00000000,
0b_00000000,
0b_01110000,
0b_00001000,
0b_01111000,
0b_10001000,
0b_01111000,
0b_00000000,
/* 98 'b' */
0b_10000000,
0b_10000000,
0b_10110000,
0b_11001000,
0b_10001000,
0b_11001000,
0b_10110000,
0b_00000000,
/* 99 'c' */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_10000000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 100 'd' */
0b_00001000,
0b_00001000,
0b_01101000,
0b_10011000,
0b_10001000,
0b_10011000,
0b_01101000,
0b_00000000,
/* 101 'e' */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_11111000,
0b_10000000,
0b_01110000,
0b_00000000,
/* 102 'f' */
0b_00010000,
0b_00101000,
0b_00100000,
0b_11111000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 103 'g' */
0b_00000000,
0b_00000000,
0b_01101000,
0b_10011000,
0b_10011000,
0b_01101000,
0b_00001000,
0b_01110000,
/* 104 'h' */
0b_10000000,
0b_10000000,
0b_11110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 105 'i' */
0b_00100000,
0b_00000000,
0b_01100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 106 'j' */
0b_00010000,
0b_00000000,
0b_00110000,
0b_00010000,
0b_00010000,
0b_00010000,
0b_10010000,
0b_01100000,
/* 107 'k' */
0b_01000000,
0b_01000000,
0b_01001000,
0b_01010000,
0b_01100000,
0b_01010000,
0b_01001000,
0b_00000000,
/* 108 'l' */
0b_01100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 109 'm' */
0b_00000000,
0b_00000000,
0b_11010000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_00000000,
/* 110 'n' */
0b_00000000,
0b_00000000,
0b_10110000,
0b_11001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 111 'o' */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 112 'p' */
0b_00000000,
0b_00000000,
0b_10110000,
0b_11001000,
0b_11001000,
0b_10110000,
0b_10000000,
0b_10000000,
/* 113 'q' */
0b_00000000,
0b_00000000,
0b_01101000,
0b_10011000,
0b_10011000,
0b_01101000,
0b_00001000,
0b_00001000,
/* 114 'r' */
0b_00000000,
0b_00000000,
0b_10110000,
0b_11001000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 115 's' */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10000000,
0b_11110000,
0b_00001000,
0b_11110000,
0b_00000000,
/* 116 't' */
0b_01000000,
0b_01000000,
0b_11110000,
0b_01000000,
0b_01000000,
0b_01001000,
0b_00110000,
0b_00000000,
/* 117 'u' */
0b_00000000,
0b_00000000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_01101000,
0b_00000000,
/* 118 'v' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_00000000,
/* 119 'w' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_01010000,
0b_00000000,
/* 120 'x' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01010000,
0b_10001000,
0b_00000000,
/* 121 'y' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10001000,
0b_10011000,
0b_01101000,
0b_00001000,
0b_01110000,
/* 122 'z' */
0b_00000000,
0b_00000000,
0b_11111000,
0b_00010000,
0b_00100000,
0b_01000000,
0b_11111000,
0b_00000000,
/* 123 '{' */
0b_00011000,
0b_00100000,
0b_00100000,
0b_01000000,
0b_00100000,
0b_00100000,
0b_00011000,
0b_00000000,
/* 124 '|' */
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 125 '}' */
0b_11000000,
0b_00100000,
0b_00100000,
0b_00010000,
0b_00100000,
0b_00100000,
0b_11000000,
0b_00000000,
/* 126 '~' */
0b_01000000,
0b_10101000,
0b_00010000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 127 */
0b_00000000,
0b_00000000,
0b_00100000,
0b_01010000,
0b_11111000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 128 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_11111111,
/* 129 */
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
/* 130 */
0b_00000000,
0b_00000000,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 131 */
0b_11111111,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 132 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00111100,
0b_00111100,
0b_00000000,
0b_00000000,
0b_00000000,
/* 133 */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_00000000,
0b_00000000,
/* 134 */
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
/* 135 */
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
/* 136 */
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
/* 137 */
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
/* 138 */
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
/* 139 */
0b_00010001,
0b_00100010,
0b_01000100,
0b_10001000,
0b_00010001,
0b_00100010,
0b_01000100,
0b_10001000,
/* 140 */
0b_10001000,
0b_01000100,
0b_00100010,
0b_00010001,
0b_10001000,
0b_01000100,
0b_00100010,
0b_00010001,
/* 141 */
0b_11111110,
0b_01111100,
0b_00111000,
0b_00010000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 142 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00010000,
0b_00111000,
0b_01111100,
0b_11111110,
/* 143 */
0b_10000000,
0b_11000000,
0b_11100000,
0b_11110000,
0b_11100000,
0b_11000000,
0b_10000000,
0b_00000000,
/* 144 */
0b_00000001,
0b_00000011,
0b_00000111,
0b_00001111,
0b_00000111,
0b_00000011,
0b_00000001,
0b_00000000,
/* 145 */
0b_11111111,
0b_01111110,
0b_00111100,
0b_00011000,
0b_00011000,
0b_00111100,
0b_01111110,
0b_11111111,
/* 146 */
0b_10000001,
0b_11000011,
0b_11100111,
0b_11111111,
0b_11111111,
0b_11100111,
0b_11000011,
0b_10000001,
/* 147 */
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 148 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
/* 149 */
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 150 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
/* 151 */
0b_00110011,
0b_00110011,
0b_11001100,
0b_11001100,
0b_00110011,
0b_00110011,
0b_11001100,
0b_11001100,
/* 152 */
0b_00000000,
0b_00100000,
0b_00100000,
0b_01010000,
0b_01010000,
0b_10001000,
0b_11111000,
0b_00000000,
/* 153 */
0b_00100000,
0b_00100000,
0b_01110000,
0b_00100000,
0b_01110000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 154 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_01010000,
0b_10001000,
0b_10101000,
0b_01010000,
0b_00000000,
/* 155 */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 156 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 157 */
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
/* 158 */
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
/* 159 */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 160 */
0b_00000000,
0b_00000000,
0b_01101000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_01101000,
0b_00000000,
/* 161 */
0b_00110000,
0b_01001000,
0b_01001000,
0b_01110000,
0b_01001000,
0b_01001000,
0b_01110000,
0b_11000000,
/* 162 */
0b_11111000,
0b_10001000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 163 */
0b_00000000,
0b_01010000,
0b_01110000,
0b_10001000,
0b_11111000,
0b_10000000,
0b_01110000,
0b_00000000,
/* 164 */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_01111000,
0b_00000000,
/* 165 */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_01100000,
0b_00000000,
/* 166 */
0b_00100000,
0b_00000000,
0b_01100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 167 */
0b_01010000,
0b_00000000,
0b_01110000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 168 */
0b_11111000,
0b_00100000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_11111000,
/* 169 */
0b_00100000,
0b_01010000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_00000000,
/* 170 */
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01010000,
0b_01010000,
0b_11011000,
0b_00000000,
/* 171 */
0b_00110000,
0b_01000000,
0b_01000000,
0b_00100000,
0b_01010000,
0b_01010000,
0b_01010000,
0b_00100000,
/* 172 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_01010000,
0b_10101000,
0b_10101000,
0b_01010000,
0b_00000000,
/* 173 */
0b_00001000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_10000000,
0b_00000000,
/* 174 */
0b_00111000,
0b_01000000,
0b_10000000,
0b_11111000,
0b_10000000,
0b_01000000,
0b_00111000,
0b_00000000,
/* 175 */
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 176 */
0b_00000000,
0b_11111000,
0b_00000000,
0b_11111000,
0b_00000000,
0b_11111000,
0b_00000000,
0b_00000000,
/* 177 */
0b_00100000,
0b_00100000,
0b_11111000,
0b_00100000,
0b_00100000,
0b_00000000,
0b_11111000,
0b_00000000,
/* 178 */
0b_11000000,
0b_00110000,
0b_00001000,
0b_00110000,
0b_11000000,
0b_00000000,
0b_11111000,
0b_00000000,
/* 179 */
0b_01010000,
0b_11111000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_11111000,
0b_00000000,
/* 180 */
0b_01111000,
0b_10000000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_01111000,
0b_00000000,
/* 181 */
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_10100000,
0b_01000000,
/* 182 */
0b_01110000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 183 */
0b_01010000,
0b_01110000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 184 */
0b_00000000,
0b_00011000,
0b_00100100,
0b_00100100,
0b_00011000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 185 */
0b_00000000,
0b_00110000,
0b_01111000,
0b_01111000,
0b_00110000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 186 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00110000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 187 */
0b_00111110,
0b_00100000,
0b_00100000,
0b_00100000,
0b_10100000,
0b_01100000,
0b_00100000,
0b_00000000,
/* 188 */
0b_10100000,
0b_01010000,
0b_01010000,
0b_01010000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 189 */
0b_01000000,
0b_10100000,
0b_00100000,
0b_01000000,
0b_11100000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 190 */
0b_00000000,
0b_00111000,
0b_00111000,
0b_00111000,
0b_00111000,
0b_00111000,
0b_00111000,
0b_00000000,
/* 191 */
0b_00111100,
0b_01000010,
0b_10011001,
0b_10100001,
0b_10100001,
0b_10011001,
0b_01000010,
0b_00111100,
/* 192 */
0b_00000000,
0b_00000000,
0b_10010000,
0b_10101000,
0b_11101000,
0b_10101000,
0b_10010000,
0b_00000000,
/* 193 */
0b_00000000,
0b_00000000,
0b_01100000,
0b_00010000,
0b_01110000,
0b_10010000,
0b_01101000,
0b_00000000,
/* 194 */
0b_00000000,
0b_00000000,
0b_11110000,
0b_10000000,
0b_11110000,
0b_10001000,
0b_11110000,
0b_00000000,
/* 195 */
0b_00000000,
0b_00000000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_11111000,
0b_00001000,
0b_00000000,
/* 196 */
0b_00000000,
0b_00000000,
0b_00110000,
0b_01010000,
0b_01010000,
0b_01110000,
0b_10001000,
0b_00000000,
/* 197 */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_11111000,
0b_10000000,
0b_01110000,
0b_00000000,
/* 198 */
0b_00000000,
0b_00100000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_00000000,
/* 199 */
0b_00000000,
0b_00000000,
0b_01111000,
0b_01001000,
0b_01000000,
0b_01000000,
0b_01000000,
0b_00000000,
/* 200 */
0b_00000000,
0b_00000000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01010000,
0b_10001000,
0b_00000000,
/* 201 */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_10001000,
0b_00000000,
/* 202 */
0b_00000000,
0b_01010000,
0b_00100000,
0b_00000000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_00000000,
/* 203 */
0b_00000000,
0b_00000000,
0b_10010000,
0b_10100000,
0b_11000000,
0b_10100000,
0b_10010000,
0b_00000000,
/* 204 */
0b_00000000,
0b_00000000,
0b_00111000,
0b_00101000,
0b_00101000,
0b_01001000,
0b_10001000,
0b_00000000,
/* 205 */
0b_00000000,
0b_00000000,
0b_10001000,
0b_11011000,
0b_10101000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 206 */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 207 */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 208 */
0b_00000000,
0b_00000000,
0b_01111000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_00000000,
/* 209 */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10001000,
0b_01111000,
0b_00101000,
0b_01001000,
0b_00000000,
/* 210 */
0b_00000000,
0b_00000000,
0b_11110000,
0b_10001000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 211 */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_01111000,
0b_00000000,
/* 212 */
0b_00000000,
0b_00000000,
0b_11111000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 213 */
0b_00000000,
0b_00000000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01000000,
0b_10000000,
0b_00000000,
/* 214 */
0b_00000000,
0b_00000000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_01110000,
0b_10101000,
0b_00000000,
/* 215 */
0b_00000000,
0b_00000000,
0b_11110000,
0b_01001000,
0b_01110000,
0b_01001000,
0b_11110000,
0b_00000000,
/* 216 */
0b_00000000,
0b_00000000,
0b_01000000,
0b_01000000,
0b_01110000,
0b_01001000,
0b_01110000,
0b_00000000,
/* 217 */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10001000,
0b_11001000,
0b_10101000,
0b_11001000,
0b_00000000,
/* 218 */
0b_00000000,
0b_00000000,
0b_11110000,
0b_00001000,
0b_01110000,
0b_00001000,
0b_11110000,
0b_00000000,
/* 219 */
0b_00000000,
0b_00000000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_11111000,
0b_00000000,
/* 220 */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_00111000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 221 */
0b_00000000,
0b_00000000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_11111000,
0b_00001000,
0b_00000000,
/* 222 */
0b_00000000,
0b_00000000,
0b_01001000,
0b_01001000,
0b_01111000,
0b_00001000,
0b_00001000,
0b_00000000,
/* 223 */
0b_00000000,
0b_00000000,
0b_11000000,
0b_01000000,
0b_01110000,
0b_01001000,
0b_01110000,
0b_00000000,
/* 224 */
0b_10010000,
0b_10101000,
0b_10101000,
0b_11101000,
0b_10101000,
0b_10101000,
0b_10010000,
0b_00000000,
/* 225 */
0b_00100000,
0b_01010000,
0b_10001000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 226 */
0b_11111000,
0b_10001000,
0b_10000000,
0b_11110000,
0b_10001000,
0b_10001000,
0b_11110000,
0b_00000000,
/* 227 */
0b_10010000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_11111000,
0b_00001000,
0b_00000000,
/* 228 */
0b_00111000,
0b_00101000,
0b_00101000,
0b_01001000,
0b_01001000,
0b_11111000,
0b_10001000,
0b_00000000,
/* 229 */
0b_11111000,
0b_10000000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_11111000,
0b_00000000,
/* 230 */
0b_00100000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_00000000,
/* 231 */
0b_11111000,
0b_10001000,
0b_10001000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 232 */
0b_10001000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01010000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 233 */
0b_10001000,
0b_10001000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 234 */
0b_01010000,
0b_00100000,
0b_10001000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_10001000,
0b_00000000,
/* 235 */
0b_10001000,
0b_10010000,
0b_10100000,
0b_11000000,
0b_10100000,
0b_10010000,
0b_10001000,
0b_00000000,
/* 236 */
0b_00011000,
0b_00101000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_10001000,
0b_00000000,
/* 237 */
0b_10001000,
0b_11011000,
0b_10101000,
0b_10101000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 238 */
0b_10001000,
0b_10001000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 239 */
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 240 */
0b_11111000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 241 */
0b_01111000,
0b_10001000,
0b_10001000,
0b_01111000,
0b_00101000,
0b_01001000,
0b_10001000,
0b_00000000,
/* 242 */
0b_11110000,
0b_10001000,
0b_10001000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 243 */
0b_01110000,
0b_10001000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 244 */
0b_11111000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 245 */
0b_10001000,
0b_10001000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01000000,
0b_10000000,
0b_00000000,
/* 246 */
0b_10101000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_00000000,
/* 247 */
0b_11110000,
0b_01001000,
0b_01001000,
0b_01110000,
0b_01001000,
0b_01001000,
0b_11110000,
0b_00000000,
/* 248 */
0b_10000000,
0b_10000000,
0b_10000000,
0b_11110000,
0b_10001000,
0b_10001000,
0b_11110000,
0b_00000000,
/* 249 */
0b_10001000,
0b_10001000,
0b_10001000,
0b_11001000,
0b_10101000,
0b_10101000,
0b_11001000,
0b_00000000,
/* 250 */
0b_11110000,
0b_00001000,
0b_00001000,
0b_00110000,
0b_00001000,
0b_00001000,
0b_11110000,
0b_00000000,
/* 251 */
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_11111000,
0b_00000000,
/* 252 */
0b_01110000,
0b_10001000,
0b_00001000,
0b_01111000,
0b_00001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 253 */
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_11111000,
0b_00001000,
0b_00000000,
/* 254 */
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01111000,
0b_00001000,
0b_00001000,
0b_00000000,
/* 255 */
0b_11000000,
0b_01000000,
0b_01000000,
0b_01110000,
0b_01001000,
0b_01001000,
0b_01110000,
0b_00000000,
];


// bits 0..3: width
// bits 4..7: lshift
public immutable ubyte[256] vlFontPropWidth = () {
  ubyte[256] res;
  foreach (immutable cnum; 0..256) {
    import core.bitop : bsf, bsr;
    immutable doshift =
      (cnum >= 32 && cnum <= 127) ||
      (cnum >= 143 && cnum <= 144) ||
      (cnum >= 166 && cnum <= 167) ||
      (cnum >= 192 && cnum <= 255);
    int shift = 0;
    if (doshift) {
      shift = 8;
      foreach (immutable dy; 0..8) {
        immutable b = kgiFont6[cnum*8+dy];
        if (b) {
          immutable mn = 7-bsr(b);
          if (mn < shift) shift = mn;
        }
      }
    }
    ubyte wdt = 0;
    foreach (immutable dy; 0..8) {
      immutable b = (kgiFont6[cnum*8+dy]<<shift);
      immutable cwdt = (b ? 8-bsf(b) : 0);
      if (cwdt > wdt) wdt = cast(ubyte)cwdt;
    }
    switch (cnum) {
      case 0: wdt = 8; break; // 8px space
      case 32: wdt = 5; break; // 5px space
      case  17: .. case  27: wdt = 8; break; // single frames
      case  48: .. case  57: wdt = 5; break; // digits are monospaced
      case 127: .. case 142: wdt = 8; break; // filled frames
      case 145: .. case 151: wdt = 8; break; // filled frames
      case 155: .. case 159: wdt = 8; break; // filled frames
      default:
    }
    res[cnum] = (wdt&0x0f)|((shift<<4)&0xf0);
  }
  return res;
}();


public static immutable ubyte[256*8] kgiFont8 = [
/* 0x00 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0x01 */
0b_01111110,
0b_10000001,
0b_10100101,
0b_10000001,
0b_10111101,
0b_10011001,
0b_10000001,
0b_01111110,
/* 0x02 */
0b_01111110,
0b_11111111,
0b_11011011,
0b_11111111,
0b_11000011,
0b_11100111,
0b_11111111,
0b_01111110,
/* 0x03 */
0b_01101100,
0b_11111110,
0b_11111110,
0b_11111110,
0b_01111100,
0b_00111000,
0b_00010000,
0b_00000000,
/* 0x04 */
0b_00010000,
0b_00111000,
0b_01111100,
0b_11111110,
0b_01111100,
0b_00111000,
0b_00010000,
0b_00000000,
/* 0x05 */
0b_00111000,
0b_01111100,
0b_00111000,
0b_11111110,
0b_11111110,
0b_11010110,
0b_00010000,
0b_00111000,
/* 0x06 */
0b_00010000,
0b_00010000,
0b_00111000,
0b_01111100,
0b_11111110,
0b_01111100,
0b_00010000,
0b_00111000,
/* 0x07 */
0b_00000000,
0b_00000000,
0b_00011000,
0b_00111100,
0b_00111100,
0b_00011000,
0b_00000000,
0b_00000000,
/* 0x08 */
0b_11111111,
0b_11111111,
0b_11100111,
0b_11000011,
0b_11000011,
0b_11100111,
0b_11111111,
0b_11111111,
/* 0x09 */
0b_00000000,
0b_00111100,
0b_01100110,
0b_01000010,
0b_01000010,
0b_01100110,
0b_00111100,
0b_00000000,
/* 0x0a */
0b_11111111,
0b_11000011,
0b_10011001,
0b_10111101,
0b_10111101,
0b_10011001,
0b_11000011,
0b_11111111,
/* 0x0b */
0b_00001111,
0b_00000111,
0b_00001111,
0b_01111101,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111000,
/* 0x0c */
0b_00111100,
0b_01100110,
0b_01100110,
0b_01100110,
0b_00111100,
0b_00011000,
0b_01111110,
0b_00011000,
/* 0x0d */
0b_00111111,
0b_00110011,
0b_00111111,
0b_00110000,
0b_00110000,
0b_01110000,
0b_11110000,
0b_11100000,
/* 0x0e */
0b_01111111,
0b_01100011,
0b_01111111,
0b_01100011,
0b_01100011,
0b_01100111,
0b_11100110,
0b_11000000,
/* 0x0f */
0b_10011001,
0b_01011010,
0b_00111100,
0b_11100111,
0b_11100111,
0b_00111100,
0b_01011010,
0b_10011001,
/* 0x10 */
0b_10000000,
0b_11100000,
0b_11111000,
0b_11111110,
0b_11111000,
0b_11100000,
0b_10000000,
0b_00000000,
/* 0x11 */
0b_00000010,
0b_00001110,
0b_00111110,
0b_11111110,
0b_00111110,
0b_00001110,
0b_00000010,
0b_00000000,
/* 0x12 */
0b_00011000,
0b_00111100,
0b_01111110,
0b_00011000,
0b_00011000,
0b_01111110,
0b_00111100,
0b_00011000,
/* 0x13 */
0b_01100110,
0b_01100110,
0b_01100110,
0b_01100110,
0b_01100110,
0b_00000000,
0b_01100110,
0b_00000000,
/* 0x14 */
0b_01111111,
0b_11011011,
0b_11011011,
0b_01111011,
0b_00011011,
0b_00011011,
0b_00011011,
0b_00000000,
/* 0x15 */
0b_01111110,
0b_11000011,
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_10001100,
0b_11111000,
/* 0x16 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_01111110,
0b_01111110,
0b_01111110,
0b_00000000,
/* 0x17 */
0b_00011000,
0b_00111100,
0b_01111110,
0b_00011000,
0b_01111110,
0b_00111100,
0b_00011000,
0b_11111111,
/* 0x18 */
0b_00011000,
0b_00111100,
0b_01111110,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00000000,
/* 0x19 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_01111110,
0b_00111100,
0b_00011000,
0b_00000000,
/* 0x1a */
0b_00000000,
0b_00011000,
0b_00001100,
0b_11111110,
0b_00001100,
0b_00011000,
0b_00000000,
0b_00000000,
/* 0x1b */
0b_00000000,
0b_00110000,
0b_01100000,
0b_11111110,
0b_01100000,
0b_00110000,
0b_00000000,
0b_00000000,
/* 0x1c */
0b_00000000,
0b_00000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11111110,
0b_00000000,
0b_00000000,
/* 0x1d */
0b_00000000,
0b_00100100,
0b_01100110,
0b_11111111,
0b_01100110,
0b_00100100,
0b_00000000,
0b_00000000,
/* 0x1e */
0b_00000000,
0b_00011000,
0b_00111100,
0b_01111110,
0b_11111111,
0b_11111111,
0b_00000000,
0b_00000000,
/* 0x1f */
0b_00000000,
0b_11111111,
0b_11111111,
0b_01111110,
0b_00111100,
0b_00011000,
0b_00000000,
0b_00000000,
/* 0x20 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* ! */
0b_00110000,
0b_01111000,
0b_01111000,
0b_00110000,
0b_00110000,
0b_00000000,
0b_00110000,
0b_00000000,
/* " */
0b_01101100,
0b_01101100,
0b_01101100,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* # */
0b_01101100,
0b_01101100,
0b_11111110,
0b_01101100,
0b_11111110,
0b_01101100,
0b_01101100,
0b_00000000,
/* $ */
0b_00110000,
0b_01111100,
0b_11000000,
0b_01111000,
0b_00001100,
0b_11111000,
0b_00110000,
0b_00000000,
/* % */
0b_00000000,
0b_11000110,
0b_11001100,
0b_00011000,
0b_00110000,
0b_01100110,
0b_11000110,
0b_00000000,
/* & */
0b_00111000,
0b_01101100,
0b_00111000,
0b_01110110,
0b_11011100,
0b_11001100,
0b_01110110,
0b_00000000,
/* ' */
0b_01100000,
0b_01100000,
0b_11000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* ( */
0b_00011000,
0b_00110000,
0b_01100000,
0b_01100000,
0b_01100000,
0b_00110000,
0b_00011000,
0b_00000000,
/* ) */
0b_01100000,
0b_00110000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00110000,
0b_01100000,
0b_00000000,
/* * */
0b_00000000,
0b_01100110,
0b_00111100,
0b_11111111,
0b_00111100,
0b_01100110,
0b_00000000,
0b_00000000,
/* + */
0b_00000000,
0b_00110000,
0b_00110000,
0b_11111100,
0b_00110000,
0b_00110000,
0b_00000000,
0b_00000000,
/* , */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_01110000,
0b_00110000,
0b_01100000,
/* - */
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111100,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* . */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00110000,
0b_00110000,
0b_00000000,
/* / */
0b_00000110,
0b_00001100,
0b_00011000,
0b_00110000,
0b_01100000,
0b_11000000,
0b_10000000,
0b_00000000,
/* 0 */
0b_01111000,
0b_11001100,
0b_11011100,
0b_11111100,
0b_11101100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 1 */
0b_00110000,
0b_11110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_11111100,
0b_00000000,
/* 2 */
0b_01111000,
0b_11001100,
0b_00001100,
0b_00111000,
0b_01100000,
0b_11001100,
0b_11111100,
0b_00000000,
/* 3 */
0b_01111000,
0b_11001100,
0b_00001100,
0b_00111000,
0b_00001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 4 */
0b_00011100,
0b_00111100,
0b_01101100,
0b_11001100,
0b_11111110,
0b_00001100,
0b_00001100,
0b_00000000,
/* 5 */
0b_11111100,
0b_11000000,
0b_11111000,
0b_00001100,
0b_00001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 6 */
0b_00111000,
0b_01100000,
0b_11000000,
0b_11111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 7 */
0b_11111100,
0b_11001100,
0b_00001100,
0b_00011000,
0b_00110000,
0b_01100000,
0b_01100000,
0b_00000000,
/* 8 */
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 9 */
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111100,
0b_00001100,
0b_00011000,
0b_01110000,
0b_00000000,
/* : */
0b_00000000,
0b_00000000,
0b_00110000,
0b_00110000,
0b_00000000,
0b_00110000,
0b_00110000,
0b_00000000,
/* ; */
0b_00000000,
0b_00000000,
0b_00110000,
0b_00110000,
0b_00000000,
0b_01110000,
0b_00110000,
0b_01100000,
/* < */
0b_00011000,
0b_00110000,
0b_01100000,
0b_11000000,
0b_01100000,
0b_00110000,
0b_00011000,
0b_00000000,
/* = */
0b_00000000,
0b_00000000,
0b_11111100,
0b_00000000,
0b_11111100,
0b_00000000,
0b_00000000,
0b_00000000,
/* > */
0b_01100000,
0b_00110000,
0b_00011000,
0b_00001100,
0b_00011000,
0b_00110000,
0b_01100000,
0b_00000000,
/* ? */
0b_01111000,
0b_11001100,
0b_00001100,
0b_00011000,
0b_00110000,
0b_00000000,
0b_00110000,
0b_00000000,
/* @ */
0b_01111100,
0b_11000110,
0b_11011110,
0b_11011110,
0b_11011110,
0b_11000000,
0b_01111000,
0b_00000000,
/* A */
0b_00110000,
0b_01111000,
0b_11001100,
0b_11001100,
0b_11111100,
0b_11001100,
0b_11001100,
0b_00000000,
/* B */
0b_11111100,
0b_01100110,
0b_01100110,
0b_01111100,
0b_01100110,
0b_01100110,
0b_11111100,
0b_00000000,
/* C */
0b_00111100,
0b_01100110,
0b_11000000,
0b_11000000,
0b_11000000,
0b_01100110,
0b_00111100,
0b_00000000,
/* D */
0b_11111100,
0b_01101100,
0b_01100110,
0b_01100110,
0b_01100110,
0b_01101100,
0b_11111100,
0b_00000000,
/* E */
0b_11111110,
0b_01100010,
0b_01101000,
0b_01111000,
0b_01101000,
0b_01100010,
0b_11111110,
0b_00000000,
/* F */
0b_11111110,
0b_01100010,
0b_01101000,
0b_01111000,
0b_01101000,
0b_01100000,
0b_11110000,
0b_00000000,
/* G */
0b_00111100,
0b_01100110,
0b_11000000,
0b_11000000,
0b_11001110,
0b_01100110,
0b_00111110,
0b_00000000,
/* H */
0b_11001100,
0b_11001100,
0b_11001100,
0b_11111100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_00000000,
/* I */
0b_01111000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_01111000,
0b_00000000,
/* J */
0b_00011110,
0b_00001100,
0b_00001100,
0b_00001100,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* K */
0b_11100110,
0b_01100110,
0b_01101100,
0b_01111000,
0b_01101100,
0b_01100110,
0b_11100110,
0b_00000000,
/* L */
0b_11110000,
0b_01100000,
0b_01100000,
0b_01100000,
0b_01100010,
0b_01100110,
0b_11111110,
0b_00000000,
/* M */
0b_11000110,
0b_11101110,
0b_11111110,
0b_11010110,
0b_11000110,
0b_11000110,
0b_11000110,
0b_00000000,
/* N */
0b_11000110,
0b_11100110,
0b_11110110,
0b_11011110,
0b_11001110,
0b_11000110,
0b_11000110,
0b_00000000,
/* O */
0b_00111000,
0b_01101100,
0b_11000110,
0b_11000110,
0b_11000110,
0b_01101100,
0b_00111000,
0b_00000000,
/* P */
0b_11111100,
0b_01100110,
0b_01100110,
0b_01111100,
0b_01100000,
0b_01100000,
0b_11110000,
0b_00000000,
/* Q */
0b_01111000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11011100,
0b_01111000,
0b_00011100,
0b_00000000,
/* R */
0b_11111100,
0b_01100110,
0b_01100110,
0b_01111100,
0b_01111000,
0b_01101100,
0b_11100110,
0b_00000000,
/* S */
0b_01111000,
0b_11001100,
0b_11100000,
0b_00111000,
0b_00011100,
0b_11001100,
0b_01111000,
0b_00000000,
/* T */
0b_11111100,
0b_10110100,
0b_00110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_01111000,
0b_00000000,
/* U */
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11111100,
0b_00000000,
/* V */
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00110000,
0b_00000000,
/* W */
0b_11000110,
0b_11000110,
0b_11000110,
0b_11010110,
0b_11111110,
0b_11101110,
0b_11000110,
0b_00000000,
/* X */
0b_11000110,
0b_11000110,
0b_01101100,
0b_00111000,
0b_01101100,
0b_11000110,
0b_11000110,
0b_00000000,
/* Y */
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00110000,
0b_00110000,
0b_01111000,
0b_00000000,
/* Z */
0b_11111110,
0b_11001100,
0b_10011000,
0b_00110000,
0b_01100010,
0b_11000110,
0b_11111110,
0b_00000000,
/* [ */
0b_01111000,
0b_01100000,
0b_01100000,
0b_01100000,
0b_01100000,
0b_01100000,
0b_01111000,
0b_00000000,
/* \ */
0b_11000000,
0b_01100000,
0b_00110000,
0b_00011000,
0b_00001100,
0b_00000110,
0b_00000010,
0b_00000000,
/* ] */
0b_01111000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_01111000,
0b_00000000,
/* ^ */
0b_00010000,
0b_00111000,
0b_01101100,
0b_11000110,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* _ */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
/* ` */
0b_00110000,
0b_00110000,
0b_00011000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* a */
0b_00000000,
0b_00000000,
0b_01111000,
0b_00001100,
0b_01111100,
0b_11001100,
0b_01110110,
0b_00000000,
/* b */
0b_11100000,
0b_01100000,
0b_01111100,
0b_01100110,
0b_01100110,
0b_01100110,
0b_10111100,
0b_00000000,
/* c */
0b_00000000,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11000000,
0b_11001100,
0b_01111000,
0b_00000000,
/* d */
0b_00011100,
0b_00001100,
0b_00001100,
0b_01111100,
0b_11001100,
0b_11001100,
0b_01110110,
0b_00000000,
/* e */
0b_00000000,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11111100,
0b_11000000,
0b_01111000,
0b_00000000,
/* f */
0b_00111000,
0b_01101100,
0b_01100000,
0b_11110000,
0b_01100000,
0b_01100000,
0b_11110000,
0b_00000000,
/* g */
0b_00000000,
0b_00000000,
0b_01110110,
0b_11001100,
0b_11001100,
0b_01111100,
0b_00001100,
0b_11111000,
/* h */
0b_11100000,
0b_01100000,
0b_01101100,
0b_01110110,
0b_01100110,
0b_01100110,
0b_11100110,
0b_00000000,
/* i */
0b_00110000,
0b_00000000,
0b_01110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_01111000,
0b_00000000,
/* j */
0b_00011000,
0b_00000000,
0b_01111000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_11011000,
0b_01110000,
/* k */
0b_11100000,
0b_01100000,
0b_01100110,
0b_01101100,
0b_01111000,
0b_01101100,
0b_11100110,
0b_00000000,
/* l */
0b_01110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_01111000,
0b_00000000,
/* m */
0b_00000000,
0b_00000000,
0b_11101100,
0b_11111110,
0b_11010110,
0b_11000110,
0b_11000110,
0b_00000000,
/* n */
0b_00000000,
0b_00000000,
0b_11111000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_00000000,
/* o */
0b_00000000,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* p */
0b_00000000,
0b_00000000,
0b_11011100,
0b_01100110,
0b_01100110,
0b_01111100,
0b_01100000,
0b_11110000,
/* q */
0b_00000000,
0b_00000000,
0b_01110110,
0b_11001100,
0b_11001100,
0b_01111100,
0b_00001100,
0b_00011110,
/* r */
0b_00000000,
0b_00000000,
0b_11011000,
0b_01101100,
0b_01101100,
0b_01100000,
0b_11110000,
0b_00000000,
/* s */
0b_00000000,
0b_00000000,
0b_01111100,
0b_11000000,
0b_01111000,
0b_00001100,
0b_11111000,
0b_00000000,
/* t */
0b_00010000,
0b_00110000,
0b_01111100,
0b_00110000,
0b_00110000,
0b_00110100,
0b_00011000,
0b_00000000,
/* u */
0b_00000000,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01110110,
0b_00000000,
/* v */
0b_00000000,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00110000,
0b_00000000,
/* w */
0b_00000000,
0b_00000000,
0b_11000110,
0b_11000110,
0b_11010110,
0b_11111110,
0b_01101100,
0b_00000000,
/* x */
0b_00000000,
0b_00000000,
0b_11000110,
0b_01101100,
0b_00111000,
0b_01101100,
0b_11000110,
0b_00000000,
/* y */
0b_00000000,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111100,
0b_00001100,
0b_11111000,
/* z */
0b_00000000,
0b_00000000,
0b_11111100,
0b_10011000,
0b_00110000,
0b_01100100,
0b_11111100,
0b_00000000,
/* { */
0b_00011100,
0b_00110000,
0b_00110000,
0b_11100000,
0b_00110000,
0b_00110000,
0b_00011100,
0b_00000000,
/* | */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00000000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00000000,
/* } */
0b_11100000,
0b_00110000,
0b_00110000,
0b_00011100,
0b_00110000,
0b_00110000,
0b_11100000,
0b_00000000,
/* ~ */
0b_01110110,
0b_11011100,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0x7f */
0b_00010000,
0b_00111000,
0b_01101100,
0b_11000110,
0b_11000110,
0b_11000110,
0b_11111110,
0b_00000000,
/* 0x80 */
0b_01111000,
0b_11001100,
0b_11000000,
0b_11001100,
0b_01111000,
0b_00011000,
0b_00001100,
0b_01111000,
/* 0x81 */
0b_00000000,
0b_11001100,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111110,
0b_00000000,
/* 0x82 */
0b_00011100,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11111100,
0b_11000000,
0b_01111000,
0b_00000000,
/* 0x83 */
0b_01111110,
0b_11000011,
0b_00111100,
0b_00000110,
0b_00111110,
0b_01100110,
0b_00111111,
0b_00000000,
/* 0x84 */
0b_11001100,
0b_00000000,
0b_01111000,
0b_00001100,
0b_01111100,
0b_11001100,
0b_01111110,
0b_00000000,
/* 0x85 */
0b_11100000,
0b_00000000,
0b_01111000,
0b_00001100,
0b_01111100,
0b_11001100,
0b_01111110,
0b_00000000,
/* 0x86 */
0b_00110000,
0b_00110000,
0b_01111000,
0b_00001100,
0b_01111100,
0b_11001100,
0b_01111110,
0b_00000000,
/* 0x87 */
0b_00000000,
0b_00000000,
0b_01111100,
0b_11000000,
0b_11000000,
0b_01111100,
0b_00000110,
0b_00111100,
/* 0x88 */
0b_01111110,
0b_11000011,
0b_00111100,
0b_01100110,
0b_01111110,
0b_01100000,
0b_00111100,
0b_00000000,
/* 0x89 */
0b_11001100,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11111100,
0b_11000000,
0b_01111000,
0b_00000000,
/* 0x8a */
0b_11100000,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11111100,
0b_11000000,
0b_01111000,
0b_00000000,
/* 0x8b */
0b_11001100,
0b_00000000,
0b_01110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_01111000,
0b_00000000,
/* 0x8c */
0b_01111100,
0b_11000110,
0b_00111000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00111100,
0b_00000000,
/* 0x8d */
0b_11100000,
0b_00000000,
0b_01110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_01111000,
0b_00000000,
/* 0x8e */
0b_11001100,
0b_00110000,
0b_01111000,
0b_11001100,
0b_11001100,
0b_11111100,
0b_11001100,
0b_00000000,
/* 0x8f */
0b_00110000,
0b_00110000,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11111100,
0b_11001100,
0b_00000000,
/* 0x90 */
0b_00011100,
0b_00000000,
0b_11111100,
0b_01100000,
0b_01111000,
0b_01100000,
0b_11111100,
0b_00000000,
/* 0x91 */
0b_00000000,
0b_00000000,
0b_01111111,
0b_00001100,
0b_01111111,
0b_11001100,
0b_01111111,
0b_00000000,
/* 0x92 */
0b_00111110,
0b_01101100,
0b_11001100,
0b_11111110,
0b_11001100,
0b_11001100,
0b_11001110,
0b_00000000,
/* 0x93 */
0b_01111000,
0b_11001100,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 0x94 */
0b_00000000,
0b_11001100,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 0x95 */
0b_00000000,
0b_11100000,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 0x96 */
0b_01111000,
0b_11001100,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111110,
0b_00000000,
/* 0x97 */
0b_00000000,
0b_11100000,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111110,
0b_00000000,
/* 0x98 */
0b_00000000,
0b_11001100,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11111100,
0b_00001100,
0b_11111000,
/* 0x99 */
0b_11000110,
0b_00111000,
0b_01111100,
0b_11000110,
0b_11000110,
0b_01111100,
0b_00111000,
0b_00000000,
/* 0x9a */
0b_11001100,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 0x9b */
0b_00011000,
0b_00011000,
0b_01111110,
0b_11000000,
0b_11000000,
0b_01111110,
0b_00011000,
0b_00011000,
/* 0x9c */
0b_00111000,
0b_01101100,
0b_01100100,
0b_11110000,
0b_01100000,
0b_11100110,
0b_11111100,
0b_00000000,
/* 0x9d */
0b_11001100,
0b_11001100,
0b_01111000,
0b_11111100,
0b_00110000,
0b_11111100,
0b_00110000,
0b_00000000,
/* 0x9e */
0b_11110000,
0b_11011000,
0b_11011000,
0b_11110100,
0b_11001100,
0b_11011110,
0b_11001100,
0b_00001110,
/* 0x9f */
0b_00001110,
0b_00011011,
0b_00011000,
0b_01111110,
0b_00011000,
0b_00011000,
0b_11011000,
0b_01110000,
/* 0xa0 */
0b_00011100,
0b_00000000,
0b_01111000,
0b_00001100,
0b_01111100,
0b_11001100,
0b_01111110,
0b_00000000,
/* 0xa1 */
0b_00111000,
0b_00000000,
0b_01110000,
0b_00110000,
0b_00110000,
0b_00110000,
0b_01111000,
0b_00000000,
/* 0xa2 */
0b_00000000,
0b_00011100,
0b_00000000,
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 0xa3 */
0b_00000000,
0b_00011100,
0b_00000000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111110,
0b_00000000,
/* 0xa4 */
0b_00000000,
0b_11111000,
0b_00000000,
0b_11111000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_00000000,
/* 0xa5 */
0b_11111100,
0b_00000000,
0b_11001100,
0b_11101100,
0b_11111100,
0b_11011100,
0b_11001100,
0b_00000000,
/* 0xa6 */
0b_00111100,
0b_01101100,
0b_01101100,
0b_00111110,
0b_00000000,
0b_01111110,
0b_00000000,
0b_00000000,
/* 0xa7 */
0b_00111100,
0b_01100110,
0b_01100110,
0b_00111100,
0b_00000000,
0b_01111110,
0b_00000000,
0b_00000000,
/* 0xa8 */
0b_00110000,
0b_00000000,
0b_00110000,
0b_01100000,
0b_11000000,
0b_11001100,
0b_01111000,
0b_00000000,
/* 0xa9 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111100,
0b_11000000,
0b_11000000,
0b_00000000,
0b_00000000,
/* 0xaa */
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111100,
0b_00001100,
0b_00001100,
0b_00000000,
0b_00000000,
/* 0xab */
0b_11000110,
0b_11001100,
0b_11011000,
0b_00111110,
0b_01100011,
0b_11001110,
0b_10011000,
0b_00011111,
/* 0xac */
0b_11000110,
0b_11001100,
0b_11011000,
0b_11110011,
0b_01100111,
0b_11001111,
0b_10011111,
0b_00000011,
/* 0xad */
0b_00000000,
0b_00011000,
0b_00000000,
0b_00011000,
0b_00011000,
0b_00111100,
0b_00111100,
0b_00011000,
/* 0xae */
0b_00000000,
0b_00110011,
0b_01100110,
0b_11001100,
0b_01100110,
0b_00110011,
0b_00000000,
0b_00000000,
/* 0xaf */
0b_00000000,
0b_11001100,
0b_01100110,
0b_00110011,
0b_01100110,
0b_11001100,
0b_00000000,
0b_00000000,
/* 0xb0 */
0b_00100010,
0b_10001000,
0b_00100010,
0b_10001000,
0b_00100010,
0b_10001000,
0b_00100010,
0b_10001000,
/* 0xb1 */
0b_01010101,
0b_10101010,
0b_01010101,
0b_10101010,
0b_01010101,
0b_10101010,
0b_01010101,
0b_10101010,
/* 0xb2 */
0b_11011100,
0b_01110110,
0b_11011100,
0b_01110110,
0b_11011100,
0b_01110110,
0b_11011100,
0b_01110110,
/* 0xb3 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xb4 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_11111000,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xb5 */
0b_00011000,
0b_00011000,
0b_11111000,
0b_00011000,
0b_11111000,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xb6 */
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_11110110,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xb7 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111110,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xb8 */
0b_00000000,
0b_00000000,
0b_11111000,
0b_00011000,
0b_11111000,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xb9 */
0b_00110110,
0b_00110110,
0b_11110110,
0b_00000110,
0b_11110110,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xba */
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xbb */
0b_00000000,
0b_00000000,
0b_11111110,
0b_00000110,
0b_11110110,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xbc */
0b_00110110,
0b_00110110,
0b_11110110,
0b_00000110,
0b_11111110,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xbd */
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_11111110,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xbe */
0b_00011000,
0b_00011000,
0b_11111000,
0b_00011000,
0b_11111000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xbf */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111000,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xc0 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xc1 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xc2 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xc3 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011111,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xc4 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xc5 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_11111111,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xc6 */
0b_00011000,
0b_00011000,
0b_00011111,
0b_00011000,
0b_00011111,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xc7 */
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110111,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xc8 */
0b_00110110,
0b_00110110,
0b_00110111,
0b_00110000,
0b_00111111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xc9 */
0b_00000000,
0b_00000000,
0b_00111111,
0b_00110000,
0b_00110111,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xca */
0b_00110110,
0b_00110110,
0b_11110111,
0b_00000000,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xcb */
0b_00000000,
0b_00000000,
0b_11111111,
0b_00000000,
0b_11110111,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xcc */
0b_00110110,
0b_00110110,
0b_00110111,
0b_00110000,
0b_00110111,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xcd */
0b_00000000,
0b_00000000,
0b_11111111,
0b_00000000,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xce */
0b_00110110,
0b_00110110,
0b_11110111,
0b_00000000,
0b_11110111,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xcf */
0b_00011000,
0b_00011000,
0b_11111111,
0b_00000000,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xd0 */
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xd1 */
0b_00000000,
0b_00000000,
0b_11111111,
0b_00000000,
0b_11111111,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xd2 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xd3 */
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_00111111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xd4 */
0b_00011000,
0b_00011000,
0b_00011111,
0b_00011000,
0b_00011111,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xd5 */
0b_00000000,
0b_00000000,
0b_00011111,
0b_00011000,
0b_00011111,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xd6 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00111111,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xd7 */
0b_00110110,
0b_00110110,
0b_00110110,
0b_00110110,
0b_11110111,
0b_00110110,
0b_00110110,
0b_00110110,
/* 0xd8 */
0b_00011000,
0b_00011000,
0b_11111111,
0b_00000000,
0b_11111111,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xd9 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_11111000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xda */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00011111,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xdb */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 0xdc */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 0xdd */
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
/* 0xde */
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
/* 0xdf */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xe0 */
0b_00000000,
0b_00000000,
0b_01110110,
0b_11011100,
0b_11001000,
0b_11011100,
0b_01110110,
0b_00000000,
/* 0xe1 */
0b_00000000,
0b_01111000,
0b_11001100,
0b_11111000,
0b_11001100,
0b_11111000,
0b_11000000,
0b_11000000,
/* 0xe2 */
0b_00000000,
0b_11111110,
0b_11000110,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_00000000,
/* 0xe3 */
0b_00000000,
0b_11111110,
0b_01101100,
0b_01101100,
0b_01101100,
0b_01101100,
0b_01101100,
0b_00000000,
/* 0xe4 */
0b_11111110,
0b_01100110,
0b_00110000,
0b_00011000,
0b_00110000,
0b_01100110,
0b_11111110,
0b_00000000,
/* 0xe5 */
0b_00000000,
0b_00000000,
0b_01111110,
0b_11001100,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 0xe6 */
0b_00000000,
0b_01100110,
0b_01100110,
0b_01100110,
0b_01100110,
0b_01111100,
0b_01100000,
0b_11000000,
/* 0xe7 */
0b_00000000,
0b_01110110,
0b_11011100,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00000000,
/* 0xe8 */
0b_11111100,
0b_00110000,
0b_01111000,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00110000,
0b_11111100,
/* 0xe9 */
0b_00111000,
0b_01101100,
0b_11000110,
0b_11111110,
0b_11000110,
0b_01101100,
0b_00111000,
0b_00000000,
/* 0xea */
0b_00111000,
0b_01101100,
0b_11000110,
0b_11000110,
0b_01101100,
0b_01101100,
0b_11101110,
0b_00000000,
/* 0xeb */
0b_00011100,
0b_00110000,
0b_00011000,
0b_01111100,
0b_11001100,
0b_11001100,
0b_01111000,
0b_00000000,
/* 0xec */
0b_00000000,
0b_00000000,
0b_01111110,
0b_11011011,
0b_11011011,
0b_01111110,
0b_00000000,
0b_00000000,
/* 0xed */
0b_00000110,
0b_00001100,
0b_01111110,
0b_11011011,
0b_11011011,
0b_01111110,
0b_01100000,
0b_11000000,
/* 0xee */
0b_00111100,
0b_01100000,
0b_11000000,
0b_11111100,
0b_11000000,
0b_01100000,
0b_00111100,
0b_00000000,
/* 0xef */
0b_01111000,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_11001100,
0b_00000000,
/* 0xf0 */
0b_00000000,
0b_11111100,
0b_00000000,
0b_11111100,
0b_00000000,
0b_11111100,
0b_00000000,
0b_00000000,
/* 0xf1 */
0b_00110000,
0b_00110000,
0b_11111100,
0b_00110000,
0b_00110000,
0b_00000000,
0b_11111100,
0b_00000000,
/* 0xf2 */
0b_01100000,
0b_00110000,
0b_00011000,
0b_00110000,
0b_01100000,
0b_00000000,
0b_11111100,
0b_00000000,
/* 0xf3 */
0b_00011000,
0b_00110000,
0b_01100000,
0b_00110000,
0b_00011000,
0b_00000000,
0b_11111100,
0b_00000000,
/* 0xf4 */
0b_00001110,
0b_00011011,
0b_00011011,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
/* 0xf5 */
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_00011000,
0b_11011000,
0b_11011000,
0b_01110000,
/* 0xf6 */
0b_00110000,
0b_00110000,
0b_00000000,
0b_11111100,
0b_00000000,
0b_00110000,
0b_00110000,
0b_00000000,
/* 0xf7 */
0b_00000000,
0b_01110010,
0b_10011100,
0b_00000000,
0b_01110010,
0b_10011100,
0b_00000000,
0b_00000000,
/* 0xf8 */
0b_00111000,
0b_01101100,
0b_01101100,
0b_00111000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xf9 */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00011000,
0b_00011000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xfa */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00011000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xfb */
0b_00001111,
0b_00001100,
0b_00001100,
0b_00001100,
0b_11101100,
0b_01101100,
0b_00111100,
0b_00011100,
/* 0xfc */
0b_01111000,
0b_01101100,
0b_01101100,
0b_01101100,
0b_01101100,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xfd */
0b_01111000,
0b_00001100,
0b_00111000,
0b_01100000,
0b_01111100,
0b_00000000,
0b_00000000,
0b_00000000,
/* 0xfe */
0b_00000000,
0b_00000000,
0b_00111100,
0b_00111100,
0b_00111100,
0b_00111100,
0b_00000000,
0b_00000000,
/* 0xff */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
];


// bits 0..3: width
// bits 4..7: lshift
public immutable ubyte[256] dosFontPropWidth = () {
  ubyte[256] res;
  foreach (immutable cnum; 0..256) {
    import core.bitop : bsf, bsr;
    immutable doshift =
      (cnum >= 32 && cnum <= 127) ||
      (cnum >= 143 && cnum <= 144) ||
      (cnum >= 166 && cnum <= 167) ||
      (cnum >= 192 && cnum <= 255);
    int shift = 0;
    if (doshift) {
      shift = 8;
      foreach (immutable dy; 0..8) {
        immutable b = kgiFont8[cnum*8+dy];
        if (b) {
          immutable mn = 7-bsr(b);
          if (mn < shift) shift = mn;
        }
      }
    }
    ubyte wdt = 0;
    foreach (immutable dy; 0..8) {
      immutable b = (kgiFont8[cnum*8+dy]<<shift);
      immutable cwdt = (b ? 8-bsf(b) : 0);
      if (cwdt > wdt) wdt = cast(ubyte)cwdt;
    }
    switch (cnum) {
      case 0: wdt = 8; break; // 8px space
      case 32: wdt = 5; break; // 5px space
      case  48: .. case  57: wdt = 5; break; // digits are monospaced
      case 176: .. case 223: wdt = 8; break; // pseudographics (frames, etc)
      default:
    }
    res[cnum] = (wdt&0x0f)|((shift<<4)&0xf0);
  }
  return res;
}();


static public immutable ushort[256*10] kgiFont10 = [
/* 0x00 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x01 */
0b_0000000000_000000,
0b_0011111100_000000,
0b_0100000010_000000,
0b_0101001010_000000,
0b_0100000010_000000,
0b_0101111010_000000,
0b_0100110010_000000,
0b_0010000100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
/* 0x02 */
0b_0000000000_000000,
0b_0011111100_000000,
0b_0111111110_000000,
0b_0110110110_000000,
0b_0111111110_000000,
0b_0110000110_000000,
0b_0111001110_000000,
0b_0011111100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
/* 0x03 */
0b_0000000000_000000,
0b_0011101110_000000,
0b_0111111111_000000,
0b_0111111111_000000,
0b_0111111111_000000,
0b_0011111110_000000,
0b_0001111100_000000,
0b_0000111000_000000,
0b_0000010000_000000,
0b_0000000000_000000,
/* 0x04 */
0b_0000010000_000000,
0b_0000111000_000000,
0b_0001111100_000000,
0b_0011111110_000000,
0b_0111111111_000000,
0b_0011111110_000000,
0b_0001111100_000000,
0b_0000111000_000000,
0b_0000010000_000000,
0b_0000000000_000000,
/* 0x05 */
0b_0000000000_000000,
0b_0000111000_000000,
0b_0001111100_000000,
0b_0000111000_000000,
0b_0011111110_000000,
0b_0111111111_000000,
0b_0011010110_000000,
0b_0000010000_000000,
0b_0000111000_000000,
0b_0000000000_000000,
/* 0x06 */
0b_0000010000_000000,
0b_0000111000_000000,
0b_0001111100_000000,
0b_0011111110_000000,
0b_0111111111_000000,
0b_0111111111_000000,
0b_0011010110_000000,
0b_0000010000_000000,
0b_0000111000_000000,
0b_0000000000_000000,
/* 0x07 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x08 */
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111001111_000000,
0b_1110000111_000000,
0b_1110000111_000000,
0b_1111001111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
/* 0x09 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111000_000000,
0b_0011001100_000000,
0b_0010000100_000000,
0b_0010000100_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x0a */
0b_1111111111_000000,
0b_1111111111_000000,
0b_1110000111_000000,
0b_1100110011_000000,
0b_1101111011_000000,
0b_1101111011_000000,
0b_1100110011_000000,
0b_1110000111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
/* 0x0b */
0b_0000000000_000000,
0b_0000011110_000000,
0b_0000001110_000000,
0b_0000011110_000000,
0b_0011111010_000000,
0b_0110011000_000000,
0b_0110011000_000000,
0b_0110011000_000000,
0b_0011110000_000000,
0b_0000000000_000000,
/* 0x0c */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0000000000_000000,
/* 0x0d */
0b_0000010000_000000,
0b_0000011000_000000,
0b_0000011100_000000,
0b_0000010100_000000,
0b_0000010100_000000,
0b_0000010000_000000,
0b_0001110000_000000,
0b_0011110000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
/* 0x0e */
0b_0000000000_000000,
0b_0001111110_000000,
0b_0001111110_000000,
0b_0001000010_000000,
0b_0001000010_000000,
0b_0001000110_000000,
0b_0011001110_000000,
0b_0111000100_000000,
0b_0010000000_000000,
0b_0000000000_000000,
/* 0x0f */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0110110110_000000,
0b_0001111000_000000,
0b_0111001110_000000,
0b_0111001110_000000,
0b_0001111000_000000,
0b_0110110110_000000,
0b_0000110000_000000,
0b_0000000000_000000,
/* 0x10 */
0b_0001000000_000000,
0b_0001100000_000000,
0b_0001110000_000000,
0b_0001111000_000000,
0b_0001111100_000000,
0b_0001111000_000000,
0b_0001110000_000000,
0b_0001100000_000000,
0b_0001000000_000000,
0b_0000000000_000000,
/* 0x11 */
0b_0000000100_000000,
0b_0000001100_000000,
0b_0000011100_000000,
0b_0000111100_000000,
0b_0001111100_000000,
0b_0000111100_000000,
0b_0000011100_000000,
0b_0000001100_000000,
0b_0000000100_000000,
0b_0000000000_000000,
/* 0x12 */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
/* 0x13 */
0b_0000000000_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0000000000_000000,
0b_0011001100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x14 */
0b_0000000000_000000,
0b_0011111110_000000,
0b_0110110110_000000,
0b_0110110110_000000,
0b_0011110110_000000,
0b_0000110110_000000,
0b_0000110110_000000,
0b_0000110110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x15 */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x16 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0111111110_000000,
0b_0111111110_000000,
0b_0111111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x17 */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_1111111111_000000,
/* 0x18 */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
/* 0x19 */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
/* 0x1a */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000011000_000000,
0b_0000001100_000000,
0b_0111111110_000000,
0b_0000001100_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x1b */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001100000_000000,
0b_0011000000_000000,
0b_0111111110_000000,
0b_0011000000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x1c */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0110000000_000000,
0b_0110000000_000000,
0b_0110000000_000000,
0b_0111111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x1d */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001000100_000000,
0b_0011000110_000000,
0b_0111111111_000000,
0b_0011000110_000000,
0b_0001000100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x1e */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000010000_000000,
0b_0000111000_000000,
0b_0001111100_000000,
0b_0011111110_000000,
0b_0111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x1f */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0111111111_000000,
0b_0011111110_000000,
0b_0001111100_000000,
0b_0000111000_000000,
0b_0000010000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x20 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ! */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* " */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0001101100_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* # */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0001101100_000000,
0b_0111111111_000000,
0b_0001101100_000000,
0b_0111111111_000000,
0b_0001101100_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* $ */
0b_0000010000_000000,
0b_0001111100_000000,
0b_0011010110_000000,
0b_0011010000_000000,
0b_0001111100_000000,
0b_0000010110_000000,
0b_0011010110_000000,
0b_0001111100_000000,
0b_0000010000_000000,
0b_0000000000_000000,
/* % */
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011001100_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* & */
0b_0000000000_000000,
0b_0001110000_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0001111110_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0001110110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ' */
0b_0000000000_000000,
0b_0000111000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ( */
0b_0000000000_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ) */
0b_0000000000_000000,
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* * */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0111111110_000000,
0b_0001111000_000000,
0b_0011001100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* + */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* , */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
/* - */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* . */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* / */
0b_0000000000_000000,
0b_0000000110_000000,
0b_0000001100_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0011000000_000000,
0b_0110000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0 */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011001110_000000,
0b_0011011110_000000,
0b_0011111110_000000,
0b_0011110110_000000,
0b_0011100110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 1 */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0001110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 2 */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0000000110_000000,
0b_0000111100_000000,
0b_0001100000_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 3 */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0000000110_000000,
0b_0000011100_000000,
0b_0000000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 4 */
0b_0000000000_000000,
0b_0000011100_000000,
0b_0000111100_000000,
0b_0001101100_000000,
0b_0011001100_000000,
0b_0011111110_000000,
0b_0000001100_000000,
0b_0000011110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 5 */
0b_0000000000_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011111100_000000,
0b_0000000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 6 */
0b_0000000000_000000,
0b_0000111100_000000,
0b_0001100000_000000,
0b_0011000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 7 */
0b_0000000000_000000,
0b_0011111110_000000,
0b_0011000110_000000,
0b_0000000110_000000,
0b_0000001100_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 8 */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 9 */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000110_000000,
0b_0000001100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* : */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ; */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
/* < */
0b_0000000000_000000,
0b_0000001100_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000001100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* = */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* > */
0b_0000000000_000000,
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000001100_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ? */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0011001100_000000,
0b_0000001100_000000,
0b_0000001100_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
/* @ */
0b_0000000000_000000,
0b_0011111100_000000,
0b_0110000110_000000,
0b_0110011110_000000,
0b_0110110110_000000,
0b_0110011110_000000,
0b_0110000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* A */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* B */
0b_0000000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* C */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* D */
0b_0000000000_000000,
0b_0011111000_000000,
0b_0011001100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011001100_000000,
0b_0011111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* E */
0b_0000000000_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011111100_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* F */
0b_0000000000_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011111100_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* G */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000000_000000,
0b_0011001110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* H */
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* I */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* J */
0b_0000000000_000000,
0b_0000011100_000000,
0b_0000001100_000000,
0b_0000001100_000000,
0b_0000001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* K */
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011001100_000000,
0b_0011111000_000000,
0b_0011001100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* L */
0b_0000000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* M */
0b_0000000000_000000,
0b_0110000110_000000,
0b_0111001110_000000,
0b_0111111110_000000,
0b_0110110110_000000,
0b_0110000110_000000,
0b_0110000110_000000,
0b_0110000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* N */
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011100110_000000,
0b_0011110110_000000,
0b_0011011110_000000,
0b_0011001110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* O */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* P */
0b_0000000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111100_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* Q */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011001110_000000,
0b_0001111100_000000,
0b_0000001110_000000,
0b_0000000000_000000,
/* R */
0b_0000000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111100_000000,
0b_0011001100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* S */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* T */
0b_0000000000_000000,
0b_0111111110_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* U */
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* V */
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001101100_000000,
0b_0000111000_000000,
0b_0000010000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* W */
0b_0000000000_000000,
0b_0110000110_000000,
0b_0110000110_000000,
0b_0110000110_000000,
0b_0110110110_000000,
0b_0111111110_000000,
0b_0111001110_000000,
0b_0110000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* X */
0b_0000000000_000000,
0b_0110000110_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0011001100_000000,
0b_0110000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* Y */
0b_0000000000_000000,
0b_0110000110_000000,
0b_0110000110_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* Z */
0b_0000000000_000000,
0b_0011111110_000000,
0b_0000001100_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0011000000_000000,
0b_0011111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* [ */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* \ */
0b_0000000000_000000,
0b_0110000000_000000,
0b_0011000000_000000,
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000001100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ] */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ^ */
0b_0000000000_000000,
0b_0000010000_000000,
0b_0000111000_000000,
0b_0001101100_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* _ */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_0000000000_000000,
/* ` */
0b_0000000000_000000,
0b_0001110000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* a */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* b */
0b_0000000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* c */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000000_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* d */
0b_0000000000_000000,
0b_0000000110_000000,
0b_0000000110_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* e */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* f */
0b_0000000000_000000,
0b_0000111100_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0011111000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* g */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000110_000000,
0b_0001111100_000000,
/* h */
0b_0000000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* i */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0001110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* j */
0b_0000000000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0000111000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0001110000_000000,
/* k */
0b_0000000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000110_000000,
0b_0011001100_000000,
0b_0011111000_000000,
0b_0011001100_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* l */
0b_0000000000_000000,
0b_0001110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000011100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* m */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011001100_000000,
0b_0111111110_000000,
0b_0110110110_000000,
0b_0110110110_000000,
0b_0110000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* n */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* o */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* p */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111100_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0000000000_000000,
/* q */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000110_000000,
0b_0000000111_000000,
0b_0000000000_000000,
/* r */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* s */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111110_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* t */
0b_0000000000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0011111000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0000111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* u */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* v */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001101100_000000,
0b_0000111000_000000,
0b_0000010000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* w */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0110000110_000000,
0b_0110110110_000000,
0b_0110110110_000000,
0b_0111111110_000000,
0b_0011001100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* x */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0001101100_000000,
0b_0000111000_000000,
0b_0001101100_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* y */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
/* z */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* { */
0b_0000000000_000000,
0b_0000111000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0011000000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0000111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* | */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
/* } */
0b_0000000000_000000,
0b_0001110000_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0000001100_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0001110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* ~ */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011100000_000000,
0b_0110110110_000000,
0b_0000011100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x7f */
0b_0000000000_000000,
0b_0000010000_000000,
0b_0000111000_000000,
0b_0001101100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x80 */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000110000_000000,
0b_0001100000_000000,
/* 0x81 */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x82 */
0b_0000011000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x83 */
0b_0000111000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x84 */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x85 */
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x86 */
0b_0000111000_000000,
0b_0001101100_000000,
0b_0000111000_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x87 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000000_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000110000_000000,
0b_0001100000_000000,
/* 0x88 */
0b_0000111000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x89 */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x8a */
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x8b */
0b_0000000000_000000,
0b_0011011000_000000,
0b_0000000000_000000,
0b_0001110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x8c */
0b_0001110000_000000,
0b_0011011000_000000,
0b_0000000000_000000,
0b_0001110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x8d */
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0001110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x8e */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x8f */
0b_0000111000_000000,
0b_0001101100_000000,
0b_0000111000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011111110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x90 */
0b_0000011000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0011111100_000000,
0b_0011000000_000000,
0b_0011111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x91 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011101110_000000,
0b_0000111011_000000,
0b_0011111111_000000,
0b_0110111000_000000,
0b_0011101110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x92 */
0b_0000000000_000000,
0b_0001111110_000000,
0b_0011011000_000000,
0b_0110011000_000000,
0b_0111111110_000000,
0b_0110011000_000000,
0b_0110011000_000000,
0b_0110011110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x93 */
0b_0000111000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x94 */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x95 */
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x96 */
0b_0000111000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x97 */
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x98 */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
/* 0x99 */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x9a */
0b_0000000000_000000,
0b_0001101100_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0x9b */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000010000_000000,
0b_0001111100_000000,
0b_0011010110_000000,
0b_0011010000_000000,
0b_0011010110_000000,
0b_0001111100_000000,
0b_0000010000_000000,
0b_0000000000_000000,
/* 0x9c */
0b_0000000000_000000,
0b_0000111100_000000,
0b_0001100110_000000,
0b_0001100000_000000,
0b_0011111000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_0011000000_000000,
0b_0011111110_000000,
0b_0000000000_000000,
/* 0x9d */
0b_0000000000_000000,
0b_0110000110_000000,
0b_0110000110_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0000000000_000000,
/* 0x9e */
0b_0000000000_000000,
0b_0111111100_000000,
0b_0110000110_000000,
0b_0110110110_000000,
0b_0110110110_000000,
0b_0111111100_000000,
0b_0110110000_000000,
0b_0110110000_000000,
0b_0110011100_000000,
0b_0000000000_000000,
/* 0x9f */
0b_0000000000_000000,
0b_0000011100_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0011100000_000000,
0b_0000000000_000000,
/* 0xa0 */
0b_0000011000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0000000110_000000,
0b_0001111110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xa1 */
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
0b_0001110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xa2 */
0b_0000011000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xa3 */
0b_0000011000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xa4 */
0b_0001110110_000000,
0b_0011011100_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xa5 */
0b_0001110110_000000,
0b_0011011100_000000,
0b_0000000000_000000,
0b_0011100110_000000,
0b_0011110110_000000,
0b_0011011110_000000,
0b_0011001110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xa6 */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0000001100_000000,
0b_0001111100_000000,
0b_0011001100_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xa7 */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xa8 */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
/* 0xa9 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111110_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xaa */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111110_000000,
0b_0000000110_000000,
0b_0000000110_000000,
0b_0000000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xab */
0b_0000000000_000000,
0b_0010000010_000000,
0b_0010000100_000000,
0b_0010001000_000000,
0b_0010010000_000000,
0b_0000101100_000000,
0b_0001000110_000000,
0b_0010001100_000000,
0b_0100001110_000000,
0b_0000000000_000000,
/* 0xac */
0b_0000000000_000000,
0b_0010000010_000000,
0b_0010000100_000000,
0b_0010001000_000000,
0b_0010010000_000000,
0b_0000101010_000000,
0b_0001001010_000000,
0b_0010001110_000000,
0b_0100000010_000000,
0b_0000000000_000000,
/* 0xad */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xae */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001100110_000000,
0b_0011001100_000000,
0b_0110011000_000000,
0b_0011001100_000000,
0b_0001100110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xaf */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0110011000_000000,
0b_0011001100_000000,
0b_0001100110_000000,
0b_0011001100_000000,
0b_0110011000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xb0 */
0b_0010001000_000000,
0b_1000100010_000000,
0b_0010001000_000000,
0b_1000100010_000000,
0b_0010001000_000000,
0b_1000100010_000000,
0b_0010001000_000000,
0b_1000100010_000000,
0b_0010001000_000000,
0b_1000100010_000000,
/* 0xb1 */
0b_0101010101_000000,
0b_1010101010_000000,
0b_0101010101_000000,
0b_1010101010_000000,
0b_0101010101_000000,
0b_1010101010_000000,
0b_0101010101_000000,
0b_1010101010_000000,
0b_0101010101_000000,
0b_1010101010_000000,
/* 0xb2 */
0b_1011101110_000000,
0b_1110111011_000000,
0b_1011101110_000000,
0b_1110111011_000000,
0b_1011101110_000000,
0b_1110111011_000000,
0b_1011101110_000000,
0b_1110111011_000000,
0b_1011101110_000000,
0b_1110111011_000000,
/* 0xb3 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xb4 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111110000_000000,
0b_1111110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xb5 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111110000_000000,
0b_1111110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111110000_000000,
0b_1111110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xb6 */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_1111001100_000000,
0b_1111001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xb7 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111100_000000,
0b_1111111100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xb8 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111110000_000000,
0b_1111110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111110000_000000,
0b_1111110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xb9 */
0b_0011001100_000000,
0b_0011001100_000000,
0b_1111001100_000000,
0b_1111001100_000000,
0b_0000001100_000000,
0b_0000001100_000000,
0b_1111001100_000000,
0b_1111001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xba */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xbb */
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111100_000000,
0b_1111111100_000000,
0b_0000001100_000000,
0b_0000001100_000000,
0b_1111001100_000000,
0b_1111001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xbc */
0b_0011001100_000000,
0b_0011001100_000000,
0b_1111001100_000000,
0b_1111001100_000000,
0b_0000001100_000000,
0b_0000001100_000000,
0b_1111111100_000000,
0b_1111111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xbd */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_1111111100_000000,
0b_1111111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xbe */
0b_0001100000_000000,
0b_0001100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_0001100000_000000,
0b_0001100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xbf */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111110000_000000,
0b_1111110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xc0 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xc1 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xc2 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xc3 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xc4 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xc5 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xc6 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xc7 */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001111_000000,
0b_0011001111_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xc8 */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001111_000000,
0b_0011001111_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011111111_000000,
0b_0011111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xc9 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111111_000000,
0b_0011111111_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011001111_000000,
0b_0011001111_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xca */
0b_0011001100_000000,
0b_0011001100_000000,
0b_1111001111_000000,
0b_1111001111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xcb */
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111001111_000000,
0b_1111001111_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xcc */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001111_000000,
0b_0011001111_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011001111_000000,
0b_0011001111_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xcd */
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xce */
0b_0011001100_000000,
0b_0011001100_000000,
0b_1111001111_000000,
0b_1111001111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111001111_000000,
0b_1111001111_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xcf */
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xd0 */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xd1 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xd2 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xd3 */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011111111_000000,
0b_0011111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xd4 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xd5 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xd6 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111111_000000,
0b_0011111111_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xd7 */
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_1111001111_000000,
0b_1111001111_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
/* 0xd8 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xd9 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_1111110000_000000,
0b_1111110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xda */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000111111_000000,
0b_0000111111_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xdb */
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
/* 0xdc */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
/* 0xdd */
0b_1111100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
0b_1111100000_000000,
/* 0xde */
0b_0000011111_000000,
0b_0000011111_000000,
0b_0000011111_000000,
0b_0000011111_000000,
0b_0000011111_000000,
0b_0000011111_000000,
0b_0000011111_000000,
0b_0000011111_000000,
0b_0000011111_000000,
0b_0000011111_000000,
/* 0xdf */
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_1111111111_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xe0 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001110110_000000,
0b_0011011100_000000,
0b_0011001000_000000,
0b_0011011100_000000,
0b_0001110110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xe1 */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011011000_000000,
0b_0011001100_000000,
0b_0011000110_000000,
0b_0011011100_000000,
0b_0011000000_000000,
0b_0000000000_000000,
/* 0xe2 */
0b_0000000000_000000,
0b_0011111110_000000,
0b_0011000110_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0011000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xe3 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0111111110_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xe4 */
0b_0000000000_000000,
0b_0011111110_000000,
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0011111110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xe5 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111110_000000,
0b_0011011000_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xe6 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0110001100_000000,
0b_0110001100_000000,
0b_0110011100_000000,
0b_0111110110_000000,
0b_0110000000_000000,
0b_0110000000_000000,
0b_0000000000_000000,
/* 0xe7 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xe8 */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0110110110_000000,
0b_0110110110_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
/* 0xe9 */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011111100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xea */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001101100_000000,
0b_0011101110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xeb */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xec */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011101110_000000,
0b_0110011011_000000,
0b_0110010011_000000,
0b_0110110011_000000,
0b_0011101110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xed */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000110_000000,
0b_0011111100_000000,
0b_0110011110_000000,
0b_0110110110_000000,
0b_0111100110_000000,
0b_0011111100_000000,
0b_0110000000_000000,
0b_0000000000_000000,
/* 0xee */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000000_000000,
0b_0001111000_000000,
0b_0011000000_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xef */
0b_0000000000_000000,
0b_0001111100_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0011000110_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xf0 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xf1 */
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0011111100_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xf2 */
0b_0000000000_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xf3 */
0b_0000000000_000000,
0b_0001100000_000000,
0b_0000110000_000000,
0b_0000011000_000000,
0b_0000110000_000000,
0b_0001100000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xf4 */
0b_0000000000_000000,
0b_0000011100_000000,
0b_0000110110_000000,
0b_0000110110_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
/* 0xf5 */
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0110110000_000000,
0b_0110110000_000000,
0b_0011100000_000000,
0b_0000000000_000000,
/* 0xf6 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0011111100_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xf7 */
0b_0000000000_000000,
0b_0011100000_000000,
0b_0110110110_000000,
0b_0000011100_000000,
0b_0000000000_000000,
0b_0011100000_000000,
0b_0110110110_000000,
0b_0000011100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xf8 */
0b_0000000000_000000,
0b_0000111000_000000,
0b_0001101100_000000,
0b_0001101100_000000,
0b_0000111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xf9 */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xfa */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000110000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xfb */
0b_0000000000_000000,
0b_0000011111_000000,
0b_0000011000_000000,
0b_0000011000_000000,
0b_0110011000_000000,
0b_0011011000_000000,
0b_0001111000_000000,
0b_0000111000_000000,
0b_0000011000_000000,
0b_0000001000_000000,
/* 0xfc */
0b_0000000000_000000,
0b_0011111000_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0011001100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xfd */
0b_0000000000_000000,
0b_0001111000_000000,
0b_0000001100_000000,
0b_0000111000_000000,
0b_0001100000_000000,
0b_0001111100_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xfe */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0001111000_000000,
0b_0001111000_000000,
0b_0001111000_000000,
0b_0001111000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
/* 0xff */
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
0b_0000000000_000000,
];
