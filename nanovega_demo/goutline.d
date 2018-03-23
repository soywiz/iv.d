module nvg000;

import arsd.simpledisplay;

version(arsd) import arsd.nanovega;
else import iv.nanovega;
import iv.vfs.io;


//version = test_flatten;
//version = test_path_outline;


// ////////////////////////////////////////////////////////////////////////// //
void main () {
  NVGContext nvg; // our NanoVega context

  // we need at least OpenGL3 with GLSL to use NanoVega,
  // so let's tell simpledisplay about that
  setOpenGLContextVersion(3, 0);

  // now create OpenGL window
  sdpyWindowClass = "NVG_RASTER_TEST";
  auto sdmain = new NVGWindow(800, 600, "NanoVega Simple Sample");

  sdmain.onInitOpenGL = delegate (self, nvg) {
    nvg.createFont("verdana", "verdana");
  };

  // this callback will be called when we will need to repaint our window
  sdmain.onRedraw = delegate (self, nvg) {
    glClearColor(0, 0, 0, 0);
    glClear(glNVGClearFlags);

    float[4] bounds;
    nvg.fontFace = "verdana";
    nvg.fontSize = 24;
    nvg.charPathBounds('A', bounds[]);
    writeln(bounds[]);

    {
      nvg.beginFrame(self.width, self.height);
      scope(exit) nvg.endFrame();

      nvg.beginPath(); // start new path
      nvg.scale(0.3, 0.3);
      nvg.translate(100, bounds[3]-bounds[1]+100);
      version(none) {
        nvg.charToPath('Q');
      } else {
        version(test_path_outline) {
          nvg.resetTransform();
          nvg.beginPath();
          nvg.moveTo(10, 80);
          nvg.quadTo(30, 60, 50, 80);
          nvg.lineTo(60, 120);
          nvg.lineTo(0, 0);
          auto ol = nvg.getCurrPathOutline();
          nvg.beginPath();
          //nvg.strokeWidth = 1;
        } else {
          auto ol = nvg.charOutline('Q');
        }
        if (!ol.empty) {
          version(test_flatten) {
            writeln("curved commands: ", ol.length);
            ol = ol.flatten;
            writeln("flattened commands: ", ol.length);
          }
          auto xol = ol;
          foreach (const ref cmd; ol.commands) {
            assert(cmd.valid);
            final switch (cmd.code) {
              case cmd.Kind.MoveTo:
                version(test_path_outline) writeln("MoveTo(", cmd.args[0], ", ", cmd.args[1], ")");
                nvg.moveTo(cmd.args[0], cmd.args[1]);
                break;
              case cmd.Kind.LineTo:
                version(test_path_outline) writeln("LineTo(", cmd.args[0], ", ", cmd.args[1], ")");
                nvg.lineTo(cmd.args[0], cmd.args[1]);
                break;
              case cmd.Kind.QuadTo:
                version(test_path_outline) writeln("QuadTo(", cmd.args[0], ", ", cmd.args[1], ", ", cmd.args[2], ", ", cmd.args[3], ")");
                version(test_flatten) {
                  assert(0, "wtf?!");
                } else {
                  nvg.quadTo(cmd.args[0], cmd.args[1], cmd.args[2], cmd.args[3]);
                }
                break;
              case cmd.Kind.BezierTo:
                version(test_path_outline) writeln("BezierTo(", cmd.args[0], ", ", cmd.args[1], ", ", cmd.args[2], ", ", cmd.args[3], ", ", cmd.args[4], ", ", cmd.args[5], ")");
                version(test_flatten) {
                  assert(0, "wtf?!");
                } else {
                  nvg.bezierTo(cmd.args[0], cmd.args[1], cmd.args[2], cmd.args[3], cmd.args[4], cmd.args[5]);
                }
                break;
              case cmd.Kind.End: break; // the thing that should not be
            }
          }
          //xol.clear();
        }
      }
      nvg.fillColor = NVGColor.red;
      nvg.strokeColor = NVGColor.red;
      nvg.strokeWidth = 4;
      nvg.stroke();
    }
  };

  sdmain.eventLoop(0, // no pulse timer required
    delegate (KeyEvent event) {
      if (event == "*-Q" || event == "Escape") { sdmain.close(); return; } // quit on Q, Ctrl+Q, and so on
    },
  );

  flushGui(); // let OS do it's cleanup
}
