/* Invisible Vector Library
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
// severely outdated! do not use!
module iv.videolib /*is aliced*/;

version(videolib_opengl) {} else { version = videolib_sdl; }

//public import iv.gccattrs;

import iv.alice;
import std.traits;


public import iv.sdl2.sdl;
version(videolib_opengl) import iv.opengl.gl;

private import core.sys.posix.time;
// idiotic phobos forgets 'nothrow' at it
extern(C) private int clock_gettime (clockid_t, timespec*) @trusted nothrow @nogc;


// ////////////////////////////////////////////////////////////////////////// //
/// generic VideoLib exception
class VideoLibError : Exception {
  this (string msg, string file=__FILE__, usize line=__LINE__, Throwable next=null) @safe pure nothrow =>
    super(msg, file, line, next);
}


/// output filter
enum VideoFilter {
  None,
  Green,
  BlackNWhite
}

private shared bool pvInited = false; // vill be set to 'true' if initVideo() initializes at least something
private shared bool pvInitedOk = false; // vill be set to 'true' if initVideo() initializes everything

/// is VideoLib properly initialized and videomode set?
@property bool isInited () @trusted nothrow @nogc {
  import core.atomic : atomicLoad;
  return atomicLoad(pvInitedOk);
}

shared bool useFullscreen = false; /// use fullscreen mode? this can be set to true before calling initVideo()
shared bool useOpenGL = false; /// allow OpenGL? this can be set to true before calling initVideo()
shared bool noDefaultOpenGLContext = false; /// don't create OpenGL context for useOpenGL?
shared bool useVSync = false; /// wait VBL? this can be set to true before calling initVideo()
shared bool useRealFullscreen = false; /// use 'real' fullscreen? defaul: false

shared bool useMag2x = true; // set to true to create double-sized window; default: true; have no effect after calling initVideo()
shared bool useScanlines = true; // set to true to use 'scanline' filter in mag2x mode; default: true
shared VideoFilter useFilter = VideoFilter.None; /// output filter; default: VideoFilter.None

__gshared SDL_Window* sdlWindow = null; /// current SDL window; DON'T CHANGE THIS!

alias PaintHookType = void function () @trusted;
__gshared PaintHookType paintHook = null; /// set this to override standard paintFrame()
//shared static this () => paintHook = &paintFrameDefault;

version(videolib_sdl) {
  private __gshared SDL_Renderer* sdlRenderer = null; // current SDL rendering context
  private __gshared SDL_Texture* sdlScreen = null; // current SDL screen
}
version(videolib_opengl) {
  private __gshared SDL_GLContext sdlGLCtx = null;
}

private shared bool sdlFrameChangedFlag = false; // this will be set to false by paintFrame()

/// call this if you want VideoLib to call rebuild callback
void frameChanged () @trusted nothrow @nogc {
  import core.atomic : atomicStore;
  atomicStore(sdlFrameChangedFlag, true);
}

@property bool isFrameChanged () @trusted nothrow @nogc {
  import core.atomic : atomicLoad;
  return atomicLoad(sdlFrameChangedFlag);
}

/// screen dimensions, should be changed prior to calling initVideo()
private shared int vsWidth = 320;
private shared int vsHeight = 240;

/*@gcc_inline*/ @property int vlWidth() () @trusted nothrow @nogc => vsWidth; /// get current screen width
/*@gcc_inline*/ @property int vlHeight() () @trusted nothrow @nogc => vsHeight; /// get current screen height

/// set screen width; must be used before initVideo()
@property void vlWidth (int wdt) @trusted {
  import core.atomic : atomicLoad, atomicStore;
  if (atomicLoad(pvInited)) throw new VideoLibError("trying to change screen width after initialization");
  if (wdt < 1 || wdt > 8192) throw new VideoLibError("invalid screen width");
  atomicStore(vsWidth, wdt);
}

/// set screen height; must be used before initVideo()
@property void vlHeight (int hgt) @trusted {
  import core.atomic : atomicLoad, atomicStore;
  if (atomicLoad(pvInited)) throw new VideoLibError("trying to change screen height after initialization");
  if (hgt < 1 || hgt > 8192) throw new VideoLibError("invalid screen height");
  atomicStore(vsHeight, hgt);
}

private __gshared int effectiveMag2x; // effective useMag2x
private __gshared SDL_Texture* sdlScr2x = null;
private __gshared int prevLogSizeWas1x = 0; // DON'T change to bool!

__gshared uint* vscr = null; /// current SDL 'virtual screen', ARGB format for LE
private __gshared uint* vscr2x = null; // this is used in magnifying blitters
private __gshared VLOverlay ovlVScr = null;

/*@gcc_inline*/ VLOverlay vscrOvl() () @trusted nothrow @nogc => ovlVScr;


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
void processArgs (ref string[] args) @trusted nothrow {
  for (auto f = 1; f < args.length; ++f) {
    auto arg = args[f];
    if (arg == "--") break;
    else if (arg == "--fs") useFullscreen = true;
    else if (arg == "--win") useFullscreen = false;
    else if (arg == "--realfs") useRealFullscreen = true;
    else if (arg == "--winfs") useRealFullscreen = false;
    else if (arg == "--tv") useScanlines = true;
    else if (arg == "--notv") useScanlines = false;
    else if (arg == "--bw") useFilter = VideoFilter.BlackNWhite;
    else if (arg == "--green") useFilter = VideoFilter.Green;
    else if (arg == "--1x") useMag2x = false;
    else if (arg == "--2x") useMag2x = true;
    else if (arg == "--vbl") useVSync = true;
    else if (arg == "--novbl") useVSync = false;
    else continue;
    foreach (auto c; f+1..args.length) args[c-1] = args[c];
    args.length = args.length-1;
    --f; // compensate for removed element
  }
}


private void sdlPrintError () @trusted nothrow @nogc {
  import core.stdc.stdio : stderr, fprintf;
  auto sdlError = SDL_GetError();
  fprintf(stderr, "SDL ERROR: %s\n", sdlError);
}


private void sdlError (bool raise) @trusted {
  if (raise) {
    sdlPrintError();
    throw new VideoLibError("SDL fucked");
  }
}


/**
 * Initialize SDL, create drawing window and buffers, init other shit.
 *
 * Params:
 *  windowName = window caption
 *
 * Returns:
 *  nothing
 *
 * Throws:
 *  VideoLibError on error
 */
void initVideo (string windowName=null) @trusted {
  if (!pvInitedOk) {
    import core.exception : onOutOfMemoryError;
    import core.stdc.stdlib : malloc, free;
    import std.string : toStringz;

    deinitInternal();
    if (windowName is null) windowName = "SDL Application";
    version(videolib_opengl) {
      enum uint winflags = SDL_WINDOW_OPENGL;
      //enforce(glClear !is null);
      //enforce(glPixelZoom !is null);
      //enforce(glDrawPixels !is null);
    } else {
      enum uint winflags = 0;
    }

    effectiveMag2x = (useMag2x ? 2 : 1);
    prevLogSizeWas1x = 1;

    if (ovlVScr !is null) ovlVScr.mVScr = null;

    if (vscr !is null) free(vscr);
    vscr = cast(uint*)malloc(vsWidth*vsHeight*vscr[0].sizeof);
    if (vscr is null) onOutOfMemoryError();

    if (vscr2x !is null) free(vscr2x);
    vscr2x = cast(uint*)malloc(vsWidth*effectiveMag2x*vsHeight*effectiveMag2x*vscr2x[0].sizeof);
    if (vscr2x is null) onOutOfMemoryError();

    if (ovlVScr is null) {
      ovlVScr = new VLOverlay(vscr, vsWidth, vsHeight);
    } else {
      ovlVScr.mVScr = vscr;
      ovlVScr.mWidth = vsWidth;
      ovlVScr.mHeight = vsHeight;
    }
    ovlVScr.resetClipOfs();

    SDL_Init(SDL_INIT_VIDEO|SDL_INIT_EVENTS|SDL_INIT_TIMER);
    pvInited = true;
    version(videolib_opengl) {
      SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 1);
      SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);
      //SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    }
    sdlWindow = SDL_CreateWindow(windowName.toStringz, SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, vsWidth*effectiveMag2x, vsHeight*effectiveMag2x,
      winflags|(useFullscreen ? (useRealFullscreen ? SDL_WINDOW_FULLSCREEN : SDL_WINDOW_FULLSCREEN_DESKTOP) : 0)|(useOpenGL ? SDL_WINDOW_OPENGL : 0));
    sdlError(!sdlWindow);
    version(videolib_opengl) {
      if (!noDefaultOpenGLContext) sdlGLCtx = SDL_GL_CreateContext(sdlWindow);
      SDL_GL_SetSwapInterval(useVSync ? 1: 0);
    } else {
      sdlRenderer = SDL_CreateRenderer(sdlWindow, -1, (useVSync ? SDL_RENDERER_PRESENTVSYNC : 0));
      sdlError(!sdlRenderer);
      SDL_SetHint(SDL_HINT_RENDER_SCALE_QUALITY, "nearest"); // "nearest" or "linear"
      SDL_RenderSetLogicalSize(sdlRenderer, vsWidth*(2-prevLogSizeWas1x), vsHeight*(2-prevLogSizeWas1x));
      sdlScreen = SDL_CreateTexture(sdlRenderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, vsWidth, vsHeight);
      sdlError(!sdlScreen);
      if (effectiveMag2x == 2) {
        sdlScr2x = SDL_CreateTexture(sdlRenderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, vsWidth*2, vsHeight*2);
        sdlError(!sdlScr2x);
      } else {
        sdlScr2x = null;
      }
    }
    pvInitedOk = true;
  }
}


