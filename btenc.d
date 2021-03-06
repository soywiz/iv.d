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
// some code to process bittorrent files
module iv.btenc /*is aliced*/;

import iv.alice;
import iv.vfs;
import iv.strex : quote;


struct BTField {
  enum Type { UInt, Str, List, Dict }
  Type type = Type.UInt;
  string vstr;
  ulong vuint;
  BTField[] vlist;
  BTField[string] vdict;

  this (ulong v) @safe nothrow @nogc { type = Type.UInt; vuint = v; }
  this (string v) @safe nothrow @nogc { type = Type.Str; vstr = v; }
  this (const(ubyte[]) v) @safe nothrow { type = Type.Str; vstr = cast(string)(v.idup); }

  const @safe pure nothrow @nogc {
    @property const(ubyte)[] bytes () { return cast(const(ubyte)[])vstr; }
    @property bool isUInt () { return (type == Type.UInt); }
    @property bool isStr () { return (type == Type.Str); }
    @property bool isList () { return (type == Type.List); }
    @property bool isDict () { return (type == Type.Dict); }
  }

  static BTField load (string fname) {
    import std.stdio : File;
    return load(File(fname));
  }

  static BTField load(ST) (auto ref ST st) if (isReadableStream!ST) {
    char tch;
    st.rawReadExact((&tch)[0..1]);
    return loadElement(st, tch);
  }

  void save (string fname) {
    import std.stdio : File;
    return save(File(fname, "w"));
  }

  void save(ST) (auto ref ST st) const if (isWriteableStream!ST) {
    void putNum (ulong n) {
      // 4294967295
      // 18446744073709551615
      char[32] str;
      usize pos = str.length;
      do str[--pos] = cast(char)('0'+n%10); while ((n /= 10) != 0);
      st.rawWriteExact(str[pos..$]);
    }

    void putChar (char ch) {
      st.rawWriteExact((&ch)[0..1]);
    }

    //{ import std.conv : to; import iv.writer; writeln(to!string(type)); }
    if (type == Type.UInt) {
      putChar('i');
      putNum(vuint);
      putChar('e');
    } else if (type == Type.Str) {
      putNum(vstr.length);
      putChar(':');
      st.rawWriteExact(vstr);
    } else if (type == Type.List) {
      putChar('l');
      foreach (const ref BTField fld; vlist) fld.save(st);
      putChar('e');
    } else if (type == Type.Dict) {
      // we have to sort keys by standard
      import std.algorithm : sort;
      putChar('d');
      foreach (string key; sort(vdict.keys)) {
        putNum(key.length);
        putChar(':');
        st.rawWriteExact(key);
        vdict[key].save(st);
      }
      putChar('e');
    } else {
      assert(0);
    }
  }

  ref BTField opIndex (string path) {
    auto res = byPath!"throw"(path);
    return *res;
  }

  BTField* opBinaryRight(string op="in") (string path) { return byPath(path); }

private:
  // opt: "throw"
  BTField* byPath(string opt="") (string path) {
    static assert(opt.length == 0 || opt == "throw", "invalid mode; only 'throw' allowed");

    static if (opt == "throw") {
      auto origpath = path;

      void error (string msg=null) {
        //import iv.strex : quote;
        if (msg.length == 0) {
          throw new Exception("invalid path: "~quote(origpath));
        } else {
          throw new Exception(msg~" at path: "~quote(origpath));
        }
      }
    }

    BTField* cf = &this;
    while (path.length > 0) {
      while (path.length > 0 && path[0] == '/') path = path[1..$];
      if (path.length == 0) break;
      // extract component
      usize epos = 1;
      while (epos < path.length && path[epos] != '/') ++epos;
      auto part = path[0..epos];
      path = path[epos..$];
      if (cf.type == Type.List) {
        // this should be number
        bool neg = false;
        if (part[0] == '-') { neg = true; part = part[1..$]; }
        else if (part[0] == '+') part = part[1..$];
        if (part.length == 0) {
          static if (opt == "throw") error("invalid number");
          else return null;
        }
        usize idx = 0;
        while (part.length > 0) {
          if (part[0] < '0' || part[0] > '9') {
            static if (opt == "throw") error("invalid number");
            else return null;
          }
          usize n1 = idx*10;
          if (n1 < idx) {
            static if (opt == "throw") error("numeric overflow");
            else return null;
          }
          n1 += part[0]-'0';
          if (n1 < idx) {
            static if (opt == "throw") error("numeric overflow");
            else return null;
          }
          idx = n1;
          part = part[1..$];
        }
        if (idx >= cf.vlist.length) {
          static if (opt == "throw") error("index out of range");
          else return null;
        }
        cf = &cf.vlist[idx];
      } else if (cf.type == Type.Dict) {
        cf = part in cf.vdict;
        if (cf is null) {
          static if (opt == "throw") {
            //import iv.strex : quote;
            error("dictionary item not found ("~quote(part)~")");
          } else {
            return null;
          }
        }
      } else {
        static if (opt == "throw") error();
        else return null;
      }
    }
    return cf;
  }


