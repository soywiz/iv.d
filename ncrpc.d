/* Written by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
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
// very simple serializer and RPC system
// WARNING! do not use for disk and other sensitive serialization,
//          as format may change without notice! at least version it!
module iv.ncrpc /*is aliced*/;
private:

import iv.alice;
import iv.vfs;
//version(rdmd) import iv.strex;


// ////////////////////////////////////////////////////////////////////////// //
public enum NCIgnore; // ignore this field
public struct NCName { string name; } // rename this field


enum NCEntryType : ubyte {
  End    = 0x00, // WARNING! SHOULD BE ZERO!
  Bool   = 0x10,
  Char   = 0x20,
  Int    = 0x30,
  Uint   = 0x40,
  Float  = 0x50,
  Struct = 0x60,
  Array  = 0x70,
  Dict   = 0x80,
}


// ////////////////////////////////////////////////////////////////////////// //
// skip serialized data block
public void ncskip(ST) (auto ref ST st) if (isReadableStream!ST) {
  void skip (uint count) {
    if (count == 0) return;
    /*
    static if (isSeekableStream!ST) {
      st.seek(count, Seek.Cur);
    } else*/ {
      ubyte[64] buf = void;
      while (count > 0) {
        int rd = (count > buf.length ? cast(int)buf.length : cast(int)count);
        st.rawReadExact(buf[0..rd]);
        count -= rd;
      }
    }
  }

  void skipStr () {
    ubyte len = st.readNum!ubyte;
    skip(len);
  }

  void skipType (ubyte tp, int count=1) {
    switch (tp&0xf0) {
      case NCEntryType.Bool:
      case NCEntryType.Char:
      case NCEntryType.Int:
      case NCEntryType.Uint:
      case NCEntryType.Float:
        skip(count*(tp&0x0f)); // size
        break;
      case NCEntryType.Struct:
        if ((tp&0x0f) != 0) throw new Exception("invalid struct type");
        while (count-- > 0) {
          skipStr(); // struct name
          // fields
          for (;;) {
            tp = st.readNum!ubyte; // name length
            if (tp == NCEntryType.End) break;
            skip(tp); // name
            tp = st.readNum!ubyte; // data type
            skipType(tp);
          }
        }
        break;
      case NCEntryType.Array:
        if ((tp&0x0f) != 0) throw new Exception("invalid array type");
        while (count-- > 0) {
          ubyte dimc = st.readNum!ubyte; // dimension count
          if (dimc == 0) throw new Exception("invalid array type");
          tp = st.readNum!ubyte; // data type

          void readDim (int dcleft) {
            auto len = st.readXInt!uint;
            if (dcleft == 1) {
              //foreach (immutable _; 0..len) skipType(tp);
              if (len <= int.max) {
                skipType(tp, len);
              } else {
                foreach (immutable _; 0..len) skipType(tp);
              }
            } else {
              foreach (immutable _; 0..len) readDim(dcleft-1);
            }
          }
          readDim(dimc);
        }
        break;
      case NCEntryType.Dict:
        if ((tp&0x0f) != 0) throw new Exception("invalid dict type");
        while (count-- > 0) {
          ubyte kt = st.readNum!ubyte; // key type
          ubyte vt = st.readNum!ubyte; // value type
          foreach (immutable _; 0..st.readXInt!usize) {
            skipType(kt);
            skipType(vt);
          }
        }
        break;
      default: throw new Exception("invalid data type");
    }
  }

  skipType(st.readNum!ubyte);
}


// ////////////////////////////////////////////////////////////////////////// //
// read serialized data block to buffer, return wrapped memory
public ubyte[] ncreadBytes(ST) (auto ref ST st) if (isReadableStream!ST) {
  ubyte[] data;

  struct CopyStream {
    void[] rawRead (void[] buf) {
      auto rd = st.rawRead(buf);
      if (rd.length) data ~= cast(const(ubyte)[])rd;
      return rd;
    }
  }
  wrapStream(CopyStream()).ncskip;
  return data;
}


// read serialized data block to buffer, return wrapped memory
public VFile ncread(ST) (auto ref ST st) if (isReadableStream!ST) {
  return st.ncreadBytes.wrapMemoryRO;
}


// ////////////////////////////////////////////////////////////////////////// //
template isSimpleType(T) {
  private import std.traits : Unqual;
  private alias UT = Unqual!T;
  enum isSimpleType = __traits(isIntegral, UT) || __traits(isFloating, UT) || is(UT == bool);
}