/*
 * Deinitialize SDL, free resources.
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
private void deinitInternal () @trusted nothrow @nogc {
  if (pvInited) {
    import core.stdc.stdlib : free;
    pvInited = false;
    if (vscr !is null) free(vscr);
    if (vscr2x !is null) free(vscr2x);
    vscr = null;
    vscr2x = null;
    if (ovlVScr !is null) {
      ovlVScr.mVScr = null;
      ovlVScr.resetClipOfs();
    }
    version(videolib_opengl) {
      if (sdlGLCtx !is null) {
        SDL_GL_DeleteContext(sdlGLCtx);
        sdlGLCtx = null;
      }
    } else {
      if (sdlScreen) SDL_DestroyTexture(sdlScreen);
      if (sdlScr2x) SDL_DestroyTexture(sdlScr2x);
      if (sdlRenderer) SDL_DestroyRenderer(sdlRenderer);
      sdlScreen = null;
      sdlScr2x = null;
      sdlRenderer = null;
    }
    if (sdlWindow) {
      SDL_DestroyWindow(sdlWindow);
      sdlWindow = null;
    }
    pvInited = pvInitedOk = false;
  }
}


/**
 * Shutdown SDL, free resources. You don't need to call this explicitely.
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
void deinitVideo () @trusted nothrow @nogc {
  if (pvInited) {
    deinitInternal();
    SDL_Quit();
  }
}


/**
 * Switches between fullscreen and windowed modes.
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
void switchFullscreen () @trusted nothrow {
  useFullscreen = !useFullscreen;
  if (SDL_SetWindowFullscreen(sdlWindow, (useFullscreen ? (useRealFullscreen ? SDL_WINDOW_FULLSCREEN : SDL_WINDOW_FULLSCREEN_DESKTOP) : 0)) != 0) {
    sdlPrintError();
    useFullscreen = !useFullscreen;
    return;
  }
  if (!useFullscreen) {
    SDL_SetWindowSize(sdlWindow, vsWidth*effectiveMag2x, vsHeight*effectiveMag2x);
    SDL_SetWindowPosition(sdlWindow, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED);
  }
}


/**
 * Post SDL_QUIT message. Can be called to initiate clean exit from main loop.
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
void postQuitMessage () @trusted nothrow @nogc {
  import core.stdc.string : memset;
  SDL_Event evt;
  memset(&evt, 0, evt.sizeof);
  evt.type = SDL_QUIT;
  SDL_PushEvent(&evt);
}


// ////////////////////////////////////////////////////////////////////////// //
/*@gcc_inline*/ ubyte clampToByte() (int n) @safe pure nothrow @nogc {
  n &= -cast(int)(n >= 0);
  return cast(ubyte)(n|((255-n)>>31));
}


alias Color = uint;

version(LittleEndian) {
  /// RGBA struct to ease color components extraction/replacing
  align(1) struct RGBA {
  align(1):
    ubyte b, g, r, a;
  }
} else version(BigEndian) {
  /// RGBA struct to ease color components extraction/replacing
  align(1) struct RGBA {
  align(1):
    ubyte a, r, g, b;
  }
} else {
  static assert(0, "WTF?!");
}

static assert(RGBA.sizeof == Color.sizeof);


enum : Color {
  AMask = 0xff000000u,
  RMask = 0x00ff0000u,
  GMask = 0x0000ff00u,
  BMask = 0x000000ffu
}

enum : Color {
  AShift = 24,
  RShift = 16,
  GShift = 8,
  BShift = 0
}


enum Color Transparent = AMask; /// completely transparent pixel color


/**
 * Is color completely transparent?
 *
 * Params:
 *  col = rgba color
 *
 * Returns:
 *  'transparent' flag
 */
/*@gcc_inline*/ bool isTransparent(T : Color) (T col) @safe pure nothrow @nogc => ((col&AMask) == AMask);


/**
 * Is color completely non-transparent?
 *
 * Params:
 *  col = rgba color
 *
 * Returns:
 *  'transparent' flag
 */
/*@gcc_inline*/ bool isOpaque(T : Color) (T col) @safe pure nothrow @nogc => ((col&AMask) == 0);


/**
 * Build opaque non-transparent rgb color from components.
 *
 * Params:
 *  r = red component [0..255]
 *  g = green component [0..255]
 *  b = blue component [0..255]
 *
 * Returns:
 *  rgba color
 */
/*@gcc_inline*/ Color rgb2col(TR, TG, TB) (TR r, TG g, TB b) @safe pure nothrow @nogc
if (__traits(isIntegral, TR) && __traits(isIntegral, TG) && __traits(isIntegral, TB)) =>
  ((r&0xff)<<RShift)|((g&0xff)<<GShift)|((b&0xff)<<BShift);

/**
 * Build rgba color from components.
 *
 * Params:
 *  r = red component [0..255]
 *  g = green component [0..255]
 *  b = blue component [0..255]
 *  a = transparency [0..255] (0: completely opaque; 255: completely transparent)
 *
 * Returns:
 *  rgba color
 */
/*@gcc_inline*/ Color rgba2col(TR, TG, TB, TA) (TR r, TG g, TB b, TA a) @safe pure nothrow @nogc
if (__traits(isIntegral, TR) && __traits(isIntegral, TG) && __traits(isIntegral, TB) && __traits(isIntegral, TA)) =>
  ((a&0xff)<<AShift)|((r&0xff)<<RShift)|((g&0xff)<<GShift)|((b&0xff)<<BShift);

// generate some templates
private enum genRGBGetSet(string cname) =
  `/*@gcc_inline*/ ubyte rgb`~cname~`() (Color clr) @safe pure nothrow @nogc => ((clr>>`~cname[0]~`Shift)&0xff);`~
  `/*@gcc_inline*/ Color rgbSet`~cname~`(T) (Color clr, T v) @safe pure nothrow @nogc if (__traits(isIntegral, T)) =>`~
    `(clr&~`~cname[0]~`Mask)|((v&0xff)<<`~cname[0]~`Shift);`;

mixin(genRGBGetSet!"Alpha");
mixin(genRGBGetSet!"Red");
mixin(genRGBGetSet!"Green");
mixin(genRGBGetSet!"Blue");


// ////////////////////////////////////////////////////////////////////////// //
/+
/**
 * Blit rectangle to virtual screen. Does clipping. Ignores alpha.
 *
 * Params:
 *  x = destination x coordinate
 *  y = destination y coordinate
 *  rx = source x coordinate
 *  ry = source y coordinate
 *  rw = source width
 *  rh = source height
 *  data = pixel data
 *  dw = data width
 *  dh = data height
 *
 * Returns:
 *  nothing
 */