  static BTField loadElement(ST) (auto ref ST st, char tch) if (isReadableStream!ST) {
    ulong loadInteger (char ech, char fch=0) {
      ulong n = 0;
      if (fch >= '0' && fch <= '9') n = fch-'0';
      for (;;) {
        char ch;
        st.rawReadExact((&ch)[0..1]);
        if (ch == ech) break;
        if (ch >= '0' && ch <= '9') {
          ulong n1 = n*10;
          if (n1 < n) throw new Exception("integer overflow");
          n1 += ch-'0';
          if (n1 < n) throw new Exception("integer overflow");
          n = n1;
        } else {
          //{ import iv.writer; writeln(ch); }
          throw new Exception("invalid file format");
        }
      }
      return n;
    }

    string loadStr (char fch=0) {
      auto len = loadInteger(':', fch);
      if (len > 1024*1024*8) throw new Exception("string overflow");
      if (len > 0) {
        import std.exception : assumeUnique;
        auto res = new char[](cast(usize)len);
        st.rawReadExact(res);
        return res.assumeUnique;
      } else {
        return "";
      }
    }

    void loadUInt (ref BTField fld) {
      fld.type = Type.UInt;
      fld.vuint = loadInteger('e');
    }

    void loadList (ref BTField fld) {
      fld.type = Type.List;
      for (;;) {
        char tch;
        st.rawReadExact((&tch)[0..1]);
        if (tch == 'e') break;
        fld.vlist ~= loadElement(st, tch);
      }
    }

    void loadDict (ref BTField fld) {
      fld.type = Type.Dict;
      for (;;) {
        char tch;
        st.rawReadExact((&tch)[0..1]);
        if (tch == 'e') break;
        if (tch < '0' || tch > '9') throw new Exception("string overflow");
        auto name = loadStr(tch);
        st.rawReadExact((&tch)[0..1]);
        fld.vdict[name] = loadElement(st, tch);
      }
    }

    BTField res;
    if (tch == 'l') {
      debug { import iv.writer; writeln("LIST"); }
      loadList(res);
    } else if (tch == 'd') {
      debug { import iv.writer; writeln("DICT"); }
      loadDict(res);
    } else if (tch == 'i') {
      debug { import iv.writer; writeln("UINT"); }
      loadUInt(res);
    } else if (tch >= '0' && tch <= '9') {
      debug { import iv.writer; writeln("STR"); }
      res.type = Type.Str;
      res.vstr = loadStr(tch);
    } else {
      debug { import iv.writer; writeln(tch); }
      throw new Exception("invalid file format");
    }
    return res;
  }
}


ubyte[20] btInfoHash (string fname) {
  import std.stdio : File;
  return btInfoHash(File(fname));
}


ubyte[20] btInfoHash(ST) (auto ref ST st) if (isReadableStream!ST) {
  import std.digest.sha : SHA1;

  SHA1 dig;
  dig.start();
  bool doHash = false;

  char getChar () {
    char ch;
    st.rawReadExact((&ch)[0..1]);
    if (doHash) dig.put(cast(ubyte)ch);
    return ch;
  }

  ulong getUInt (char ech, char fch=0) {
    ulong n = 0;
    char ch;
    if (fch >= '0' && fch <= '9') n = fch-'0';
    for (;;) {
      ch = getChar();
      if (ch == ech) break;
      if (ch >= '0' && ch <= '9') {
        ulong n1 = n*10;
        if (n1 < n) throw new Exception("integer overflow");
        n1 += ch-'0';
        if (n1 < n) throw new Exception("integer overflow");
        n = n1;
      } else {
        throw new Exception("invalid file format");
      }
    }
    return n;
  }

  void skipBytes (ulong n) {
    ubyte[256] buf = void;
    while (n > 0) {
      usize rd = cast(usize)(n > buf.length ? buf.length : n);
      st.rawReadExact(buf[0..rd]);
      if (doHash) dig.put(buf[0..rd]);
      n -= rd;
    }
  }

  void skipElement (char ch) {
    if (ch == 'i') {
      // skip until 'e'
      do {
        ch = getChar();
        if (ch != 'e' && (ch < '0' || ch > '9')) throw new Exception("invalid torrent file element");
      } while (ch != 'e');
    } else if (ch == 'l') {
      // list
      for (;;) {
        ch = getChar();
        if (ch == 'e') break;
        skipElement(ch);
      }
    } else if (ch == 'd') {
      // dictionary
      for (;;) {
        ch = getChar();
        if (ch == 'e') break;
        if (ch < '0' || ch > '9') throw new Exception("invalid torrent file element");
        // skip key name
        auto n = getUInt(':', ch);
        skipBytes(n);
        // skip key value
        ch = getChar();
        skipElement(ch);
      }
    } else if (ch >= '0' && ch <= '9') {
      auto n = getUInt(':', ch);
      // skip string
      skipBytes(n);
    } else {
      throw new Exception("invalid torrent file element");
    }
  }

  // torrent file must be dictionary
  char ch = getChar();
  if (ch != 'd') throw new Exception("invalid torrent file: not a dictionary");
  // now find "info" key
  for (;;) {
    ch = getChar();
    if (ch < '0' || ch > '9') break;
    // key name
    auto n = getUInt(':', ch);
    if (n == 4) {
      char[4] buf;
      st.rawReadExact(buf[]);
      if (buf[] == "info") {
        // wow! this is "info" section, hash it
        doHash = true;
        ch = getChar();
        if (ch != 'd') throw new Exception("invalid torrent file: \"info\" section is not a dictionary");
        skipElement(ch);
        return dig.finish();
      }
    } else {
      // skip name
      skipBytes(n);
    }
    // skip data
    ch = getChar();
    skipElement(ch);
  }
  throw new Exception("invalid torrent file: no \"info\" section");
}