void ncWriteUbyte(ST) (auto ref ST fl, ubyte b) {
  fl.rawWriteExact((&b)[0..1]);
}


ubyte ncReadUbyte(ST) (auto ref ST fl) {
  ubyte b;
  fl.rawReadExact((&b)[0..1]);
  return b;
}


// ////////////////////////////////////////////////////////////////////////// //
public void ncser(T, ST) (auto ref ST fl, in auto ref T v) if (!is(T == class) && isWriteableStream!ST) {
  import std.traits : Unqual;

  void writeTypeHeader(T) () {
    alias UT = Unqual!T;
    static if (is(UT : V[], V)) {
      enum dc = dimensionCount!UT;
      static assert(dc <= 255, "too many array dimenstions");
      fl.ncWriteUbyte(NCEntryType.Array);
      fl.ncWriteUbyte(cast(ubyte)dc);
      writeTypeHeader!(arrayElementType!UT);
    } else static if (is(UT : K[V], K, V)) {
      fl.ncWriteUbyte(NCEntryType.Dict);
      writeTypeHeader!(Unqual!K);
      writeTypeHeader!(Unqual!V);
    } else static if (is(UT == bool)) {
      fl.ncWriteUbyte(cast(ubyte)(NCEntryType.Bool|bool.sizeof));
    } else static if (is(UT == char) || is(UT == wchar) || is(UT == dchar)) {
      fl.ncWriteUbyte(cast(ubyte)(NCEntryType.Char|UT.sizeof));
    } else static if (__traits(isIntegral, UT)) {
      static if (__traits(isUnsigned, UT)) {
        fl.ncWriteUbyte(cast(ubyte)(NCEntryType.Uint|UT.sizeof));
      } else {
        fl.ncWriteUbyte(cast(ubyte)(NCEntryType.Int|UT.sizeof));
      }
    } else static if (__traits(isFloating, UT)) {
      fl.ncWriteUbyte(cast(ubyte)(NCEntryType.Float|UT.sizeof));
    } else static if (is(UT == struct)) {
      static assert(UT.stringof.length <= 255, "struct name too long: "~UT.stringof);
      fl.ncWriteUbyte(NCEntryType.Struct);
      fl.ncWriteUbyte(cast(ubyte)UT.stringof.length);
      fl.rawWriteExact(UT.stringof[]);
    } else {
      static assert(0, "can't serialize type '"~T.stringof~"'");
    }
  }

  void serData(T) (in ref T v) {
    alias UT = arrayElementType!T;
    static if (is(T : V[], V)) {
      // array
      void writeMArray(AT) (AT arr) {
        fl.writeXInt(arr.length);
        static if (isMultiDimArray!AT) {
          foreach (const a2; arr) writeMArray(a2);
        } else {
          // write POD arrays in one chunk
          static if (isSimpleType!UT) {
            fl.rawWriteExact(arr[]);
          } else {
            foreach (const ref it; arr) serData(it);
          }
        }
      }
      writeMArray(v);
    } else static if (is(T : V[K], K, V)) {
      // associative array
      fl.writeXInt(v.length);
      foreach (const kv; v.byKeyValue) {
        serData(kv.key);
        serData(kv.value);
      }
    } else static if (isSimpleType!UT) {
      fl.rawWriteExact((&v)[0..1]);
    } else static if (is(UT == struct)) {
      import std.traits : FieldNameTuple, getUDAs, hasUDA;
      foreach (string fldname; FieldNameTuple!UT) {
        static if (!hasUDA!(__traits(getMember, UT, fldname), NCIgnore)) {
          enum names = getUDAs!(__traits(getMember, UT, fldname), NCName);
          static if (names.length) enum xname = names[0].name; else enum xname = fldname;
          static assert(xname.length <= 255, "struct '"~UT.stringof~"': field name too long: "~xname);
          fl.ncWriteUbyte(cast(ubyte)xname.length);
          fl.rawWriteExact(xname[]);
          fl.ncser(__traits(getMember, v, fldname));
        }
      }
      fl.ncWriteUbyte(NCEntryType.End);
    } else {
      static assert(0, "can't serialize type '"~T.stringof~"'");
    }
  }

  writeTypeHeader!T;
  serData(v);
}


