import core.time;
import std.stdio;
import iv.nanovega;
import iv.nanovega.fui;
import iv.nanovega.perf;

import arsd.simpledisplay;
import arsd.color;
import arsd.png;
import arsd.jpeg;

import std.functional : toDelegate;


////////////////////////////////////////////////////////////////////////////////
//version = LineBreakTest;


////////////////////////////////////////////////////////////////////////////////
__gshared int GWidth = 800;
__gshared int GHeight = 600;


////////////////////////////////////////////////////////////////////////////////
float getSeconds () {
  import core.time;
  __gshared bool inited = false;
  __gshared MonoTime stt;
  if (!inited) { stt = MonoTime.currTime; inited = true; }
  auto ct = MonoTime.currTime;
  return cast(float)((ct-stt).total!"msecs")/1000.0;
}


// ////////////////////////////////////////////////////////////////////////// //
__gshared NVGContext nvg = null;


// ////////////////////////////////////////////////////////////////////////// //
void init (NVGContext vg) {
  import std.path : expandTilde;
  //enum FontFile = "~/ttf/ms/arial.ttf";
  //enum FontFile = "~/ttf/ms/verdana.ttf";
  enum FontFile = "~/.fonts/PTC55F.ttf";
  //enum FontFile = "~/ttf/ms/tahoma.ttf";
  bndSetFont(vg.createFont("system:noaa", FontFile.expandTilde));
  bndSetIconImage(vg.createImage("../data/images/blender_icons16.png", 0));
}


// ////////////////////////////////////////////////////////////////////////// //
void buildWindow0 (FuiContext ctx) {
  //ctx.clear();
  ctx.clearControls();

  with (ctx.layprops(0)) {
    vertical = true;
    padding.left = 1;
    padding.right = 8;
    padding.top = 4;
    padding.bottom = 6;
    spacing = 0;
    lineSpacing = 1;
  }

  // horizontal box for the first two lines
  auto hbox = ctx.hbox(0);
  with (ctx.layprops(hbox)) flex = 0;

    // left span to push buttons to center
    ctx.hspan(hbox);
    // button
    with (ctx.layprops(ctx.button(hbox, "button 0"))) {
      flex = 0;
      //minSize = FuiSize(64, 16);
    }
    // button
    ctx.button(hbox, "button 1");
    // right span to push buttons to center, line break
    with (ctx.layprops(ctx.hspan(hbox))) {
      lineBreak = true;
    }

    // left span to push buttons to right
    ctx.hspan(hbox);
    // button
    with (ctx.layprops(ctx.button(hbox, "long button 2"))) {
      flex = 0;
      //clickMask |= FuiLayoutProps.Buttons.Left;
      doubleMask |= FuiLayoutProps.Buttons.Left;
    }

  // horizontal box for the first text line
  __gshared bool cbval;
  hbox = ctx.hbox(0);
  with (ctx.layprops(hbox)) flex = 0;

    // label
    auto lbl0 = ctx.label(hbox, "\x02first label:");
    with (ctx.layprops(lbl0)) {
      flex = 0;
      hgroup = lbl0;
      vgroup = lbl0;
    }
    // button
    auto but0 = ctx.checkbox(hbox, "checkbox for first label", &cbval);
    with (ctx.layprops(but0)) {
      flex = 0;
      hgroup = but0;
      vgroup = lbl0;
    }

  // horizontal box for the second text line
  hbox = ctx.hbox(0);
  with (ctx.layprops(hbox)) flex = 0;

    // label
    with (ctx.layprops(ctx.label(hbox, "\x02second label:"))) {
      flex = 0;
      hgroup = lbl0;
      vgroup = lbl0;
    }
    // button
    with (ctx.layprops(ctx.checkbox(hbox, "checkbox for second label", &cbval))) {
      flex = 0;
      hgroup = but0;
      vgroup = lbl0;
    }

  // horizontal box for the first text line
  __gshared int rbval;
  hbox = ctx.hbox(0);
  with (ctx.layprops(hbox)) flex = 0;

    // label
    auto lbl1 = ctx.label(hbox, "\x02first label:");
    with (ctx.layprops(lbl1)) {
      flex = 0;
      hgroup = lbl1;
      vgroup = lbl1;
    }
    // button
    auto rad0 = ctx.radio(hbox, "radio for first label", &rbval);
    with (ctx.layprops(rad0)) {
      flex = 0;
      hgroup = rad0;
      vgroup = lbl1;
    }

  // horizontal box for the second text line
  hbox = ctx.hbox(0);
  with (ctx.layprops(hbox)) flex = 0;

    // label
    with (ctx.layprops(ctx.label(hbox, "\x02second label:"))) {
      flex = 0;
      hgroup = lbl1;
      vgroup = lbl1;
    }
    // button
    with (ctx.layprops(ctx.radio(hbox, "radio for second label", &rbval))) {
      flex = 0;
      hgroup = rad0;
      vgroup = lbl1;
    }

  // horizontal box to push last line down
  hbox = ctx.hbox(0);
  with (ctx.layprops(hbox)) flex = 1;

  // horizontal box for the last line
  hbox = ctx.hbox(0);
  with (ctx.layprops(hbox)) flex = 0;

    // left span to push button to right
    ctx.hspan(hbox);
    // button
    with (ctx.layprops(ctx.button(hbox, "last long button"))) {
      flex = 0;
      //clickMask |= FuiLayoutProps.Buttons.Left;
      doubleMask |= FuiLayoutProps.Buttons.Left;
    }
}


