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
module gesturespro_test /*is aliced*/;
private:

import arsd.color;
import arsd.simpledisplay;

import iv.alice;
import iv.cmdcongl;
import iv.gengpro1;
import iv.pxclock;
import iv.vfs.io;


// ////////////////////////////////////////////////////////////////////////// //
SimpleWindow sdwin;


// ////////////////////////////////////////////////////////////////////////// //
ulong msgHideTime = 0;
int msgAlpha = -1;
string msgText;


void updateMsg () {
  if (msgAlpha >= 0) {
    if (msgAlpha > 0) {
      if ((msgAlpha += 10) > 255) {
        msgAlpha = -1;
        msgText = null;
      }
    } else {
      if (clockMilli() >= msgHideTime) {
        msgAlpha = 1;
      }
    }
    frameChanged();
  }
}


void showMessage (string msg) {
  if (msg.length == 0) return;
  /+
  ovlMsg = new VLOverlay(msg.length*6+6, 8+6);
  ovlMsg.fillRect(0, 0, ovlMsg.width, ovlMsg.height, rgb2col(25, 69, 247));
  ovlMsg.rect(0, 0, ovlMsg.width, ovlMsg.height, rgb2col(255, 255, 255));
  ovlMsg.rect(1, 1, ovlMsg.width-2, ovlMsg.height-2, rgb2col(0, 0, 0));
  Color fg = rgb2col(255, 255, 255);
  int x = 3;
  foreach (/+auto+/ ch; msg) {
    /*
    switch (ch) {
      case 1: fg = rgb2col(255, 255, 255); break;
      case 2: fg = rgb2col(0, 255, 0); break;
      case 3: fg = rgb2col(255, 255, 0); break;
      case 4: fg = rgb2col(255, 127, 0); break;
      default: break;
    }
    if (ch < 32) continue;
    */
    ovlMsg.drawChar(x, 3, ch, fg);
    x += 6;
  }
  +/
  msgText = msg;
  msgHideTime = clockMilli()+5000;
  msgAlpha = 0;
  frameChanged();
}


// ////////////////////////////////////////////////////////////////////////// //
PTGlyph[] glib;
int nameMaxLen = 0;
int curPattern = -1;
PTGlyph drawnGlyph;
PTGlyph detectedGlyph;
bool helpVisible;


void fixNameMaxLen () {
  nameMaxLen = 0;
  foreach (/*auto*/ g; glib) if (g.name.length > nameMaxLen) nameMaxLen = cast(int)g.name.length;
}


// ////////////////////////////////////////////////////////////////////////// //
int curGlyph = -1;
string curGlyphName;
bool editingName;
string yesNoMessage;