// ////////////////////////////////////////////////////////////////////////// //
public void ncunser(T, ST) (auto ref ST fl, out T v) if (!is(T == class) && isReadableStream!ST) {
  import std.traits : Unqual;

  void checkTypeId(T) () {
    static if (is(T : V[], V)) {
      if (fl.ncReadUbyte != NCEntryType.Array) throw new Exception(`invalid stream (array expected)`);
      if (fl.ncReadUbyte != dimensionCount!T) throw new Exception(`invalid stream (dimension count)`);
      checkTypeId!(arrayElementType!T);
    } else static if (is(T : K[V], K, V)) {
      if (fl.ncReadUbyte != NCEntryType.Dict) throw new Exception(`invalid stream (dict expected)`);
      checkTypeId!(Unqual!K);
      checkTypeId!(Unqual!V);
    } else static if (is(T == bool)) {
      if (fl.ncReadUbyte != (NCEntryType.Bool|bool.sizeof)) throw new Exception(`invalid stream (bool expected)`);
    } else static if (is(T == char) || is(T == wchar) || is(T == dchar)) {
      if (fl.ncReadUbyte != (NCEntryType.Char|T.sizeof)) throw new Exception(`invalid stream (char expected)`);
    } else static if (__traits(isIntegral, T)) {
      static if (__traits(isUnsigned, T)) {
        if (fl.ncReadUbyte != (NCEntryType.Uint|T.sizeof)) throw new Exception(`invalid stream (int expected)`);
      } else {
        if (fl.ncReadUbyte != (NCEntryType.Int|T.sizeof)) throw new Exception(`invalid stream (int expected)`);
      }
    } else static if (__traits(isFloating, T)) {
      if (fl.ncReadUbyte != (NCEntryType.Float|T.sizeof)) throw new Exception(`invalid stream (float expected)`);
    } else static if (is(T == struct)) {
      char[255] cbuf = void;
      static assert(T.stringof.length <= 255, "struct name too long: "~T.stringof);
      if (fl.ncReadUbyte != NCEntryType.Struct) throw new Exception(`invalid stream (struct expected)`);
      if (fl.ncReadUbyte != T.stringof.length) throw new Exception(`invalid stream (struct name length)`);
      fl.rawReadExact(cbuf[0..T.stringof.length]);
      if (cbuf[0..T.stringof.length] != T.stringof) throw new Exception(`invalid stream (struct name)`);
    } else {
      static assert(0, "can't unserialize type '"~T.stringof~"'");
    }
  }

  void unserData(T) (out T v) {
    static if (is(T : V[], V)) {
      void readMArray(AT) (out AT arr) {
        auto llen = fl.readXInt!usize;
        if (llen == 0) return;
        static if (__traits(isStaticArray, AT)) {
          if (arr.length != llen) throw new Exception(`invalid stream (array size)`);
          alias narr = arr;
        } else {
          Unqual!(typeof(arr[0]))[] narr;
          narr.length = llen;
        }
        static if (isMultiDimArray!AT) {
          foreach (ref a2; narr) readMArray(a2);
        } else {
          alias ET = arrayElementType!AT;
          // read byte arrays in one chunk
          static if (isSimpleType!ET) {
            fl.rawReadExact(narr[]);
          } else {
            foreach (ref it; narr) unserData(it);
          }
        }
        static if (!__traits(isStaticArray, AT)) arr = cast(AT)narr;
      }
      readMArray(v);
    } else static if (is(T : V[K], K, V)) {
      K key = void;
      V value = void;
      foreach (immutable _; 0..fl.readXInt!usize) {
        unserData(key);
        unserData(value);
        v[key] = value;
      }
    } else static if (isSimpleType!T) {
      fl.rawReadExact((&v)[0..1]);
    } else static if (is(T == struct)) {
      import std.traits : FieldNameTuple, getUDAs, hasUDA;

      ulong[(FieldNameTuple!T.length+ulong.sizeof-1)/ulong.sizeof] fldseen = 0;

      bool tryField(uint idx, string fldname) (const(char)[] name) {
        static if (hasUDA!(__traits(getMember, T, fldname), NCName)) {
          enum names = getUDAs!(__traits(getMember, T, fldname), NCName);
        } else {
          alias tuple(T...) = T;
          enum names = tuple!(NCName(fldname));
        }
        foreach (immutable xname; names) {
          if (xname.name == name) {
            if (fldseen[idx/8]&(1UL<<(idx%8))) throw new Exception(`duplicate field value for '`~fldname~`'`);
            fldseen[idx/8] |= 1UL<<(idx%8);
            fl.ncunser(__traits(getMember, v, fldname));
            return true;
          }
        }
        return false;
      }

      void tryAllFields (const(char)[] name) {
        foreach (immutable idx, string fldname; FieldNameTuple!T) {
          static if (!hasUDA!(__traits(getMember, T, fldname), NCIgnore)) {
            if (tryField!(idx, fldname)(name)) return;
          }
        }
        throw new Exception("unknown field '"~name.idup~"'");
      }

      char[255] cbuf = void;
      // let's hope that fields are in order
      foreach (immutable idx, string fldname; FieldNameTuple!T) {
        static if (!hasUDA!(__traits(getMember, T, fldname), NCIgnore)) {
          auto nlen = fl.ncReadUbyte;
          if (nlen == NCEntryType.End) throw new Exception("invalid stream (out of fields)");
          fl.rawReadExact(cbuf[0..nlen]);
          if (!tryField!(idx, fldname)(cbuf[0..nlen])) tryAllFields(cbuf[0..nlen]);
        }
      }
      if (fl.ncReadUbyte != NCEntryType.End) throw new Exception("invalid stream (extra fields)");
    }
  }

  checkTypeId!T;
  unserData(v);
}


