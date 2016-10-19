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
module iv.vfs.writers.zip;
private:

import iv.utfutil;
import iv.vfs;


// ////////////////////////////////////////////////////////////////////////// //
public struct ZipFileInfo {
  string name;
  ulong pkofs; // offset of file header
  ulong size;
  ulong pksize;
  uint crc; // crc32(0, null, 0);
  ushort method;
}


// ////////////////////////////////////////////////////////////////////////// //
// returs crc
uint zpack (VFile ds, VFile ss, out bool aborted) {
  import etc.c.zlib;
  import core.stdc.stdlib;

  enum IBSize = 65536;
  enum OBSize = 65536;

  z_stream zst;
  ubyte* ib, ob;
  int err;
  uint crc;

  aborted = false;
  crc = crc32(0, null, 0);

  ib = cast(ubyte*)malloc(IBSize);
  if (ib is null) assert(0, "out of memory");
  scope(exit) free(ib);

  ob = cast(ubyte*)malloc(OBSize);
  if (ob is null) assert(0, "out of memory");
  scope(exit) free(ob);

  ulong srcsize = ss.size, outsize = 0;

  zst.next_out = ob;
  zst.avail_out = OBSize;
  zst.next_in = ib;
  zst.avail_in = 0;
  err = deflateInit2(&zst, Z_BEST_COMPRESSION, Z_DEFLATED, -15, 9, 0);
  if (err != Z_OK) throw new Exception("zlib error");
  scope(exit) deflateEnd(&zst);

  bool eof = false;
  while (!eof) {
    if (zst.avail_in == 0) {
      // read input buffer part
      auto rd = ss.rawRead(ib[0..IBSize]);
      eof = (rd.length == 0);
      if (rd.length != 0) { crc = crc32(crc, ib, cast(uint)rd.length); }
      zst.next_in = ib;
      zst.avail_in = cast(uint)rd.length;
    }
    // now process the whole input
    while (zst.avail_in > 0) {
      err = deflate(&zst, Z_NO_FLUSH);
      if (err != Z_OK) throw new Exception("zlib compression error");
      if (zst.avail_out < OBSize) {
        if (outsize+(OBSize-zst.avail_out) >= srcsize) {
          // this will be overwritten anyway
          aborted = true;
          return 0;
        }
        outsize += OBSize-zst.avail_out;
        ds.rawWriteExact(ob[0..OBSize-zst.avail_out]);
        zst.next_out = ob;
        zst.avail_out = OBSize;
      }
    }
  }
  // empty write buffer (just in case)
  if (zst.avail_out < OBSize) {
    if (outsize+(OBSize-zst.avail_out) >= srcsize) {
      // this will be overwritten anyway
      aborted = true;
      return 0;
    }
    outsize += OBSize-zst.avail_out;
    ds.rawWriteExact(ob[0..OBSize-zst.avail_out]);
    zst.next_out = ob;
    zst.avail_out = OBSize;
  }
  // do leftovers
  for (;;) {
    zst.avail_in = 0;
    err = deflate(&zst, Z_FINISH);
    if (err != Z_OK && err != Z_STREAM_END) throw new Exception("zlib compression error");
    if (zst.avail_out < OBSize) {
      if (outsize+(OBSize-zst.avail_out) >= srcsize) {
        // this will be overwritten anyway
        aborted = true;
        return 0;
      }
      outsize += OBSize-zst.avail_out;
      ds.rawWriteExact(ob[0..OBSize-zst.avail_out]);
      zst.next_out = ob;
      zst.avail_out = OBSize;
    } else {
      //if (err != Z_OK) break;
      break;
    }
  }
  // succesfully flushed?
  if (err != Z_STREAM_END) throw new Exception("zlib compression error");
  return crc;
}


// ////////////////////////////////////////////////////////////////////////// //
string toUtf8 (const(char)[] s) {
  import iv.utfutil;
  char[] res;
  char[4] buf;
  foreach (char ch; s) {
    auto len = utf8Encode(buf[], koi2uni(ch));
    if (len < 1) throw new Exception("invalid utf8");
    res ~= buf[0..len];
  }
  return cast(string)res; // safe cast
}


// ////////////////////////////////////////////////////////////////////////// //
// this will write "extra field length" and extra field itself
enum UtfFlags = (1<<10); // bit 11
//enum UtfFlags = 0;

ubyte[] buildUtfExtra (const(char)[] fname) {
  import etc.c.zlib : crc32;
  if (fname.length == 0) return null; // no need to write anything
  auto fu = toUtf8(fname);
  if (fu == fname) return null; // no need to write anything
  uint crc = crc32(0, cast(ubyte*)fname.ptr, cast(uint)fname.length);
  uint sz = 2+2+1+4+cast(uint)fu.length;
  auto res = new ubyte[](sz);
  res[0] = 'u';
  res[1] = 'p';
  sz -= 4;
  res[2] = sz&0xff;
  res[3] = (sz>>8)&0xff;
  res[4] = 1;
  res[5] = crc&0xff;
  res[6] = (crc>>8)&0xff;
  res[7] = (crc>>16)&0xff;
  res[8] = (crc>>24)&0xff;
  res[9..$] = cast(const(ubyte)[])fu[];
  return res;
}


