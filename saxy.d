/* Invisible Vector Library
 * coded by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
 * Understanding is not required. Only obedience.
 *
 * This software is provided 'as-is', without any express or implied
 * warranty.  In no event will the authors be held liable for any damages
 * arising from the use of this software.
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 3. This notice may not be removed or altered from any source distribution.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 */
module iv.saxy;

import std.range;
static if (is(typeof({import iv.vfs;}))) {
  import iv.vfs;
  import iv.strex;
} else {
  // check if a given stream supports `rawRead()`.
  // it's enough to support `void[] rawRead (void[] buf)`
  private enum isReadableStream(T) = is(typeof((inout int=0) {
    auto t = T.init;
    ubyte[1] b;
    auto v = cast(void[])b;
    t.rawRead(v);
  }));
}


//alias XmlString = const(char)[];


//*WARNING*: attr keys are *NOT* strings!
void xmparse(ST) (auto ref ST fl,
  scope void delegate (char[] name, char[][string] attrs) tagStart,
  scope void delegate (char[] name) tagEnd,
  scope void delegate (char[] text) content,
) if (isReadableStream!ST || (isInputRange!ST && is(ElementEncodingType!ST == char))) {
  char[] buf;
  uint bufpos;
  char[][string] attrs;
  scope(exit) {
    attrs.destroy;
    buf.destroy;
  }

  static bool isValidNameChar() (char ch) {
    return
      (ch >= '0' && ch <= '9') ||
      (ch >= 'A' && ch <= 'Z') ||
      (ch >= 'a' && ch <= 'z') ||
      ch == '_' || ch == '-' || ch == ':';
  }

  int tagLevel = 0;

  void bufPut (const(char)[] chars...) {
    if (/*tagLevel &&*/ chars.length) {
      if (chars.length+bufpos > buf.length) {
        if (chars.length+bufpos >= int.max) throw new Exception("out of memory in xml parser");
        buf.assumeSafeAppend;
        buf.length = ((chars.length+bufpos)|0x3ff)+1;
      }
      buf[bufpos..bufpos+chars.length] = chars[];
      bufpos += chars.length;
    }
  }

  void clearBuf () {
    bufpos = 0;
  }

  char curCh;
  bool eof;

  void skipChar () {
    if (!eof) {
      static if (isReadableStream!ST) {
        if (fl.rawRead((&curCh)[0..1]).length == 0) {
          eof = true;
          curCh = 0;
        } else {
          if (curCh == 0) curCh = ' ';
        }
      } else {
        if (fl.empty) {
          eof = true;
          curCh = 0;
        } else {
          curCh = fl.front;
          fl.popFront;
          if (curCh == 0) curCh = ' ';
        }
      }
    }
  }

  void parseCData () {
    clearBuf();
    while (!eof) {
      if (bufpos >= 3 && buf.ptr[bufpos-1] == '>' && buf.ptr[bufpos-2] == ']' && buf.ptr[bufpos-3] == ']') {
        bufpos -= 3;
        break;
      }
      bufPut(curCh);
      skipChar();
    }
    if (tagLevel && bufpos > 0 && content !is null) content(buf[0..bufpos]);
    clearBuf();
  }

  void parseContent () {
    clearBuf();
    while (!eof) {
      if (curCh == '<') break;
      if (curCh != '&') {
        bufPut(curCh);
        skipChar();
      } else {
        bufPut(curCh);
        auto xpos = bufpos;
        skipChar();
        while (!eof && curCh != '<' && curCh != ';' && bufpos-xpos < 8) {
          bufPut(curCh);
          skipChar();
        }
        if (!eof && curCh == ';' && bufpos > xpos) {
          switch (buf[xpos..bufpos]) {
            case "lt": bufpos = xpos-1; bufPut('<'); break;
            case "gt": bufpos = xpos-1; bufPut('>'); break;
            case "amp": bufpos = xpos-1; bufPut('&'); break;
            case "quot": bufpos = xpos-1; bufPut('"'); break;
            default: bufPut(curCh); break;
          }
          skipChar();
        }
      }
    }
    if (tagLevel && bufpos > 0 && content !is null) content(buf[0..bufpos]);
    clearBuf();
  }

  void parseTag () {
    assert(!eof && curCh == '<');
    clearBuf();
    skipChar();
    if (eof) throw new Exception("invalid xml");
    bool inlineClose = false, closeTag = false;
    if (curCh == '!') {
      // either CDATA, or comment-like
      skipChar();
      if (curCh == '[') {
        // this *must* be CDATA
        skipChar();
        if (curCh != 'C') throw new Exception("invalid xml");
        skipChar();
        if (curCh != 'D') throw new Exception("invalid xml");
        skipChar();
        if (curCh != 'A') throw new Exception("invalid xml");
        skipChar();
        if (curCh != 'T') throw new Exception("invalid xml");
        skipChar();
        if (curCh != 'A') throw new Exception("invalid xml");
        skipChar();
        if (curCh != '[') throw new Exception("invalid xml");
        clearBuf();
        parseCData();
        return;
      } else if (curCh == '-') {
        // comment
        skipChar();
        if (curCh != '-') throw new Exception("invalid xml");
        skipChar();
        for (;;) {
          if (eof) throw new Exception("invalid xml");
          if (curCh == '-') {
            skipChar();
            if (curCh == '-') {
              skipChar();
              if (curCh == '>') {
                skipChar();
                break;
              }
            }
          } else {
            skipChar();
          }
        }
        clearBuf();
        return;
      } else {
        // !tag
        bufPut('!');
      }
    } else {
      if (curCh == '/') { closeTag = true; skipChar(); }
      if (curCh == '?') { bufPut(curCh); skipChar(); }
    }
    if (eof || !isValidNameChar(curCh)) throw new Exception("invalid xml");
    while (isValidNameChar(curCh)) {
      bufPut(curCh);
      skipChar();
    }
    //{ import std.stdio; writeln("TAG: ", buf[0..bufpos].quote); }
    // now parse attributes
    scope(exit) attrs.clear();
    while (!eof && curCh <= ' ') skipChar();
    // closing tag?
    auto tagnameend = bufpos;
    if (!closeTag) {
      // attr=["]name["]
      // read the whole tag, so we can add AA items without anchoring stale memory
      if (eof) throw new Exception("invalid xml");
      if (curCh != '/' && curCh != '>' && curCh != '?') {
        bufPut(' ');
        auto stpos = bufpos;
        char qch = 0;
        for (;;) {
          if (eof) throw new Exception("invalid xml");
          if (qch) {
            if (curCh == qch) qch = 0;
            if (curCh == '&') {
              bufPut(curCh);
              auto xpos = bufpos;
              skipChar();
              while (!eof && curCh != qch && curCh != ';' && bufpos-xpos < 8) {
                bufPut(curCh);
                skipChar();
              }
              if (!eof && curCh == ';' && bufpos > xpos) {
                switch (buf[xpos..bufpos]) {
                  case "lt": bufpos = xpos-1; bufPut('<'); break;
                  case "gt": bufpos = xpos-1; bufPut('>'); break;
                  case "amp": bufpos = xpos-1; bufPut('&'); break;
                  case "quot": bufpos = xpos-1; bufPut('"'); break;
                  default: bufPut(curCh); break;
                }
                skipChar();
              }
              continue;
            }
          } else {
            if (curCh == '/' || curCh == '>' || curCh == '?') break;
            if (curCh == '"' || curCh == '\'') qch = curCh;
          }
          bufPut(curCh);
          skipChar();
        }
        // now parse attributes
        while (stpos < bufpos) {
          while (stpos < bufpos && buf.ptr[stpos] <= ' ') ++stpos;
          if (stpos >= bufpos) break;
          //{ import std.stdio; writeln(": ", buf[stpos..bufpos].quote); }
          if (!isValidNameChar(buf.ptr[stpos])) throw new Exception("invalid xml");
          auto nst = stpos;
          while (stpos < bufpos && isValidNameChar(buf.ptr[stpos])) ++stpos;
          string aname = cast(string)(buf[nst..stpos]); // unsafe cast, but meh...
          while (stpos < bufpos && buf.ptr[stpos] <= ' ') ++stpos;
          if (stpos >= bufpos) { attrs[aname] = null; break; } // no value
          if (buf.ptr[stpos] != '=') { attrs[aname] = null; continue; } // no value
          ++stpos;
          if (stpos >= bufpos) { attrs[aname] = buf[bufpos..bufpos]; break; }
          if (buf.ptr[stpos] == '"' || buf.ptr[stpos] == '\'') {
            auto ech = buf.ptr[stpos];
            nst = ++stpos;
            while (stpos < bufpos && buf.ptr[stpos] != ech) ++stpos;
            if (stpos >= bufpos) throw new Exception("invalid xml");
            attrs[aname] = buf[nst..stpos];
            ++stpos;
          } else {
            nst = stpos;
            while (stpos < bufpos && buf.ptr[stpos] > ' ') ++stpos;
            attrs[aname] = buf[nst..stpos];
          }
        }
      }
    }
    if (curCh == '?') {
      if (buf.ptr[0] != '?') throw new Exception("invalid xml");
      skipChar();
      inlineClose = true;
    } else if (buf.ptr[0] != '!') {
      if (curCh == '/') { inlineClose = true; skipChar(); }
    } else {
      inlineClose = true;
    }
    if (curCh != '>') throw new Exception("invalid xml");
    skipChar();
    if (closeTag) {
      if (inlineClose) throw new Exception("invalid xml");
      if (tagEnd !is null) tagEnd(buf[0..tagnameend]);
      --tagLevel;
    } else {
      ++tagLevel;
      if (tagStart !is null) tagStart(buf[0..tagnameend], attrs);
      if (inlineClose) {
        if (tagEnd !is null) tagEnd(buf[0..tagnameend]);
        --tagLevel;
      }
    }
  }

  while (!eof) {
    //writeln("*** ", tagLevel, " ***");
    parseContent();
    if (eof) break;
    if (curCh == '<') {
      parseTag();
      if (tagLevel < 0) throw new Exception("invalid xml");
    }
  }

  if (tagLevel != 0) throw new Exception("invalid xml");
}