// ////////////////////////////////////////////////////////////////////////// //
template isMultiDimArray(T) {
  private import std.range.primitives : hasLength;
  private import std.traits : isArray, isNarrowString;
  static if (isArray!T) {
    alias DT = typeof(T.init[0]);
    static if (hasLength!DT || isNarrowString!DT) {
      enum isMultiDimArray = true;
    } else {
      enum isMultiDimArray = false;
    }
  } else {
    enum isMultiDimArray = false;
  }
}
static assert(isMultiDimArray!(string[]) == true);
static assert(isMultiDimArray!string == false);
static assert(isMultiDimArray!(int[int]) == false);


template dimensionCount(T) {
  private import std.range.primitives : hasLength;
  private import std.traits : isArray, isNarrowString;
  static if (isArray!T) {
    alias DT = typeof(T.init[0]);
    static if (hasLength!DT || isNarrowString!DT) {
      enum dimensionCount = 1+dimensionCount!DT;
    } else {
      enum dimensionCount = 1;
    }
  } else {
    enum dimensionCount = 0;
  }
}
static assert(dimensionCount!string == 1);
static assert(dimensionCount!(int[int]) == 0);


template arrayElementType(T) {
  private import std.traits : isArray, Unqual;
  static if (isArray!T) {
    alias arrayElementType = arrayElementType!(typeof(T.init[0]));
  } else static if (is(typeof(T))) {
    alias arrayElementType = Unqual!(typeof(T));
  } else {
    alias arrayElementType = Unqual!T;
  }
}
static assert(is(arrayElementType!string == char));


// ////////////////////////////////////////////////////////////////////////// //
version(ncserial_test) unittest {
  import iv.vfs;

  // ////////////////////////////////////////////////////////////////////////// //
  static struct AssemblyInfo {
    uint id;
    string name;
    @NCIgnore uint ignoreme;
  }

  static struct ReplyAsmInfo {
    @NCName("command") @NCName("xcommand") ubyte cmd;
    @NCName("values") AssemblyInfo[][2] list;
    uint[string] dict;
    bool fbool;
    char[3] ext;
  }


  // ////////////////////////////////////////////////////////////////////////// //
  void test0 () {
    ReplyAsmInfo ri;
    ri.cmd = 42;
    ri.list[0] ~= AssemblyInfo(666, "hell");
    ri.list[1] ~= AssemblyInfo(69, "fuck");
    ri.dict["foo"] = 42;
    ri.dict["boo"] = 666;
    ri.fbool = true;
    ri.ext = "elf";
    {
      auto fl = VFile("z00.bin", "w");
      fl.ncser(ri);
    }
    {
      ReplyAsmInfo xf;
      auto fl = VFile("z00.bin");
      fl.ncunser(xf);
      assert(fl.tell == fl.size);
      assert(xf.cmd == 42);
      assert(xf.list.length == 2);
      assert(xf.list[0].length == 1);
      assert(xf.list[1].length == 1);
      assert(xf.list[0][0].id == 666);
      assert(xf.list[0][0].name == "hell");
      assert(xf.list[1][0].id == 69);
      assert(xf.list[1][0].name == "fuck");
      assert(xf.dict.length == 2);
      assert(xf.dict["foo"] == 42);
      assert(xf.dict["boo"] == 666);
      assert(xf.fbool == true);
      assert(xf.ext == "elf");
    }
  }

  void test1 () {
    ReplyAsmInfo ri;
    ri.cmd = 42;
    ri.list[0] ~= AssemblyInfo(666, "hell");
    ri.list[1] ~= AssemblyInfo(69, "fuck");
    ri.dict["foo"] = 42;
    ri.dict["boo"] = 666;
    ri.fbool = true;
    ri.ext = "elf";
    auto mem = wrapMemoryRW(null);
    mem.ncser(ri);
    {
      mem.seek(0);
      ReplyAsmInfo xf;
      mem.ncunser(xf);
      assert(mem.tell == mem.size);
      assert(xf.cmd == 42);
      assert(xf.list.length == 2);
      assert(xf.list[0].length == 1);
      assert(xf.list[1].length == 1);
      assert(xf.list[0][0].id == 666);
      assert(xf.list[0][0].name == "hell");
      assert(xf.list[1][0].id == 69);
      assert(xf.list[1][0].name == "fuck");
      assert(xf.dict.length == 2);
      assert(xf.dict["foo"] == 42);
      assert(xf.dict["boo"] == 666);
      assert(xf.fbool == true);
      assert(xf.ext == "elf");
    }
    mem.seek(0);
    mem.ncskip;
    assert(mem.tell == mem.size);

    auto m2 = mem.ncread;
    assert(mem.tell == mem.size);
    assert(m2.tell == mem.size);
  }
}


