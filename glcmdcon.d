/* coded by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
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
module iv.glcmdcon /*is aliced*/;
private:

//import arsd.color;
//import arsd.simpledisplay;

public import iv.cmdcon;
public import iv.vfs;
import iv.glbinds;
import iv.strex;

static if (__traits(compiles, (){import arsd.simpledisplay;}())) {
  enum OptGlCmdConHasSdpy = true;
} else {
  enum OptGlCmdConHasSdpy = false;
}

version(aliced) {} else { private alias usize = size_t; }


// ////////////////////////////////////////////////////////////////////////// //
__gshared uint winScale = 0;
__gshared uint scrwdt, scrhgt;


// ////////////////////////////////////////////////////////////////////////// //
/// open VFile with the given name. supports "file.pak:file1.pak:file.ext" pathes.
public VFile openFileEx (ConString name) {
  VFSDriverId[128] dids;
  int didcount;
  scope(exit) foreach_reverse (VFSDriverId did; dids[0..didcount]) vfsRemovePack(did);

  if (name.length >= int.max/4) throw new VFSException("name too long");
  int cp = 0;
  while (cp < name.length) {
    auto ep = cp;
    while (ep < name.length && name[ep] != ':') ++ep;
    if (ep >= name.length) return VFile(name);
    //{ writeln("pak: '", name[0..ep], "'; prefix: '", name[0..ep+1], "'"); }
    vfsAddPak(name[0..ep], name[0..ep+1]);
    /*
    vfsForEachFile((in ref VFSDriver.DirEntry de) {
      writeln("  ", de.name);
      return 0;
    });
    */
    cp = ep+1;
  }
  throw new VFSException("empty name");
}


// ////////////////////////////////////////////////////////////////////////// //
// public void initConsole (uint ascrwdt, uint ascrhgt, uint ascale=1); -- call at startup
// public void oglInitConsole (); -- call in `visibleForTheFirstTime`
// public void oglDrawConsole (); -- call in `redrawOpenGlScene` (it should not modify render modes)
// public bool conKeyEvent (KeyEvent event); -- returns `true` if event was eaten
// public bool conCharEvent (dchar ch); -- returns `true` if event was eaten
//
// public void concmdDoAll ();
//   call this in your main loop to process all accumulated console commands.
//   WARNING! this is NOT thread-safe, you MUST call this in your "processing thread", and
//            you MUST put `consoleLock()/consoleUnlock()` around the call!

// ////////////////////////////////////////////////////////////////////////// //
public bool isConsoleVisible () nothrow @trusted @nogc { pragma(inline, true); return rConsoleVisible; }
public bool isQuitRequested () nothrow @trusted @nogc { pragma(inline, true); import core.atomic; return atomicLoad(vquitRequested); }


// ////////////////////////////////////////////////////////////////////////// //
/// add console command to execution queue
public void concmd (ConString cmd) {
  //if (!atomicLoad(renderThreadStarted)) return;
  consoleLock();
  scope(exit) consoleUnlock();
  concmdAdd(cmd);
}

/// get console variable value; doesn't do complex conversions!
public T convar(T) (ConString s) {
  consoleLock();
  scope(exit) consoleUnlock();
  return conGetVar!T(s);
}

/// set console variable value; doesn't do complex conversions!
public void convar(T) (ConString s, T val) {
  consoleLock();
  scope(exit) consoleUnlock();
  conSetVar!T(s, val);
}


