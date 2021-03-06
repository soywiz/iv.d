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
// linux tty utilities
module iv.rawtty /*is aliced*/;

import iv.alice;
import core.sys.posix.termios : termios;
import iv.strex : strEquCI;
import iv.utfutil;

public import iv.termrgb;


// ////////////////////////////////////////////////////////////////////////// //
alias TtyRgb2Color = TtyRGB;
alias ttyRgb2Color = ttyRGB;


// ////////////////////////////////////////////////////////////////////////// //
private __gshared termios origMode;
private __gshared bool doRestoreOrig = false;
private shared bool inRawMode = false;

private class XLock {}


// ////////////////////////////////////////////////////////////////////////// //
/// TTY mode
enum TTYMode {
  Bad = -1, /// some error occured
  Normal, /// normal ('cooked') mode
  Raw /// 'raw' mode
}


__gshared bool xtermMetaSendsEscape = true; /// you should add `XTerm*metaSendsEscape: true` to "~/.Xdefaults"
private __gshared bool ttyIsFuckedFlag = false;


// ////////////////////////////////////////////////////////////////////////// //
/// is TTY fucked with utfuck?
@property bool ttyIsUtfucked () nothrow @trusted @nogc { pragma(inline, true); return ttyIsFuckedFlag; }


// ////////////////////////////////////////////////////////////////////////// //
/// return TTY width
@property int ttyWidth () nothrow @trusted @nogc {
  if (!ttyIsRedirected) {
    import core.sys.posix.sys.ioctl : ioctl, winsize, TIOCGWINSZ;
    winsize sz = void;
    if (ioctl(1, TIOCGWINSZ, &sz) != -1) return sz.ws_col;
  }
  return 80;
}


/// return TTY height
@property int ttyHeight () nothrow @trusted @nogc {
  if (!ttyIsRedirected) {
    import core.sys.posix.sys.ioctl : ioctl, winsize, TIOCGWINSZ;
    winsize sz = void;
    if (ioctl(1, TIOCGWINSZ, &sz) != -1) return sz.ws_row;
    return sz.ws_row;
  }
  return 25;
}


// ////////////////////////////////////////////////////////////////////////// //
void ttyRawWrite (const(char)[] str...) nothrow @trusted @nogc {
  import core.sys.posix.unistd : write;
  if (str.length) write(1, str.ptr, str.length);
}


void ttyRawWriteInt(T) (T n) nothrow @trusted @nogc if (__traits(isIntegral, T) && !is(T == char) && !is(T == wchar) && !is(T == dchar) && !is(T == bool) && !is(T == enum)) {
  import core.stdc.stdio : snprintf;
  import core.sys.posix.unistd : write;
  char[64] buf = void;
  static if (__traits(isUnsigned, T)) {
    static if (T.sizeof > 4) {
      auto len = snprintf(buf.ptr, buf.length, "%llu", n);
    } else {
      auto len = snprintf(buf.ptr, buf.length, "%u", cast(uint)n);
    }
  } else {
    static if (T.sizeof > 4) {
      auto len = snprintf(buf.ptr, buf.length, "%lld", n);
    } else {
      auto len = snprintf(buf.ptr, buf.length, "%d", cast(int)n);
    }
  }
  if (len > 0) write(1, buf.ptr, len);
}


void ttyBeep () nothrow @trusted @nogc {
  import core.sys.posix.unistd : write;
  enum str = "\x07";
  write(1, str.ptr, str.length);
}


void ttyEnableBracketedPaste () nothrow @trusted @nogc {
  import core.sys.posix.unistd : write;
  enum str = "\x1b[?2004h";
  write(1, str.ptr, str.length);
}


void ttyDisableBracketedPaste () nothrow @trusted @nogc {
  import core.sys.posix.unistd : write;
  enum str = "\x1b[?2004l";
  write(1, str.ptr, str.length);
}


void ttyEnableFocusReports () nothrow @trusted @nogc {
  import core.sys.posix.unistd : write;
  enum str = "\x1b[?1004h";
  write(1, str.ptr, str.length);
}


void ttyDisableFocusReports () nothrow @trusted @nogc {
  import core.sys.posix.unistd : write;
  enum str = "\x1b[?1004l";
  write(1, str.ptr, str.length);
}


void ttyEnableMouseReports () nothrow @trusted @nogc {
  import core.sys.posix.unistd : write;
  enum str = "\x1b[?1000h\x1b[?1006h\x1b[?1002h";
  write(1, str.ptr, str.length);
}


void ttyDisableMouseReports () nothrow @trusted @nogc {
  import core.sys.posix.unistd : write;
  enum str = "\x1b[?1002l\x1b[?1006l\x1b[?1000l";
  write(1, str.ptr, str.length);
}


// ////////////////////////////////////////////////////////////////////////// //
/// get current TTY mode
TTYMode ttyGetMode () nothrow @trusted @nogc {
  import core.atomic;
  return (atomicLoad(inRawMode) ? TTYMode.Raw : TTYMode.Normal);
}