// ////////////////////////////////////////////////////////////////////////// //
// simple RPC system
private import std.traits;

public enum RPCommand : ushort {
  Call = 0x29a,
  RetVoid,
  RetRes,
  Err,
}


// ////////////////////////////////////////////////////////////////////////// //
private alias Id(alias T) = T;

private struct RPCEndPoint {
  string name;
  ubyte[32] hash;
  bool isFunction;
  VFile delegate (VFile fi) dg; // read args, do call, write result; throws on error; returns serialized res
}


private RPCEndPoint[string] endpoints;


// ////////////////////////////////////////////////////////////////////////// //
private string nodots (string s) {
  if (s.length > 2 && s[0] == '"' && s[$-1] == '"') s = s[1..$-1];
  usize pos = s.length;
  while (pos > 0 && s[pos-1] != '.') --pos;
  return s[pos..$];
}


// ////////////////////////////////////////////////////////////////////////// //
public string[] rpcEndpointNames () { return endpoints.keys; }


// ////////////////////////////////////////////////////////////////////////// //
public static ubyte[32] rpchash(alias func) () if (isCallable!func) {
  import std.digest.sha;
  SHA256 sha;

  void put (const(void)[] buf) {
    sha.put(cast(const(ubyte)[])buf);
  }

  sha.start();
  //put(nodots(fullyQualifiedName!func.stringof));
  put(ReturnType!func.stringof);
  put(",");
  foreach (immutable par; Parameters!func) {
    put(par.stringof);
    put(",");
  }
  return sha.finish();
}


// ////////////////////////////////////////////////////////////////////////// //
private string BuildCall(alias func) () {
  string res = "func(";
  foreach (immutable idx, immutable par; Parameters!func) {
    import std.conv : to;
    res ~= "mr.a";
    res ~= idx.to!string;
    res ~= ",";
  }
  return res~")";
}


// ////////////////////////////////////////////////////////////////////////// //
private static mixin template BuildRPCArgs (alias func) {
  private import std.traits;
  private static string buildIt(alias func) () {
    string res;
    alias defs = ParameterDefaults!func;
    foreach (immutable idx, immutable par; Parameters!func) {
      import std.conv : to;
      res ~= par.stringof;
      res ~= " a";
      res ~= to!string(idx);
      static if (!is(defs[idx] == void)) res ~= " = "~defs[idx].stringof;
      res ~= ";\n";
    }
    return res;
  }
  mixin(buildIt!func);
}


// ////////////////////////////////////////////////////////////////////////// //
public struct RPCCallHeader {
  string name; // fqn
  ubyte[32] hash;
}


// ////////////////////////////////////////////////////////////////////////// //
private void fcopy (VFile to, VFile from) {
  ubyte[64] buf = void;
  for (;;) {
    auto rd = from.rawRead(buf[]);
    if (rd.length == 0) break;
    to.rawWriteExact(rd[]);
  }
}