////////////////////////////////////////////////////////////////////////////////
void main () {
  bool doQuit = false;
  PerfGraph fps;
  bool perfHidden = true;
  bool alwaysRelayout = false;

  //setOpenGLContextVersion(3, 2); // up to GLSL 150
  setOpenGLContextVersion(2, 0); // it's enough
  //openGLContextCompatible = false;

  auto ctx = FuiContext.create();
  int prevItemAt = -1;

  auto sdwindow = new SimpleWindow(GWidth, GHeight, "OUI", OpenGlOptions.yes, Resizability.fixedSize/*allowResizing*/);
  //sdwindow.hideCursor();

  void clearWindowData () {
    if (!sdwindow.closed && nvg !is null) {
      nvg.deleteGL2();
      nvg = null;
    }
  }

  sdwindow.closeQuery = delegate () {
    clearWindowData();
    doQuit = true;
  };

  void closeWindow () {
    clearWindowData();
    if (!sdwindow.closed) sdwindow.close();
  }

  auto stt = MonoTime.currTime;
  auto prevt = MonoTime.currTime;
  auto curt = prevt;
  int owdt = -1, ohgt = -1;

  sdwindow.windowResized = delegate (int w, int h) {
    //writeln("w=", w, "; h=", h);
    owdt = w;
    ohgt = h;
    glViewport(0, 0, w, h);
    // set dimensions and relayout
    ctx.layprops(0).minSize = FuiSize(w, h);
    ctx.layprops(0).maxSize = ctx.layprops(0).minSize;
    ctx.relayout();
  };

  sdwindow.redrawOpenGlScene = delegate () {
    ctx.update();

    // process events
    while (ctx.hasEvents) {
      auto ev = ctx.getEvent();
      if (ctx.fuiProcessEvent(ev)) continue;
      { import std.stdio; writeln(ev); }
    }

    if (alwaysRelayout) {
      nvg.fontSize(16);
      ctx.buildWindow0();
      glViewport(0, 0, owdt, ohgt);
      // set dimensions and relayout
      ctx.layprops(0).minSize = FuiSize(owdt, ohgt);
      ctx.layprops(0).maxSize = ctx.layprops(0).minSize;
      ctx.relayout();
      //writeln("w=", owdt, "; h=", ohgt, "; w=", ctx.layprops(0).position.w, "; h=", ctx.layprops(0).position.h);
    }

    // timers
    prevt = curt;
    curt = MonoTime.currTime;
    float secs = cast(double)((curt-stt).total!"msecs")/1000.0;
    float dt = cast(double)((curt-prevt).total!"msecs")/1000.0;

    // Update and render
    glClearColor(0, 0, 0, 1);
    glClear(glNVGClearFlags);

    if (nvg !is null) {
      if (fps !is null) fps.update(dt);
      nvg.beginFrame(owdt, ohgt, 1);
      nvg.fontBlur(0);
      ctx.draw();
      if (fps !is null && !perfHidden) fps.render(nvg, owdt-200-5, ohgt-35-5);
      version(none) {
        import iv.nanovega.fontstash;
        //fonsDrawDebug(nvg.fs, 1, 1);
        int w, h;
        const(ubyte)*d = fonsGetTextureData(nvg.fs, &w, &h);
        writeln("w=", w, "; h=", h);
        auto tc = new TrueColorImage(w, h);
        scope(exit) tc.destroy;
        foreach (immutable y; 0..h) {
          foreach (immutable x; 0..w) {
            auto b = d[y*w+x];
            if (b == 0) {
              tc.setPixel(x, y, Color(255, 127, 0));
            } else {
              tc.setPixel(x, y, Color(b, b, b));
            }
          }
        }
        writePng("z00.png", tc);
        /*
        auto fo = File("z00.raw", "w");
        fo.rawWrite(d[0..w*h]);
        */
      }
      nvg.endFrame();
    }
  };

  sdwindow.visibleForTheFirstTime = delegate () {
    sdwindow.setAsCurrentOpenGlContext(); // make this window active
    sdwindow.vsync = false;
    //sdwindow.useGLFinish = false;
    //glbindLoadFunctions();

    nvg = createGL2NVG(NVG_ANTIALIAS|NVG_STENCIL_STROKES|NVG_DEBUG);
    if (nvg is null) {
      import std.stdio;
      writeln("Could not init nanovg.");
      //sdwindow.close();
    }
    init(nvg);
    ctx.vg = nvg;

    nvg.fontSize(16);
    buildWindow0(ctx);
    // layout controls in default root box to determine minimal dimenstions
    // but set maximal dimensions to our max window size
    ctx.layprops(0).maxSize = FuiSize(1028, 768);
    ctx.relayout();

    GWidth = ctx.layprops(0).position.w;
    GHeight = ctx.layprops(0).position.h;

    // as font sizes changes slightly, we'll do this hack
    glViewport(0, 0, GWidth, GHeight);
    nvg.beginFrame(GWidth, GHeight, 1);
    ctx.draw();
    nvg.cancelFrame();

    // and layout it all again
    buildWindow0(ctx);
    ctx.layprops(0).minSize = FuiSize(GWidth, GHeight);
    ctx.layprops(0).maxSize = FuiSize(1028, 768);
    ctx.relayout();

    GWidth = ctx.layprops(0).position.w;
    GHeight = ctx.layprops(0).position.h;

    sdwindow.resize(GWidth, GHeight);

    if (fps is null) fps = new PerfGraph("Frame Time", PerfGraph.Style.FPS, "system:noaa");
    //sdwindow.redrawOpenGlScene();
  };

  sdwindow.eventLoop(1000/60,
    delegate () {
      if (sdwindow.closed) return;
      if (doQuit) { closeWindow(); return; }
      sdwindow.redrawOpenGlSceneNow();
    },
    delegate (KeyEvent event) {
      if (sdwindow.closed) return;
      if (!event.pressed) return;
      switch (event.key) {
        case Key.Escape: sdwindow.close(); return;
        default:
      }
      ctx.keyboardEvent(event);
    },
    delegate (MouseEvent event) {
      ctx.mouseEvent(event);
    },
    delegate (dchar ch) {
      if (ch == 'P') { perfHidden = !perfHidden; return; }
      if (ch == 'L') { alwaysRelayout = !alwaysRelayout; return; }
      ctx.charEvent(ch);
    },
  );
  closeWindow();
}