// ////////////////////////////////////////////////////////////////////////// //
/// you may call this in char event, but `conCharEvent()` will do that for you
public void concliChar (char ch) {
  if (!ch) return;
  consoleLock();
  scope(exit) consoleUnlock();

  if (ch == ConInputChar.PageUp) {
    int lnx = rConsoleHeight/conCharHeight-2;
    if (lnx < 1) lnx = 1;
    conskiplines += lnx;
    conLastChange = 0;
    return;
  }

  if (ch == ConInputChar.PageDown) {
    if (conskiplines > 0) {
      int lnx = rConsoleHeight/conCharHeight-2;
      if (lnx < 1) lnx = 1;
      if ((conskiplines -= lnx) < 0) conskiplines = 0;
      conLastChange = 0;
    }
    return;
  }

  if (ch == ConInputChar.Enter) {
    if (conskiplines) { conskiplines = 0; conLastChange = 0; }
    auto s = conInputBuffer;
    if (s.length > 0) {
      concmdAdd(s);
      conInputBufferClear(true); // add to history
      conLastChange = 0;
    }
    return;
  }

  if (ch == '`' && conInputBuffer.length == 0) { concmd("r_console ona"); return; }

  auto pcc = conInputLastChange();
  conAddInputChar(ch);
  if (pcc != conInputLastChange()) conLastChange = 0;
}


// ////////////////////////////////////////////////////////////////////////// //
__gshared char[] concmdbuf;
__gshared uint concmdbufpos;
shared static this () { concmdbuf.length = 65536; }

__gshared int conskiplines = 0;


void concmdAdd (ConString s) {
  if (s.length) {
    if (concmdbuf.length-concmdbufpos < s.length+1) {
      concmdbuf.assumeSafeAppend.length += s.length-(concmdbuf.length-concmdbufpos)+512;
    }
    if (concmdbufpos > 0 && concmdbuf[concmdbufpos-1] != '\n') concmdbuf.ptr[concmdbufpos++] = '\n';
    concmdbuf[concmdbufpos..concmdbufpos+s.length] = s[];
    concmdbufpos += s.length;
  }
}


/** execute commands added with `concmd()`.
 *
 * all new commands will be postponed for the next call.
 * call this in your main loop to process all accumulated console commands.
 * WARNING! this is NOT thread-safe, you MUST call this in your "processing thread", and
 *          you MUST put `consoleLock()/consoleUnlock()` around the call!
 *
 * Returns:
 *   "has more commands" flag
 */
public bool concmdDoAll () {
  if (concmdbufpos == 0) return false;
  auto ebuf = concmdbufpos;
  ConString s = concmdbuf[0..ebuf];
  //conwriteln("===================");
  while (s.length) {
    auto cmd = conGetCommandStr(s);
    if (cmd is null) break;
    try {
      //consoleLock();
      //scope(exit) consoleUnlock();
      //conwriteln("  <", cmd, ">");
      conExecute(cmd);
    } catch (Exception e) {
      conwriteln("***ERROR: ", e.msg);
    }
  }
  // shift postponed commands
  if (concmdbufpos > ebuf) {
    import core.stdc.string : memmove;
    //consoleLock();
    //scope(exit) consoleUnlock();
    memmove(concmdbuf.ptr, concmdbuf.ptr+ebuf, concmdbufpos-ebuf);
    concmdbufpos -= ebuf;
    //s = concmdbuf[0..concmdbufpos];
    //ebuf = concmdbufpos;
    return true;
  } else {
    concmdbufpos = 0;
    return false;
  }
}


static int conCharWidth() (char ch) { pragma(inline, true); return 10; }
enum conCharHeight = 10;


// ////////////////////////////////////////////////////////////////////////// //
__gshared char rPromptChar = '>';
__gshared float rConAlpha = 0.8;
__gshared bool rConsoleVisible = false;
__gshared int rConsoleHeight = 10*3;
__gshared uint rConTextColor = 0x00ff00; // rgb
__gshared uint rConCursorColor = 0xff7f00; // rgb
__gshared uint rConInputColor = 0xffff00; // rgb
__gshared uint rConPromptColor = 0xffffff; // rgb
__gshared uint rConStarColor = 0x3f0000; // rgb
shared bool vquitRequested = false;