// ////////////////////////////////////////////////////////////////////////// //
// client will use this
// it will send RPCommand.Call
// throws on fatal stream error
public static auto rpcall(alias func, string prefix=null, string name=null, ST, A...) (auto ref ST chan, A args)
if (isRWStream!ST && (is(typeof(func) == function) || is(typeof(func) == delegate)))
{
  //pragma(msg, "type: ", typeof(func));
  //pragma(msg, "prot: ", __traits(getProtection, func));
  import std.traits;
  static struct RPCMarshalArgs { mixin BuildRPCArgs!func; }
  RPCMarshalArgs mr;
  alias defs = ParameterDefaults!func;
  static assert(A.length <= defs.length, "too many arguments");
  static if (A.length < defs.length) static assert(!is(defs[A.length] == void), "not enough default argument values");
  foreach (immutable idx, ref arg; args) {
    import std.conv : to;
    mixin("mr.a"~to!string(idx)~" = arg;");
  }
  RPCCallHeader hdr;
  static if (name.length > 0) {
    hdr.name = prefix~name;
  } else {
    hdr.name = prefix~nodots(fullyQualifiedName!func.stringof);
  }
  hdr.hash = rpchash!func;
  // call
  chan.writeNum!ushort(RPCommand.Call);
  chan.ncser(hdr);
  chan.ncser(mr);
  // result
  auto replyCode = chan.readNum!ushort;
  if (replyCode == RPCommand.Err) {
    string msg;
    chan.ncunser(msg);
    throw new Exception("RPC ERROR: "~msg);
  }
  if (replyCode == RPCommand.RetRes) {
    static if (!is(ReturnType!func == void)) {
      // read result
      ReturnType!func rval;
      chan.ncunser(rval);
      return rval;
    } else {
      chan.ncskip;
      return;
    }
  } else if (replyCode == RPCommand.RetVoid) {
    // got reply, wow
    static if (!is(ReturnType!func == void)) {
      return ReturnType!func.init;
    } else {
      return;
    }
  }
  throw new Exception("invalid RPC reply");
}


// ////////////////////////////////////////////////////////////////////////// //
// client will use this
// it will send RPCommand.Call
// throws on fatal stream error
public static RT rpcallany(RT, ST, A...) (auto ref ST chan, const(char)[] name, A args) if (isRWStream!ST) {
  import std.traits;
  string BuildIt () {
    string res;
    foreach (immutable idx, const tp; A) {
      import std.conv : to;
      res ~= tp.stringof;
      res ~= " a";
      res ~= to!string(idx);
      res ~= ";\n";
    }
    return res;
  }
  static struct RPCMarshalArgs { mixin(BuildIt); /*pragma(msg, BuildIt);*/ }
  RPCMarshalArgs mr;
  foreach (immutable idx, ref arg; args) {
    import std.conv : to;
    mixin("mr.a"~to!string(idx)~" = arg;");
  }
  RPCCallHeader hdr;
  hdr.name = cast(string)name; // it is safe to cast it here
  hdr.hash[] = 0;
  // call
  chan.writeNum!ushort(RPCommand.Call);
  chan.ncser(hdr);
  chan.ncser(mr);
  // result
  auto replyCode = chan.readNum!ushort;
  if (replyCode == RPCommand.Err) {
    string msg;
    chan.ncunser(msg);
    throw new Exception("RPC ERROR: "~msg);
  }
  if (replyCode == RPCommand.RetRes) {
    static if (!is(RT == void)) {
      // read result
      RT rval;
      chan.ncunser(rval);
      return rval;
    } else {
      chan.ncskip;
      return;
    }
  } else if (replyCode == RPCommand.RetVoid) {
    // got reply, wow
    static if (!is(RT == void)) {
      return RT.init;
    } else {
      return;
    }
  }
  throw new Exception("invalid RPC reply");
}


// ////////////////////////////////////////////////////////////////////////// //
// register RPC endpoint (server-side)
// if you'll specify only prefix, it will be added to func name
public static void rpcRegisterEndpoint(alias Dg) (typeof(Dg) func, const(char)[] prefix=null, const(char)[] name=null)
if (is(typeof(Dg) == function) || is(typeof(Dg) == delegate))
{
  import std.traits : FieldNameTuple, getUDAs, hasUDA;
  import std.digest.sha;
  RPCEndPoint ep;

  if (name.length) {
    ep.name = prefix.idup~name.idup;
  } else {
    ep.name = prefix.idup~nodots(fullyQualifiedName!Dg.stringof);
    //{ import std.stdio; stderr.writeln("name: [", ep.name, "]"); }
  }
  ep.hash = rpchash!Dg;
  ep.dg = delegate (VFile fi) {
    // parse and call
    static struct RPCMarshalArgs { mixin BuildRPCArgs!Dg; }
    RPCMarshalArgs mr;
    fi.ncunser(mr);
    auto fo = wrapMemoryRW(null);
    static if (is(ReturnType!Dg == void)) {
      mixin(BuildCall!Dg~";");
    } else {
      mixin("fo.ncser("~BuildCall!Dg~");");
    }
    fo.seek(0);
    return fo;
  };
  endpoints[ep.name] = ep;
}


