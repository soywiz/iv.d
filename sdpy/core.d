/*
 * Pixel Graphics Library
 * coded by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
 * Understanding is not required. Only obedience.
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
module iv.sdpy.core /*is aliced*/;

import iv.alice;
import iv.sdpy.compat;
private import iv.sdpy.gfxbuf;


// ////////////////////////////////////////////////////////////////////////// //
/// generic VideoLib exception
class VideoLibError : Exception {
  static if (__VERSION__ > 2067) {
    this (string msg, string file=__FILE__, usize line=__LINE__, Throwable next=null) @safe pure nothrow @nogc {
      super(msg, file, line, next);
    }
  } else {
    this (string msg, string file=__FILE__, usize line=__LINE__, Throwable next=null) @safe pure nothrow {
      super(msg, file, line, next);
    }
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/// output filter
enum VLFilter {
  None,
  Green,
  BlackNWhite
}


/// is videolib initialized?
enum VLInitState {
  Not, /// no
  Partial, /// not fully (i.e. `vlInit()` failed in the middle)
  Done /// completely initialized
}


// ////////////////////////////////////////////////////////////////////////// //
private shared VLInitState pvInited = VLInitState.Not;

/// is VideoLib properly initialized and videomode set?
@property VLInitState vlInitState () @trusted nothrow @nogc {
  import core.atomic : atomicLoad;
  return atomicLoad(pvInited);
}

// ////////////////////////////////////////////////////////////////////////// //
shared bool vlMag2x = true; // set to true to create double-sized window; default: true; have no effect after calling vlInit()
shared bool vlScanlines = true; // set to true to use 'scanline' filter in mag2x mode; default: true
shared VLFilter vlFilter = VLFilter.None; /// output filter; default: VLFilter.None

__gshared bool sdpyUseOpenGL = false;
__gshared bool sdpyShowFPS = true;
__gshared uint sdpyFPS = 35;
__gshared string sdpyWindowTitle = "SDPY";


// ////////////////////////////////////////////////////////////////////////// //
/// screen dimensions, should be changed prior to calling vlInit()
private shared uint vsWidth = 320;
private shared uint vsHeight = 240;

/// get current screen width
@gcc_inline @property uint vlWidth() () @trusted nothrow @nogc {
  //static if (__VERSION__ > 2067) pragma(inline, true);
  import core.atomic : atomicLoad;
  return atomicLoad(vsWidth);
}

/// get current screen height
@gcc_inline @property uint vlHeight() () @trusted nothrow @nogc {
  //static if (__VERSION__ > 2067) pragma(inline, true);
  import core.atomic : atomicLoad;
  return atomicLoad(vsHeight);
}

/// set screen width; must be used before vlInit()
@property void vlWidth (int wdt) @trusted {
  import core.atomic : atomicLoad, atomicStore;
  if (atomicLoad(pvInited) != VLInitState.Not) throw new VideoLibError("trying to change screen width after initialization");
  if (wdt < 1 || wdt > 8192) throw new VideoLibError("invalid screen width");
  atomicStore(vsWidth, wdt);
}

/// set screen height; must be used before vlInit()
@property void vlHeight (int hgt) @trusted {
  import core.atomic : atomicLoad, atomicStore;
  if (atomicLoad(pvInited) != VLInitState.Not) throw new VideoLibError("trying to change screen height after initialization");
  if (hgt < 1 || hgt > 8192) throw new VideoLibError("invalid screen height");
  atomicStore(vsHeight, hgt);
}

__gshared uint* vlVScr = null; /// current SDL 'virtual screen', ARGB format for LE
private __gshared uint* vscr2x = null; // this is used in magnifying blitters

/// build `vscr2x` if necessary, return buffer
@property uint[] vlBuildBuffer2Blit () @trusted nothrow @nogc { return vlPaintFrameDefault(); }


private __gshared int effectiveMag2x; // effective vlMag2x (1, 2)
private __gshared int prevLogSizeWas1x = 0; // DON'T change to bool!

@gcc_inline @property int vlEffectiveWidth() () nothrow @trusted @nogc {
  //static if (__VERSION__ > 2067) pragma(inline, true);
  import core.atomic : atomicLoad;
  return cast(int)atomicLoad(vsWidth)*effectiveMag2x;
}
@gcc_inline @property int vlEffectiveHeight() () nothrow @trusted @nogc {
  //static if (__VERSION__ > 2067) pragma(inline, true);
  import core.atomic : atomicLoad;
  return cast(int)atomicLoad(vsHeight)*effectiveMag2x;
}
@gcc_inline @property int vlEffectiveMag() () nothrow @trusted @nogc {
  //static if (__VERSION__ > 2067) pragma(inline, true);
  return effectiveMag2x;
}


// ////////////////////////////////////////////////////////////////////////// //
/**
 * Process CLI args from main().
 *
 * Params:
 *  args = command line arguments
 *
 * Returns:
 *  command line with processed arguments removed
 */
void vlProcessArgs (ref string[] args) @trusted nothrow {
 main_loop:
  for (uint idx = 1; idx < args.length; ++idx) {
    auto arg = args[idx];
    if (arg == "--") break;
    if (arg.length < 3 || arg[0] != '-' || arg[1] != '-') continue;
    bool yes = true;
    if (arg.length > 5 && arg[2..5] == "no-") {
      yes = false;
      arg = arg[5..$];
    } else {
      arg = arg[2..$];
    }
    switch (arg) {
      case "tv": vlScanlines = yes; break;
      case "bw": if (yes) vlFilter = VLFilter.BlackNWhite; break;
      case "green": if (yes) vlFilter = VLFilter.Green; break;
      case "1x": vlMag2x = !yes; break;
      case "2x": vlMag2x = yes; break;
      case "x11": sdpyUseOpenGL = !yes; break;
      case "ogl": sdpyUseOpenGL = yes; break;
      case "fps": sdpyShowFPS = yes; break;
      case "vhelp":
        if (yes) {
          import core.stdc.stdlib : exit;
          import core.stdc.stdio : stderr, fprintf;
          fprintf(stderr,
            "video options (add \"no-\" to negate):\n"~
            "  --tv      scanlines filter\n"
            "  --bw      black-and-white filter\n"
            "  --green   green filter\n"
            "  --1x      normal size\n"
            "  --2x      magnify\n"
            "  --x11     use X11 backend (default)\n"
            "  --ogl     use OpenGl backend\n"
            "  --fps     show FPS (default)\n"
            "  --no-fps  don't show FPS\n"
          );
          exit(0);
        }
        break;
      default: continue main_loop;
    }
    // remove option
    foreach (immutable c; idx..args.length-1) args[c] = args[c+1];
    args.length -= 1;
    --idx; // compensate for removed element
  }
}


/**
 * Initialize buffers.
 *
 * Returns:
 *  nothing
 *
 * Throws:
 *  VideoLibError on error
 */
void vlInit () @trusted {
  import core.atomic : atomicLoad, atomicStore;

  final switch (atomicLoad(pvInited)) with (VLInitState) {
    case Not: break;
    case Partial: throw new VideoLibError("can't continue initialization");
    case Done: return;
  }

  if (vsWidth < 1 || vsHeight < 1) throw new VideoLibError("sdpy: screen size is not set");

  import core.exception : onOutOfMemoryError;
  import core.stdc.stdlib : malloc, free;

  vlDeinitInternal();

  effectiveMag2x = (vlMag2x ? 2 : 1);
  prevLogSizeWas1x = 1;

  if (vlVScr !is null) free(vlVScr);
  vlVScr = cast(uint*)malloc(vsWidth*vsHeight*vlVScr[0].sizeof);
  if (vlVScr is null) onOutOfMemoryError();

  if (vscr2x !is null) free(vscr2x);
  vscr2x = cast(uint*)malloc(vsWidth*effectiveMag2x*vsHeight*effectiveMag2x*vscr2x[0].sizeof);
  if (vscr2x is null) onOutOfMemoryError();

  atomicStore(pvInited, VLInitState.Partial);
  GfxBuf.updateVScr();
  atomicStore(pvInited, VLInitState.Done);
}


/*
 * Deinitialize, free resources.
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
private void vlDeinitInternal () /*@trusted nothrow @nogc*/ {
  import core.atomic : atomicLoad, atomicStore;
  import core.stdc.stdlib : free;

  if (atomicLoad(pvInited) == VLInitState.Not) return;

  if (vlVScr !is null) { free(vlVScr); vlVScr = null; }
  if (vscr2x !is null) { free(vscr2x); vscr2x = null; }
  GfxBuf.updateVScr();

  atomicStore(pvInited, VLInitState.Not);
}


/**
 * Shutdown, free resources. You don't need to call this explicitely.
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
void vlDeinit () /*@trusted nothrow @nogc*/ {
  import core.atomic : atomicLoad;
  if (atomicLoad(pvInited) != VLInitState.Not) {
    vlDeinitInternal();
  }
}


// ////////////////////////////////////////////////////////////////////////// //
private enum buildBlit1x(string name, string op, string wrt) =
`private void `~name~` () @trusted nothrow @nogc {`~
`  auto s = cast(const(ubyte)*)vlVScr;`~
`  auto d = cast(ubyte*)vscr2x;`~
`  foreach (immutable _; 0..vsWidth*vsHeight) {`~
`    ubyte i = `~op~`;`~
`    `~wrt~`;`~
`    s += 4;`~
`    d += 4;`~
`  }`~
`}`;


mixin(buildBlit1x!("blit1xBW", "(s[0]*28+s[1]*151+s[2]*77)/256", "d[0] = d[1] = d[2] = i"));
mixin(buildBlit1x!("blit1xGreen", "(s[0]*28+s[1]*151+s[2]*77)/256", "d[0] = d[2] = 0; d[1] = i"));


private enum buildBlit2x(string name, string op) =
`private void `~name~` () @trusted nothrow @nogc {`~
`  auto s = cast(const(ubyte)*)vlVScr;`~
`  auto d = cast(uint*)vscr2x;`~
`  immutable auto wdt = vsWidth;`~
`  immutable auto wdt2x = vsWidth*2;`~
`  foreach (immutable y; 0..vsHeight) {`~
`    foreach (immutable x; 0..wdt) {`~
       op~
`      immutable uint c1 = ((((c0&0x00ff00ff)*6)>>3)&0x00ff00ff)|(((c0&0x0000ff00)*6)>>3)&0x0000ff00;`~
`      d[0] = d[1] = c0;`~
`      d[wdt2x] = d[wdt2x+1] = c1;`~
`      s += 4;`~
`      d += 2;`~
`    }`~
     // fix d: skip one scanline
`    d += wdt2x;`~
`  }`~
`}`;


mixin(buildBlit2x!("blit2xTV", "immutable uint c0 = (cast(immutable(uint)*)s)[0];"));
mixin(buildBlit2x!("blit2xTVBW", "immutable ubyte i = cast(ubyte)((s[0]*28+s[1]*151+s[2]*77)/256); immutable uint c0 = (i<<16)|(i<<8)|i;"));
mixin(buildBlit2x!("blit2xTVGreen", "immutable ubyte i = cast(ubyte)((s[0]*28+s[1]*151+s[2]*77)/256); immutable uint c0 = i<<8;"));


// ////////////////////////////////////////////////////////////////////////// //
/**
 * Paint virtual screen onto blit buffer.
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
private uint[] vlPaintFrameDefault () @trusted nothrow @nogc {
  import core.atomic : atomicLoad;
  // fix 'logical size'
  immutable flt = atomicLoad(vlFilter);
  immutable scanln = atomicLoad(vlScanlines);
  if (effectiveMag2x == 2 && scanln) {
    // mag2x and scanlines: size is 2x
    if (prevLogSizeWas1x) {
      prevLogSizeWas1x = 0;
    }
  } else {
    // any other case: size is 2x
    if (!prevLogSizeWas1x) {
      prevLogSizeWas1x = 1;
    }
  }
  // apply filters if any
  if (effectiveMag2x == 2 && scanln) {
    // heavy case: scanline filter turned on
    final switch (flt) with (VLFilter) {
      case None: blit2xTV(); break;
      case BlackNWhite: blit2xTVBW(); break;
      case Green: blit2xTVGreen(); break;
    }
    return vscr2x[0..(vsHeight*2)*(vsWidth*2)*vscr2x[0].sizeof];
  } else {
    // light cases
    if (flt == VLFilter.None) {
      // easiest case
      return vlVScr[0..vsHeight*vsWidth*vlVScr[0].sizeof];
    } else {
      import core.stdc.string : memcpy;
      final switch (flt) with (VLFilter) {
        case None: memcpy(vscr2x, vlVScr, vsWidth*vsHeight*vlVScr[0].sizeof); break; // just in case
        case BlackNWhite: blit1xBW(); break;
        case Green: blit1xGreen(); break;
      }
      return vscr2x[0..vsHeight*vsWidth*vscr2x[0].sizeof];
    }
  }
}


// ////////////////////////////////////////////////////////////////////////// //
shared static ~this () {
  vlDeinit();
}