/// initialize glcmdcon variables and commands, sets screen size and scale
public void initConsole (uint ascrwdt, uint ascrhgt, uint ascale=1) {
  if (winScale != 0) assert(0, "cmdcon already initialized");
  if (ascrwdt < 64 || ascrhgt < 64 || ascrwdt > 4096 || ascrhgt > 4096) assert(0, "invalid cmdcon dimensions");
  if (ascale < 1 || ascale > 64) assert(0, "invalid cmdcon scale");
  scrwdt = ascrwdt;
  scrhgt = ascrhgt;
  winScale = ascale;
  conRegFunc!((ConString fname, bool silent=false) {
    try {
      auto fl = openFileEx(fname);
      auto sz = fl.size;
      if (sz > 1024*1024*64) throw new Exception("script file too big");
      if (sz > 0) {
        enum AbortCmd = "!!abort!!";
        auto s = new char[](cast(uint)sz);
        fl.rawReadExact(s);
        if (s.indexOf(AbortCmd) >= 0) {
          auto apos = s.indexOf(AbortCmd);
          while (apos >= 0) {
            if (s.length-apos <= AbortCmd.length || s[apos+AbortCmd.length] <= ' ') {
              bool good = true;
              // it should be the first command, not commented
              auto pos = apos;
              while (pos > 0 && s[pos-1] != '\n') {
                if (s[pos-1] != ' ' && s[pos-1] != '\t') { good = false; break; }
                --pos;
              }
              if (good) { s = s[0..apos]; break; }
            }
            // check next
            apos = s.indexOf(AbortCmd, apos+1);
          }
        }
        concmd(s);
      }
    } catch (Exception e) {
      if (!silent) conwriteln("ERROR loading script \"", fname, "\"");
    }
  })("exec", "execute console script (name [silent_failure_flag])");
  conRegVar!rConsoleVisible("r_console", "console visibility");
  conRegVar!rConsoleHeight(10*3, scrhgt, "r_conheight");
  conRegVar!rConTextColor("r_contextcolor", "console log text color, 0xrrggbb", ConVarAttr.Hex);
  conRegVar!rConCursorColor("r_concursorcolor", "console cursor color, 0xrrggbb", ConVarAttr.Hex);
  conRegVar!rConInputColor("r_coninputcolor", "console input color, 0xrrggbb", ConVarAttr.Hex);
  conRegVar!rConPromptColor("r_conpromptcolor", "console prompt color, 0xrrggbb", ConVarAttr.Hex);
  conRegVar!rConStarColor("r_constarcolor", "console star color, 0xrrggbb", ConVarAttr.Hex);
  conRegVar!rPromptChar("r_conpromptchar", "console prompt character");
  conRegVar!rConAlpha("r_conalpha", "console transparency (0 is fully transparent, 1 is opaque)");
  //rConsoleHeight = scrhgt-scrhgt/3;
  rConsoleHeight = scrhgt/2;
  conRegFunc!({
    import core.atomic;
    atomicStore(vquitRequested, true);
  })("quit", "quit");
}


// ////////////////////////////////////////////////////////////////////////// //
__gshared uint* convbuf = null; // RGBA
__gshared uint convbufTexId = 0;


/// initialize OpenGL part of glcmdcon, should be called after `initConsole()`
public void oglInitConsole () {
  import core.stdc.stdlib;
  //import iv.glbinds;

  //conwriteln("scrwdt=", scrwdt, "; scrhgt=", scrhgt, "; scale=", winScale);

  convbuf = cast(uint*)realloc(convbuf, scrwdt*scrhgt*4);
  if (convbuf is null) assert(0, "out of memory");
  convbuf[0..scrwdt*scrhgt] = 0xff000000;

  if (convbufTexId) { glDeleteTextures(1, &convbufTexId); convbufTexId = 0; }

  GLuint wrapOpt = GL_REPEAT;
  GLuint filterOpt = GL_NEAREST; //GL_LINEAR;
  GLuint ttype = GL_UNSIGNED_BYTE;

  glGenTextures(1, &convbufTexId);
  if (convbufTexId == 0) assert(0, "can't create cmdcon texture");

  GLint gltextbinding;
  glGetIntegerv(GL_TEXTURE_BINDING_2D, &gltextbinding);
  scope(exit) glBindTexture(GL_TEXTURE_2D, gltextbinding);

  glBindTexture(GL_TEXTURE_2D, convbufTexId);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrapOpt);
  glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrapOpt);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filterOpt);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filterOpt);
  //glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
  //glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);

  GLfloat[4] bclr = 0.0;
  glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, bclr.ptr);
  glTexImage2D(GL_TEXTURE_2D, 0, (ttype == GL_FLOAT ? GL_RGBA16F : GL_RGBA), scrwdt, scrhgt, 0, GL_RGBA, GL_UNSIGNED_BYTE, convbuf);
}