// ////////////////////////////////////////////////////////////////////////// //
// server will use this; RPCommand.Call already read
// throws on unrecoverable stream error
public static bool rpcProcessCall(ST) (auto ref ST chan) if (isRWStream!ST) {
  RPCCallHeader hdr;
  chan.ncunser(hdr);
  auto epp = hdr.name in endpoints;
  if (epp is null) {
    chan.ncskip;
    chan.writeNum!ushort(RPCommand.Err);
    chan.ncser("unknown function '"~hdr.name~"'");
    return false;
  }
  foreach (ubyte b; hdr.hash) {
    if (b != 0) {
      if (epp.hash != hdr.hash) {
        chan.ncskip;
        chan.writeNum!ushort(RPCommand.Err);
        chan.ncser("invalid signature for function '"~hdr.name~"'");
        return false;
      }
      break;
    }
  }
  auto rdf = chan.ncread;
  VFile rf;
  try {
    rf = epp.dg(rdf);
  } catch (Exception e) {
    chan.writeNum!ushort(RPCommand.Err);
    chan.ncser("EXCEPTION: "~e.msg);
    return false;
  }
  if (rf.size > 0) {
    chan.writeNum!ushort(RPCommand.RetRes);
    ubyte[512] buf = void;
    for (;;) {
      auto rd = rf.rawRead(buf[]);
      if (rd.length == 0) break;
      chan.rawWriteExact(rd[]);
    }
  } else {
    chan.writeNum!ushort(RPCommand.RetVoid);
  }
  return true;
}


// ////////////////////////////////////////////////////////////////////////// //
/** unix domain socket without inode
 * for server:
 *
 * ---------
 *   UDSocket sk;
 *   sk.create("/k8/rpc-test");
 *   auto cl = sk.accept();
 * ---------
 *
 *
 * for client:
 *
 * ---------
 *   UDSocket sk;
 *   sk.connect("/k8/rpc-test");
 * ---------
 */
public struct UDSocket {
private:
  static struct UDSData {
    uint rc;
    int fd;
    uint bytesSent;
    uint bytesReceived;
    bool didlisten;
    bool dontclose;
    @disable this (this);
  }

private:
  usize udsp;

  void decRef () nothrow @nogc {
    if (!udsp) return;
    auto uds = cast(UDSData*)udsp;
    if (--uds.rc == 0) {
      import core.stdc.stdlib : free;
      import core.sys.posix.unistd : close;
      if (!uds.dontclose) close(uds.fd);
      free(uds);
    }
    udsp = 0;
  }

public:
  this (this) nothrow @nogc { pragma(inline, true); if (udsp) ++(cast(UDSData*)udsp).rc; } ///
  ~this () nothrow @nogc { pragma(inline, true); if (udsp) close(); } ///

  ///
  void opAssign (UDSocket sk) {
    pragma(inline, true);
    if (sk.udsp) ++(cast(UDSData*)sk.udsp).rc;
    close();
    udsp = sk.udsp;
  }

  @property bool isOpen () const nothrow @trusted @nogc { pragma(inline, true); return (udsp != 0); } ///
  @property int fd () const nothrow @trusted @nogc { pragma(inline, true); return (udsp != 0 ? (cast(UDSData*)udsp).fd : -1); } ///

  void close () nothrow @nogc { pragma(inline, true); if (udsp) decRef(); } ///
  void create (const(char)[] name) { doCC!"server"(name); } ///
  void connect (const(char)[] name) { doCC!"client"(name); } ///

  @property uint bytesSent () const nothrow @trusted @nogc { pragma(inline, true); return (udsp != 0 ? (cast(UDSData*)udsp).bytesSent : 0); } ///
  @property uint bytesReceived () const nothrow @trusted @nogc { pragma(inline, true); return (udsp != 0 ? (cast(UDSData*)udsp).bytesReceived : 0); } ///

  @property void resetBytesSent () nothrow @trusted @nogc { pragma(inline, true); if (udsp != 0) (cast(UDSData*)udsp).bytesSent = 0; } ///
  @property void resetBytesReceived () nothrow @trusted @nogc { pragma(inline, true); if (udsp != 0) (cast(UDSData*)udsp).bytesReceived = 0; } ///

  ///
  void listen () {
    if (!udsp) throw new Exception("can't listen on closed socket");
    auto uds = cast(UDSData*)udsp;
    if (!uds.didlisten) {
      import core.sys.posix.sys.socket : listen;
      if (listen(uds.fd, 1) != 0) throw new Exception("listen failed");
      uds.didlisten = true;
    }
  }