// ////////////////////////////////////////////////////////////////////////// //
public ZipFileInfo zipOne (VFile ds, const(char)[] fname, VFile st, bool dopack=true) {
  ZipFileInfo res;
  ubyte[] ef;
  char[4] sign;

  if (fname.length == 0 || fname.length > ushort.max) throw new Exception("inalid file name");

  res.pkofs = ds.tell;
  res.size = st.size;
  res.method = (res.size > 0 ? 8 : 0);
  if (res.method == 0) dopack = false;
  if (!dopack) { res.method = 0; res.pksize = res.size; }
  res.name = fname.idup;
  ef = buildUtfExtra(res.name);
  if (ef.length > ushort.max) throw new Exception("extra field too big");

  if (res.size > uint.max-1) throw new Exception("file too big");

  // write local header
  sign = "PK\x03\x04";
  ds.rawWriteExact(sign[]);
  ds.writeNum!ushort(0x0310); // version to extract
  ds.writeNum!ushort(ef.length ? UtfFlags : 0); // flags
  ds.writeNum!ushort(res.method); // compression method
  ds.writeNum!ushort(0); // file time
  ds.writeNum!ushort(0); // file date
  auto nfoofs = ds.tell;
  ds.writeNum!uint(res.crc); // crc32
  ds.writeNum!uint(0/*res.pksize*/); // packed size
  ds.writeNum!uint(cast(uint)res.size); // unpacked size
  ds.writeNum!ushort(cast(ushort)fname.length); // name length
  ds.writeNum!ushort(cast(ushort)ef.length); // extra field length
  ds.rawWriteExact(fname[]);
  if (ef.length > 0) ds.rawWriteExact(ef[]);
  if (dopack) {
    // write packed data
    if (res.size > 0) {
      bool aborted;
      auto pkdpos = ds.tell;
      st.seek(0);
      res.crc = zpack(ds, st, aborted);
      res.pksize = ds.tell-pkdpos;
      if (aborted) {
        // there's no sense to pack this file, just store it
        st.seek(0);
        ds.seek(res.pkofs);
        // store it
        return zipOne(ds, fname, st, false);
      }
    }
  } else {
    import etc.c.zlib : crc32;
    import core.stdc.stdlib;
    enum bufsz = 65536;
    auto buf = cast(ubyte*)malloc(bufsz);
    if (buf is null) assert(0, "out of memory");
    scope(exit) free(buf);
    st.seek(0);
    res.crc = crc32(0, null, 0);
    res.pksize = 0;
    while (res.pksize < res.size) {
      auto rd = res.size-res.pksize;
      if (rd > bufsz) rd = bufsz;
      st.rawReadExact(buf[0..cast(uint)rd]);
      ds.rawWriteExact(buf[0..cast(uint)rd]);
      res.pksize += rd;
      res.crc = crc32(res.crc, buf, cast(uint)rd);
    }
  }
  // fix header
  auto oldofs = ds.tell;
  scope(exit) ds.seek(oldofs);
  ds.seek(nfoofs);
  ds.writeNum!uint(res.crc); // crc32
  ds.writeNum!uint(cast(uint)res.pksize);
  return res;
}


// ////////////////////////////////////////////////////////////////////////// //
public void zipFinish (VFile ds, const(ZipFileInfo)[] files) {
  if (files.length > ushort.max) throw new Exception("too many files");
  char[4] sign;
  auto cdofs = ds.tell;
  foreach (const ref fi; files) {
    auto ef = buildUtfExtra(fi.name);
    sign = "PK\x01\x02";
    ds.rawWriteExact(sign[]);
    ds.writeNum!ushort(0x0310); // version made by
    ds.writeNum!ushort(0x0010); // version to extract
    ds.writeNum!ushort(ef.length ? UtfFlags : 0); // flags
    ds.writeNum!ushort(fi.method); // compression method
    ds.writeNum!ushort(0); // file time
    ds.writeNum!ushort(0); // file date
    ds.writeNum!uint(fi.crc);
    ds.writeNum!uint(cast(uint)fi.pksize);
    ds.writeNum!uint(cast(uint)fi.size);
    ds.writeNum!ushort(cast(ushort)fi.name.length); // name length
    ds.writeNum!ushort(cast(ushort)ef.length); // extra field length
    ds.writeNum!ushort(0); // comment length
    ds.writeNum!ushort(0); // disk start
    ds.writeNum!ushort(0); // internal attributes
    ds.writeNum!uint(0); // external attributes
    ds.writeNum!uint(cast(uint)fi.pkofs); // header offset
    ds.rawWriteExact(fi.name[]);
    if (ef.length > 0) ds.rawWriteExact(ef[]);
  }
  auto cdend = ds.tell;
  // write end of central dir
  sign = "PK\x05\x06";
  ds.rawWriteExact(sign[]);
  ds.writeNum!ushort(0); // disk number
  ds.writeNum!ushort(0); // disk with central dir
  ds.writeNum!ushort(cast(ushort)files.length); // number of files on this dist
  ds.writeNum!ushort(cast(ushort)files.length); // number of files total
  ds.writeNum!uint(cast(uint)(cdend-cdofs)); // size of central directory
  ds.writeNum!uint(cast(uint)cdofs); // central directory offset
  ds.writeNum!ushort(0); // archive comment length
}


/*
void main () {
  auto fo = VFile("z00.zip", "w");
  vfsRegister!"first"(new VFSDriverDiskListed(".")); // data dir, will be looked last
  ZipFileInfo[] files;
  foreach (const ref de; vfsAllFiles()) {
    if (de.name.endsWithCI(".zip")) continue;
    writeln(de.name);
    files ~= zipOne(fo, de.name, VFile(de.name));
  }
  zipFinish(fo, files);
}
*/