/// Restore terminal mode we had at program startup
void ttyRestoreOrigMode () {
  import core.atomic;
  import core.sys.posix.termios : tcflush, tcsetattr;
  import core.sys.posix.termios : TCIOFLUSH, TCSAFLUSH;
  import core.sys.posix.unistd : STDIN_FILENO;
  //tcflush(STDIN_FILENO, TCIOFLUSH);
  if (doRestoreOrig) tcsetattr(STDIN_FILENO, TCSAFLUSH, &origMode);
  atomicStore(inRawMode, false);
}


/// returns previous mode or Bad
TTYMode ttySetNormal () @trusted @nogc {
  import core.atomic;
  if (!doRestoreOrig) return TTYMode.Bad;
  synchronized(XLock.classinfo) {
    if (atomicLoad(inRawMode)) {
      import core.sys.posix.termios : tcflush, tcsetattr;
      import core.sys.posix.termios : TCIOFLUSH, TCSAFLUSH;
      import core.sys.posix.unistd : STDIN_FILENO;
      //tcflush(STDIN_FILENO, TCIOFLUSH);
      if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &origMode) < 0) return TTYMode.Bad;
      atomicStore(inRawMode, false);
      return TTYMode.Raw;
    }
    return TTYMode.Normal;
  }
}


/// returns previous mode or Bad
TTYMode ttySetRaw (bool waitkey=true) @trusted @nogc {
  import core.atomic;
  if (ttyIsRedirected || !doRestoreOrig) return TTYMode.Bad;
  synchronized(XLock.classinfo) {
    if (!atomicLoad(inRawMode)) {
      //import core.sys.posix.termios : tcflush, tcsetattr;
      //import core.sys.posix.termios : TCIOFLUSH, TCSAFLUSH;
      //import core.sys.posix.termios : BRKINT, CS8, ECHO, ICANON, IEXTEN, INPCK, ISIG, ISTRIP, IXOFF, IGNCR, INLCR, ONLCR, OPOST, VMIN, VTIME;
      import core.sys.posix.termios;
      import core.sys.posix.unistd : STDIN_FILENO;
      import core.stdc.string : memset;
      enum IUCLC = 512; //0001000
      //termios raw = origMode; // modify the original mode
      termios raw = void;
      memset(&raw, 0, raw.sizeof);
      //tcflush(STDIN_FILENO, TCIOFLUSH);
      raw.c_iflag = IGNBRK;
      // output modes: disable post processing
      raw.c_oflag = OPOST|ONLCR;
      // control modes: set 8 bit chars
      raw.c_cflag = CS8|CLOCAL;
      // control chars: set return condition: min number of bytes and timer; we want read to return every single byte, without timeout
      raw.c_cc[VMIN] = (waitkey ? 1 : 0); // wait/poll mode
      raw.c_cc[VTIME] = 0; // no timer
      // put terminal in raw mode after flushing
      if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) < 0) return TTYMode.Bad;
      {
        import core.sys.posix.unistd : write;
        // G0 is ASCII, G1 is graphics
        enum setupStr = "\x1b(B\x1b)0\x0f";
        write(1, setupStr.ptr, setupStr.length);
      }
      atomicStore(inRawMode, true);
      return TTYMode.Normal;
    }
    return TTYMode.Raw;
  }
}


/// change TTY mode if possible
/// returns previous mode or Bad
TTYMode ttySetMode (TTYMode mode) @trusted @nogc {
  // check what we can without locking
  if (mode == TTYMode.Bad) return TTYMode.Bad;
  if (ttyIsRedirected) return (mode == TTYMode.Normal ? TTYMode.Normal : TTYMode.Bad);
  synchronized(XLock.classinfo) return (mode == TTYMode.Normal ? ttySetNormal() : ttySetRaw());
}


// ////////////////////////////////////////////////////////////////////////// //
/// set wait/poll mode
bool ttySetWaitKey (bool doWait) @trusted @nogc {
  import core.atomic;
  if (ttyIsRedirected) return false;
  synchronized(XLock.classinfo) {
    if (atomicLoad(inRawMode)) {
      import core.sys.posix.termios : tcflush, tcgetattr, tcsetattr;
      import core.sys.posix.termios : TCIOFLUSH, TCSAFLUSH;
      import core.sys.posix.termios : VMIN;
      import core.sys.posix.unistd : STDIN_FILENO;
      termios raw;
      //tcflush(STDIN_FILENO, TCIOFLUSH);
      if (tcgetattr(STDIN_FILENO, &raw) != 0) return false; //redirected = false;
      raw.c_cc[VMIN] = (doWait ? 1 : 0); // wait/poll mode
      if (tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) < 0) return false;
      return true;
    }
  }
  return false;
}


// ////////////////////////////////////////////////////////////////////////// //
/**
 * Wait for keypress.
 *
 * Params:
 *  toMSec = timeout in milliseconds; <0: infinite; 0: don't wait; default is -1
 *
 * Returns:
 *  true if key was pressed, false if no key was pressed in the given time
 */