/// render console (if it is visible). tries hard to not change OpenGL state.
public void oglDrawConsole () {
  if (!rConsoleVisible) return;
  if (convbufTexId && convbuf !is null) {
    //import iv.glbinds;
    consoleLock();
    scope(exit) consoleUnlock();

    //conwriteln("scrwdt=", scrwdt, "; scrhgt=", scrhgt, "; scale=", winScale, "; tid=", convbufTexId);
    renderConsole();

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

    glTextureSubImage2D(convbufTexId, 0, 0/*x*/, 0/*y*/, scrwdt, scrhgt, GL_RGBA, GL_UNSIGNED_BYTE, convbuf);

    enum x = 0;
    int y = 0;
    int w = scrwdt*winScale;
    int h = scrhgt*winScale;

    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    glBindFramebufferEXT(GL_FRAMEBUFFER_EXT, 0);
    glUseProgram(0);

    glMatrixMode(GL_PROJECTION); // for ortho camera
    glLoadIdentity();
    // left, right, bottom, top, near, far
    //glOrtho(0, wdt, 0, hgt, -1, 1); // bottom-to-top
    glOrtho(0, w, h, 0, -1, 1); // top-to-bottom
    glViewport(0, 0, w, h);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();

    glEnable(GL_TEXTURE_2D);
    glDisable(GL_LIGHTING);
    glDisable(GL_DITHER);
    //glDisable(GL_BLEND);
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    //glDisable(GL_BLEND);
    glDisable(GL_STENCIL_TEST);

    int ofs = (scrhgt-rConsoleHeight)*winScale;
    y -= ofs;
    h -= ofs;
    float alpha = rConAlpha;
    if (alpha < 0) alpha = 0; else if (alpha > 1) alpha = 1;
    glColor4f(1, 1, 1, alpha);
    glBindTexture(GL_TEXTURE_2D, convbufTexId);
    //scope(exit) glBindTexture(GL_TEXTURE_2D, 0);
    glBegin(GL_QUADS);
      glTexCoord2f(0.0f, 0.0f); glVertex2i(x, y); // top-left
      glTexCoord2f(1.0f, 0.0f); glVertex2i(w, y); // top-right
      glTexCoord2f(1.0f, 1.0f); glVertex2i(w, h); // bottom-right
      glTexCoord2f(0.0f, 1.0f); glVertex2i(x, h); // bottom-left
    glEnd();
    //glDisable(GL_BLEND);
  }
}


// ////////////////////////////////////////////////////////////////////////// //
__gshared uint conLastChange = 0;

static void vsetPixel (int x, int y, uint c) nothrow @trusted @nogc {
  pragma(inline, true);
  if (x >= 0 && y >= 0 && x < scrwdt && y < scrhgt) convbuf[y*scrwdt+x] = c;
}


//import iv.x11gfx : dosFont10;