void blitRect (int x, int y, int rx, int ry, int rw, int rh, const(Color)[] data, usize dw, usize dh) {
  if (rw < 1 || rh < 1 || dw < 1 || dh < 1) return;
  if (x >= vsWidth || y >= vsHeight) return;
  // clip rx and ry left and top
  if (rx < 0) {
    if ((rw += rx) <= 0) return;
    rx = 0;
  }
  if (ry < 0) {
    if ((rh += ry) <= 0) return;
    ry = 0;
  }
  if (rx >= dw || ry >= dh) return;
  if (rw > dw) rw = dw;
  if (rh > dh) rh = dh;
  // now clip x and y
  if (x < 0) {
}
+/


// ////////////////////////////////////////////////////////////////////////// //
private enum buildBlit1x(string name, string op, string wrt) =
`private void `~name~` () @trusted nothrow @nogc {`~
`  auto s = cast(immutable(ubyte)*)vscr;`~
`  auto d = cast(ubyte*)vscr2x;`~
`  foreach (; 0..vsWidth*vsHeight) {`~
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
`  auto s = cast(immutable(ubyte)*)vscr;`~
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
 * Paint frame contents. Using paintHook()
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
void paintFrame () @trusted {
  if (paintHook !is null) {
    paintHook();
  } else {
    paintFrameDefault();
  }
  import core.atomic : atomicStore;
  atomicStore(sdlFrameChangedFlag, false);
}


/**
 * Paint virtual screen onto real screen or window.
 *
 * Params:
 *  none
 *
 * Returns:
 *  nothing
 */
void paintFrameDefault () @trusted {
  version(videolib_sdl) {
    // SDL
    // fix 'logical size'
    if (effectiveMag2x == 2 && useScanlines) {
      // mag2x and scanlines: size is 2x
      if (prevLogSizeWas1x) {
        prevLogSizeWas1x = 0;
        SDL_RenderSetLogicalSize(sdlRenderer, vsWidth*2, vsHeight*2);
      }
    } else {
      // any other case: size is 2x
      if (!prevLogSizeWas1x) {
        prevLogSizeWas1x = 1;
        SDL_RenderSetLogicalSize(sdlRenderer, vsWidth, vsHeight);
      }
    }
    // apply filters if any
    if (effectiveMag2x == 2 && useScanlines) {
      // heavy case: scanline filter turned on
      final switch (useFilter) {
        case VideoFilter.None: blit2xTV(); break;
        case VideoFilter.BlackNWhite: blit2xTVBW(); break;
        case VideoFilter.Green: blit2xTVGreen(); break;
      }
      SDL_UpdateTexture(sdlScr2x, null, vscr2x, cast(uint)(vsWidth*2*vscr2x[0].sizeof));
      SDL_RenderCopy(sdlRenderer, sdlScr2x, null, null);
    } else {
      // light cases
      if (useFilter == VideoFilter.None) {
        // easiest case
        SDL_UpdateTexture(sdlScreen, null, vscr, cast(uint)(vsWidth*vscr[0].sizeof));
      } else {
        import core.stdc.string : memcpy;
        final switch (useFilter) {
          case VideoFilter.None: memcpy(vscr2x, vscr, vsWidth*vsHeight*vscr[0].sizeof); break; // just in case
          case VideoFilter.BlackNWhite: blit1xBW(); break;
          case VideoFilter.Green: blit1xGreen(); break;
        }
        SDL_UpdateTexture(sdlScreen, null, vscr2x, cast(uint)(vsWidth*vscr2x[0].sizeof));
      }
      SDL_RenderCopy(sdlRenderer, sdlScreen, null, null);
    }
    SDL_RenderPresent(sdlRenderer);
  } else {
    // OpenGL
    glClear(GL_COLOR_BUFFER_BIT);
    glTranslatef(0, vsHeight, 0);
    // apply filters if any
    if (effectiveMag2x == 2 && useScanlines) {
      // heavy case: scanline filter turned on
      glPixelZoom(1.0f, 1.0f); // scale
      final switch (useFilter) {
        case VideoFilter.None: blit2xTV(); break;
        case VideoFilter.BlackNWhite: blit2xTVBW(); break;
        case VideoFilter.Green: blit2xTVGreen(); break;
      }
      glDrawPixels(vsWidth*2, vsHeight*2, GL_BGRA, GL_UNSIGNED_BYTE, vscr);
    } else {
      // light cases
      // scale
      glPixelZoom(effectiveMag2x, effectiveMag2x);
      if (useFilter == VideoFilter.None) {
        // easiest case
        glDrawPixels(vsWidth, vsHeight, GL_BGRA, GL_UNSIGNED_BYTE, vscr);
      } else {
        import core.stdc.string : memcpy;
        final switch (useFilter) {
          case VideoFilter.None: memcpy(vscr2x, vscr, vsWidth*vsHeight*vscr[0].sizeof); break; // just in case
          case VideoFilter.BlackNWhite: blit1xBW(); break;
          case VideoFilter.Green: blit1xGreen(); break;
        }
        glDrawPixels(vsWidth, vsHeight, GL_BGRA, GL_UNSIGNED_BYTE, vscr2x);
      }
    }
    SDL_GL_SwapWindow(sdlWindow);
  }
}


// ////////////////////////////////////////////////////////////////////////// //
version(GNU) {
  private import core.sys.posix.time : CLOCK_MONOTONIC_RAW;
} else {
  private import core.sys.linux.time : CLOCK_MONOTONIC_RAW;
}

private __gshared int vl_k8clock_initialized = 0;
private __gshared timespec videolib_clock_stt;


private void initializeClock () @trusted nothrow @nogc {
  timespec cres;
  vl_k8clock_initialized = -1;
  if (clock_getres(CLOCK_MONOTONIC_RAW, &cres) != 0) {
    //fprintf(stderr, "ERROR: can't get clock resolution!\n");
    return;
  }
  //fprintf(stderr, "CLOCK_MONOTONIC: %ld:%ld\n", cres.tv_sec, cres.tv_nsec);
  if (cres.tv_sec > 0 || cres.tv_nsec > cast(long)1000000*10 /*10 ms*/) {
    //fprintf(stderr, "ERROR: real-time clock resolution is too low!\n");
    return;
  }
  if (clock_gettime(CLOCK_MONOTONIC_RAW, &videolib_clock_stt) != 0) {
    //fprintf(stderr, "ERROR: real-time clock initialization failed!\n");
    return;
  }
  vl_k8clock_initialized = 1;
}


/** returns monitonically increasing time; starting value is UNDEFINED (i.e. can be any number)
 * milliseconds; (0: no timer available) */
ulong getTicks () @trusted nothrow @nogc {
  if (vl_k8clock_initialized > 0) {
    timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC_RAW, &ts) != 0) {
      //fprintf(stderr, "ERROR: can't get real-time clock value!\n");
      return 0;
    }
    // ah, ignore nanoseconds in videolib_clock_stt->stt here: we need only 'differential' time, and it can start with something weird
    return (cast(ulong)(ts.tv_sec-videolib_clock_stt.tv_sec))*1000+ts.tv_nsec/1000000+1;
  }
  return 0;
}


/** returns monitonically increasing time; starting value is UNDEFINED (i.e. can be any number)
 * microseconds; (0: no timer available) */
ulong ticksMicro () @trusted nothrow @nogc {
  if (vl_k8clock_initialized > 0) {
    timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC_RAW, &ts) != 0) {
      //fprintf(stderr, "ERROR: can't get real-time clock value!\n");
      return 0;
    }
    // ah, ignore nanoseconds in videolib_clock_stt->stt here: we need only 'differential' time, and it can start with something weird
    return (cast(ulong)(ts.tv_sec-videolib_clock_stt.tv_sec))*1000000+ts.tv_nsec/1000+1;
  }
  return 0;
}


// ////////////////////////////////////////////////////////////////////////// //
// main loop

enum SDL_MOUSEDOUBLE = SDL_USEREVENT+1; /// same as SDL_MouseButtonEvent
enum SDL_FREEEVENT = SDL_USEREVENT+42; /// first event available for user


// ////////////////////////////////////////////////////////////////////////// //
/* return >0 if event was eaten by handler; <0 to exit loop and 0 to go on */
/* this is hooks for vlwidgets */
__gshared int function (ref SDL_Event ev) preprocessEventsHook = null; //DO NOT USE! WILL BE DEPRECATED!


/**
 * mechanics is like this:
 * when it's time to show new frame, videolib will call onUpdateCB().
 * if frameChanged is set (either from previous frame, or by onUpdateCB(),
 * videolib will call onRebuildCB() and paintFrame().
 * note that videolib will reset frameChanged after onRebuildCB() called.
 * also note that if onUpdateCB() or onRebuildCB() will not set frameChanged,
 * frame visuals will not be updated properly.
 * you can either update and onRebuildCB screen in onUpdateCB(), or update state in
 * onUpdateCB() and rebuild virtual screen in onRebuildCB().
 * you can count on videolib never changes virtual screen contents by itself.
 */
/** elapsedTicks: ms elapsed from the last call; will try to keep up with FPS; 0: first call in mainLoop()
 * can call frameChanged() flag so mainLoop() will call onRebuildCB() or call onRebuildCB() itself */
private {
  __gshared void delegate (int elapsedTicks) onUpdateCB = null;
  __gshared void delegate () onRebuildCB = null;

  __gshared void delegate (in ref SDL_KeyboardEvent ev) onKeyDownCB = null;
  __gshared void delegate (in ref SDL_KeyboardEvent ev) onKeyUpCB = null;
  __gshared void delegate (dchar ch) onTextInputCB = null;

  __gshared void delegate (in ref SDL_MouseButtonEvent ev) onMouseDownCB = null;
  __gshared void delegate (in ref SDL_MouseButtonEvent ev) onMouseUpCB = null;
  __gshared void delegate (in ref SDL_MouseButtonEvent ev) onMouseDoubleCB = null; /// mouse double-click
  __gshared void delegate (in ref SDL_MouseMotionEvent ev) onMouseMotionCB = null;
  __gshared void delegate (in ref SDL_MouseWheelEvent ev) onMouseWheelCB = null;
}


@trusted nothrow @nogc {
  private import std.functional : toDelegate;
  @property void onUpdate (void function (int elapsedTicks) cb) => onUpdateCB = toDelegate(cb);
  @property void onRebuild (void function () cb) => onRebuildCB = toDelegate(cb);
  @property void onKeyDown (void function (in ref SDL_KeyboardEvent ev) cb) => onKeyDownCB = toDelegate(cb);
  @property void onKeyUp (void function (in ref SDL_KeyboardEvent ev) cb) => onKeyUpCB = toDelegate(cb);
  @property void onTextInput (void function (dchar ch) cb) => onTextInputCB = toDelegate(cb);
  @property void onMouseDown (void function (in ref SDL_MouseButtonEvent ev) cb) => onMouseDownCB = toDelegate(cb);
  @property void onMouseUp (void function (in ref SDL_MouseButtonEvent ev) cb) => onMouseUpCB = toDelegate(cb);
  @property void onMouseDouble (void function (in ref SDL_MouseButtonEvent ev) cb) => onMouseDoubleCB = toDelegate(cb);
  @property void onMouseMotion (void function (in ref SDL_MouseMotionEvent ev) cb) => onMouseMotionCB = toDelegate(cb);
  @property void onMouseWheel (void function (in ref SDL_MouseWheelEvent ev) cb) => onMouseWheelCB = toDelegate(cb);

  @property void onUpdate (void delegate (int elapsedTicks) cb) => onUpdateCB = cb;
  @property void onRebuild (void delegate () cb) => onRebuildCB = cb;
  @property void onKeyDown (void delegate (in ref SDL_KeyboardEvent ev) cb) => onKeyDownCB = cb;
  @property void onKeyUp (void delegate (in ref SDL_KeyboardEvent ev) cb) => onKeyUpCB = cb;
  @property void onTextInput (void delegate (dchar ch) cb) => onTextInputCB = cb;
  @property void onMouseDown (void delegate (in ref SDL_MouseButtonEvent ev) cb) => onMouseDownCB = cb;
  @property void onMouseUp (void delegate (in ref SDL_MouseButtonEvent ev) cb) => onMouseUpCB = cb;
  @property void onMouseDouble (void delegate (in ref SDL_MouseButtonEvent ev) cb) => onMouseDoubleCB = cb;
  @property void onMouseMotion (void delegate (in ref SDL_MouseMotionEvent ev) cb) => onMouseMotionCB = cb;
  @property void onMouseWheel (void delegate (in ref SDL_MouseWheelEvent ev) cb) => onMouseWheelCB = cb;

  @property auto onUpdate () => onUpdateCB;
  @property auto onRebuild () => onRebuildCB;
  @property auto onKeyDown () => onKeyDownCB;
  @property auto onKeyUp () => onKeyUpCB;
  @property auto onTextInput () => onTextInputCB;
  @property auto onMouseDown () => onMouseDownCB;
  @property auto onMouseUp () => onMouseUpCB;
  @property auto onMouseDouble () => onMouseDoubleCB;
  @property auto onMouseMotion () => onMouseMotionCB;
  @property auto onMouseWheel () => onMouseWheelCB;
}