bool ttyWaitKey (int toMSec=-1) @trusted @nogc {
  import core.atomic;
  if (!ttyIsRedirected && atomicLoad(inRawMode)) {
    import core.sys.posix.sys.select : fd_set, select, timeval, FD_ISSET, FD_SET, FD_ZERO;
    import core.sys.posix.unistd : STDIN_FILENO;
    timeval tv;
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds); //STDIN_FILENO is 0
    if (toMSec <= 0) {
      tv.tv_sec = 0;
      tv.tv_usec = 0;
    } else {
      tv.tv_sec = cast(int)(toMSec/1000);
      tv.tv_usec = (toMSec%1000)*1000;
    }
    select(STDIN_FILENO+1, &fds, null, null, (toMSec < 0 ? null : &tv));
    return FD_ISSET(STDIN_FILENO, &fds);
  }
  return false;
}


/**
 * Check if key was pressed. Don't block.
 *
 * Returns:
 *  true if key was pressed, false if no key was pressed
 */
bool ttyIsKeyHit () @trusted @nogc { return ttyWaitKey(0); }


/**
 * Read one byte from stdin.
 *
 * Params:
 *  toMSec = timeout in milliseconds; <0: infinite; 0: don't wait; default is -1
 *
 * Returns:
 *  read byte or -1 on error/timeout
 */
int ttyReadKeyByte (int toMSec=-1) @trusted @nogc {
  import core.atomic;
  if (!ttyIsRedirected && atomicLoad(inRawMode)) {
    import core.sys.posix.unistd : read, STDIN_FILENO;
    ubyte res;
    if (toMSec >= 0) {
      synchronized(XLock.classinfo) if (ttyWaitKey(toMSec) && read(STDIN_FILENO, &res, 1) == 1) return res;
    } else {
      if (read(STDIN_FILENO, &res, 1) == 1) {
        //{ import core.stdc.stdio; if (res > 32 && res != 127) printf("[%c]\n", res); else printf("{%d}\n", res); }
        return res;
      }
    }
  }
  return -1;
}