void registerGlyph () {
  if (drawnGlyph !is null && drawnGlyph.valid && curGlyphName.length > 0) {
    auto gg = drawnGlyph.clone;
    gg.normalize(true); // drop original points
    gg.name = curGlyphName;
    usize gpos = usize.max;
    foreach (/*auto*/ idx, /*auto*/ g; glib) if (g.name == curGlyphName) { gpos = idx; break; }
    if (gpos != usize.max) {
      glib[gpos] = gg;
    } else {
      gpos = glib.length;
      glib ~= gg;
    }
    fixNameMaxLen();
    curPattern = cast(int)gpos;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
enum CharWidth = 10;
enum CharHeight = 10;

void frameChanged () {
  if (sdwin is null || sdwin.closed) return;

  {
    auto painter = sdwin.draw();

    void drawText (int x, int y, const(char)[] str...) {
      foreach (immutable char ch; str) {
        foreach (immutable int dy; 0..CharHeight) {
          ushort v = glConFont10.ptr[cast(ubyte)ch*CharHeight+dy];
          foreach (immutable int dx; 0..CharWidth) {
            if (v&0x8000) {
              painter.drawPixel(Point(x+dx, y+dy));
              //painter.drawLine(Point(x+dx, y+dy), Point(x+dx+1, y+dy+1));
            }
            v <<= 1;
          }
        }
        x += CharWidth;
      }
    }

    void helpOverlay () {
      static immutable string[] helpText = [
        "\x1fDemo actions",
        "\x1f------------",
        "\3keyboard:\1",
        " \2F1\1: toggle help",
        " \2F2\1: save library to '\4strokes.dat\1'",
        " \2F3\1: replace library with '\4strokes.dat\1'",
        " \2ESC\1: quit",
        " \2DEL\1: delete selected stroke",
        "",
        "\3mouse:\1",
        " \2LMB\1: select name or start drawing",
        " \2RMB\1: register current stroke as template",
      ];

      static int stlen (string s) {
        int res = 0;
        foreach (immutable char ch; s) if (ch >= 32) ++res;
        return res;
      }

      int maxlen = 0;
      foreach (/*auto*/ s; helpText) {
        auto ln = stlen(s);
        if (ln > maxlen) maxlen = ln;
      }

      int wdt = (maxlen*CharWidth+6);
      int hgt = (CharHeight*cast(int)helpText.length+6);
      int x0 = (sdwin.width-wdt)/2;
      int y0 = (sdwin.height-hgt)/2;

      painter.outlineColor = Color(25, 69, 247);
      painter.fillColor = Color(25, 69, 247);
      painter.drawRectangle(Point(x0, y0), wdt, hgt);
      painter.fillColor = Color.transparent;
      painter.outlineColor = Color(255, 255, 255);
      painter.drawRectangle(Point(x0, y0), wdt, hgt);
      painter.outlineColor = Color.black;
      painter.drawRectangle(Point(x0+1, y0+1), wdt-2, hgt-2);

      foreach (/*auto*/ idx, /*auto*/ s; helpText) {
        if (s.length == 0) continue;
        auto ln = stlen(s)*CharWidth;
        auto x = (wdt-ln)/2;
        auto y = idx*CharHeight+3;
        string st = s;
        if (s[0] == '\x1f') {
          st = s[1..$];
        } else {
          x = 3;
        }
        Color fg = Color(255, 255, 255);
        foreach (/*auto*/ ch; st) {
          switch (ch) {
            case 1: fg = Color(255, 255, 255); break;
            case 2: fg = Color(0, 255, 0); break;
            case 3: fg = Color(255, 255, 0); break;
            case 4: fg = Color(255, 127, 0); break;
            default: break;
          }
          if (ch < 32) continue;
          painter.outlineColor = fg;
          drawText(x0+x, y0+y, ch);
          x += CharWidth;
        }
      }
    }

    void drawStroke (const(PTGlyph) stk) {
      painter.outlineColor = Color(255, 255, 0);
      foreach (uint idx; 1..stk.length) {
        immutable p0 = stk[idx-1], p1 = stk[idx];
        double x0 = p0.x, y0 = p0.y;
        double x1 = p1.x, y1 = p1.y;
        painter.drawLine(Point(cast(int)x0, cast(int)y0), Point(cast(int)x1, cast(int)y1));
      }
    }

    void drawTemplate (const(PTGlyph) stk) {
      if (!stk.valid) return;
      foreach (uint idx; 1..stk.normLength) {
        auto g = cast(ubyte)(255*idx/(stk.normLength-1));
        auto b = cast(ubyte)(255-(255*idx/(stk.normLength-1)));
        immutable p0 = stk.normPoint(idx-1), p1 = stk.normPoint(idx);
        double x0 = p0.x, y0 = p0.y;
        double x1 = p1.x, y1 = p1.y;
        x0 = x0*200+400;
        y0 = y0*200+300;
        x1 = x1*200+400;
        y1 = y1*200+300;
        painter.outlineColor = Color(0, g, b);
        painter.drawLine(Point(cast(int)x0, cast(int)y0), Point(cast(int)x1, cast(int)y1));
      }
    }

    void drawStrokeList (int curptr) {
      int wdt = nameMaxLen*CharWidth+4;
      int hgt = cast(int)(glib.length*CharHeight+4);
      painter.outlineColor = Color.white;
      painter.fillColor = Color.transparent;
      painter.drawRectangle(Point(0, 0), wdt, hgt);
      painter.outlineColor = Color.black;
      painter.drawRectangle(Point(1, 1), wdt-2, hgt-2);
      painter.fillColor = Color.white;
      painter.drawRectangle(Point(2, 2), wdt-4, hgt-4);
      painter.fillColor = Color.transparent;
      foreach (/*auto*/ idx, /*auto*/ g; glib) {
        Color col, bkcol;
        if (g is detectedGlyph) {
          // highlighted
          col = Color(255, 255, 255);
          //bkcol = rgb2col(0, 0, 255);
          bkcol = Color(0, 100, 0);
        } else {
          col = Color(255, 127, 0);
          bkcol = Color(0, 0, 127);
        }
        if (curptr == idx) bkcol = Color(0, 127, 0);
        if (idx == curPattern) col = Color(255, 255, 0);
        painter.outlineColor = bkcol;
        painter.fillColor = bkcol;
        painter.drawRectangle(Point(2, idx*CharHeight+2), wdt-4, CharHeight);
        painter.outlineColor = col;
        painter.fillColor = Color.transparent;
        drawText(2, idx*CharHeight+2, g.name);
      }
    }

    painter.outlineColor = Color.black;
    painter.fillColor = Color.black;
    painter.drawRectangle(Point(0, 0), sdwin.width, sdwin.height);

    if (curPattern >= 0 && curPattern < cast(int)glib.length) drawTemplate(glib[curPattern]);
    drawStrokeList(curGlyph);
    if (drawnGlyph !is null && drawnGlyph.valid) drawStroke(drawnGlyph);
    if (yesNoMessage.length > 0) {
      painter.outlineColor = Color(128, 0, 0);
      painter.fillColor = Color(128, 0, 0);
      painter.drawRectangle(Point(0, sdwin.height-CharHeight), sdwin.width, CharHeight);
      painter.outlineColor = Color(255, 255, 0);
      painter.fillColor = Color.transparent;
      drawText(0, sdwin.height-CharHeight, yesNoMessage);
    } else if (editingName) {
      painter.outlineColor = Color(0, 0, 190);
      painter.fillColor = Color(0, 0, 190);
      painter.drawRectangle(Point(0, sdwin.height-CharHeight), sdwin.width, CharHeight);
      painter.outlineColor = Color(255, 127, 0);
      painter.fillColor = Color.transparent;
      drawText(0, sdwin.height-CharHeight, curGlyphName);
      painter.outlineColor = Color(255, 255, 0);
      painter.fillColor = Color(255, 255, 0);
      painter.drawRectangle(Point(CharWidth*cast(int)curGlyphName.length, sdwin.height-CharHeight), CharWidth, CharHeight);
      painter.outlineColor = Color(255, 127, 0);
      painter.fillColor = Color.transparent;
    }
    if (msgAlpha >= 0 && msgText.length) {
      int y = sdwin.height-CharHeight;
      painter.outlineColor = Color(60, 60, 90);
      painter.fillColor = Color(60, 60, 90);
      painter.drawRectangle(Point(0, y), sdwin.width, CharHeight);
      painter.outlineColor = Color(255, 255, 255);
      painter.fillColor = Color.transparent;
      drawText((sdwin.width-CharWidth*cast(int)msgText.length)/2, y, msgText);
      painter.fillColor = Color.transparent;
    }
    if (helpVisible) {
      helpOverlay();
    }
  }
  flushGui();
}


// ////////////////////////////////////////////////////////////////////////// //
int mdown = 0;


int getSelectedGlyph (int x, int y) {
  int wdt = nameMaxLen*CharWidth+4;
  int hgt = cast(int)(glib.length*CharHeight+4);
  if (x >= 2 && y >= 2 && x < wdt-4 && y < hgt-4) {
    return cast(int)((y-2)/CharHeight);
  } else {
    return -1;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
void main (string[] args) {
  glib = gstLibLoad(VFile("strokes.dat"));
  fixNameMaxLen();
  writefln("%s strokes loaded", glib.length);
  //gstLibSave(File("strokes_new.dat", "w"), glib[]);
  sdwin = new SimpleWindow(800, 600, "Protractor Gesture Recognizer test");
  frameChanged();
  sdwin.eventLoop(100,
    // pulse timer
    delegate () {
      updateMsg();
    },
    // mouse events
    delegate (MouseEvent event) {
      switch (event.type) {
        case MouseEventType.buttonPressed:
          if (yesNoMessage.length > 0 || editingName) break;
          if (mdown == 0) {
            if (event.button == MouseButton.left) {
              auto ng = getSelectedGlyph(event.x, event.y);
              if (ng >= 0) {
                curPattern = ng;
                frameChanged();
                return;
              }
            }
            if (event.button == MouseButton.left || event.button == MouseButton.right) {
              mdown = (event.button == MouseButton.left ? 1 : 2);
              detectedGlyph = null;
              drawnGlyph = new PTGlyph();
              drawnGlyph.appendPoint(event.x, event.y);
              frameChanged();
            }
          }
          break;
        case MouseEventType.buttonReleased:
          if (yesNoMessage.length > 0 || editingName) return;
          if (mdown != 0) {
            if (drawnGlyph.valid) {
              if (mdown == 1) {
                GengFloat score;
                detectedGlyph = cast(PTGlyph)drawnGlyph.findMatch(glib[], &score); // sorry
                if (detectedGlyph !is null && detectedGlyph.name.length > 0) {
                  showMessage("glyph: '"~detectedGlyph.name~"'");
                  writeln("glyph: '", detectedGlyph.name, "'; score: ", score);
                }
              } else {
                curGlyphName = (curPattern >= 0 ? glib[curPattern].name : "");
                editingName = true;
              }
            } else {
              drawnGlyph = null;
            }
            frameChanged();
          }
          mdown = 0;
          break;
        case MouseEventType.motion:
          if (yesNoMessage.length > 0 || editingName) break;
          if (mdown == 0) {
            auto ng = getSelectedGlyph(event.x, event.y);
            if (ng != curGlyph) {
              curGlyph = ng;
              frameChanged();
            }
          } else if (mdown != 0) {
            drawnGlyph.appendPoint(event.x, event.y);
            frameChanged();
          }
          break;
        default:
      }
    },
    // keyboard events
    delegate (KeyEvent event) {
      if (!event.pressed) return;
      if (helpVisible) {
        if (event == "Escape" || event == "F1") {
          helpVisible = false;
          frameChanged();
        }
        return;
      }
      if (yesNoMessage.length > 0) {
        if (event == "Escape") {
          yesNoMessage = null;
        } else if (event == "Enter") {
          glib = glib[0..curPattern]~glib[curPattern+1..$];
          detectedGlyph = null;
          curPattern = -1;
          yesNoMessage = null;
        }
        frameChanged();
        return;
      }
      if (event == "C-Q") { sdwin.close(); return; }
      if (event == "F1") {
        helpVisible = true;
        frameChanged();
        return;
      }
      if (event == "F2") {
        gstLibSave(VFile("strokes.dat", "w"), glib[]);
        writefln("%s strokes saved", glib.length);
        frameChanged();
        return;
      }
      if (event == "F3") {
        glib = gstLibLoad(VFile("strokes.dat"));
        fixNameMaxLen();
        writefln("%s strokes loaded", glib.length);
        detectedGlyph = null;
        curPattern = -1;
        drawnGlyph = null;
        frameChanged();
        return;
      }
      if (event == "Delete") {
        if (curPattern >= 0) {
          yesNoMessage = "Remove '"~glib[curPattern].name~"'?";
          frameChanged();
          return;
        }
      }
    },
    // characters
    delegate (dchar ch) {
      if (!editingName) return;
      if (ch == 27) { editingName = false; frameChanged(); return; }
      if (ch == 8) {
        if (curGlyphName.length > 0) curGlyphName = curGlyphName[0..$-1];
        frameChanged();
        return;
      }
      if (ch == 25) {
        // C-Y
        curGlyphName = null;
        frameChanged();
        return;
      }
      if (ch == 10 || ch == 13) {
        registerGlyph();
        editingName = false;
        return;
      }
      if (ch >= ' ' && ch < 127) {
        curGlyphName ~= cast(char)ch;
        frameChanged();
        return;
      }
    },
  );
}