/// start receiving text input events
void startTextInput() () => SDL_StartTextInput();

/// stop receiving text input events
void stopTextInput() () => SDL_StopTextInput();


/* doubleclick processing */
// for 3 buttons (SDL_BUTTON_XXX-1)
// left: 0
// middle: 1
// right: 2
private ulong[3] mdbClickTick; // autoinit to 0
private int[3] mdbClickX, mdbClickY; // autoinit to 0
private int[3] mdbSkipUp; // 1: there was one click; 2: skip next 'mouse up' event for this button
int mdbThreshold = 2; /// double-click threshold
uint mdbTime = 500; /// default double-click time, milliseconds (ticks)


// returns true: forget this event
private bool mdbProcess (in ref SDL_Event ev) @trusted nothrow @nogc {
  if (ev.type == SDL_MOUSEBUTTONDOWN || ev.type == SDL_MOUSEBUTTONUP) {
    immutable int idx = ev.button.button-1;
    if (idx < 0 || idx > 2) return false; // we don't know about other buttons
    if (ev.type == SDL_MOUSEBUTTONDOWN) {
      // button pressed
      if (mdbSkipUp[idx] == 0) {
        // first click
        mdbClickTick[idx] = getTicks();
        mdbClickX[idx] = ev.button.x;
        mdbClickY[idx] = ev.button.y;
        mdbSkipUp[idx] = 1;
      } else if (mdbSkipUp[idx] == 1) {
        import std.math : abs;
        // second click, check for double
        ulong now = getTicks();
        mdbSkipUp[idx] = 0;
        if (now >= mdbClickTick[idx] && now-mdbClickTick[idx] <= mdbTime) {
          mdbClickTick[idx] = 0;
          if (abs(mdbClickX[idx]-ev.button.x) <= mdbThreshold && abs(mdbClickY[idx]-ev.button.y) <= mdbThreshold) {
            // got one!
            SDL_Event event = ev;
            event.type = SDL_MOUSEDOUBLE;
            event.button.state = SDL_PRESSED;
            SDL_PushEvent(&event);
            mdbSkipUp[idx] = 2;
            return true; // fuck this event
          }
        } else {
          mdbClickTick[idx] = now;
          mdbClickX[idx] = ev.button.x;
          mdbClickY[idx] = ev.button.y;
          mdbSkipUp[idx] = 1;
        }
      } else {
        mdbClickTick[idx] = 0;
        mdbSkipUp[idx] = 0;
      }
    } else {
      // button released
      if (mdbSkipUp[idx] >= 2) {
        // this is 'up' event from generated doubleclick, fuck it
        mdbSkipUp[idx] = 0;
        return true;
      }
    }
  }
  return false;
}


/** returns !0 to stop event loop; <0: from event preprocessor; >0: from SDL_QUIT */
int processEvent (ref SDL_Event ev) {
  if (useMag2x) {
    if (ev.type == SDL_MOUSEBUTTONDOWN || ev.type == SDL_MOUSEBUTTONUP) {
      ev.button.x /= 2;
      ev.button.y /= 2;
    } else if (ev.type == SDL_MOUSEMOTION) {
      ev.motion.x /= 2;
      ev.motion.y /= 2;
    }
  }
  if (mdbProcess(ev)) return 0; // process doubleclicks
  if (preprocessEventsHook !is null) {
    int res = preprocessEventsHook(ev);
    if (res < 0) return -1;
    if (res > 0) return 0;
  }
  if (ev.type == SDL_QUIT) return 1;
  switch (ev.type) {
    case SDL_KEYDOWN: if (onKeyDownCB !is null) onKeyDownCB(ev.key); break;
    case SDL_KEYUP: if (onKeyUpCB !is null) onKeyUpCB(ev.key); break;
    case SDL_MOUSEBUTTONDOWN: if (onMouseDownCB !is null) onMouseDownCB(ev.button); break;
    case SDL_MOUSEBUTTONUP: if (onMouseUpCB !is null) onMouseUpCB(ev.button); break;
    case SDL_MOUSEDOUBLE: if (onMouseDoubleCB !is null) onMouseDoubleCB(ev.button); break;
    case SDL_MOUSEMOTION: if (onMouseMotionCB !is null) onMouseMotionCB(ev.motion); break;
    case SDL_MOUSEWHEEL: if (onMouseWheelCB !is null) onMouseWheelCB(ev.wheel); break;
    case SDL_TEXTINPUT:
      if (onTextInputCB !is null) {
        //TODO: UTF-8 decode!
        if (ev.text.text[0] && ev.text.text[0] < 127) {
          onTextInputCB(ev.text.text[0]);
        }
      }
      break;
    case SDL_USEREVENT:
      //TODO: forward other user events
      //(ev.user.code)
      break;
    case SDL_WINDOWEVENT:
      switch (ev.window.event) {
        case SDL_WINDOWEVENT_EXPOSED:
          frameChanged(); // this will force repaint
          break;
        default:
      }
      break;
    default:
  }
  return 0;
}


private __gshared int curFPS = 35; /// desired FPS (default: 35)
private __gshared ulong lastUpdateCall = 0;
private __gshared ulong nextUpdateCall = 0;
private __gshared int msecsInFrame = 1000/35;

@property int currentFPS () @trusted nothrow @nogc => curFPS; /// return current FPS
@property int msecsPerFrame () @trusted nothrow @nogc => msecsInFrame; /// return number of milliseconds in frame


/// set desired FPS
void setFPS (int newfps) @trusted nothrow @nogc {
  if (newfps < 1) newfps = 1;
  if (newfps > 500) newfps = 500;
  msecsInFrame = 1000/newfps;
  if (msecsInFrame == 0) msecsInFrame = 1;
  curFPS = newfps;
}


/// update and rebuild frame if necessary
/// will not paint frame to screen
void sdlCheckFrameUpdate () {
  auto tm = getTicks();
  if (tm >= nextUpdateCall) {
    if (onUpdateCB !is null) onUpdateCB(cast(int)(tm-lastUpdateCall));
    lastUpdateCall = tm;//getTicks();
    while (tm >= nextUpdateCall) {
      // do something with skipped frames
      nextUpdateCall += msecsInFrame;
    }
  }
  import core.atomic : cas;
  bool cf = cas(&sdlFrameChangedFlag, true, false); // cf is true if sdlFrameChangedFlag was true
  if (cf) {
    frameChanged();
    if (onRebuildCB !is null) onRebuildCB();
  }
}


/** will start and stop FPS timer automatically */
void mainLoop () {
  bool doQuit = false;
  SDL_Event ev;
  lastUpdateCall = getTicks();
  nextUpdateCall = lastUpdateCall+msecsInFrame;
  if (onUpdateCB !is null) onUpdateCB(0);
  if (onRebuildCB !is null) onRebuildCB();
  paintFrame();
  while (!doQuit) {
    if (!SDL_PollEvent(null)) {
      // no events, see if we have to wait for the next frame
      auto now = getTicks();
      if (now < nextUpdateCall) {
        // have some time to waste
        int n = cast(int)(nextUpdateCall-now);
        if (!SDL_WaitEventTimeout(null, n)) goto noevent;
      }
    }
    while (SDL_PollEvent(&ev)) {
      if (processEvent(ev)) { doQuit = true; break; }
    }
    if (doQuit) break;
noevent:
    sdlCheckFrameUpdate();
    if (isFrameChanged) paintFrame(); // this will reset sdlFrameChangedFlag again
  }
}


// ////////////////////////////////////////////////////////////////////////// //
class VLOverlay {
private:
  int mWidth, mHeight;
  int mClipX0, mClipY0;
  int mClipX1, mClipY1;
  int mXOfs, mYOfs;
  uint* mVScr;
  bool dontFree = false;

private:
  this (void* avscr, int wdt, int hgt) @trusted nothrow @nogc {
    mVScr = cast(uint*)avscr;
    dontFree = true;
    mWidth = wdt;
    mHeight = hgt;
    resetClipOfs();
  }

public:
  this(TW, TH) (TW wdt, TH hgt) if (__traits(isIntegral, TW) && __traits(isIntegral, TH)) {
    resize(wdt, hgt);
  }