// ////////////////////////////////////////////////////////////////////////// //
/// pressed key info
public align(1) struct TtyEvent {
align(1): // make it tightly packed
  ///
  enum Key : ubyte {
    None, ///
    Error, /// error reading key
    Unknown, /// can't interpret escape code

    Char, ///

    // for bracketed paste mode
    PasteStart,
    PasteEnd,

    ModChar, /// char with some modifier

    Up, ///
    Down, ///
    Left, ///
    Right, ///
    Insert, ///
    Delete, ///
    PageUp, ///
    PageDown, ///
    Home, ///
    End, ///

    Escape, ///
    Backspace, ///
    Tab, ///
    Enter, ///

    Pad5, /// xterm can return this

    F1, ///
    F2, ///
    F3, ///
    F4, ///
    F5, ///
    F6, ///
    F7, ///
    F8, ///
    F9, ///
    F10, ///
    F11, ///
    F12, ///

    //A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z,
    //N0, N1, N2, N3, N4, N5, N6, N7, N8, N9,

    MLeftDown, ///
    MLeftUp, ///
    MLeftMotion, ///
    MMiddleDown, ///
    MMiddleUp, ///
    MMiddleMotion, ///
    MRightDown, ///
    MRightUp, ///
    MRightMotion, ///

    MWheelUp, ///
    MWheelDown, ///

    MMotion, /// mouse motion without buttons, not read from tty by now, but can be useful for other backends

    // synthesized events, used in tui
    MLeftClick, ///
    MMiddleClick, ///
    MRightClick, ///

    MLeftDouble, ///
    MMiddleDouble, ///
    MRightDouble, ///

    FocusIn, ///
    FocusOut, ///
  }

   ///
  enum ModFlag : ubyte {
    Ctrl  = 1<<0, ///
    Alt   = 1<<1, ///
    Shift = 1<<2, ///
  }

   ///
  enum MButton : int {
    None = 0, ///
    Left = 1, ///
    Middle = 2, ///
    Right = 3, ///
    WheelUp = 4, ///
    WheelDown = 5, ///
    First = Left, ///
  }

  Key key; /// key type/sym
  ubyte mods; /// set of ModFlag
  dchar ch = 0; /// can be 0 for special key
  short x, y; /// for mouse reports
  //void* udata; /// arbitrary user data

  @property const pure nothrow @safe @nogc {
    ///
    MButton button () { pragma(inline, true); return
      key == Key.MLeftDown || key == Key.MLeftUp || key == Key.MLeftMotion || key == Key.MLeftClick || key == Key.MLeftDouble ? MButton.Left :
      key == Key.MRightDown || key == Key.MRightUp || key == Key.MRightMotion || key == Key.MRightClick || key == Key.MRightDouble ? MButton.Right :
      key == Key.MMiddleDown || key == Key.MMiddleUp || key == Key.MMiddleMotion || key == Key.MMiddleClick || key == Key.MMiddleDouble ? MButton.Middle :
      key == Key.MWheelUp ? MButton.WheelUp :
      key == Key.MWheelDown ? MButton.WheelDown :
      MButton.None;
    }
    bool mouse () { pragma(inline, true); return (key >= Key.MLeftDown && key <= Key.MRightDouble); } ///
    bool mpress () { pragma(inline, true); return (key == Key.MLeftDown || key == Key.MRightDown || key == Key.MMiddleDown); } ///
    bool mrelease () { pragma(inline, true); return (key == Key.MLeftUp || key == Key.MRightUp || key == Key.MMiddleUp); } ///
    bool mclick () { pragma(inline, true); return (key == Key.MLeftClick || key == Key.MRightClick || key == Key.MMiddleClick); } ///
    bool mdouble () { pragma(inline, true); return (key == Key.MLeftDouble || key == Key.MRightDouble || key == Key.MMiddleDouble); } ///
    bool mmotion () { pragma(inline, true); return (key == Key.MLeftMotion || key == Key.MRightMotion || key == Key.MMiddleMotion || key == Key.MMotion); } ///
    bool mwheel () { pragma(inline, true); return (key == Key.MWheelUp || key == Key.MWheelDown); } ///
    bool focusin () { pragma(inline, true); return (key == Key.FocusIn); } ///
    bool focusout () { pragma(inline, true); return (key == Key.FocusOut); } ///
    bool ctrl () { pragma(inline, true); return ((mods&ModFlag.Ctrl) != 0); } ///
    bool alt () { pragma(inline, true); return ((mods&ModFlag.Alt) != 0); } ///
    bool shift () { pragma(inline, true); return ((mods&ModFlag.Shift) != 0); } ///
  }

  @property pure nothrow @safe @nogc {
    void ctrl (bool v) { pragma(inline, true); if (v) mods |= ModFlag.Ctrl; else mods &= ~(ModFlag.Ctrl); } ///
    void alt (bool v) { pragma(inline, true); if (v) mods |= ModFlag.Alt; else mods &= ~(ModFlag.Alt); } ///
    void shift (bool v) { pragma(inline, true); if (v) mods |= ModFlag.Shift; else mods &= ~(ModFlag.Shift); } ///
  }

  this (const(char)[] s) pure nothrow @safe @nogc {
    if (TtyEvent.parse(this, s).length != 0) {
      key = Key.Error;
      mods = 0;
      ch = 0;
    }
  }

  bool opEquals (in TtyEvent k) const pure nothrow @safe @nogc {
    pragma(inline, true);
    return
      (key == k.key ?
       (key == Key.Char ? (ch == k.ch) :
        key == Key.ModChar ? (mods == k.mods && ch == k.ch) :
        //key >= Key.MLeftDown && key <= MWheelDown ? true :
        key > Key.ModChar ? (mods == k.mods) :
        true
       ) : false
      );
  }

  bool opEquals (const(char)[] s) const pure nothrow @safe @nogc {
    TtyEvent k;
    if (TtyEvent.parse(k, s).length != 0) return false;
    return (k == this);
  }

  ///
  string toString () const nothrow {
    char[128] buf = void;
    return toCharBuf(buf[]).idup;
  }

  ///
  char[] toCharBuf (char[] dest) const nothrow @trusted @nogc {
    static immutable string hexD = "0123456789abcdef";
    int dpos = 0;
    void put (const(char)[] s...) nothrow @nogc {
      foreach (char ch; s) {
        if (dpos >= dest.length) break;
        dest.ptr[dpos++] = ch;
      }
    }
    void putMods () nothrow @nogc {
      if (ctrl) put("C-");
      if (alt) put("M-");
      if (shift) put("S-");
    }
    if (key == Key.ModChar) putMods();
    if (key == Key.Char || key == Key.ModChar) {
      if (ch < ' ' || ch == 127) {
        put("x");
        put(hexD.ptr[(ch>>4)&0x0f]);
        put(hexD.ptr[ch&0x0f]);
      } else if (ch == ' ') {
        put("space");
      } else if (ch < 256) {
        put(cast(char)ch);
      } else if (ch <= 0xffff) {
        put("u");
        put(hexD.ptr[(ch>>12)&0x0f]);
        put(hexD.ptr[(ch>>8)&0x0f]);
        put(hexD.ptr[(ch>>4)&0x0f]);
        put(hexD.ptr[ch&0x0f]);
      } else {
        put("error");
      }
      return dest[0..dpos];
    }
    if (key == Key.None) { put("none"); return dest[0..dpos]; }
    if (key == Key.Error) { put("error"); return dest[0..dpos]; }
    if (key == Key.Unknown) { put("unknown"); return dest[0..dpos]; }
    foreach (string kn; __traits(allMembers, TtyEvent.Key)) {
      if (__traits(getMember, TtyEvent.Key, kn) == key) {
        putMods();
        put(kn);
        return dest[0..dpos];
      }
    }
    put("error");
    return dest[0..dpos];
  }

  /** parse key name. get first word, return rest of the string (with trailing spaces removed)
   *
   * "C-<home>" (emacs-like syntax is recognized)
   *
   * "C-M-x"
   *
   * mods: C(trl), M(eta:alt), S(hift)
   *
   * `key` will be `TtyEvent.Key.Error` on error, `TtyEvent.Key.None` on empty string
   */
  static T parse(T) (out TtyEvent key, T s) pure nothrow @trusted @nogc if (is(T : const(char)[])) {
    static if (is(T == typeof(null))) {
      return null;
    } else {
      while (s.length && s.ptr[0] <= ' ') s = s[1..$];
      if (s.length == 0) return s; // no more
      // get space-delimited word
      int pos = 1; // 0 is always non-space here
      while (pos < s.length && s.ptr[pos] > ' ') { if (++pos >= 1024) return s; }
      auto olds = s; // return this in case of error
      const(char)[] str = s[0..pos]; // string to parse
      // `s` will be our result; remove leading spaces for convenience
      while (pos < s.length && s.ptr[pos] <= ' ') ++pos;
      s = s[pos..$];
      // parse word
      while (str.length > 0) {
        if (str.length >= 2 && str.ptr[1] == '-') {
          // modifier
          switch (str.ptr[0]) {
            case 'C': case 'c': key.ctrl = true; break;
            case 'M': case 'm': key.alt = true; break;
            case 'S': case 's': key.shift = true; break;
            default: goto error; // unknown modifier
          }
          str = str[2..$];
        } else {
          // key
          if (str.length > 1 && str.ptr[0] == '^') {
            // ^A means C-A
            key.ctrl = true;
            str = str[1..$];
          } else if (str.length > 2 && str.ptr[0] == '<' && str[$-1] == '>') {
            str = str[1..$-1];
          }
          if (str.length == 0) goto error; // just in case
          if (str.strEquCI("space")) str = " ";
          if (str.length == 1) {
            // single char
            key.ch = str.ptr[0];
            if (key.ctrl || key.alt) {
              key.key = TtyEvent.Key.ModChar;
              if (key.ch >= 'a' && key.ch <= 'z') key.ch -= 32; // toupper
            } else {
              key.key = TtyEvent.Key.Char;
              if (key.shift) {
                if (key.ch >= 'a' && key.ch <= 'z') key.ch -= 32; // toupper
                else switch (key.ch) {
                  case '`': key.ch = '~'; break;
                  case '1': key.ch = '!'; break;
                  case '2': key.ch = '@'; break;
                  case '3': key.ch = '#'; break;
                  case '4': key.ch = '$'; break;
                  case '5': key.ch = '%'; break;
                  case '6': key.ch = '^'; break;
                  case '7': key.ch = '&'; break;
                  case '8': key.ch = '*'; break;
                  case '9': key.ch = '('; break;
                  case '0': key.ch = ')'; break;
                  case '-': key.ch = '_'; break;
                  case '=': key.ch = '+'; break;
                  case '[': key.ch = '{'; break;
                  case ']': key.ch = '}'; break;
                  case ';': key.ch = ':'; break;
                  case '\'': key.ch = '"'; break;
                  case '\\': key.ch = '|'; break;
                  case ',': key.ch = '<'; break;
                  case '.': key.ch = '>'; break;
                  case '/': key.ch = '?'; break;
                  default:
                }
                key.shift = false;
              }
            }
          } else {
            // key name
            if (str.strEquCI("return")) str = "enter";
            if (str.strEquCI("esc")) str = "escape";
            if (str.strEquCI("bs")) str = "backspace";
            if (str.strEquCI("PasteStart") || str.strEquCI("Paste-Start")) {
              key.key = TtyEvent.Key.PasteStart;
              key.mods = 0;
              key.ch = 0;
            } else if (str.strEquCI("PasteEnd") || str.strEquCI("Paste-End")) {
              key.key = TtyEvent.Key.PasteEnd;
              key.mods = 0;
              key.ch = 0;
            } else {
              bool found = false;
              foreach (string kn; __traits(allMembers, TtyEvent.Key)) {
                if (!found && str.strEquCI(kn)) {
                  found = true;
                  key.key = __traits(getMember, TtyEvent.Key, kn);
                  break;
                }
              }
              if (!found || key.key < TtyEvent.Key.Up) goto error;
            }
            // just in case
                 if (key.key == TtyEvent.Key.Enter) key.ch = 13;
            else if (key.key == TtyEvent.Key.Tab) key.ch = 9;
            else if (key.key == TtyEvent.Key.Escape) key.ch = 27;
            else if (key.key == TtyEvent.Key.Backspace) key.ch = 8;
          }
          return s;
        }
      }
    error:
      key = TtyEvent.init;
      key.key = TtyEvent.Key.Error;
      return olds;
    }
  }
}