  ///
  UDSocket accept () {
    listen();
    auto uds = cast(UDSData*)udsp;
    assert(uds.didlisten);
    import core.sys.posix.sys.socket : accept;
    int cfd = accept(uds.fd, null, null);
    if (cfd == -1) throw new Exception("accept failed");
    UDSocket res;
    res.assignFD(cfd);
    return res;
  }

  /// detach fd
  int detach () {
    if (!udsp) throw new Exception("can't detach closed socket");
    auto uds = cast(UDSData*)udsp;
    int rfd = uds.fd;
    uds.dontclose = true;
    close();
    return rfd;
  }

  ///
  void[] rawRead (void[] buf) {
    import core.sys.posix.sys.socket : recv;
    if (!udsp) throw new Exception("can't read from closed socket");
    auto uds = cast(UDSData*)udsp;
    if (buf.length == 0) return buf[];
    auto rd = recv(uds.fd, buf.ptr, buf.length, 0);
    if (rd < 0) throw new Exception("socket read error");
    uds.bytesReceived += rd;
    return buf[0..rd];
  }

  ///
  void rawWrite (const(void)[] buf) {
    import core.sys.posix.sys.socket : send, MSG_NOSIGNAL;
    if (!udsp) throw new Exception("can't write to closed socket");
    auto uds = cast(UDSData*)udsp;
    auto dp = cast(const(ubyte)*)buf.ptr;
    auto left = buf.length;
    while (left > 0) {
      auto wr = send(uds.fd, dp, left, 0);
      if (wr <= 0) throw new Exception("socket write error");
      uds.bytesSent += wr;
      dp += wr;
      left -= wr;
    }
  }

private:
  void assignFD (int fd) {
    import core.stdc.stdlib : malloc;
    import core.stdc.string : memset;
    close();
    if (fd >= 0) {
      auto uds = cast(UDSData*)malloc(UDSData.sizeof);
      if (uds is null) {
        import core.sys.posix.unistd : close;
        close(fd);
        throw new Exception("out of memory"); // let's hope that we can do it
      }
      memset(uds, 0, (*uds).sizeof);
      uds.rc = 1;
      uds.fd = fd;
      udsp = cast(usize)uds;
    }
  }

  void doCC(string mode) (const(char)[] name) {
    static assert(mode == "client" || mode == "server", "invalid mode");
    import core.stdc.stdlib : malloc;
    import core.stdc.string : memset;
    close();
    int fd = makeUADS!mode(name);
    auto uds = cast(UDSData*)malloc(UDSData.sizeof);
    if (uds is null) {
      import core.sys.posix.unistd : close;
      close(fd);
      throw new Exception("out of memory"); // let's hope that we can do it
    }
    memset(uds, 0, (*uds).sizeof);
    uds.rc = 1;
    uds.fd = fd;
    udsp = cast(usize)uds;
  }

  static int makeUADS(string mode) (const(char)[] name) {
    static assert(mode == "client" || mode == "server", "invalid mode");
    import core.stdc.string : memset;
    import core.sys.posix.sys.socket;
    import core.sys.posix.sys.un : sockaddr_un;
    import core.sys.posix.unistd : close;
    // max name length is 108, so be safe here
    if (name.length == 0 || name.length > 100) throw new Exception("invalid name");
    //{ import core.stdc.stdio; printf("[%.*s]\n", cast(uint)name.length, name.ptr); }
    sockaddr_un sun = void;
    memset(&sun, 0, sun.sizeof);
    sun.sun_family = AF_UNIX;
    // create domain socket without FS inode (first byte of name buffer should be zero)
    sun.sun_path[1..1+name.length] = cast(byte[])name[];
    int fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0) throw new Exception("can't create unix domain socket");
    static if (mode == "server") {
      import core.sys.posix.sys.socket : bind;
      if (bind(fd, cast(sockaddr*)&sun, sun.sizeof) != 0) { close(fd); throw new Exception("can't bind unix domain socket"); }
    } else {
      import core.sys.posix.sys.socket : connect;
      if (connect(fd, cast(sockaddr*)&sun, sun.sizeof) != 0) {
        import core.stdc.errno;
        auto err = errno;
        close(fd);
        //{ import std.stdio; writeln("ERRNO: ", err); }
        throw new Exception("can't connect to unix domain socket");
      }
    }
    //{ import core.stdc.stdio; printf("fd=%d\n", fd); }
    return fd;
  }
}