  ~this () @trusted nothrow @nogc => free();

final:
  void resize(TW, TH) (TW wdt, TH hgt) if (__traits(isIntegral, TW) && __traits(isIntegral, TH)) {
    import core.exception : onOutOfMemoryError;
    import core.stdc.stdlib : malloc, realloc, free;
    if (wdt < 1 || wdt > 16384 || hgt < 1 || hgt > 16384) throw new VideoLibError("VLOverlay: invalid size");
    if (dontFree) throw new VideoLibError("VLOverlay: can't resize predefined overlay");
    if (mVScr is null) {
      mWidth = cast(int)wdt;
      mHeight = cast(int)hgt;
      mVScr = cast(uint*)malloc(mWidth*mHeight*mVScr[0].sizeof);
      if (mVScr is null) onOutOfMemoryError();
    } else if (mWidth != cast(int)wdt || mHeight != cast(int)hgt) {
      mWidth = cast(int)wdt;
      mHeight = cast(int)hgt;
      auto scr = cast(uint*)realloc(mVScr, mWidth*mHeight*mVScr[0].sizeof);
      if (scr is null) { this.free(); onOutOfMemoryError(); }
      mVScr = scr;
    }
    resetClipOfs();
  }

  /// WARNING! this will trash virtual screen!
  @property void width(T) (T w) if (__traits(isIntegral, T)) => resize(w, mHeight);
  @property void height(T) (T h) if (__traits(isIntegral, T)) => resize(mWidth, h);

@nogc:
nothrow:
  @property bool valid () const pure => (mVScr !is null);

  void free () @trusted {
    if (!dontFree && mVScr !is null) {
      import core.stdc.stdlib : free;
      free(mVScr);
      mVScr = null;
      resetClipOfs();
    }
  }