/**
 * Read key from stdin.
 *
 * WARNING! no utf-8 support yet!
 *
 * Params:
 *  toMSec = timeout in milliseconds; <0: infinite; 0: don't wait; default is -1
 *  toEscMSec = timeout in milliseconds for escape sequences
 *
 * Returns:
 *  null on error or keyname
 */
TtyEvent ttyReadKey (int toMSec=-1, int toEscMSec=-1/*300*/) @trusted @nogc {
  TtyEvent key;

  void skipCSI () @nogc {
    key.key = TtyEvent.Key.Unknown;
    for (;;) {
      auto ch = ttyReadKeyByte(toEscMSec);
      if (ch < 0 || ch == 27) { key.key = TtyEvent.Key.Escape; key.ch = 27; break; }
      if (ch != ';' && (ch < '0' || ch > '9')) break;
    }
  }

  void badCSI () @nogc {
    key = key.init;
    key.key = TtyEvent.Key.Unknown;
  }

  bool xtermMods (uint mci) @nogc {
    switch (mci) {
      case 2: key.shift = true; return true;
      case 3: key.alt = true; return true;
      case 4: key.alt = true; key.shift = true; return true;
      case 5: key.ctrl = true; return true;
      case 6: key.ctrl = true; key.shift = true; return true;
      case 7: key.alt = true; key.ctrl = true; return true;
      case 8: key.alt = true; key.ctrl = true; key.shift = true; return true;
      default:
    }
    return false;
  }

  void xtermSpecial (char ch) @nogc {
    switch (ch) {
      case 'A': key.key = TtyEvent.Key.Up; break;
      case 'B': key.key = TtyEvent.Key.Down; break;
      case 'C': key.key = TtyEvent.Key.Right; break;
      case 'D': key.key = TtyEvent.Key.Left; break;
      case 'E': key.key = TtyEvent.Key.Pad5; break;
      case 'H': key.key = TtyEvent.Key.Home; break;
      case 'F': key.key = TtyEvent.Key.End; break;
      case 'P': key.key = TtyEvent.Key.F1; break;
      case 'Q': key.key = TtyEvent.Key.F2; break;
      case 'R': key.key = TtyEvent.Key.F3; break;
      case 'S': key.key = TtyEvent.Key.F4; break;
      case 'Z': key.key = TtyEvent.Key.Tab; key.ch = 9; if (!key.shift && !key.alt && !key.ctrl) key.shift = true; break;
      default: badCSI(); break;
    }
  }

  void linconSpecial (char ch) @nogc {
    switch (ch) {
      case 'A': key.key = TtyEvent.Key.F1; break;
      case 'B': key.key = TtyEvent.Key.F2; break;
      case 'C': key.key = TtyEvent.Key.F3; break;
      case 'D': key.key = TtyEvent.Key.F4; break;
      default: badCSI(); break;
    }
  }

  void csiSpecial (uint n) @nogc {
    switch (n) {
      case 1: key.key = TtyEvent.Key.Home; return; // xterm
      case 2: key.key = TtyEvent.Key.Insert; return;
      case 3: key.key = TtyEvent.Key.Delete; return;
      case 4: key.key = TtyEvent.Key.End; return;
      case 5: key.key = TtyEvent.Key.PageUp; return;
      case 6: key.key = TtyEvent.Key.PageDown; return;
      case 7: key.key = TtyEvent.Key.Home; return; // rxvt
      case 8: key.key = TtyEvent.Key.End; return;
      case 1+10: key.key = TtyEvent.Key.F1; return;
      case 2+10: key.key = TtyEvent.Key.F2; return;
      case 3+10: key.key = TtyEvent.Key.F3; return;
      case 4+10: key.key = TtyEvent.Key.F4; return;
      case 5+10: key.key = TtyEvent.Key.F5; return;
      case 6+11: key.key = TtyEvent.Key.F6; return;
      case 7+11: key.key = TtyEvent.Key.F7; return;
      case 8+11: key.key = TtyEvent.Key.F8; return;
      case 9+11: key.key = TtyEvent.Key.F9; return;
      case 10+11: key.key = TtyEvent.Key.F10; return;
      case 11+12: key.key = TtyEvent.Key.F11; return;
      case 12+12: key.key = TtyEvent.Key.F12; return;
      default: badCSI(); break;
    }
  }

  // {\e}[<0;58;32M (button;x;y;[Mm])
  void parseMouse () @nogc {
    uint[3] nn;
    uint nc = 0;
    bool press = false;
    for (;;) {
      auto ch = ttyReadKeyByte(toEscMSec);
      if (ch < 0 || ch == 27) { key.key = TtyEvent.Key.Escape; key.ch = 27; return; }
      if (ch == ';') {
        ++nc;
      } else if (ch >= '0' && ch <= '9') {
        if (nc < nn.length) nn.ptr[nc] = nn.ptr[nc]*10+ch-'0';
      } else {
             if (ch == 'M') press = true;
        else if (ch == 'm') press = false;
        else { key.key = TtyEvent.Key.Unknown; return; }
        break;
      }
    }
    if (nn[1] > 0) --nn[1];
    if (nn[2] > 0) --nn[2];
    if (nn[1] < 0) nn[1] = 1;
    if (nn[1] > short.max) nn[1] = short.max;
    if (nn[2] < 0) nn[2] = 1;
    if (nn[2] > short.max) nn[2] = short.max;
    switch (nn[0]) {
      case 0: key.key = (press ? TtyEvent.Key.MLeftDown : TtyEvent.Key.MLeftUp); break;
      case 1: key.key = (press ? TtyEvent.Key.MMiddleDown : TtyEvent.Key.MMiddleUp); break;
      case 2: key.key = (press ? TtyEvent.Key.MRightDown : TtyEvent.Key.MRightUp); break;
      case 32: if (!press) { key.key = TtyEvent.Key.Unknown; return; } key.key = TtyEvent.Key.MLeftMotion; break;
      case 33: if (!press) { key.key = TtyEvent.Key.Unknown; return; } key.key = TtyEvent.Key.MMiddleMotion; break;
      case 34: if (!press) { key.key = TtyEvent.Key.Unknown; return; } key.key = TtyEvent.Key.MRightMotion; break;
      case 64: if (!press) { key.key = TtyEvent.Key.Unknown; return; } key.key = TtyEvent.Key.MWheelUp; break;
      case 65: if (!press) { key.key = TtyEvent.Key.Unknown; return; } key.key = TtyEvent.Key.MWheelDown; break;
      default: key.key = TtyEvent.Key.Unknown; return;
    }
    key.x = cast(short)nn[1];
    key.y = cast(short)nn[2];
  }

  int ch = ttyReadKeyByte(toMSec);
  if (ch < 0) { key.key = TtyEvent.Key.Error; return key; } // error
  if (ch == 0) { key.key = TtyEvent.Key.ModChar; key.ctrl = true; key.ch = ' '; return key; }
  if (ch == 8 || ch == 127) { key.key = TtyEvent.Key.Backspace; key.ch = 8; return key; }
  if (ch == 9) { key.key = TtyEvent.Key.Tab; key.ch = 9; return key; }
  //if (ch == 10) { key.key = TtyEvent.Key.Enter; key.ch = 13; return key; }
  if (ch == 13) { key.key = TtyEvent.Key.Enter; key.ch = 13; return key; }

  key.key = TtyEvent.Key.Unknown;

  // escape?
  if (ch == 27) {
    ch = ttyReadKeyByte(toEscMSec);
    if (ch < 0 || ch == 27) { key.key = TtyEvent.Key.Escape; key.ch = 27; return key; }
    // xterm stupidity
    if (termType != TermType.rxvt && ch == 'O') {
      ch = ttyReadKeyByte(toEscMSec);
      if (ch < 0 || ch == 27) { key.key = TtyEvent.Key.Escape; key.ch = 27; return key; }
      if (ch >= 'A' && ch <= 'Z') xtermSpecial(cast(char)ch);
      if (ch >= 'a' && ch <= 'z') { key.shift = true; xtermSpecial(cast(char)(ch-32)); }
      return key;
    }
    // csi
    if (ch == '[') {
      uint[2] nn;
      uint nc = 0;
      bool wasDigit = false;
      bool firstChar = true;
      bool linuxCon = false;
      // parse csi
      for (;;) {
        ch = ttyReadKeyByte(toEscMSec);
        if (firstChar && ch == '<') { parseMouse(); return key; }
        if (firstChar && ch == 'I') { key.key = TtyEvent.Key.FocusIn; return key; }
        if (firstChar && ch == 'O') { key.key = TtyEvent.Key.FocusOut; return key; }
        if (firstChar && ch == '[') { linuxCon = true; firstChar = false; continue; }
        firstChar = false;
        if (ch < 0 || ch == 27) { key.key = TtyEvent.Key.Escape; key.ch = 27; return key; }
        if (ch == ';') {
          ++nc;
          if (nc > nn.length) { skipCSI(); return key; }
        } else if (ch >= '0' && ch <= '9') {
          if (nc >= nn.length) { skipCSI(); return key; }
          nn.ptr[nc] = nn.ptr[nc]*10+ch-'0';
          wasDigit = true;
        } else {
          if (wasDigit) ++nc;
          break;
        }
      }
      debug(rawtty_show_csi) { import core.stdc.stdio : printf; printf("nc=%u", nc); foreach (uint idx; 0..nc) printf("; n%u=%u", idx, nn.ptr[idx]); printf("; ch=%c\n", ch); }
      // process specials
      if (nc == 0) {
             if (linuxCon) linconSpecial(cast(char)ch);
        else if (ch >= 'A' && ch <= 'Z') xtermSpecial(cast(char)ch);
      } else if (nc == 1) {
        if (ch == '~' && nn.ptr[0] == 200) { key.key = TtyEvent.Key.PasteStart; return key; }
        if (ch == '~' && nn.ptr[0] == 201) { key.key = TtyEvent.Key.PasteEnd; return key; }
        switch (ch) {
          case '~':
            switch (nn.ptr[0]) {
              case 23: key.shift = true; key.key = TtyEvent.Key.F1; return key;
              case 24: key.shift = true; key.key = TtyEvent.Key.F2; return key;
              case 25: key.shift = true; key.key = TtyEvent.Key.F3; return key;
              case 26: key.shift = true; key.key = TtyEvent.Key.F4; return key;
              case 28: key.shift = true; key.key = TtyEvent.Key.F5; return key;
              case 29: key.shift = true; key.key = TtyEvent.Key.F6; return key;
              case 31: key.shift = true; key.key = TtyEvent.Key.F7; return key;
              case 32: key.shift = true; key.key = TtyEvent.Key.F8; return key;
              case 33: key.shift = true; key.key = TtyEvent.Key.F9; return key;
              case 34: key.shift = true; key.key = TtyEvent.Key.F10; return key;
              default:
            }
            break;
          case '^': key.ctrl = true; break;
          case '$': key.shift = true; break;
          case '@': key.ctrl = true; key.shift = true; break;
          case 'A': .. case 'Z': xtermMods(nn.ptr[0]); xtermSpecial(cast(char)ch); return key;
          default: badCSI(); return key;
        }
        csiSpecial(nn.ptr[0]);
      } else if (nc == 2 && xtermMods(nn.ptr[1])) {
        if (nn.ptr[0] == 1 && ch >= 'A' && ch <= 'Z') {
          xtermSpecial(cast(char)ch);
        } else if (ch == '~') {
          csiSpecial(nn.ptr[0]);
        }
      } else {
        badCSI();
      }
      return key;
    }
    if (ch == 9) {
      key.key = TtyEvent.Key.Tab;
      key.alt = true;
      key.ch = 9;
      return key;
    }
    if (ch >= 1 && ch <= 26) {
      key.key = TtyEvent.Key.ModChar;
      key.alt = true;
      key.ctrl = true;
      key.ch = cast(dchar)(ch+64);
           if (key.ch == 'H') { key.key = TtyEvent.Key.Backspace; key.ctrl = false; key.ch = 8; }
      else if (key.ch == 'J') { key.key = TtyEvent.Key.Enter; key.ctrl = false; key.ch = 13; }
      return key;
    }
    if (/*(ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') || ch == '_' || ch == '`'*/true) {
      key.alt = true;
      key.key = TtyEvent.Key.ModChar;
      key.shift = (ch >= 'A' && ch <= 'Z'); // ignore capslock
      if (ch >= 'a' && ch <= 'z') ch -= 32;
      key.ch = cast(dchar)ch;
      return key;
    }
    return key;
  }

  if (ch == 9) {
    key.key = TtyEvent.Key.Tab;
    key.ch = 9;
  } else if (ch < 32) {
    // ctrl+letter
    key.key = TtyEvent.Key.ModChar;
    key.ctrl = true;
    key.ch = cast(dchar)(ch+64);
         if (key.ch == 'H') { key.key = TtyEvent.Key.Backspace; key.ctrl = false; key.ch = 8; }
    else if (key.ch == 'J') { key.key = TtyEvent.Key.Enter; key.ctrl = false; key.ch = 13; }
  } else {
    key.key = TtyEvent.Key.Char;
    key.ch = cast(dchar)(ch);
    if (ttyIsFuckedFlag && ch >= 0x80) {
      Utf8Decoder udc;
      for (;;) {
        auto dch = udc.decode(cast(ubyte)ch);
        if (dch <= dchar.max) break;
        // want more shit!
        ch = ttyReadKeyByte(toEscMSec);
        if (ch < 0) break;
      }
      if (!udc.invalid) {
        key.ch = uni2koi(udc.currCodePoint);
      }
    } else {
      // xterm does alt+letter with 7th bit set
      if (!xtermMetaSendsEscape && termType == TermType.xterm && ch >= 0x80 && ch <= 0xff) {
        ch -= 0x80;
        if ((ch >= 'A' && ch <= 'Z') || (ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9') || ch == '_') {
          key.alt = true;
          key.key = TtyEvent.Key.ModChar;
          key.shift = (ch >= 'A' && ch <= 'Z'); // ignore capslock
          if (ch >= 'a' && ch <= 'z') ch -= 32;
          key.ch = cast(dchar)ch;
          return key;
        }
      }
    }
  }
  return key;
}


// ////////////////////////////////////////////////////////////////////////// //
// housekeeping
private extern(C) void ttyExitRestore () {
  import core.atomic;
  if (atomicLoad(inRawMode)) {
    import core.sys.posix.termios : tcflush, tcsetattr;
    import core.sys.posix.termios : TCIOFLUSH, TCSAFLUSH;
    import core.sys.posix.unistd : STDIN_FILENO;
    //tcflush(STDIN_FILENO, TCIOFLUSH);
    if (doRestoreOrig) tcsetattr(STDIN_FILENO, TCSAFLUSH, &origMode);
  }
}

shared static this () {
  {
    import core.stdc.stdlib : atexit;
    atexit(&ttyExitRestore);
  }
  {
    import core.sys.posix.unistd : isatty, STDIN_FILENO, STDOUT_FILENO;
    import core.sys.posix.termios : tcgetattr;
    import core.sys.posix.termios : termios;
    doRestoreOrig = false;
    if (isatty(STDIN_FILENO) && isatty(STDOUT_FILENO)) {
      doRestoreOrig = (tcgetattr(STDIN_FILENO, &origMode) == 0);
    }
  }
}


shared static ~this () {
  ttySetNormal();
}


// ////////////////////////////////////////////////////////////////////////// //
shared static this () {
  import core.sys.posix.stdlib : getenv;

  ttyIsFuckedFlag = false;

  auto lang = getenv("LANG");
  if (lang is null) return;

  static char tolower (char ch) pure nothrow @safe @nogc { return (ch >= 'A' && ch <= 'Z' ? cast(char)(ch-'A'+'a') : ch); }

  while (*lang) {
    if (tolower(lang[0]) == 'u' && tolower(lang[1]) == 't' && tolower(lang[2]) == 'f') { ttyIsFuckedFlag = true; return; }
    ++lang;
  }
}
