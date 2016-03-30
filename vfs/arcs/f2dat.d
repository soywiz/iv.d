/* Invisible Vector Library
 * coded by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
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
module iv.vfs.arcs.f2dat;

import iv.vfs : usize, ssize, Seek;
import iv.vfs.augs;
import iv.vfs.main;
import iv.vfs.vfile;


// ////////////////////////////////////////////////////////////////////////// //
shared static this () {
  vfsRegisterDetector(new F2DatDetector());
}


// ////////////////////////////////////////////////////////////////////////// //
private final class F2DatDetector : VFSDriverDetector {
  override VFSDriver tryOpen (VFile fl) {
    debug(f2datarc) { import std.stdio : writeln; writeln("trying ZIP..."); }
    try {
      auto pak = new F2DatArchiveImpl(fl);
      return new VFSDriverF2Dat(pak);
    } catch (Exception) {}
    return null;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
public final class VFSDriverF2Dat : VFSDriver {
private:
  F2DatArchiveImpl pak;

public:
  this (F2DatArchiveImpl apak) {
    if (apak is null) throw new VFSException("wtf?!");
    pak = apak;
  }

  /// doesn't do any security checks, 'cause i don't care
  override VFile tryOpen (const(char)[] fname) {
    static import core.stdc.stdio;
    if (fname.length == 0) return VFile.init;
    try {
      return pak.fopen(fname);
    } catch (Exception) {}
    return VFile.init;
  }
}


// ////////////////////////////////////////////////////////////////////////// //
private final class F2DatArchiveImpl {
protected:
  static struct FileInfo {
    bool packed;
    ulong pksize;
    ulong size;
    ulong ofs; // offset in .DAT
    string name; // with path
  }

  // for dir range
  public static struct DirEntry {
    string name;
    ulong size;
  }

protected:
  VFile st;
  FileInfo[] dir;
  bool mNormNames; // true: convert names to lower case, do case-insensitive comparison (ASCII only)

public:
  this (VFile fl, bool anormNames=true) {
    mNormNames = anormNames;
    open(fl);
    st = fl;
  }

  final @property auto files () {
    static struct Range {
    private:
      F2DatArchiveImpl me;
      usize curindex;

    nothrow @safe @nogc:
      this (F2DatArchiveImpl ame, usize aidx=0) { me = ame; curindex = aidx; }

    public:
      @property bool empty () const { return (curindex >= me.dir.length); }
      @property DirEntry front () const {
        return DirEntry(
          (curindex < me.dir.length ? me.dir[cast(usize)curindex].name : null),
          (curindex < me.dir.length ? me.dir[cast(usize)curindex].size : 0));
      }
      @property Range save () { return Range(me, curindex); }
      void popFront () { if (curindex < me.dir.length) ++curindex; }
      @property usize length () const { return me.dir.length; }
      @property usize position () const { return curindex; } // current position
      @property void position (usize np) { curindex = np; }
      void rewind () { curindex = 0; }
    }
    return Range(this);
  }

  VFile fopen (ref in DirEntry de) {
    static bool strequ() (const(char)[] s0, const(char)[] s1) {
      if (s0.length != s1.length) return false;
      foreach (immutable idx, char ch; s0) {
        char c1 = s1[idx];
        if (ch >= 'A' && ch <= 'Z') ch += 32; // poor man's `toLower()`
        if (c1 >= 'A' && c1 <= 'Z') c1 += 32; // poor man's `toLower()`
        if (ch != c1) return false;
      }
      return true;
    }

    foreach_reverse (immutable idx, ref fi; dir) {
      if (mNormNames) {
        if (strequ(fi.name, de.name)) return wrapStream(F2DatFileLowLevel(this, idx));
      } else {
        if (fi.name == de.name) return wrapStream(F2DatFileLowLevel(this, idx));
      }
    }

    throw new VFSNamedException!"F2DatArchive"("file not found");
  }

  VFile fopen (const(char)[] fname) {
    DirEntry de;
    de.name = cast(string)fname; // it's safe here
    return fopen(de);
  }

private:
  void cleanup () {
    dir.length = 0;
  }

  void open (VFile fl) {
    debug(f2datarc) import std.stdio : writeln, writefln;
    scope(failure) cleanup();

    if (fl.size > 0xffff_ffffu) throw new VFSNamedException!"F2DatArchive"("file too big");
    ulong flsize = fl.size;
    // check it
    if (flsize < 8) throw new VFSNamedException!"F2DatArchive"("invalid DAT file");
    fl.seek(fl.size-8);
    auto dirSize = fl.readNum!uint;
    auto datSize = fl.readNum!uint;
    if (datSize != fl.size || dirSize > datSize-4) throw new VFSNamedException!"F2DatArchive"("invalid DAT file");
    debug(f2datarc) writefln("dir at: 0x%08x", datSize-4-dirSize);
    // read directory
    fl.seek(datSize-4-dirSize);
    char[2048] nbuf;
    while (dirSize >= 17) {
      FileInfo fi;
      dirSize -= 17;
      auto nlen = fl.readNum!uint;
      if (nlen == 0 || nlen > dirSize || nlen > 2048) throw new VFSNamedException!"F2DatArchive"("invalid DAT file directory");
      char[] name;
      {
        usize nbpos = 0;
        fl.rawReadExact(nbuf[0..nlen]);
        dirSize -= nlen;
        name = new char[](nlen);
        foreach (char ch; nbuf[0..nlen]) {
               if (ch == 0) break;
          else if (ch == '\\') ch = '/';
          else if (ch == '/') ch = '_';
          if (ch == '/' && (nbpos == 0 || name.ptr[nbpos-1] == '/')) continue;
          name.ptr[nbpos++] = ch;
        }
        name = name[0..nbpos];
        if (name.length && name[$-1] == '/') name = null;
      }
      fi.packed = (fl.readNum!ubyte() != 0);
      fi.size = fl.readNum!uint;
      fi.pksize = fl.readNum!uint;
      fi.ofs = fl.readNum!uint;
      // some sanity checks
      if (fi.size > 0 && fi.ofs >= datSize-4-dirSize) throw new VFSNamedException!"F2DatArchive"("invalid DAT file directory");
      if (fi.size >= datSize) throw new VFSNamedException!"F2DatArchive"("invalid DAT file directory");
      if (fi.ofs+fi.size >= datSize-4-dirSize) throw new VFSNamedException!"F2DatArchive"("invalid DAT file directory");
      if (name.length) {
        import std.exception : assumeUnique;
        fi.name = name.assumeUnique; // it's safe here
        dir ~= fi;
      }
    }
    debug(f2datarc) writeln(dir.length, " files found");
  }
}


// ////////////////////////////////////////////////////////////////////////// //
private struct F2DatFileLowLevel {
  private import etc.c.zlib;

  enum ibsize = 32768;

  enum Mode { Raw, ZLib }

  VFile zfl; // archive file
  Mode mode;
  long stpos; // starting position
  uint size; // unpacked size
  uint pksize; // packed size
  uint pos; // current file position
  uint prpos; // previous file position
  uint pkpos; // current position in DAT
  ubyte[] pkb; // packed data
  z_stream zs;
  bool eoz;

  alias tell = pos;

  this (F2DatArchiveImpl pak, usize idx) {
    assert(pak !is null);
    assert(idx < pak.dir.length);
    stpos = cast(uint)pak.dir[idx].ofs; //FIXME
    size = cast(uint)pak.dir[idx].size; //FIXME
    pksize = cast(uint)pak.dir[idx].pksize; //FIXME
    mode = (pak.dir[idx].packed ? F2DatFileLowLevel.Mode.ZLib : F2DatFileLowLevel.Mode.Raw);
    zfl = pak.st;
  }

  @property bool isOpen () { pragma(inline, true); return zfl.isOpen; }

  void close () {
    import core.stdc.stdlib : free;
    if (pkb.length) {
      inflateEnd(&zs);
      free(pkb.ptr);
      pkb = null;
    }
    if (zfl.isOpen) zfl.close();
    eoz = true;
  }

  private bool initZStream () {
    import core.stdc.stdlib : malloc, free;
    if (mode == Mode.Raw || pkb.ptr !is null) return true;
    // allocate buffer for packed data
    auto pb = cast(ubyte*)malloc(ibsize);
    if (pb is null) return false;
    pkb = pb[0..ibsize];
    zs.avail_in = 0;
    zs.avail_out = 0;
    // initialize unpacker
    if (inflateInit2(&zs, 15) != Z_OK) {
      free(pb);
      pkb = null;
      return false;
    }
    // we are ready
    return true;
  }

  private bool readPackedChunk () {
    import core.stdc.stdio : fread;
    import core.sys.posix.stdio : fseeko;
    if (zs.avail_in > 0) return true;
    if (pkpos >= pksize) return false;
    zs.next_in = cast(typeof(zs.next_in))pkb.ptr;
    zs.avail_in = cast(uint)(pksize-pkpos > ibsize ? ibsize : pksize-pkpos);
    zfl.seek(stpos+pkpos);
    auto rd = zfl.rawRead(pkb[0..zs.avail_in]);
    if (rd.length == 0) return false;
    zs.avail_in = cast(int)rd.length;
    pkpos += zs.avail_in;
    return true;
  }

  private bool unpackNextChunk () {
    while (zs.avail_out > 0) {
      if (eoz) return false;
      if (!readPackedChunk()) return false;
      auto err = inflate(&zs, Z_SYNC_FLUSH);
      //if (err == Z_BUF_ERROR) { import iv.writer; writeln("*** OUT OF BUFFER!"); }
      if (err != Z_STREAM_END && err != Z_OK) return false;
      if (err == Z_STREAM_END) eoz = true;
    }
    return true;
  }

  ssize read (void* buf, usize count) {
    if (buf is null) return -1;
    if (count == 0 || size == 0) return 0;
    if (!isOpen) return -1; // read error
    if (pos >= size) return 0; // EOF
    if (mode == Mode.Raw) {
      if (size-pos < count) count = cast(usize)(size-pos);
      zfl.seek(stpos+pos);
      auto rd = zfl.rawRead(buf[0..count]);
      pos += rd.length;
      return rd.length;
    } else {
      if (pkb.ptr is null && !initZStream()) return -1;
      // do we want to seek backward?
      if (prpos > pos) {
        // yes, rewind
        inflateEnd(&zs);
        zs = zs.init;
        pkpos = 0;
        if (!initZStream()) return -1;
        prpos = 0;
      }
      // do we need to seek forward?
      if (prpos < pos) {
        // yes, skip data
        ubyte[1024] tbuf = void;
        uint skp = pos-prpos;
        while (skp > 0) {
          uint rd = cast(uint)(skp > tbuf.length ? tbuf.length : skp);
          zs.next_out = cast(typeof(zs.next_out))tbuf.ptr;
          zs.avail_out = rd;
          if (!unpackNextChunk()) return -1;
          skp -= rd;
        }
        prpos = pos;
      }
      // unpack data
      if (size-pos < count) count = cast(usize)(size-pos);
      zs.next_out = cast(typeof(zs.next_out))buf;
      zs.avail_out = cast(uint)count;
      if (!unpackNextChunk()) return -1;
      prpos = (pos += count);
      return count;
    }
  }

  ssize write (in void* buf, usize count) { return -1; }

  void seek (long ofs, int whence=Seek.Set) {
    if (!isOpen) throw new VFSException("can't seek in closed stream");
    //TODO: overflow checks
    switch (whence) {
      case Seek.Set: break;
      case Seek.Cur: ofs += pos; break;
      case Seek.End:
        if (ofs > 0) ofs = 0;
        ofs += size;
        break;
      default:
        throw new VFSException("seek error");
    }
    if (ofs < 0) throw new VFSException("seek error");
    if (ofs > size) ofs = size;
    pos = cast(uint)ofs;
  }
}