  /**
   * Draw (possibly semi-transparent) pixel onto virtual screen; mix colors.
   *
   * Params:
   *  x = x coordinate
   *  y = y coordinate
   *  col = rgba color
   *
   * Returns:
   *  nothing
   */
  /*@gcc_inline*/ void putPixel(TX, TY) (TX x, TY y, Color col) @trusted
  if (__traits(isIntegral, TX) && __traits(isIntegral, TY))
  {
    immutable long xx = cast(long)x+mXOfs;
    immutable long yy = cast(long)y+mYOfs;
    if ((col&AMask) != AMask && xx >= mClipX0 && yy >= mClipY0 && xx <= mClipX1 && yy <= mClipY1) {
      uint* da = mVScr+yy*mWidth+xx;
      if (col&AMask) {
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

  /**
   * Draw (possibly semi-transparent) pixel onto virtual screen; don't mix colors.
   *
   * Params:
   *  x = x coordinate
   *  y = y coordinate
   *  col = rgba color
   *
   * Returns:
   *  nothing
   */
  /*@gcc_inline*/ void setPixel(TX, TY) (TX x, TY y, Color col) @trusted
  if (__traits(isIntegral, TX) && __traits(isIntegral, TY))
  {
    immutable long xx = cast(long)x+mXOfs;
    immutable long yy = cast(long)y+mYOfs;
    if (xx >= mClipX0 && yy >= mClipY0 && xx <= mClipX1 && yy <= mClipY1) {
      uint* da = mVScr+yy*mWidth+xx;
      *da = col;
    }
  }

  void resetClipOfs () @safe {
    if (mVScr !is null) {
      mClipX0 = mClipY0 = mXOfs = mYOfs = 0;
      mClipX1 = mWidth-1;
      mClipY1 = mHeight-1;
    } else {
      // all functions checks clipping, and this is not valid region
      // so we can omit VScr checks
      mClipX0 = mClipY0 = -42;
      mClipX1 = mClipY1 = -666;
    }
  }

  @property int width () const @safe pure => mWidth;
  @property int height () const @safe pure => mHeight;

  @property int xOfs () const @safe pure => mXOfs;
  @property void xOfs (int v) @safe => mXOfs = v;

  @property int yOfs () const @safe pure => mYOfs;
  @property void yOfs (int v) @safe => mYOfs = v;

  void getOfs (ref int x, ref int y) const @safe pure { x = mXOfs; y = mYOfs; }
  void setOfs (in int x, in int y) @safe { mXOfs = x; mYOfs = y; }


  struct Ofs {
    int x, y;
  }

  void getOfs (ref Ofs ofs) const @safe pure { ofs.x = mXOfs; ofs.y = mYOfs; }
  void setOfs (in ref Ofs ofs) @safe { mXOfs = ofs.x; mYOfs = ofs.y; }
  void resetOfs () @safe => mXOfs = mYOfs = 0;


  struct Clip {
    int x, y, w, h;
  }

  void getClip (ref int x0, ref int y0, ref int wdt, ref int hgt) const @safe pure {
    if (mVScr !is null) {
      x0 = mClipX0;
      y0 = mClipY0;
      wdt = mClipX1-mClipX0+1;
      hgt = mClipY1-mClipY0+1;
    } else {
      x0 = y0 = wdt = hgt = 0;
    }
  }

  void setClip (in int x0, in int y0, in int wdt, in int hgt) @safe {
    if (mVScr !is null) {
      mClipX0 = x0;
      mClipY0 = y0;
      mClipX1 = (wdt > 0 ? x0+wdt-1 : x0-1);
      mClipY1 = (hgt > 0 ? y0+hgt-1 : y0-1);
      if (mClipX0 < 0) mClipX0 = 0;
      if (mClipY0 < 0) mClipY0 = 0;
      if (mClipX0 >= mWidth) mClipX0 = mWidth-1;
      if (mClipY0 >= mHeight) mClipY0 = mHeight-1;
      if (mClipX1 < 0) mClipX1 = 0;
      if (mClipY1 < 0) mClipY1 = 0;
      if (mClipX1 >= mWidth) mClipX1 = mWidth-1;
      if (mClipY1 >= mHeight) mClipY1 = mHeight-1;
    }
  }

  void resetClip () @safe {
    if (mVScr !is null) {
      mClipX0 = mClipY0 = 0;
      mClipX1 = mWidth-1;
      mClipY1 = mHeight-1;
    } else {
      // all functions checks clipping, and this is not valid region
      // so we can omit VScr checks
      mClipX0 = mClipY0 = -42;
      mClipX1 = mClipY1 = -666;
    }
  }

  void getClip (ref Clip clip) const @safe pure => getClip(clip.x, clip.y, clip.w, clip.h);
  void setClip (in ref Clip clip) @safe => setClip(clip.x, clip.y, clip.w, clip.h);

  void clipIntrude (int dx, int dy) @safe {
    if (mVScr !is null) {
      mClipX0 += dx;
      mClipY0 += dx;
      mClipX1 -= dx;
      mClipY1 -= dx;
    }
  }

  void clipExtrude (int dx, int dy) @safe => clipIntrude(-dx, -dy);

  // //////////////////////////////////////////////////////////////////////// //
  /**
   * Draw 6x8 character onto virtual screen in KOI8 encoding.
   *
   * Params:
   *  x = x coordinate
   *  y = y coordinate
   *  ch = character
   *  col = foreground color
   *  bkcol = background color
   *
   * Returns:
   *  nothing
   */
  void drawChar (int x, int y, char ch, Color col, Color bkcol=Transparent) @trusted {
    usize pos = ch*8;
    foreach (immutable int dy; 0..8) {
      ubyte b = vlFont6[pos++];
      foreach (immutable int dx; 0..6) {
        Color c = (b&0x80 ? col : bkcol);
        if (!isTransparent(c)) putPixel(x+dx, y+dy, c);
        b = (b<<1)&0xff;
      }
    }
  }

  void drawStr (int x, int y, string str, Color col, Color bkcol=Transparent) @trusted {
    foreach (immutable char ch; str) {
      drawChar(x, y, ch, col, bkcol);
      x += 6;
    }
  }

  static int charWidthProp (char ch) @trusted pure => (vlFontPropWidth[ch]&0x0f);

  int strWidthProp (string str) @trusted pure {
    int wdt = 0;
    foreach (immutable char ch; str) wdt += (vlFontPropWidth[ch]&0x0f)+1;
    if (wdt > 0) --wdt; // don't count last empty pixel
    return wdt;
  }

  int drawCharProp (int x, int y, char ch, Color col, Color bkcol=Transparent) @trusted {
    usize pos = ch*8;
    immutable int wdt = (vlFontPropWidth[ch]&0x0f);
    foreach (immutable int dy; 0..8) {
      ubyte b = (vlFont6[pos++]<<(vlFontPropWidth[ch]>>4))&0xff;
      foreach (immutable int dx; 0..wdt) {
        Color c = (b&0x80 ? col : bkcol);
        if (!isTransparent(c)) putPixel(x+dx, y+dy, c);
        b = (b<<1)&0xff;
      }
    }
    return wdt;
  }

  int drawStrProp (int x, int y, string str, Color col, Color bkcol=Transparent) @trusted {
    bool vline = false;
    int sx = x;
    foreach (immutable char ch; str) {
      if (vline) {
        if (!isTransparent(bkcol)) foreach (int dy; 0..8) putPixel(x, y+dy, bkcol);
        ++x;
      }
      vline = true;
      x += drawCharProp(x, y, ch, col, bkcol);
    }
    return x-sx;
  }

  void drawOutlineStr (int x, int y, string text, Color col, Color outcol) @trusted {
    foreach (immutable int dy; -1..2) {
      foreach (immutable int dx; -1..2) {
        if (dx || dy) drawStr(x+dx, y+dy, text, outcol, Transparent);
      }
    }
    drawStr(x, y, text, col, Transparent);
  }

  int drawOutlineProp (int x, int y, string text, Color col, Color outcol) @trusted {
    foreach (immutable int dy; -1..2) {
      foreach (immutable int dx; -1..2) {
        if (dx || dy) drawStrProp(x+dx, y+dy, text, outcol, Transparent);
      }
    }
    return drawStrProp(x, y, text, col, Transparent);
  }

  // ////////////////////////////////////////////////////////////////////////// //
  void clear (Color col) @trusted {
    if (mVScr !is null) {
      if (dontFree) col &= 0xffffff;
      mVScr[0..mWidth*mHeight] = col;
    }
  }

  void hline (int x0, int y0, int len, Color col) @trusted {
    if (isOpaque(col) && len > 0 && mVScr !is null) {
      x0 += mXOfs;
      y0 += mYOfs;
      if (y0 >= mClipY0 && x0 <= mClipX1 && y0 <= mClipY1 && x0+len > mClipX0) {
        if (x0 < mClipX0) { if ((len += (x0-mClipX0)) <= 0) return; x0 = mClipX0; }
        if (x0+len-1 > mClipX1) len = mClipX1-x0+1;
        immutable usize ofs = y0*mWidth+x0;
        mVScr[ofs..ofs+len] = col;
      }
    } else {
      while (len-- > 0) putPixel(x0++, y0, col);
    }
  }

  void vline (int x0, int y0, int len, Color col) @trusted {
    while (len-- > 0) putPixel(x0, y0++, col);
  }


  /+
  void drawLine(bool lastPoint) (int x0, int y0, int x1, int y1, Color col) @trusted {
    import std.math : abs;
    int dx =  abs(x1-x0), sx = (x0 < x1 ? 1 : -1);
    int dy = -abs(y1-y0), sy = (y0 < y1 ? 1 : -1);
    int err = dx+dy, e2; // error value e_xy
    for (;;) {
      static if (lastPoint) putPixel(x0, y0, col);
      if (x0 == x1 && y0 == y1) break;
      static if (!lastPoint) putPixel(x0, y0, col);
      e2 = 2*err;
      if (e2 >= dy) { err += dy; x0 += sx; } // e_xy+e_x > 0
      if (e2 <= dx) { err += dx; y0 += sy; } // e_xy+e_y < 0
    }
  }
  +/

  // as the paper on which this code is based in not available to public,
  // i say "fuck you!"
  // knowledge must be publicly available; the ones who hides the knowledge
  // are not deserving any credits.
  void drawLine(bool lastPoint) (int x0, int y0, int x1, int y1, immutable Color col) {
    enum swap(string a, string b) = "{int tmp_="~a~";"~a~"="~b~";"~b~"=tmp_;}";

    if ((col&AMask) == AMask || mClipX0 > mClipX1 || mClipY0 > mClipY1 || mVScr is null) return;

    if (x0 == x1 && y0 == y1) {
      static if (lastPoint) putPixel(x0, y0, col);
      return;
    }

    x0 += mXOfs; x1 += mXOfs;
    y0 += mYOfs; y1 += mYOfs;

    // clip rectange
    int wx0 = mClipX0, wy0 = mClipY0, wx1 = mClipX1, wy1 = mClipY1;
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
      // inlined `putPixel(*d0, *d1, col)`
      // this can be made even faster by precalculating `da` and making
      // separate code branches for mixing and non-mixing drawing, but...
      // ah, screw it!
      uint* da = mVScr+(*d1)*mWidth+(*d0);
      if (col&AMask) {
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

  void line (int x0, int y0, int x1, int y1, Color col) @trusted => drawLine!true(x0, y0, x1, y1, col);
  void lineNoLast (int x0, int y0, int x1, int y1, Color col) @trusted => drawLine!false(x0, y0, x1, y1, col);

  void fillRect (int x, int y, int w, int h, Color col) @trusted {
    x += mXOfs;
    y += mYOfs;
    if (w > 0 && h > 0 && x+w > mClipX0 && y+h > mClipY0 && x <= mClipX1 && y <= mClipY1) {
      SDL_Rect r, sr, dr;
      sr.x = mClipX0; sr.y = mClipY0; sr.w = mClipX1-mClipX0+1; sr.h = mClipY1-mClipY0+1;
      r.x = x; r.y = y; r.w = w; r.h = h;
      if (SDL_IntersectRect(&sr, &r, &dr)) {
        x = dr.x-mXOfs;
        y = dr.y-mYOfs;
        while (dr.h-- > 0) hline(x, y++, dr.w, col);
      }
    }
  }

  void rect (int x, int y, int w, int h, Color col) @trusted {
    if (w > 0 && h > 0) {
      hline(x, y, w, col);
      hline(x, y+h-1, w, col);
      vline(x, y+1, h-2, col);
      vline(x+w-1, y+1, h-2, col);
    }
  }

  /* 4 phases */
  void selectionRect (int phase, int x0, int y0, int wdt, int hgt, Color col0, Color col1=Transparent) @trusted {
    if (wdt > 0 && hgt > 0) {
      // top
      foreach (immutable f; x0..x0+wdt) { putPixel(f, y0, ((phase %= 4) < 2 ? col0 : col1)); ++phase; }
      // right
      foreach (immutable f; y0+1..y0+hgt) { putPixel(x0+wdt-1, f, ((phase %= 4) < 2 ? col0 : col1)); ++phase; }
      // bottom
      foreach_reverse (immutable f; x0..x0+wdt-1) { putPixel(f, y0+hgt-1, ((phase %= 4) < 2 ? col0 : col1)); ++phase; }
      // left
      foreach_reverse (immutable f; y0..y0+hgt-1) { putPixel(x0, f, ((phase %= 4) < 2 ? col0 : col1)); ++phase; }
    }
  }

  private void plot4points() (int cx, int cy, int x, int y, Color clr) @trusted {
    putPixel(cx+x, cy+y, clr);
    if (x != 0) putPixel(cx-x, cy+y, clr);
    if (y != 0) putPixel(cx+x, cy-y, clr);
    putPixel(cx-x, cy-y, clr);
  }

  void circle (int cx, int cy, int radius, Color clr) @trusted {
    if (radius > 0 && !isTransparent(clr)) {
      int error = -radius, x = radius, y = 0;
      if (radius == 1) { putPixel(cx, cy, clr); return; }
      while (x > y) {
        plot4points(cx, cy, x, y, clr);
        plot4points(cx, cy, y, x, clr);
        error += y*2+1;
        ++y;
        if (error >= 0) { --x; error -= x*2; }
      }
      plot4points(cx, cy, x, y, clr);
    }
  }

  void fillCircle (int cx, int cy, int radius, Color clr) @trusted {
    if (radius > 0 && !isTransparent(clr)) {
      int error = -radius, x = radius, y = 0;
      if (radius == 1) { putPixel(cx, cy, clr); return; }
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
    }
  }

  void ellipse (int x0, int y0, int x1, int y1, Color clr) @trusted {
    import std.math : abs;
    int a = abs(x1-x0), b = abs(y1-y0), b1 = b&1; // values of diameter
    long dx = 4*(1-a)*b*b, dy = 4*(b1+1)*a*a; // error increment
    long err = dx+dy+b1*a*a; // error of 1.step
    if (x0 > x1) { x0 = x1; x1 += a; } // if called with swapped points...
    if (y0 > y1) y0 = y1; // ...exchange them
    y0 += (b+1)/2; y1 = y0-b1;  // starting pixel
    a *= 8*a; b1 = 8*b*b;
    do {
      long e2;
      putPixel(x1, y0, clr); //   I. Quadrant
      putPixel(x0, y0, clr); //  II. Quadrant
      putPixel(x0, y1, clr); // III. Quadrant
      putPixel(x1, y1, clr); //  IV. Quadrant
      e2 = 2*err;
      if (e2 >= dx) { ++x0; --x1; err += dx += b1; } // x step
      if (e2 <= dy) { ++y0; --y1; err += dy += a; }  // y step
    } while (x0 <= x1);
    while (y0-y1 < b) {
      // too early stop of flat ellipses a=1
      putPixel(x0-1, ++y0, clr); // complete tip of ellipse
      putPixel(x0-1, --y1, clr);
    }
  }

  void fillEllipse (int x0, int y0, int x1, int y1, Color clr) @trusted {
    import std.math : abs;
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
      putPixel(x0-1, ++y0, clr); // complete tip of ellipse
      putPixel(x0-1, --y1, clr);
    }
  }

  /** blit overlay to main screen */
  void blitTpl(string btype) (VLOverlay destovl, int xd, int yd, ubyte alpha=0) @trusted {
    static if (btype == "NoSrcAlpha") import core.stdc.string : memcpy;
    if (!valid || destovl is null || !destovl.valid) return;
    if (xd > -mWidth && yd > -mHeight && xd < destovl.mWidth && yd < destovl.mHeight && alpha < 255) {
      int w = mWidth, h = mHeight;
      immutable uint vsPitch = destovl.mWidth;
      immutable uint myPitch = mWidth;
      uint *my = mVScr;
      uint *dest;
      // vertical clipping
      if (yd < 0) {
        // skip invisible top part
        if ((h += yd) < 1) return;
        my -= yd*mWidth;
        yd = 0;
      }
      if (yd+h > destovl.mHeight) {
        // don't draw invisible bottom part
        if ((h = destovl.mHeight-yd) < 1) return;
      }
      // horizontal clipping
      if (xd < 0) {
        // skip invisible left part
        if ((w += xd) < 1) return;
        my -= xd;
        xd = 0;
      }
      if (xd+w > destovl.mWidth) {
        // don't draw invisible right part
        if ((w = destovl.mWidth-xd) < 1) return;
      }
      // copying?
      dest = destovl.mVScr+yd*vsPitch+xd;
      static if (btype == "NoSrcAlpha") {
        if (alpha == 0) {
          while (h-- > 0) {
            import core.stdc.string : memcpy;
            memcpy(dest, my, w*destovl.mVScr[0].sizeof);
            dest += vsPitch;
            my += myPitch;
          }
          return;
        }
      }
      // alpha mixing
      {
        static if (btype == "NoSrcAlpha") immutable uint a = 256-alpha; // to not loose bits
        while (h-- > 0) {
          auto src = cast(immutable(uint)*)my;
          auto dst = dest;
          foreach_reverse (immutable dx; 0..w) {
            immutable uint s = *src++;
            static if (btype == "SrcAlpha") {
              if ((s&AMask) == Transparent) { ++dst; continue; }
              immutable uint a = 256-clampToByte(cast(int)(alpha+(s>>AShift)&0xff)); // to not loose bits
            }
            immutable uint dc = (*dst)&0xffffff;
            immutable uint srb = (s&0xff00ff);
            immutable uint sg = (s&0x00ff00);
            immutable uint drb = (dc&0xff00ff);
            immutable uint dg = (dc&0x00ff00);
            immutable uint orb = (drb+(((srb-drb)*a+0x800080)>>8))&0xff00ff;
            immutable uint og = (dg+(((sg-dg)*a+0x008000)>>8))&0x00ff00;
            *dst++ = orb|og;
          }
          dest += vsPitch;
          my += myPitch;
        }
      }
    }
  }

  alias blit = blitTpl!"NoSrcAlpha";
  alias blitSrcAlpha = blitTpl!"SrcAlpha";
}


// ////////////////////////////////////////////////////////////////////////// //
shared static this () {
  initializeClock();
}


shared static ~this () {
  deinitVideo();
}


// ////////////////////////////////////////////////////////////////////////// //
/+
private immutable ubyte[0x458-0x401] utf2koiTable = [
  0xB3,0x3F,0x3F,0xB4,0x3F,0xB6,0xB7,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0xE1,
  0xE2,0xF7,0xE7,0xE4,0xE5,0xF6,0xFA,0xE9,0xEA,0xEB,0xEC,0xED,0xEE,0xEF,0xF0,0xF2,
  0xF3,0xF4,0xF5,0xE6,0xE8,0xE3,0xFE,0xFB,0xFD,0xFF,0xF9,0xF8,0xFC,0xE0,0xF1,0xC1,
  0xC2,0xD7,0xC7,0xC4,0xC5,0xD6,0xDA,0xC9,0xCA,0xCB,0xCC,0xCD,0xCE,0xCF,0xD0,0xD2,
  0xD3,0xD4,0xD5,0xC6,0xC8,0xC3,0xDE,0xDB,0xDD,0xDF,0xD9,0xD8,0xDC,0xC0,0xD1,0x3F,
  0xA3,0x3F,0x3F,0xA4,0x3F,0xA6,0xA7
];


/// Convert utf-8 to koi8-u
/*@gcc_inline*/ ubyte utf2koi() (dchar ch) @safe pure nothrow @nogc {
  if (ch < 127) return ch&0xff;
  if (ch > 0x400 && ch < 0x458) return utf2koiTable[ch-0x401];
  if (ch == 0x490) return 0xBD;
  if (ch == 0x491) return 0xAD;
  return 63;
}
+/


// ////////////////////////////////////////////////////////////////////////// //
public immutable ubyte[256*8] vlFont6 = [
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
/* 128 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_11111111,
/* 129 '�' */
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
/* 130 '�' */
0b_00000000,
0b_00000000,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 131 '�' */
0b_11111111,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 132 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00111100,
0b_00111100,
0b_00000000,
0b_00000000,
0b_00000000,
/* 133 '�' */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_00000000,
0b_00000000,
/* 134 '�' */
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
0b_11000000,
/* 135 '�' */
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
/* 136 '�' */
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
0b_11111100,
/* 137 '�' */
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
0b_00000011,
/* 138 '�' */
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
0b_00111111,
/* 139 '�' */
0b_00010001,
0b_00100010,
0b_01000100,
0b_10001000,
0b_00010001,
0b_00100010,
0b_01000100,
0b_10001000,
/* 140 '�' */
0b_10001000,
0b_01000100,
0b_00100010,
0b_00010001,
0b_10001000,
0b_01000100,
0b_00100010,
0b_00010001,
/* 141 '�' */
0b_11111110,
0b_01111100,
0b_00111000,
0b_00010000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 142 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00010000,
0b_00111000,
0b_01111100,
0b_11111110,
/* 143 '�' */
0b_10000000,
0b_11000000,
0b_11100000,
0b_11110000,
0b_11100000,
0b_11000000,
0b_10000000,
0b_00000000,
/* 144 '�' */
0b_00000001,
0b_00000011,
0b_00000111,
0b_00001111,
0b_00000111,
0b_00000011,
0b_00000001,
0b_00000000,
/* 145 '�' */
0b_11111111,
0b_01111110,
0b_00111100,
0b_00011000,
0b_00011000,
0b_00111100,
0b_01111110,
0b_11111111,
/* 146 '�' */
0b_10000001,
0b_11000011,
0b_11100111,
0b_11111111,
0b_11111111,
0b_11100111,
0b_11000011,
0b_10000001,
/* 147 '�' */
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 148 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
/* 149 '�' */
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 150 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
/* 151 '�' */
0b_00110011,
0b_00110011,
0b_11001100,
0b_11001100,
0b_00110011,
0b_00110011,
0b_11001100,
0b_11001100,
/* 152 '�' */
0b_00000000,
0b_00100000,
0b_00100000,
0b_01010000,
0b_01010000,
0b_10001000,
0b_11111000,
0b_00000000,
/* 153 '�' */
0b_00100000,
0b_00100000,
0b_01110000,
0b_00100000,
0b_01110000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 154 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_01010000,
0b_10001000,
0b_10101000,
0b_01010000,
0b_00000000,
/* 155 '�' */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 156 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
/* 157 '�' */
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
0b_11110000,
/* 158 '�' */
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
0b_00001111,
/* 159 '�' */
0b_11111111,
0b_11111111,
0b_11111111,
0b_11111111,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 160 '�' */
0b_00000000,
0b_00000000,
0b_01101000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_01101000,
0b_00000000,
/* 161 '�' */
0b_00110000,
0b_01001000,
0b_01001000,
0b_01110000,
0b_01001000,
0b_01001000,
0b_01110000,
0b_11000000,
/* 162 '�' */
0b_11111000,
0b_10001000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 163 '�' */
0b_00000000,
0b_01010000,
0b_01110000,
0b_10001000,
0b_11111000,
0b_10000000,
0b_01110000,
0b_00000000,
/* 164 '�' ukr. ie small */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_01111000,
0b_00000000,
/* 165 '�' */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_01100000,
0b_00000000,
/* 166 '�' ukr. i small */
0b_00100000,
0b_00000000,
0b_01100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 167 '�' ukr. ji small */
0b_01010000,
0b_00000000,
0b_01110000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 168 '�' */
0b_11111000,
0b_00100000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_11111000,
/* 169 '�' */
0b_00100000,
0b_01010000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_00000000,
/* 170 '�' */
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01010000,
0b_01010000,
0b_11011000,
0b_00000000,
/* 171 '�' */
0b_00110000,
0b_01000000,
0b_01000000,
0b_00100000,
0b_01010000,
0b_01010000,
0b_01010000,
0b_00100000,
/* 172 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_01010000,
0b_10101000,
0b_10101000,
0b_01010000,
0b_00000000,
/* 173 '�' */
0b_00001000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_10000000,
0b_00000000,
/* 174 '�' */
0b_00111000,
0b_01000000,
0b_10000000,
0b_11111000,
0b_10000000,
0b_01000000,
0b_00111000,
0b_00000000,
/* 175 '�' */
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 176 '�' */
0b_00000000,
0b_11111000,
0b_00000000,
0b_11111000,
0b_00000000,
0b_11111000,
0b_00000000,
0b_00000000,
/* 177 '�' */
0b_00100000,
0b_00100000,
0b_11111000,
0b_00100000,
0b_00100000,
0b_00000000,
0b_11111000,
0b_00000000,
/* 178 '�' */
0b_11000000,
0b_00110000,
0b_00001000,
0b_00110000,
0b_11000000,
0b_00000000,
0b_11111000,
0b_00000000,
/* 179 '�' */
0b_01010000,
0b_11111000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_11111000,
0b_00000000,
/* 180 '�' ukr. ie big */
0b_01111000,
0b_10000000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_01111000,
0b_00000000,
/* 181 '�' */
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_10100000,
0b_01000000,
/* 182 '�' ukr. i big */
0b_01110000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 183 '�' ukr. ij big */
0b_01010000,
0b_01110000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_01110000,
0b_00000000,
/* 184 '�' */
0b_00000000,
0b_00011000,
0b_00100100,
0b_00100100,
0b_00011000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 185 '�' */
0b_00000000,
0b_00110000,
0b_01111000,
0b_01111000,
0b_00110000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 186 '�' */
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00110000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 187 '�' */
0b_00111110,
0b_00100000,
0b_00100000,
0b_00100000,
0b_10100000,
0b_01100000,
0b_00100000,
0b_00000000,
/* 188 '�' */
0b_10100000,
0b_01010000,
0b_01010000,
0b_01010000,
0b_00000000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 189 '�' */
0b_01000000,
0b_10100000,
0b_00100000,
0b_01000000,
0b_11100000,
0b_00000000,
0b_00000000,
0b_00000000,
/* 190 '�' */
0b_00000000,
0b_00111000,
0b_00111000,
0b_00111000,
0b_00111000,
0b_00111000,
0b_00111000,
0b_00000000,
/* 191 '�' */
0b_00111100,
0b_01000010,
0b_10011001,
0b_10100001,
0b_10100001,
0b_10011001,
0b_01000010,
0b_00111100,
/* 192 '�' */
0b_00000000,
0b_00000000,
0b_10010000,
0b_10101000,
0b_11101000,
0b_10101000,
0b_10010000,
0b_00000000,
/* 193 '�' */
0b_00000000,
0b_00000000,
0b_01100000,
0b_00010000,
0b_01110000,
0b_10010000,
0b_01101000,
0b_00000000,
/* 194 '�' */
0b_00000000,
0b_00000000,
0b_11110000,
0b_10000000,
0b_11110000,
0b_10001000,
0b_11110000,
0b_00000000,
/* 195 '�' */
0b_00000000,
0b_00000000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_11111000,
0b_00001000,
0b_00000000,
/* 196 '�' */
0b_00000000,
0b_00000000,
0b_00110000,
0b_01010000,
0b_01010000,
0b_01110000,
0b_10001000,
0b_00000000,
/* 197 '�' */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_11111000,
0b_10000000,
0b_01110000,
0b_00000000,
/* 198 '�' */
0b_00000000,
0b_00100000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_00000000,
/* 199 '�' */
0b_00000000,
0b_00000000,
0b_01111000,
0b_01001000,
0b_01000000,
0b_01000000,
0b_01000000,
0b_00000000,
/* 200 '�' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01010000,
0b_10001000,
0b_00000000,
/* 201 '�' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_10001000,
0b_00000000,
/* 202 '�' */
0b_00000000,
0b_01010000,
0b_00100000,
0b_00000000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_00000000,
/* 203 '�' */
0b_00000000,
0b_00000000,
0b_10010000,
0b_10100000,
0b_11000000,
0b_10100000,
0b_10010000,
0b_00000000,
/* 204 '�' */
0b_00000000,
0b_00000000,
0b_00111000,
0b_00101000,
0b_00101000,
0b_01001000,
0b_10001000,
0b_00000000,
/* 205 '�' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_11011000,
0b_10101000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 206 '�' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 207 '�' */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 208 '�' */
0b_00000000,
0b_00000000,
0b_01111000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_00000000,
/* 209 '�' */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10001000,
0b_01111000,
0b_00101000,
0b_01001000,
0b_00000000,
/* 210 '�' */
0b_00000000,
0b_00000000,
0b_11110000,
0b_10001000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 211 '�' */
0b_00000000,
0b_00000000,
0b_01111000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_01111000,
0b_00000000,
/* 212 '�' */
0b_00000000,
0b_00000000,
0b_11111000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 213 '�' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01000000,
0b_10000000,
0b_00000000,
/* 214 '�' */
0b_00000000,
0b_00000000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_01110000,
0b_10101000,
0b_00000000,
/* 215 '�' */
0b_00000000,
0b_00000000,
0b_11110000,
0b_01001000,
0b_01110000,
0b_01001000,
0b_11110000,
0b_00000000,
/* 216 '�' */
0b_00000000,
0b_00000000,
0b_01000000,
0b_01000000,
0b_01110000,
0b_01001000,
0b_01110000,
0b_00000000,
/* 217 '�' */
0b_00000000,
0b_00000000,
0b_10001000,
0b_10001000,
0b_11001000,
0b_10101000,
0b_11001000,
0b_00000000,
/* 218 '�' */
0b_00000000,
0b_00000000,
0b_11110000,
0b_00001000,
0b_01110000,
0b_00001000,
0b_11110000,
0b_00000000,
/* 219 '�' */
0b_00000000,
0b_00000000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_11111000,
0b_00000000,
/* 220 '�' */
0b_00000000,
0b_00000000,
0b_01110000,
0b_10001000,
0b_00111000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 221 '�' */
0b_00000000,
0b_00000000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_11111000,
0b_00001000,
0b_00000000,
/* 222 '�' */
0b_00000000,
0b_00000000,
0b_01001000,
0b_01001000,
0b_01111000,
0b_00001000,
0b_00001000,
0b_00000000,
/* 223 '�' */
0b_00000000,
0b_00000000,
0b_11000000,
0b_01000000,
0b_01110000,
0b_01001000,
0b_01110000,
0b_00000000,
/* 224 '�' */
0b_10010000,
0b_10101000,
0b_10101000,
0b_11101000,
0b_10101000,
0b_10101000,
0b_10010000,
0b_00000000,
/* 225 '�' */
0b_00100000,
0b_01010000,
0b_10001000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 226 '�' */
0b_11111000,
0b_10001000,
0b_10000000,
0b_11110000,
0b_10001000,
0b_10001000,
0b_11110000,
0b_00000000,
/* 227 '�' */
0b_10010000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_10010000,
0b_11111000,
0b_00001000,
0b_00000000,
/* 228 '�' */
0b_00111000,
0b_00101000,
0b_00101000,
0b_01001000,
0b_01001000,
0b_11111000,
0b_10001000,
0b_00000000,
/* 229 '�' */
0b_11111000,
0b_10000000,
0b_10000000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_11111000,
0b_00000000,
/* 230 '�' */
0b_00100000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_00000000,
/* 231 '�' */
0b_11111000,
0b_10001000,
0b_10001000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 232 '�' */
0b_10001000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01010000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 233 '�' */
0b_10001000,
0b_10001000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 234 '�' */
0b_01010000,
0b_00100000,
0b_10001000,
0b_10011000,
0b_10101000,
0b_11001000,
0b_10001000,
0b_00000000,
/* 235 '�' */
0b_10001000,
0b_10010000,
0b_10100000,
0b_11000000,
0b_10100000,
0b_10010000,
0b_10001000,
0b_00000000,
/* 236 '�' */
0b_00011000,
0b_00101000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_01001000,
0b_10001000,
0b_00000000,
/* 237 '�' */
0b_10001000,
0b_11011000,
0b_10101000,
0b_10101000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 238 '�' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_11111000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 239 '�' */
0b_01110000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 240 '�' */
0b_11111000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_00000000,
/* 241 '�' */
0b_01111000,
0b_10001000,
0b_10001000,
0b_01111000,
0b_00101000,
0b_01001000,
0b_10001000,
0b_00000000,
/* 242 '�' */
0b_11110000,
0b_10001000,
0b_10001000,
0b_11110000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_00000000,
/* 243 '�' */
0b_01110000,
0b_10001000,
0b_10000000,
0b_10000000,
0b_10000000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 244 '�' */
0b_11111000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00100000,
0b_00000000,
/* 245 '�' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_01010000,
0b_00100000,
0b_01000000,
0b_10000000,
0b_00000000,
/* 246 '�' */
0b_10101000,
0b_10101000,
0b_01110000,
0b_00100000,
0b_01110000,
0b_10101000,
0b_10101000,
0b_00000000,
/* 247 '�' */
0b_11110000,
0b_01001000,
0b_01001000,
0b_01110000,
0b_01001000,
0b_01001000,
0b_11110000,
0b_00000000,
/* 248 '�' */
0b_10000000,
0b_10000000,
0b_10000000,
0b_11110000,
0b_10001000,
0b_10001000,
0b_11110000,
0b_00000000,
/* 249 '�' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_11001000,
0b_10101000,
0b_10101000,
0b_11001000,
0b_00000000,
/* 250 '�' */
0b_11110000,
0b_00001000,
0b_00001000,
0b_00110000,
0b_00001000,
0b_00001000,
0b_11110000,
0b_00000000,
/* 251 '�' */
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_11111000,
0b_00000000,
/* 252 '�' */
0b_01110000,
0b_10001000,
0b_00001000,
0b_01111000,
0b_00001000,
0b_10001000,
0b_01110000,
0b_00000000,
/* 253 '�' */
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_10101000,
0b_11111000,
0b_00001000,
0b_00000000,
/* 254 '�' */
0b_10001000,
0b_10001000,
0b_10001000,
0b_10001000,
0b_01111000,
0b_00001000,
0b_00001000,
0b_00000000,
/* 255 '�' */
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
        immutable b = vlFont6[cnum*8+dy];
        if (b) {
          immutable mn = 7-bsr(b);
          if (mn < shift) shift = mn;
        }
      }
    }
    ubyte wdt = 0;
    foreach (immutable dy; 0..8) {
      immutable b = (vlFont6[cnum*8+dy]<<shift);
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