void renderConsole () nothrow @trusted @nogc {
  static int conDrawX, conDrawY;
  static uint conColor;

  static void conDrawChar (char ch) nothrow @trusted @nogc {
    foreach (immutable y; 0..10) {
      ushort v = dosFont10.ptr[cast(uint)ch*10+y];
      foreach (immutable x; 0..10) {
        if (v&0x8000) vsetPixel(conDrawX+x, conDrawY+y, conColor);
        v <<= 1;
      }
    }
    conDrawX += 10;
  }

  static void conSetColor (uint c) nothrow @trusted @nogc {
    pragma(inline, true);
    conColor = (c&0x00ff00)|((c>>16)&0xff)|((c&0xff)<<16)|0xff000000;
  }

  static void conRect (int w, int h) nothrow @trusted @nogc {
    foreach (immutable y; 0..h) {
      foreach (immutable x; 0..w) {
        vsetPixel(conDrawX+x, conDrawY+y, conColor);
      }
    }
    conDrawX += 10;
  }

  // ////////////////////////////////////////////////////////////////////// //
  static void drawStar (int x0, int y0, int radius) nothrow @trusted @nogc {
    if (radius < 32) return;
    //conSetColor(color);

    static void drawLine(bool lastPoint=true) (int x0, int y0, int x1, int y1) nothrow @trusted @nogc {
      enum swap(string a, string b) = "{int tmp_="~a~";"~a~"="~b~";"~b~"=tmp_;}";

      if (x0 == x1 && y0 == y1) {
        static if (lastPoint) vsetPixel(x0, y0, conColor);
        return;
      }

      // clip rectange
      int wx0 = 0, wy0 = 0, wx1 = scrwdt-1, wy1 = scrhgt-1;
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
      // draw it; `vsetPixel()` can omit checks
      while (xd != term) {
        vsetPixel(*d0, *d1, conColor);
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

    static void drawCircle (int cx, int cy, int radius) nothrow @trusted @nogc {
      static void plot4points() (int cx, int cy, int x, int y) nothrow @trusted @nogc {
        vsetPixel(cx+x, cy+y, conColor);
        if (x != 0) vsetPixel(cx-x, cy+y, conColor);
        if (y != 0) vsetPixel(cx+x, cy-y, conColor);
        vsetPixel(cx-x, cy-y, conColor);
      }

      if (radius > 0) {
        int error = -radius, x = radius, y = 0;
        if (radius == 1) { vsetPixel(cx, cy, conColor); return; }
        while (x > y) {
          plot4points(cx, cy, x, y);
          plot4points(cx, cy, y, x);
          error += y*2+1;
          ++y;
          if (error >= 0) { --x; error -= x*2; }
        }
        plot4points(cx, cy, x, y);
      }
    }

    static auto deg2rad(T : double) (T v) pure nothrow @safe @nogc { pragma(inline, true); import std.math : PI; return v*PI/180.0; }

    drawCircle(x0, y0, radius);
    foreach (immutable n; 0..5) {
      import std.math;
      auto a0 = deg2rad(360.0/5*n+18);
      auto a1 = deg2rad(360.0/5*(n+2)+18);
      drawLine(
        cast(uint)(x0+cos(a0)*radius), cast(uint)(y0+sin(a0)*radius),
        cast(uint)(x0+cos(a1)*radius), cast(uint)(y0+sin(a1)*radius),
      );
    }
  }

  enum XOfs = 0;
  if (conLastChange == cbufLastChange) return;
  // rerender console
  conLastChange = cbufLastChange;
  int skipLines = conskiplines;
  convbuf[0..scrwdt*scrhgt] = 0xff000000;
  immutable sw = scrwdt, sh = scrhgt;
  {
    import std.algorithm : min;
    conSetColor(rConStarColor);
    int radius = min(sw, sh)/3;
    drawStar(sw/2, /*sh/2*/sh-radius-16, radius);
  }

  int y = sh-conCharHeight;
  // draw command line
  {
    conDrawX = XOfs;
    conDrawY = y;
    int curWidth = conCharWidth('W');
    int w = XOfs;
    if (rPromptChar >= ' ') {
      w += conCharWidth(rPromptChar);
      conSetColor(rConPromptColor);
      conDrawChar(rPromptChar);
    }
    uint spos = conclilen;
    while (spos > 0) {
      char ch = concli.ptr[spos-1];
      if (w+conCharWidth(ch) > sw-XOfs*2-curWidth) break;
      w += conCharWidth(ch);
      --spos;
    }
    conSetColor(rConInputColor);
    foreach (char ch; concli[spos..conclilen]) conDrawChar(ch);
    // cursor
    conSetColor(rConCursorColor);
    conRect(curWidth, conCharHeight);
    y -= conCharHeight;
  }

  // draw console text
  conSetColor(rConTextColor);
  conDrawX = XOfs;
  conDrawY = y;

  void putLine(T) (auto ref T line, usize pos=0) {
    if (y+conCharHeight <= 0 || pos >= line.length) return;
    int w = XOfs, lastWordW = -1;
    usize sp = pos, lastWordEnd = 0;
    while (sp < line.length) {
      char ch = line[sp++];
      int cw = conCharWidth(ch);
      // remember last word position
      if (/*lastWordW < 0 &&*/ (ch == ' ' || ch == '\t')) {
        lastWordEnd = sp-1; // space will be put on next line (rough indication of line wrapping)
        lastWordW = w;
      }
      if ((w += cw) > sw-XOfs*2) {
        w -= cw;
        --sp;
        // current char is non-space, and, previous char is non-space, and we have a complete word?
        if (lastWordW > 0 && ch != ' ' && ch != '\t' && sp > pos && line[sp-1] != ' ' && line[sp-1] != '\t') {
          // yes, split on last word boundary
          sp = lastWordEnd;
        }
        break;
      }
    }
    if (sp < line.length) putLine(line, sp); // recursive put tail
    // draw line
    if (skipLines-- <= 0) {
      while (pos < sp) conDrawChar(line[pos++]);
      y -= conCharHeight;
      conDrawX = XOfs;
      conDrawY = y;
    }
  }

  foreach (/*auto*/ line; conbufLinesRev) {
    putLine(line);
    if (y+conCharHeight <= 0) break;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
static if (OptGlCmdConHasSdpy) {
import arsd.simpledisplay : KeyEvent;

/// process keyboard event. returns `true` if event was eaten.
public bool conKeyEvent (KeyEvent event) {
  import arsd.simpledisplay;
  if (!rConsoleVisible) return false;
  if (!event.pressed) return true;
  if (event.key == Key.Escape) { concmd("r_console 0"); return true; }
  switch (event.key) {
    case Key.Up: concliChar(ConInputChar.Up); return true;
    case Key.Down: concliChar(ConInputChar.Down); return true;
    case Key.Left: concliChar(ConInputChar.Left); return true;
    case Key.Right: concliChar(ConInputChar.Right); return true;
    case Key.Home: concliChar(ConInputChar.Home); return true;
    case Key.End: concliChar(ConInputChar.End); return true;
    case Key.PageUp: concliChar(ConInputChar.PageUp); return true;
    case Key.PageDown: concliChar(ConInputChar.PageDown); return true;
    case Key.Backspace: concliChar(ConInputChar.Backspace); return true;
    case Key.Tab: concliChar(ConInputChar.Tab); return true;
    case Key.Enter: concliChar(ConInputChar.Enter); return true;
    case Key.Delete: concliChar(ConInputChar.Delete); return true;
    case Key.Insert: concliChar(ConInputChar.Insert); return true;
    case Key.Y: if (event.modifierState&ModifierState.ctrl) concliChar(ConInputChar.CtrlY); return true;
    default:
  }
  return true;
}


/// process character event. returns `true` if event was eaten.
public bool conCharEvent (dchar ch) {
  if (!rConsoleVisible) return false;
  if (ch >= ' ' && ch < 128) concliChar(cast(char)ch);
  return true;
}
}


// ////////////////////////////////////////////////////////////////////////// //
static private immutable ushort[256*10] dosFont10 = [
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