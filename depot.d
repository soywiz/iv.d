/* ********************************************************************************************* *
 * The basic API of QDBM
 *                                                      Copyright (C) 2000-2007 Mikio Hirabayashi
 * This file is part of QDBM, Quick Database Manager.
 * QDBM is free software; you can redistribute it and/or modify it under the terms of the GNU
 * Lesser General Public License as published by the Free Software Foundation; either version
 * 2.1 of the License or any later version.  QDBM is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
 * details.
 * You should have received a copy of the GNU Lesser General Public License along with QDBM; if
 * not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
 * 02111-1307 USA.
 *
 * D translation and "d-fication" by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
 * ********************************************************************************************* */
module iv.depot /*is aliced*/;

version(aliced) {
} else {
  private alias usize = size_t;
}


/// database errors
class DepotException : Exception {
  static if (__VERSION__ >= 2068) {
    // it's @nogc in 2.068+
    this (uint ecode, string file=__FILE__, usize line=__LINE__, Throwable next=null) @safe pure nothrow @nogc {
      super(errorMessage(ecode), file, line, next);
    }
  } else {
    // it's not @nogc in 2.067 and lower
    this (uint ecode, string file=__FILE__, usize line=__LINE__, Throwable next=null) @safe pure nothrow {
      super(errorMessage(ecode), file, line, next);
    }
  }

  /** Get a message string corresponding to an error code.
   *
   * Params:
   *   ecode = an error code
   *
   * Returns:
   *   The message string of the error code.
   */
  static string errorMessage (uint ecode) @safe pure nothrow @nogc {
    switch (ecode) with (Depot) {
      case DP_ENOERR: return "no error";
      case DP_EFATAL: return "with fatal error";
      case DP_ECLOSED: return "database not opened error";
      case DP_EOPENED: return "already opened database error";
      case DP_EMODE: return "invalid mode";
      case DP_EBROKEN: return "broken database file";
      case DP_EKEEP: return "existing record";
      case DP_ENOITEM: return "no item found";
      case DP_EALLOC: return "memory allocation error";
      case DP_EMAP: return "memory mapping error";
      case DP_EOPEN: return "open error";
      case DP_ECLOSE: return "close error";
      case DP_ETRUNC: return "trunc error";
      case DP_ESYNC: return "sync error";
      case DP_ESTAT: return "stat error";
      case DP_ESEEK: return "seek error";
      case DP_EREAD: return "read error";
      case DP_EWRITE: return "write error";
      case DP_ELOCK: return "lock error";
      case DP_EUNLINK: return "unlink error";
      case DP_EMKDIR: return "mkdir error";
      case DP_ERMDIR: return "rmdir error";
      case DP_EMISC: return "miscellaneous error";
      default: return "(invalid ecode)";
    }
    assert(0);
  }
}


/// database
public final class Depot {
  public import core.sys.posix.sys.types : time_t;
  private import std.typecons : Flag, Yes, No;

  enum QDBM_VERSION = "1.8.78"; /// library version
  enum QDBM_LIBVER = 1414;

  this (const(char)* name, int omode, int bnum=-1) { open(name, omode, bnum); }
  ~this () { close(); }

private:
  string m_name;   // name of the database file; terminated with '\0', but '\0' is not a string part
  bool m_wmode;    // whether to be writable
  ulong m_inode;   // inode of the database file
  time_t m_mtime;  // last modified time of the database
  int m_fd = -1;   // file descriptor of the database file
  long m_fsiz;     // size of the database file
  char* m_map;     // pointer to the mapped memory
  int m_msiz;      // size of the mapped memory
  int* m_buckets;  // pointer to the bucket array
  int m_bnum;      // number of the bucket array
  int m_rnum;      // number of records
  bool m_fatal;    // whether a fatal error occured
  int m_ioff;      // offset of the iterator
  int* m_fbpool;   // free block pool
  int m_fbpsiz;    // size of the free block pool
  int m_fbpinc;    // incrementor of update of the free block pool
  int m_alignment; // basic size of alignment (can be negative; why?)

private:
  version(BigEndian) {
    enum dpbigendian = true;
  } else {
    enum dpbigendian = false;
  }
  enum DP_MAGICNUMB = "[Depot]\n\f"; // magic number on environments of big endian
  enum DP_MAGICNUML = "[depot]\n\f"; // magic number on environments of little endian
  enum DP_FILEMODE  = 384;  // 0o600: permission of a creating file
  enum DP_HEADSIZ   = 48;   // size of the reagion of the header
  enum DP_LIBVEROFF = 12;   // offset of the region for the library version
  enum DP_FLAGSOFF  = 16;   // offset of the region for flags
  enum DP_FSIZOFF   = 24;   // offset of the region for the file size
  enum DP_BNUMOFF   = 32;   // offset of the region for the bucket number
  enum DP_RNUMOFF   = 40;   // offset of the region for the record number
  enum DP_DEFBNUM   = 8191; // default bucket number
  enum DP_FBPOOLSIZ = 16;   // size of free block pool
  enum DP_ENTBUFSIZ = 128;  // size of the entity buffer
  enum DP_STKBUFSIZ = 256;  // size of the stack key buffer
  enum DP_WRTBUFSIZ = 8192; // size of the writing buffer
  enum DP_FSBLKSIZ  = 4096; // size of a block of the file system
  enum DP_OPTBLOAD  = 0.25; // ratio of bucket loading at optimization
  enum DP_OPTRUNIT  = 256;  // number of records in a process of optimization
  enum DP_NUMBUFSIZ = 32;   // size of a buffer for a number
  enum DP_IOBUFSIZ  = 8192; // size of an I/O buffer

  enum DP_TMPFSUF = ".dptmp"; // suffix of a temporary file

  // enumeration for a record header
  enum {
    DP_RHIFLAGS, // offset of flags
    DP_RHIHASH,  // offset of value of the second hash function
    DP_RHIKSIZ,  // offset of the size of the key
    DP_RHIVSIZ,  // offset of the size of the value
    DP_RHIPSIZ,  // offset of the size of the padding bytes
    DP_RHILEFT,  // offset of the offset of the left child
    DP_RHIRIGHT, // offset of the offset of the right child
    DP_RHNUM     // number of elements of a header
  }

  // enumeration for the flag of a record
  enum {
    DP_RECFDEL = 1 << 0,  // deleted
    DP_RECFREUSE = 1 << 1 // reusable
  }

public:
  /// enumeration for error codes
  enum {
    DP_ENOERR,  /// no error
    DP_EFATAL,  /// with fatal error
    DP_ECLOSED, /// trying to operate on closed db
    DP_EOPENED, /// trying to opend an already opened db
    DP_EMODE,   /// invalid mode
    DP_EBROKEN, /// broken database file
    DP_EKEEP,   /// existing record
    DP_ENOITEM, /// no item found
    DP_EALLOC,  /// memory allocation error
    DP_EMAP,    /// memory mapping error
    DP_EOPEN,   /// open error
    DP_ECLOSE,  /// close error
    DP_ETRUNC,  /// trunc error
    DP_ESYNC,   /// sync error
    DP_ESTAT,   /// stat error
    DP_ESEEK,   /// seek error
    DP_EREAD,   /// read error
    DP_EWRITE,  /// write error
    DP_ELOCK,   /// lock error
    DP_EUNLINK, /// unlink error
    DP_EMKDIR,  /// mkdir error
    DP_ERMDIR,  /// rmdir error
    DP_EMISC,   /// miscellaneous error
  }

  /// enumeration for open modes
  enum {
    DP_OREADER = 1 << 0, /// open as a reader
    DP_OWRITER = 1 << 1, /// open as a writer
    DP_OCREAT = 1 << 2,  /// a writer creating
    DP_OTRUNC = 1 << 3,  /// a writer truncating
    DP_ONOLCK = 1 << 4,  /// open without locking
    DP_OLCKNB = 1 << 5,  /// lock without blocking
    DP_OSPARSE = 1 << 6  /// create as a sparse file
  }

  /// enumeration for write modes
  enum {
    DP_DOVER, /// overwrite an existing value
    DP_DKEEP, /// keep an existing value
    DP_DCAT   /// concatenate values
  }

final:
public:
  @property bool opened () const @safe pure nothrow @nogc { return (m_fd >= 0); }

  void checkOpened () {
    if (m_fatal) raise(DP_EFATAL);
    if (!opened) raise(DP_ECLOSED);
  }

  /** Free `malloc()`ed pointer and set variable to `null`.
   *
   * Params:
   *   ptr = the pointer to variable holding a pointer
   */
  static freeptr(T) (ref T* ptr) {
    import core.stdc.stdlib : free;
    if (ptr !is null) {
      free(cast(void*)ptr);
      ptr = null;
    }
  }

  /** Get a database handle.
   *
   *  While connecting as a writer, an exclusive lock is invoked to the database file.
   *  While connecting as a reader, a shared lock is invoked to the database file. The thread
   *  blocks until the lock is achieved. If `DP_ONOLCK` is used, the application is responsible
   *  for exclusion control.
   *
   * Params:
   *   name = the name of a database file
   *   omode = specifies the connection mode: `DP_OWRITER` as a writer, `DP_OREADER` as a reader.
   *    If the mode is `DP_OWRITER`, the following may be added by bitwise or: `DP_OCREAT`, which
   *    means it creates a new database if not exist, `DP_OTRUNC`, which means it creates a new
   *    database regardless if one exists.  Both of `DP_OREADER` and `DP_OWRITER` can be added to by
   *    bitwise or: `DP_ONOLCK`, which means it opens a database file without file locking, or
   *    `DP_OLCKNB`, which means locking is performed without blocking.  `DP_OCREAT` can be added to
   *    by bitwise or: `DP_OSPARSE`, which means it creates a database file as a sparse file.
   *   bnum = the number of elements of the bucket array.
   *    If it is not more than 0, the default value is specified.  The size of a bucket array is
   *    determined on creating, and can not be changed except for by optimization of the database.
   *    Suggested size of a bucket array is about from 0.5 to 4 times of the number of all records
   *    to store.
   *   errcode = the error code (can be `null`)
   *
   * Throws:
   *   DepotException on various errors
   */
  void open (const(char)* name, int omode, int bnum) {
    import core.stdc.stdio : sprintf;
    import core.stdc.stdlib : malloc, free;
    import core.stdc.string : memcpy;
    import core.sys.posix.fcntl : open, O_CREAT, O_RDONLY, O_RDWR;
    import core.sys.posix.sys.mman : mmap, munmap, MAP_FAILED, PROT_READ, PROT_WRITE, MAP_SHARED;
    import core.sys.posix.sys.stat : fstat, lstat, S_ISREG, stat_t;
    import core.sys.posix.unistd : close, ftruncate;
    char[DP_HEADSIZ] hbuf;
    char* map;
    char c;
    string tname;
    int mode, fd, rnum, msiz;
    ulong inode;
    long fsiz;
    int* fbpool;
    stat_t sbuf;
    time_t mtime;
    if (opened) raise(DP_EOPENED);
    assert(name !is null);
    mode = O_RDONLY;
    if (omode&DP_OWRITER) {
      mode = O_RDWR;
      if (omode&DP_OCREAT) mode |= O_CREAT;
    }
    if ((fd = open(name, mode, DP_FILEMODE)) == -1) raise(DP_EOPEN);
    scope(failure) close(fd);
    if ((omode&DP_ONOLCK) == 0) fdlock(fd, omode&DP_OWRITER, omode&DP_OLCKNB);
    if ((omode&DP_OWRITER) && (omode&DP_OTRUNC)) {
      if (ftruncate(fd, 0) == -1) raise(DP_ETRUNC);
    }
    if (fstat(fd, &sbuf) == -1 || !S_ISREG(sbuf.st_mode) || (sbuf.st_ino == 0 && lstat(name, &sbuf) == -1)) raise(DP_ESTAT);
    inode = sbuf.st_ino;
    mtime = sbuf.st_mtime;
    fsiz = sbuf.st_size;
    if ((omode&DP_OWRITER) && fsiz == 0) {
      hbuf[] = 0;
      static if (dpbigendian) {
        hbuf[0..DP_MAGICNUMB.length] = DP_MAGICNUMB[];
      } else {
        hbuf[0..DP_MAGICNUML.length] = DP_MAGICNUML[];
      }
      sprintf(hbuf.ptr+DP_LIBVEROFF, "%d", QDBM_LIBVER/100);
      bnum = (bnum < 1 ? DP_DEFBNUM : bnum);
      bnum = primenum(bnum);
      memcpy(hbuf.ptr+DP_BNUMOFF, &bnum, int.sizeof);
      rnum = 0;
      memcpy(hbuf.ptr+DP_RNUMOFF, &rnum, int.sizeof);
      fsiz = DP_HEADSIZ+bnum*int.sizeof;
      memcpy(hbuf.ptr+DP_FSIZOFF, &fsiz, int.sizeof);
      fdseekwrite(fd, 0, hbuf[]);
      if (omode&DP_OSPARSE) {
        c = 0;
        fdseekwrite(fd, fsiz-1, (&c)[0..1]);
      } else {
        ubyte[DP_IOBUFSIZ] ebuf; // totally empty buffer initialized with 0 %-)
        map = cast(char*)malloc(bnum*int.sizeof);
        usize left = bnum*int.sizeof;
        usize pos = DP_HEADSIZ;
        while (left > 0) {
          usize wr = (left > ebuf.length ? ebuf.length : left);
          fdseekwrite(fd, pos, ebuf[0..wr]);
          left -= wr;
          pos += wr;
        }
      }
    }
    try {
      fdseekread(fd, 0, hbuf[0..DP_HEADSIZ]);
    } catch (Exception) {
      raise(DP_EBROKEN);
    }
    static if (dpbigendian) {
      alias MAGIC = DP_MAGICNUMB;
    } else {
      alias MAGIC = DP_MAGICNUML;
    }
    if ((omode&DP_ONOLCK) == 0 && (hbuf[0..MAGIC.length] != MAGIC || *(cast(int*)(hbuf.ptr+DP_FSIZOFF)) != fsiz)) raise(DP_EBROKEN);
    bnum = *(cast(int*)(hbuf.ptr+DP_BNUMOFF));
    rnum = *(cast(int*)(hbuf.ptr+DP_RNUMOFF));
    if (bnum < 1 || rnum < 0 || fsiz < DP_HEADSIZ+bnum*int.sizeof) raise(DP_EBROKEN);
    msiz = DP_HEADSIZ+bnum*int.sizeof;
    map = cast(char*)mmap(null, msiz, PROT_READ | ((mode & DP_OWRITER) ? PROT_WRITE : 0), MAP_SHARED, fd, 0);
    if (map == MAP_FAILED) raise(DP_EMAP);
    scope(failure) munmap(map, msiz);
    tname = null;
    fbpool = null;
    { // keep '\0' after string
      import std.exception : assumeUnique;
      usize len = 0;
      while (name[len]) ++len;
      auto nmd = name[0..len+1].dup;
      tname = nmd[0..$-1].assumeUnique;
    }
    fbpool = cast(int*)malloc(DP_FBPOOLSIZ*2*int.sizeof);
    if (fbpool is null) raise(DP_EALLOC);
    m_name = tname;
    m_wmode = (mode & DP_OWRITER) != 0;
    m_inode = inode;
    m_mtime = mtime;
    m_fd = fd;
    m_fsiz = fsiz;
    m_map = map;
    m_msiz = msiz;
    m_buckets = cast(int*)(map+DP_HEADSIZ);
    m_bnum = bnum;
    m_rnum = rnum;
    m_fatal = false;
    m_ioff = 0;
    m_fbpool = fbpool;
    m_fbpool[0..DP_FBPOOLSIZ*2] = -1;
    m_fbpsiz = DP_FBPOOLSIZ*2;
    m_fbpinc = 0;
    m_alignment = 0;
  }

  /** Close a database handle.
   *
   * Returns:
   *   If successful, the return value is true, else, it is false.
   *   Because the region of a closed handle is released, it becomes impossible to use the handle.
   *   Updating a database is assured to be written when the handle is closed. If a writer opens
   *   a database but does not close it appropriately, the database will be broken.
   *
   * Throws:
   *   DepotException on various errors
   */
  void close () {
    import core.sys.posix.sys.mman : munmap, MAP_FAILED;
    import core.sys.posix.unistd : close;
    import core.stdc.stdlib : free;
    if (!opened) return;
    bool fatal = m_fatal;
    uint err = DP_ENOERR;
    if (m_wmode) {
      *(cast(int*)(this.m_map+DP_FSIZOFF)) = cast(int)this.m_fsiz;
      *(cast(int*)(this.m_map+DP_RNUMOFF)) = this.m_rnum;
    }
    if (m_map != MAP_FAILED) {
      if (munmap(m_map, m_msiz) == -1) err = DP_EMAP;
    }
    if (close(m_fd) == -1) err = DP_ECLOSE;
    freeptr(m_fbpool);
    m_name = null;
    if (fatal) err = DP_EFATAL;
    if (err != DP_ENOERR) raise(err);
  }

  /** Store a record.
   *
   * Params:
   *   kbuf = the pointer to the region of a key
   *   vbuf = the pointer to the region of a value
   *   dmode = behavior when the key overlaps, by the following values:
   *           `DP_DOVER`, which means the specified value overwrites the existing one,
   *           `DP_DKEEP`, which means the existing value is kept,
   *           `DP_DCAT`, which means the specified value is concatenated at the end of the existing value.
   *
   * Throws:
   *   DepotException on various errors
   */
  void put (const(void)[] kbuf, const(void)[] vbuf, int dmode=DP_DOVER) {
    import core.stdc.string : memcpy;
    import core.stdc.stdlib : free, malloc, realloc;
    int[DP_RHNUM] head, next;
    int hash, bi, off, entoff, newoff, rsiz, nsiz, fdel, mroff, mrsiz, mi, min;
    bool ee;
    char[DP_ENTBUFSIZ] ebuf;
    char* tval, swap;
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    newoff = -1;
    hash = secondhash(kbuf);
    if (recsearch(kbuf, hash, &bi, &off, &entoff, head[], ebuf[], &ee, Yes.delhit)) {
      // record found
      fdel = head.ptr[DP_RHIFLAGS]&DP_RECFDEL;
      if (dmode == DP_DKEEP && !fdel) raise(DP_EKEEP);
      if (fdel) {
        head.ptr[DP_RHIPSIZ] += head.ptr[DP_RHIVSIZ];
        head.ptr[DP_RHIVSIZ] = 0;
      }
      rsiz = recsize(head[]);
      nsiz = DP_RHNUM*int.sizeof+kbuf.length+vbuf.length;
      if (dmode == DP_DCAT) nsiz += head.ptr[DP_RHIVSIZ];
      if (off+rsiz >= m_fsiz) {
        if (rsiz < nsiz) {
          head.ptr[DP_RHIPSIZ] += nsiz-rsiz;
          rsiz = nsiz;
          m_fsiz = off+rsiz;
        }
      } else {
        while (nsiz > rsiz && off+rsiz < m_fsiz) {
          rechead(off+rsiz, next[], null, null);
          if ((next.ptr[DP_RHIFLAGS]&DP_RECFREUSE) == 0) break;
          head.ptr[DP_RHIPSIZ] += recsize(next[]);
          rsiz += recsize(next[]);
        }
        for (usize i = 0; i < m_fbpsiz; i += 2) {
          if (m_fbpool[i] >= off && m_fbpool[i] < off+rsiz) {
            m_fbpool[i] = m_fbpool[i+1] = -1;
          }
        }
      }
      if (nsiz <= rsiz) {
        recover(off, head[], vbuf, (dmode == DP_DCAT ? Yes.catmode : No.catmode));
      } else {
        tval = null;
        scope(failure) { m_fatal = true; freeptr(tval); }
        if (dmode == DP_DCAT) {
          if (ee && DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+head.ptr[DP_RHIVSIZ] <= DP_ENTBUFSIZ) {
            tval = cast(char*)malloc(head.ptr[DP_RHIVSIZ]+vbuf.length+1);
            if (tval is null) { m_fatal = true; raise(DP_EALLOC); }
            memcpy(tval, ebuf.ptr+(DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]), head.ptr[DP_RHIVSIZ]);
          } else {
            tval = recval(off, head[]);
            swap = cast(char*)realloc(tval, head.ptr[DP_RHIVSIZ]+vbuf.length+1);
            if (swap is null) raise(DP_EALLOC);
            tval = swap;
          }
          memcpy(tval+head.ptr[DP_RHIVSIZ], vbuf.ptr, vbuf.length);
          immutable newsize = head.ptr[DP_RHIVSIZ]+vbuf.length;
          vbuf = tval[0..newsize];
        }
        mi = -1;
        min = -1;
        for (usize i = 0; i < this.m_fbpsiz; i += 2) {
          if (m_fbpool[i+1] < nsiz) continue;
          if (mi == -1 || m_fbpool[i+1] < min) {
            mi = i;
            min = m_fbpool[i+1];
          }
        }
        if (mi >= 0) {
          mroff = m_fbpool[mi];
          mrsiz = m_fbpool[mi+1];
          m_fbpool[mi] = -1;
          m_fbpool[mi+1] = -1;
        } else {
          mroff = -1;
          mrsiz = -1;
        }
        recdelete(off, head[], Yes.reusable);
        if (mroff > 0 && nsiz <= mrsiz) {
          recrewrite(mroff, mrsiz, kbuf, vbuf, hash, head.ptr[DP_RHILEFT], head.ptr[DP_RHIRIGHT]);
          newoff = mroff;
        } else {
          newoff = recappend(kbuf, vbuf, hash, head.ptr[DP_RHILEFT], head.ptr[DP_RHIRIGHT]);
        }
        free(tval);
      }
      if (fdel) ++m_rnum;
    } else {
      // no such record
      scope(failure) m_fatal = true;
      newoff = recappend(kbuf, vbuf, hash, 0, 0);
      ++m_rnum;
    }
    if (newoff > 0) {
      if (entoff > 0) {
        fdseekwritenum(m_fd, entoff, newoff);
      } else {
        m_buckets[bi] = newoff;
      }
    }
  }

  /** Delete a record.
   *
   * Params:
   *   kbuf = the pointer to the region of a key
   *
   * Returns:
   *   If successful, the return value is true, else, it is false.
   *   False is returned when no record corresponds to the specified key.
   *
   * Throws:
   *   DepotException on various errors
   */
  bool del (const(void)[] kbuf) {
    int[DP_RHNUM] head;
    int hash, bi, off, entoff;
    bool ee;
    char[DP_ENTBUFSIZ] ebuf;
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    hash = secondhash(kbuf);
    if (!recsearch(kbuf, hash, &bi, &off, &entoff, head[], ebuf[], &ee)) return false; //raise(DP_ENOITEM);
    recdelete(off, head[], No.reusable);
    --m_rnum;
    return true;
  }

  /** Retrieve a record.
   *
   * Params:
   *   kbuf = the pointer to the region of a key
   *   start = the offset address of the beginning of the region of the value to be read
   *   max = specifies the max size to be read; if it is `uint.max`, the size to read is unlimited
   *   sp = the pointer to a variable to which the size of the region of the return
   *        value is assigned; if it is `null`, it is not used
   *
   * Returns:
   *   If successful, the return value is the pointer to the region of the value of the
   *   corresponding record, else, it is `null`. `null` is returned when no record corresponds to
   *   the specified key or the size of the value of the corresponding record is less than `start`.
   *   Because an additional zero code is appended at the end of the region of the return value,
   *   the return value can be treated as a character string. Because the region of the return
   *   value is allocated with the `malloc` call, it should be released with the `free` call if it
   *   is no longer in use.
   *
   * Throws:
   *   DepotException on various errors
   */
  char* get (const(void)[] kbuf, uint start=0, uint max=uint.max, usize* sp=null) {
    import core.stdc.string : memcpy;
    import core.stdc.stdlib : malloc;
    int[DP_RHNUM] head;
    int hash, bi, off, entoff;
    bool ee;
    usize vsiz;
    char[DP_ENTBUFSIZ] ebuf;
    char* vbuf;
    if (sp !is null) *sp = 0;
    checkOpened();
    hash = secondhash(kbuf);
    if (!recsearch(kbuf, hash, &bi, &off, &entoff, head[], ebuf[], &ee)) return null; //raise(DP_ENOITEM);
    if (start > head.ptr[DP_RHIVSIZ]) return null; //raise(DP_ENOITEM);
    scope(failure) m_fatal = true; // any failure beyond this point is fatal
    if (ee && DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+head.ptr[DP_RHIVSIZ] <= DP_ENTBUFSIZ) {
      head.ptr[DP_RHIVSIZ] -= start;
      if (max == uint.max) {
        vsiz = head.ptr[DP_RHIVSIZ];
      } else {
        vsiz = (max < head.ptr[DP_RHIVSIZ] ? max : head.ptr[DP_RHIVSIZ]);
      }
      vbuf = cast(char*)malloc(vsiz+1);
      if (vbuf is null) raise(DP_EALLOC);
      memcpy(vbuf, ebuf.ptr+(DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+start), vsiz);
      vbuf[vsiz] = '\0';
    } else {
      vbuf = recval(off, head[], start, max);
    }
    if (sp !is null) {
      if (max == uint.max) {
        *sp = head.ptr[DP_RHIVSIZ];
      } else {
        *sp = (max < head.ptr[DP_RHIVSIZ] ? max : head.ptr[DP_RHIVSIZ]);
      }
    }
    return vbuf;
  }

  /** Retrieve a record and write the value into a buffer.
   *
   * Params:
   *   vbuf = the pointer to a buffer into which the value of the corresponding record is written
   *   kbuf = the pointer to the region of a key
   *   start = the offset address of the beginning of the region of the value to be read
   *
   * Returns:
   *   If successful, the return value is the read data (slice of vbuf), else, it is `null`.
   *   `null` returned when no record corresponds to the specified key or the size of the value
   *   of the corresponding record is less than `start`.
   *   Note that no additional zero code is appended at the end of the region of the writing buffer.
   *
   * Throws:
   *   DepotException on various errors
   */
  char[] getwb (void[] vbuf, const(void)[] kbuf, uint start=0) {
    import core.stdc.string : memcpy;
    int[DP_RHNUM] head;
    int hash, bi, off, entoff;
    bool ee;
    usize vsiz;
    char[DP_ENTBUFSIZ] ebuf;
    checkOpened();
    hash = secondhash(kbuf);
    if (!recsearch(kbuf, hash, &bi, &off, &entoff, head[], ebuf[], &ee)) return null; //raise(DP_ENOITEM);
    if (start > head.ptr[DP_RHIVSIZ]) return null; //raise(DP_ENOITEM);
    scope(failure) m_fatal = true; // any failure beyond this point is fatal
    if (ee && DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+head.ptr[DP_RHIVSIZ] <= DP_ENTBUFSIZ) {
      head.ptr[DP_RHIVSIZ] -= start;
      vsiz = (vbuf.length < head.ptr[DP_RHIVSIZ] ? vbuf.length : head.ptr[DP_RHIVSIZ]);
      memcpy(vbuf.ptr, ebuf.ptr+(DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+start), vsiz);
    } else {
      vsiz = recvalwb(vbuf, off, head[], start);
    }
    return cast(char[])(vbuf[0..vsiz]);
  }

  /** Get the size of the value of a record.
   *
   * Params:
   *   kbuf = the pointer to the region of a key
   *
   * Returns:
   *   If successful, the return value is the size of the value of the corresponding record, else, it is -1.
   *   Because this function does not read the entity of a record, it is faster than `get`.
   *
   * Throws:
   *   DepotException on various errors
   */
  usize vsize (const(void)[] kbuf) {
    int[DP_RHNUM] head;
    int hash, bi, off, entoff;
    bool ee;
    char[DP_ENTBUFSIZ] ebuf;
    checkOpened();
    hash = secondhash(kbuf);
    if (!recsearch(kbuf, hash, &bi, &off, &entoff, head[], ebuf[], &ee)) return -1; //raise(DP_ENOITEM);
    return head.ptr[DP_RHIVSIZ];
  }

  /** Initialize the iterator of a database handle.
   *
   * Returns:
   *   If successful, the return value is true, else, it is false.
   *   The iterator is used in order to access the key of every record stored in a database.
   *
   * Throws:
   *   DepotException on various errors
   */
  void itInit () {
    checkOpened();
    m_ioff = 0;
  }

  /** Get the next key of the iterator.
   *
   * Params:
   *   sp = the pointer to a variable to which the size of the region of the return value is assigned.
   *        If it is `null`, it is not used.
   *
   * Returns:
   *   If successful, the return value is the pointer to the region of the next key, else, it is
   *   `null`. `null` is returned when no record is to be get out of the iterator.
   *   Because an additional zero code is appended at the end of the region of the return value,
   *   the return value can be treated as a character string. Because the region of the return
   *   value is allocated with the `malloc` call, it should be released with the `free` call if
   *   it is no longer in use. It is possible to access every record by iteration of calling
   *   this function. However, it is not assured if updating the database is occurred while the
   *   iteration. Besides, the order of this traversal access method is arbitrary, so it is not
   *   assured that the order of storing matches the one of the traversal access.
   *
   * Throws:
   *   DepotException on various errors
   */
  char* itNext (usize* sp=null) {
    import core.stdc.stdlib : malloc;
    import core.stdc.string : memcpy;
    int[DP_RHNUM] head;
    int off;
    bool ee;
    char[DP_ENTBUFSIZ] ebuf;
    char* kbuf;
    if (sp !is null) *sp = 0;
    checkOpened();
    off = DP_HEADSIZ+m_bnum*int.sizeof;
    off = (off > m_ioff ? off : m_ioff);
    scope(failure) m_fatal = true; // any failure is fatal here
    while (off < m_fsiz) {
      rechead(off, head[], ebuf[], &ee);
      if (head.ptr[DP_RHIFLAGS]&DP_RECFDEL) {
        off += recsize(head[]);
      } else {
        if (ee && DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ] <= DP_ENTBUFSIZ) {
          kbuf = cast(char*)malloc(head.ptr[DP_RHIKSIZ]+1);
          if (kbuf is null) raise(DP_EALLOC);
          memcpy(kbuf, ebuf.ptr+(DP_RHNUM*int.sizeof), head.ptr[DP_RHIKSIZ]);
          kbuf[head.ptr[DP_RHIKSIZ]] = '\0';
        } else {
          kbuf = reckey(off, head[]);
        }
        m_ioff = off+recsize(head[]);
        if (sp !is null) *sp = head.ptr[DP_RHIKSIZ];
        return kbuf;
      }
    }
    //raise(DP_ENOITEM);
    return null;
  }

  /** Set alignment of a database handle.
   *
   * If alignment is set to a database, the efficiency of overwriting values is improved.
   * The size of alignment is suggested to be average size of the values of the records to be
   * stored. If alignment is positive, padding whose size is multiple number of the alignment
   * is placed. If alignment is negative, as `vsiz` is the size of a value, the size of padding
   * is calculated with `(vsiz/pow(2, abs(alignment)-1))'. Because alignment setting is not
   * saved in a database, you should specify alignment every opening a database.
   *
   * Params:
   *   alignment = the size of alignment
   *
   * Throws:
   *   DepotException on various errors
   */
  @property void alignment (int alignment) {
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    m_alignment = alignment;
  }

  /** Get alignment of a database handle.
   *
   * Returns:
   *   The size of alignment
   *
   * Throws:
   *   DepotException on various errors
   */
  @property int alignment () {
    checkOpened();
    return m_alignment;
  }

  /** Set the size of the free block pool of a database handle.
   *
   * The default size of the free block pool is 16. If the size is greater, the space efficiency
   * of overwriting values is improved with the time efficiency sacrificed.
   *
   * Params:
   *   size = the size of the free block pool of a database
   *
   * Throws:
   *   DepotException on various errors
   */
  @property void freeBlockPoolSize (uint size) {
    import core.stdc.stdlib : realloc;
    int* fbpool;
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    size *= 2;
    fbpool = cast(int*)realloc(m_fbpool, size*int.sizeof+1);
    if (fbpool is null) raise(DP_EALLOC);
    fbpool[0..size] = -1;
    m_fbpool = fbpool;
    m_fbpsiz = size;
  }

  /** Get the size of the free block pool of a database handle.
   *
   * Returns:
   *   The size of the free block pool of a database
   *
   * Throws:
   *   DepotException on various errors
   */
  @property uint freeBlockPoolSize () {
    import core.stdc.stdlib : realloc;
    int* fbpool;
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    return m_fbpsiz/2;
  }

  /** Synchronize updating contents with the file and the device.
   *
   * This function is useful when another process uses the connected database file.
   *
   * Throws:
   *   DepotException on various errors
   */
  void sync () {
    import core.sys.posix.sys.mman : msync, MS_SYNC;
    import core.sys.posix.unistd : fsync;
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    *(cast(int*)(m_map+DP_FSIZOFF)) = cast(int)m_fsiz;
    *(cast(int*)(m_map+DP_RNUMOFF)) = m_rnum;
    if (msync(m_map, m_msiz, MS_SYNC) == -1) {
      m_fatal = true;
      raise(DP_EMAP);
    }
    if (fsync(m_fd) == -1) {
      m_fatal = true;
      raise(DP_ESYNC);
    }
  }

  /** Optimize a database.
   *
   * In an alternating succession of deleting and storing with overwrite or concatenate,
   * dispensable regions accumulate. This function is useful to do away with them.
   *
   * Params:
   *   bnum = the number of the elements of the bucket array. If it is not more than 0,
   *          the default value is specified
   *
   * Throws:
   *   DepotException on various errors
   */
  void optimize (int bnum=-1) {
    import core.stdc.stdlib : free, malloc;
    import core.stdc.string : memcpy, strlen;
    import core.sys.posix.sys.mman : mmap, munmap, MAP_FAILED, MAP_SHARED, PROT_READ, PROT_WRITE;
    import core.sys.posix.unistd : ftruncate, unlink;
    Depot tdepot;
    char* name;
    int[DP_RHNUM] head;
    int off, unum;
    bool ee;
    int[DP_OPTRUNIT] ksizs, vsizs;
    char[DP_ENTBUFSIZ] ebuf;
    char*[DP_OPTRUNIT] kbufs, vbufs;
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    name = cast(char*)malloc(m_name.length+DP_TMPFSUF.length+1);
    if (name is null) raise(DP_EALLOC);
    {
      import core.stdc.stdio : sprintf;
      sprintf(name, "%s%s", m_name.ptr, DP_TMPFSUF.ptr);
    }
    if (bnum < 0) {
      bnum = cast(int)(m_rnum*(1.0/DP_OPTBLOAD))+1;
      if (bnum < DP_DEFBNUM/2) bnum = DP_DEFBNUM/2;
    }
    tdepot = new Depot(name, DP_OWRITER|DP_OCREAT|DP_OTRUNC, bnum);
    scope(failure) {
      import std.exception : collectException;
      m_fatal = true;
      unlink(tdepot.m_name.ptr);
      collectException(tdepot.close());
    }
    scope(exit) delete tdepot;
    free(name);
    tdepot.flags = flags;
    tdepot.m_alignment = m_alignment;
    off = DP_HEADSIZ+m_bnum*int.sizeof;
    unum = 0;
    while (off < m_fsiz) {
      rechead(off, head[], ebuf[], &ee);
      if ((head.ptr[DP_RHIFLAGS]&DP_RECFDEL) == 0) {
        if (ee && DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ] <= DP_ENTBUFSIZ) {
          if ((kbufs[unum] = cast(char*)malloc(head.ptr[DP_RHIKSIZ]+1)) is null) raise(DP_EALLOC);
          memcpy(kbufs[unum], ebuf.ptr+(DP_RHNUM*int.sizeof), head.ptr[DP_RHIKSIZ]);
          if (DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+head.ptr[DP_RHIVSIZ] <= DP_ENTBUFSIZ) {
            if ((vbufs[unum] = cast(char*)malloc(head.ptr[DP_RHIVSIZ] + 1)) is null) raise(DP_EALLOC);
            memcpy(vbufs[unum], ebuf.ptr+(DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]), head.ptr[DP_RHIVSIZ]);
          } else {
            vbufs[unum] = recval(off, head[]);
          }
        } else {
          kbufs[unum] = reckey(off, head[]);
          vbufs[unum] = recval(off, head[]);
        }
        ksizs[unum] = head.ptr[DP_RHIKSIZ];
        vsizs[unum] = head.ptr[DP_RHIVSIZ];
        ++unum;
        if (unum >= DP_OPTRUNIT) {
          for (usize i = 0; i < unum; ++i) {
            assert(kbufs[i] !is null && vbufs[i] !is null);
            tdepot.put(kbufs[i][0..ksizs[i]], vbufs[i][0..vsizs[i]], DP_DKEEP);
            free(kbufs[i]);
            free(vbufs[i]);
          }
          unum = 0;
        }
      }
      off += recsize(head[]);
    }
    for (usize i = 0; i < unum; ++i) {
      assert(kbufs[i] !is null && vbufs[i] !is null);
      tdepot.put(kbufs[i][0..ksizs[i]], vbufs[i][0..vsizs[i]], DP_DKEEP);
      free(kbufs[i]);
      free(vbufs[i]);
    }
    tdepot.sync();
    if (munmap(m_map, m_msiz) == -1) raise(DP_EMAP);
    m_map = cast(char*)MAP_FAILED;
    if (ftruncate(m_fd, 0) == -1) raise(DP_ETRUNC);
    fcopy(m_fd, 0, tdepot.m_fd, 0);
    m_fsiz = tdepot.m_fsiz;
    m_bnum = tdepot.m_bnum;
    m_ioff = 0;
    for (usize i = 0; i < this.m_fbpsiz; i += 2) {
      m_fbpool[i] = m_fbpool[i+1] = -1;
    }
    m_msiz = tdepot.m_msiz;
    m_map = cast(char*)mmap(null, m_msiz, PROT_READ|PROT_WRITE, MAP_SHARED, m_fd, 0);
    if (m_map == MAP_FAILED) raise(DP_EMAP);
    m_buckets = cast(int*)(m_map+DP_HEADSIZ);
    string sname = tdepot.m_name;
    tdepot.close();
    if (unlink(sname.ptr) == -1) raise(DP_EUNLINK);
  }

  /** Get the name of a database.
   *
   * Returns:
   *   If successful, the return value is the pointer to the region of the name of the database,
   *   else, it is `null`.
   *   Because the region of the return value is allocated with the `malloc` call, it should be
   *   released with the `free` call if it is no longer in use.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property string name () const @safe pure nothrow @nogc {
    return m_name;
  }

  /** Get the size of a database file.
   *
   * Returns:
   *   If successful, the return value is the size of the database file, else, it is -1.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property long fileSize () {
    checkOpened();
    return m_fsiz;
  }


  /** Get the number of the elements of the bucket array.
   *
   * Returns:
   *   If successful, the return value is the number of the elements of the bucket array, else, it is -1.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property int bucketCount () {
    checkOpened();
    return m_bnum;
  }

  /** Get the number of the used elements of the bucket array.
   *
   * This function is inefficient because it accesses all elements of the bucket array.
   *
   * Returns:
   *   If successful, the return value is the number of the used elements of the bucket array, else, it is -1.
   *
   * Throws:
   *   DepotException on various errors
   */
  int bucketUsed () {
    checkOpened();
    int hits = 0;
    for (usize i = 0; i < m_bnum; ++i) if (m_buckets[i]) ++hits;
    return hits;
  }

  /** Get the number of the records stored in a database.
   *
   * Returns:
   *   If successful, the return value is the number of the records stored in the database, else, it is -1.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property int recordCount () {
    checkOpened();
    return m_rnum;
  }

  /** Check whether a database handle is a writer or not.
   *
   * Returns:
   *   The return value is true if the handle is a writer, false if not.
   */
  @property bool writable () const @safe pure nothrow @nogc {
    return (opened && m_wmode);
  }

  /** Check whether a database has a fatal error or not.
   *
   * Returns:
   *   The return value is true if the database has a fatal error, false if not.
   */
  @property bool fatalError () const @safe pure nothrow @nogc {
    return m_fatal;
  }

  /** Get the inode number of a database file.
   *
   * Returns:
   *   The return value is the inode number of the database file.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property long inode () {
    checkOpened();
    return m_inode;
  }

  /** Get the last modified time of a database.
   *
   * Returns:
   *   The return value is the last modified time of the database.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property time_t mtime () {
    checkOpened();
    return m_mtime;
  }

  /** Get the file descriptor of a database file.
   *
   * Returns:
   *   The return value is the file descriptor of the database file.
   *   Handling the file descriptor of a database file directly is not suggested.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property int fdesc () {
    checkOpened();
    return m_fd;
  }

  /** Remove a database file.
   *
   * Params:
   *   name = the name of a database file
   *
   * Throws:
   *   DepotException on various errors
   */
  static void remove (const(char)* name) {
    import core.stdc.errno : errno, ENOENT;
    import core.sys.posix.sys.stat : lstat, stat_t;
    import core.sys.posix.unistd : unlink;
    assert(name !is null);
    stat_t sbuf;
    if (lstat(name, &sbuf) == -1) {
      if (errno != ENOENT) straise(DP_ESTAT);
      // no file
      return;
    }
    //k8:??? try to open the file to check if it's not locked or something
    auto depot = new Depot(name, DP_OWRITER|DP_OTRUNC);
    delete depot;
    // remove file
    if (unlink(name) == -1) {
      if (errno != ENOENT) straise(DP_EUNLINK);
      // no file
    }
  }

  /** Repair a broken database file.
   *
   * There is no guarantee that all records in a repaired database file correspond to the original
   * or expected state.
   *
   * Params:
   *   name = the name of a database file
   *
   * Returns:
   *   true if ok, false is there were some errors
   *
   * Throws:
   *   DepotException on various errors
   */
  bool repair (const(char)* name) {
    import core.stdc.stdlib : free, malloc;
    import core.stdc.string : strlen;
    import core.sys.posix.fcntl : open, O_RDWR;
    import core.sys.posix.sys.stat : lstat, stat_t;
    import core.sys.posix.unistd : close, ftruncate, unlink;
    Depot tdepot;
    char[DP_HEADSIZ] dbhead;
    char* tname, kbuf, vbuf;
    int[DP_RHNUM] head;
    int fd, flags, bnum, tbnum, off, rsiz, ksiz, vsiz;
    long fsiz;
    stat_t sbuf;
    assert(name !is null);
    if (lstat(name, &sbuf) == -1) raise(DP_ESTAT);
    fsiz = sbuf.st_size;
    if ((fd = open(name, O_RDWR, DP_FILEMODE)) == -1) raise(DP_EOPEN);
    scope(exit) if (fd >= 0) close(fd);
    fdseekread(fd, 0, dbhead[]);
    flags = *cast(int *)(dbhead.ptr+DP_FLAGSOFF);
    bnum = *cast(int *)(dbhead.ptr+DP_BNUMOFF);
    tbnum = *cast(int *)(dbhead.ptr+DP_RNUMOFF)*2;
    if (tbnum < DP_DEFBNUM) tbnum = DP_DEFBNUM;
    tname = cast(char*)malloc(strlen(name)+DP_TMPFSUF.length+1);
    if (tname is null) raise(DP_EALLOC);
    scope(exit) free(tname);
    {
      import core.stdc.stdio : sprintf;
      sprintf(tname, "%s%s", name, DP_TMPFSUF.ptr);
    }
    tdepot = new Depot(tname, DP_OWRITER|DP_OCREAT|DP_OTRUNC, tbnum);
    off = DP_HEADSIZ+bnum*int.sizeof;
    bool err = false;
    while (off < fsiz) {
      try {
        fdseekread(fd, off, head[]);
      } catch (Exception) {
        break;
      }
      if (head.ptr[DP_RHIFLAGS]&DP_RECFDEL) {
        rsiz = recsize(head[]);
        if (rsiz < 0) break;
        off += rsiz;
        continue;
      }
      ksiz = head.ptr[DP_RHIKSIZ];
      vsiz = head.ptr[DP_RHIVSIZ];
      if (ksiz >= 0 && vsiz >= 0) {
        kbuf = cast(char*)malloc(ksiz+1);
        vbuf = cast(char*)malloc(vsiz+1);
        if (kbuf !is null && vbuf !is null) {
          try {
            fdseekread(fd, off+DP_RHNUM*int.sizeof, kbuf[0..ksiz]);
            fdseekread(fd, off+DP_RHNUM*int.sizeof+ksiz, vbuf[0..vsiz]);
            tdepot.put(kbuf[0..ksiz], vbuf[0..vsiz], DP_DKEEP);
          } catch (Exception) {
            err = true;
          }
        } else {
          //if (!err) raise(DP_EALLOC);
          err = true;
        }
        if (vbuf !is null) free(vbuf);
        if (kbuf !is null) free(kbuf);
      } else {
        //if (!err) raise(DP_EBROKEN);
        err = true;
      }
      rsiz = recsize(head[]);
      if (rsiz < 0) break;
      off += rsiz;
    }
    tdepot.flags = flags; // err = true;
    try {
      tdepot.sync();
    } catch (Exception) {
      err = true;
    }
    if (ftruncate(fd, 0) == -1) {
      //if (!err) raise(DP_ETRUNC);
      err = true;
    }
    try {
      fcopy(fd, 0, tdepot.m_fd, 0);
      tdepot.close();
    } catch (Exception) {
      err = true;
    }
    if (close(fd) == -1) {
      //if (!err) raise(DP_ECLOSE);
      err = true;
    }
    fd = -1;
    if (unlink(tname) == -1) {
      //if (!err) raise(DP_EUNLINK);
      err = true;
    }
    return !err;
  }

  /** Hash function used inside Depot.
   *
   * This function is useful when an application calculates the state of the inside bucket array.
   *
   * Params:
   *   kbuf = the pointer to the region of a key
   *
   * Returns:
   *   The return value is the hash value of 31 bits length computed from the key.
   */
  static int innerhash (const(void)[] kbuf) @trusted nothrow @nogc {
    int res;
    if (kbuf.length == int.sizeof) {
      import core.stdc.string : memcpy;
      memcpy(&res, kbuf.ptr, res.sizeof);
    } else {
      res = 751;
    }
    foreach (immutable bt; cast(const(ubyte)[])kbuf) res = res*31+bt;
    return (res*87767623)&int.max;
  }

  /** Hash function which is independent from the hash functions used inside Depot.
   *
   * This function is useful when an application uses its own hash algorithm outside Depot.
   *
   * Params:
   *   kbuf = the pointer to the region of a key
   *
   * Returns:
   *   The return value is the hash value of 31 bits length computed from the key.
   */
  static int outerhash (const(void)[] kbuf) @trusted nothrow @nogc {
    int res = 774831917;
    foreach_reverse (immutable bt; cast(const(ubyte)[])kbuf) res = res*29+bt;
    return (res*5157883)&int.max;
  }

  /** Get a natural prime number not less than a number.
   *
   * This function is useful when an application determines the size of a bucket array of its
   * own hash algorithm.
   *
   * Params:
   *   num = a natural number
   *
   * Returns:
   *   The return value is a natural prime number not less than the specified number
   */
  static int primenum (int num) @safe pure nothrow @nogc {
    static immutable int[217] primes = [
      1, 2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 43, 47, 53, 59, 61, 71, 79, 83,
      89, 103, 109, 113, 127, 139, 157, 173, 191, 199, 223, 239, 251, 283, 317, 349,
      383, 409, 443, 479, 509, 571, 631, 701, 761, 829, 887, 953, 1021, 1151, 1279,
      1399, 1531, 1663, 1789, 1913, 2039, 2297, 2557, 2803, 3067, 3323, 3583, 3833,
      4093, 4603, 5119, 5623, 6143, 6653, 7159, 7673, 8191, 9209, 10223, 11261,
      12281, 13309, 14327, 15359, 16381, 18427, 20479, 22511, 24571, 26597, 28669,
      30713, 32749, 36857, 40949, 45053, 49139, 53239, 57331, 61417, 65521, 73727,
      81919, 90107, 98299, 106487, 114679, 122869, 131071, 147451, 163819, 180221,
      196597, 212987, 229373, 245759, 262139, 294911, 327673, 360439, 393209, 425977,
      458747, 491503, 524287, 589811, 655357, 720887, 786431, 851957, 917503, 982981,
      1048573, 1179641, 1310719, 1441771, 1572853, 1703903, 1835003, 1966079,
      2097143, 2359267, 2621431, 2883577, 3145721, 3407857, 3670013, 3932153,
      4194301, 4718579, 5242877, 5767129, 6291449, 6815741, 7340009, 7864301,
      8388593, 9437179, 10485751, 11534329, 12582893, 13631477, 14680063, 15728611,
      16777213, 18874367, 20971507, 23068667, 25165813, 27262931, 29360087, 31457269,
      33554393, 37748717, 41943023, 46137319, 50331599, 54525917, 58720253, 62914549,
      67108859, 75497467, 83886053, 92274671, 100663291, 109051903, 117440509,
      125829103, 134217689, 150994939, 167772107, 184549373, 201326557, 218103799,
      234881011, 251658227, 268435399, 301989881, 335544301, 369098707, 402653171,
      436207613, 469762043, 503316469, 536870909, 603979769, 671088637, 738197503,
      805306357, 872415211, 939524087, 1006632947, 1073741789, 1207959503,
      1342177237, 1476394991, 1610612711, 1744830457, 1879048183, 2013265907,
    ];
    assert(num > 0);
    foreach (immutable pr; primes) if (num <= pr) return pr;
    return primes[$-1];
  }

  /* ********************************************************************************************* *
   * features for experts
   * ********************************************************************************************* */

  /** Synchronize updating contents on memory.
   *
   * Throws:
   *   DepotException on various errors
   */
  void memsync () {
    import core.sys.posix.sys.mman : msync, MS_SYNC;
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    *(cast(int*)(m_map+DP_FSIZOFF)) = cast(int)m_fsiz;
    *(cast(int*)(m_map+DP_RNUMOFF)) = m_rnum;
    if (msync(m_map, m_msiz, MS_SYNC) == -1) {
      m_fatal = true;
      raise(DP_EMAP);
    }
  }

  /** Synchronize updating contents on memory, not physically.
   *
   * Throws:
   *   DepotException on various errors
   */
  void memflush () {
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    *(cast(int*)(m_map+DP_FSIZOFF)) = cast(int)m_fsiz;
    *(cast(int*)(m_map+DP_RNUMOFF)) = m_rnum;
    // there is no mflush() call
    version(none) {
      if (mflush(this.m_map, this.m_msiz, MS_SYNC) == -1) {
        m_fatal = true;
        raise(DP_EMAP);
      }
    }
  }

  /** Get flags of a database.
   *
   * Returns:
   *   The return value is the flags of a database.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property int flags () {
    import core.stdc.string : memcpy;
    int res;
    checkOpened();
    memcpy(&res, m_map+DP_FLAGSOFF, int.sizeof);
    return res;
  }

  /** Set flags of a database.
   *
   * Params:
   *   flags = flags to set. Least ten bits are reserved for internal use.
   *
   * Returns:
   *   If successful, the return value is true, else, it is false.
   *
   * Throws:
   *   DepotException on various errors
   */
  @property void flags (int v) {
    import core.stdc.string : memcpy;
    checkOpened();
    if (!m_wmode) raise(DP_EMODE);
    memcpy(m_map+DP_FLAGSOFF, &v, int.sizeof);
  }

private:
  /* ********************************************************************************************* *
   * private objects
   * ********************************************************************************************* */

  void raise (uint errcode, string file=__FILE__, usize line=__LINE__) {
    assert(errcode >= DP_ENOERR);
    if (errcode == DP_EFATAL) m_fatal = true;
    throw new DepotException(errcode, file, line);
  }

  static void straise (uint errcode, string file=__FILE__, usize line=__LINE__) {
    assert(errcode >= DP_ENOERR);
    throw new DepotException(errcode, file, line);
  }

  // get the second hash value
  static int secondhash (const(void)[] kbuf) @trusted nothrow @nogc {
    int res = 19780211;
    foreach_reverse (immutable bt; cast(const(ubyte)[])kbuf) res = res*37+bt;
    return (res*43321879)&int.max;
  }

  /* Lock a file descriptor.
   *
   * Params:
   *   fd = a file descriptor
   *   ex = whether an exclusive lock or a shared lock is performed
   *   nb = whether to request with non-blocking
   *   errcode = the error code (can be `null`)
   *
   * Throws:
   *   DepotException on various errors
   */
  static void fdlock (int fd, int ex, int nb) {
    import core.stdc.stdio : SEEK_SET;
    import core.stdc.string : memset;
    import core.sys.posix.fcntl : flock, fcntl, F_RDLCK, F_SETLK, F_SETLKW, F_WRLCK;
    flock lock;
    assert(fd >= 0);
    memset(&lock, 0, lock.sizeof);
    lock.l_type = (ex ? F_WRLCK : F_RDLCK);
    lock.l_whence = SEEK_SET;
    lock.l_start = 0;
    lock.l_len = 0;
    lock.l_pid = 0;
    while (fcntl(fd, nb ? F_SETLK : F_SETLKW, &lock) == -1) {
      import core.stdc.errno : errno, EINTR;
      if (errno != EINTR) straise(DP_ELOCK);
    }
  }

  /* Write into a file.
   *
   * Params:
   *   fd = a file descriptor
   *   buf = a buffer to write
   *
   * Returns:
   *   The return value is the size of the written buffer, or -1 on failure
   *
   * Throws:
   *   Nothing
   */
  static int fdwrite (int fd, const(void)[] buf) @trusted nothrow @nogc {
    auto lbuf = cast(const(ubyte)[])buf;
    int rv = 0;
    assert(fd >= 0);
    while (lbuf.length > 0) {
      import core.sys.posix.unistd : write;
      auto wb = write(fd, lbuf.ptr, lbuf.length);
      if (wb == -1) {
        import core.stdc.errno : errno, EINTR;
        if (errno != EINTR) return -1;
        continue;
      }
      if (wb == 0) break;
      lbuf = lbuf[wb..$];
      rv += cast(int)wb;
    }
    return rv;
  }

  /* Write into a file at an offset.
   *
   * Params:
   *   fd = a file descriptor
   *   off = an offset of the file
   *   buf = a buffer to write
   *
   * Throws:
   *   DepotException on various errors
   */
  static void fdseekwrite (int fd, long off, const(void)[] buf) {
    import core.stdc.stdio : SEEK_END, SEEK_SET;
    import core.sys.posix.unistd : lseek;
    assert(fd >= 0);
    if (buf.length < 1) return;
    if (lseek(fd, (off < 0 ? 0 : off), (off < 0 ? SEEK_END : SEEK_SET)) == -1) straise(DP_ESEEK);
    if (fdwrite(fd, buf) != buf.length) straise(DP_EWRITE);
  }

  /* Write an integer into a file at an offset.
   *
   * Params:
   *   fd = a file descriptor
   *   off = an offset of the file
   *   num = an integer
   *
   * Throws:
   *   DepotException on various errors
   */
  void fdseekwritenum (int fd, long off, int num) {
    assert(fd >= 0);
    scope(failure) m_fatal = true;
    fdseekwrite(fd, off, (&num)[0..1]);
  }

  /* Read from a file and store the data into a buffer.
   *
   * Params:
   *   fd = a file descriptor
   *   buf = a buffer to store into.
   *
   * Returns:
   *   The return value is the size read with, or -1 on failure
   *
   * Throws:
   *   Nothing
   */
  static int fdread (int fd, void[] buf) @trusted nothrow @nogc {
    import core.sys.posix.unistd : read;
    auto lbuf = cast(ubyte[])buf;
    int total = 0;
    assert(fd >= 0);
    while (lbuf.length > 0) {
      auto bs = read(fd, lbuf.ptr, lbuf.length);
      if (bs < 0) {
        import core.stdc.errno : errno, EINTR;
        if (errno != EINTR) return -1;
        continue;
      }
      if (bs == 0) break;
      lbuf = lbuf[bs..$];
      total += cast(int)bs;
    }
    return total;
  }

  /* Read from a file at an offset and store the data into a buffer.
   *
   * Params:
   *   fd = a file descriptor
   *   off = an offset of the file
   *   buf = a buffer to store into
   *
   * Throws:
   *   DepotException on various errors
   */
  static void fdseekread (int fd, long off, void[] buf) {
    import core.sys.posix.unistd : lseek;
    import core.stdc.stdio : SEEK_SET;
    assert(fd >= 0 && off >= 0);
    if (lseek(fd, off, SEEK_SET) != off) straise(DP_ESEEK);
    if (fdread(fd, buf) != buf.length) straise(DP_EREAD);
  }

  /* Copy data between files.
   *
   * Params:
   *   destfd = a file descriptor of a destination file
   *   destoff = an offset of the destination file
   *   srcfd = a file descriptor of a source file
   *   srcoff = an offset of the source file
   *
   * Returns:
   *   The return value is the size copied with
   *
   * Throws:
   *   DepotException on various errors
   */
  static int fcopy (int destfd, long destoff, int srcfd, long srcoff) {
    import core.stdc.stdio : SEEK_SET;
    import core.sys.posix.unistd : lseek;
    char[DP_IOBUFSIZ] iobuf;
    int sum, iosiz;
    if (lseek(srcfd, srcoff, SEEK_SET) == -1 || lseek(destfd, destoff, SEEK_SET) == -1) straise(DP_ESEEK);
    sum = 0;
    while ((iosiz = fdread(srcfd, iobuf[])) > 0) {
      if (fdwrite(destfd, iobuf[0..iosiz]) != iosiz) straise(DP_EWRITE);
      sum += iosiz;
    }
    if (iosiz < 0) straise(DP_EREAD);
    return sum;
  }

  /* Get the padding size of a record.
   *
   * Params:
   *   ksiz = the size of the key of a record
   *   vsiz = the size of the value of a record
   *
   * Returns:
   *   The return value is the padding size of a record
   */
  usize padsize (usize ksiz, usize vsiz) const @safe pure nothrow @nogc {
    if (m_alignment > 0) {
      return cast(usize)(m_alignment-(m_fsiz+DP_RHNUM*int.sizeof+ksiz+vsiz)%m_alignment);
    } else if (m_alignment < 0) {
      usize pad = cast(usize)(vsiz*(2.0/(1<<(-m_alignment))));
      if (vsiz+pad >= DP_FSBLKSIZ) {
        if (vsiz <= DP_FSBLKSIZ) pad = 0;
        if (m_fsiz%DP_FSBLKSIZ == 0) {
          return cast(usize)((pad/DP_FSBLKSIZ)*DP_FSBLKSIZ+DP_FSBLKSIZ-(m_fsiz+DP_RHNUM*int.sizeof+ksiz+vsiz)%DP_FSBLKSIZ);
        } else {
          return cast(usize)((pad/(DP_FSBLKSIZ/2))*(DP_FSBLKSIZ/2)+(DP_FSBLKSIZ/2)-
            (m_fsiz+DP_RHNUM*int.sizeof+ksiz+vsiz)%(DP_FSBLKSIZ/2));
        }
      } else {
        return (pad >= DP_RHNUM*int.sizeof ? pad : DP_RHNUM*int.sizeof);
      }
    }
    return 0;
  }

  /* Get the size of a record in a database file.
   *
   * Params:
   *   head = the header of a record
   *
   * Returns:
   *   The return value is the size of a record in a database file.
   */
  static int recsize (in int[] head) @trusted pure nothrow @nogc {
    assert(head.length >= DP_RHNUM);
    return DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+head.ptr[DP_RHIVSIZ]+head.ptr[DP_RHIPSIZ];
  }

  /* Read the header of a record.
   *
   * Params:
   *   off = an offset of the database file
   *   head = specifies a buffer for the header
   *   ebuf = specifies the pointer to the entity buffer
   *   eep = the pointer to a variable to which whether ebuf was used is assigned
   *
   * Throws:
   *   DepotException on various errors
   */
  void rechead (long off, int[] head, void[] ebuf, bool* eep) {
    import core.stdc.string : memcpy;
    assert(off >= 0 && head.length >= DP_RHNUM);
    if (eep !is null) *eep = false;
    if (off < 0 || off > m_fsiz) raise(DP_EBROKEN);
    scope(failure) m_fatal = true; // any failure is fatal here
    if (ebuf.length >= DP_ENTBUFSIZ && off < m_fsiz-DP_ENTBUFSIZ) {
      if (eep !is null) *eep = true;
      fdseekread(m_fd, off, ebuf[0..DP_ENTBUFSIZ]);
      memcpy(head.ptr, ebuf.ptr, DP_RHNUM*int.sizeof);
    } else {
      fdseekread(m_fd, off, head[0..DP_RHNUM]);
    }
    if (head.ptr[DP_RHIKSIZ] < 0 || head.ptr[DP_RHIVSIZ] < 0 || head.ptr[DP_RHIPSIZ] < 0 ||
        head.ptr[DP_RHILEFT] < 0 || head.ptr[DP_RHIRIGHT] < 0) raise(DP_EBROKEN);
  }

  /* Read the entitiy of the key of a record.
   *
   * Params:
   *   off = an offset of the database file
   *   head = the header of a record
   *
   * Returns:
   *   The return value is a key data whose region is allocated by `malloc`
   *
   * Throws:
   *   DepotException on various errors
   */
  char* reckey (long off, in int[] head) {
    //TODO: return slice instead of pointer?
    import core.stdc.stdlib : free, malloc;
    char* kbuf;
    assert(off >= 0 && head.length >= DP_RHNUM);
    int ksiz = head.ptr[DP_RHIKSIZ];
    kbuf = cast(char*)malloc(ksiz+1);
    if (kbuf is null) raise(DP_EALLOC);
    scope(failure) free(kbuf);
    fdseekread(m_fd, off+DP_RHNUM*int.sizeof, kbuf[0..ksiz]);
    kbuf[ksiz] = '\0';
    return kbuf;
  }

  /* Read the entitiy of the value of a record.
   *
   * Params:
   *   off = an offset of the database file
   *   head = the header of a record
   *   start = the offset address of the beginning of the region of the value to be read
   *   max = the max size to be read; if it is `uint.max`, the size to read is unlimited
   *
   * Returns:
   *  The return value is a value data whose region is allocated by `malloc`
   *
   * Throws:
   *   DepotException on various errors
   */
  char* recval (long off, int[] head, uint start=0, uint max=uint.max) {
    //TODO: return slice instead of pointer?
    import core.stdc.stdlib : free, malloc;
    char* vbuf;
    uint vsiz;
    assert(off >= 0 && head.length >= DP_RHNUM);
    head.ptr[DP_RHIVSIZ] -= start;
    if (max == uint.max) {
      vsiz = head.ptr[DP_RHIVSIZ];
    } else {
      vsiz = (max < head.ptr[DP_RHIVSIZ] ? max : head.ptr[DP_RHIVSIZ]);
    }
    vbuf = cast(char*)malloc(vsiz+1);
    if (vbuf is null) { m_fatal = true; raise(DP_EALLOC); }
    scope(failure) { m_fatal = true; free(vbuf); }
    fdseekread(m_fd, off+DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+start, vbuf[0..vsiz]);
    vbuf[vsiz] = '\0';
    return vbuf;
  }

  /* Read the entitiy of the value of a record and write it into a given buffer.
   *
   * Params:
   *   off = an offset of the database file
   *   head = the header of a record
   *   start = the offset address of the beginning of the region of the value to be read
   *   vbuf = the pointer to a buffer into which the value of the corresponding record is written
   *
   * Returns:
   *   The return value is the size of the written data
   *
   * Throws:
   *   DepotException on various errors
   */
  usize recvalwb (void[] vbuf, long off, int[] head, uint start=0) {
    assert(off >= 0 && head.length >= DP_RHNUM);
    head.ptr[DP_RHIVSIZ] -= start;
    usize vsiz = (vbuf.length < head.ptr[DP_RHIVSIZ] ? vbuf.length : head.ptr[DP_RHIVSIZ]);
    fdseekread(m_fd, off+DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ]+start, vbuf[0..vsiz]);
    return vsiz;
  }

  /* Compare two keys.
   *
   * Params:
   *   abuf = the pointer to the region of the former
   *   asiz = the size of the region
   *   bbuf = the pointer to the region of the latter
   *   bsiz = the size of the region
   *
   * Returns:
   *   The return value is 0 if two equals, positive if the formar is big, else, negative.
   */
  static int keycmp (const(void)[] abuf, const(void)[] bbuf) @trusted nothrow @nogc {
    import core.stdc.string : memcmp;
    //assert(abuf && asiz >= 0 && bbuf && bsiz >= 0);
    if (abuf.length > bbuf.length) return 1;
    if (abuf.length < bbuf.length) return -1;
    return memcmp(abuf.ptr, bbuf.ptr, abuf.length);
  }

  /* Search for a record.
   *
   * Params:
   *   kbuf = the pointer to the region of a key
   *   hash = the second hash value of the key
   *   bip = the pointer to the region to assign the index of the corresponding record
   *   offp = the pointer to the region to assign the last visited node in the hash chain,
   *          or, -1 if the hash chain is empty
   *   entp = the offset of the last used joint, or, -1 if the hash chain is empty
   *   head = the pointer to the region to store the header of the last visited record in
   *   ebuf = the pointer to the entity buffer
   *   eep = the pointer to a variable to which whether ebuf was used is assigned
   *   delhit = whether a deleted record corresponds or not
   *
   * Returns:
   *   The return value is true if record was found, false if there is no corresponding record.
   *
   * Throws:
   *   DepotException on various errors
   */
  bool recsearch (const(void)[] kbuf, int hash, int* bip, int* offp, int* entp,
                  int[] head, void[] ebuf, bool* eep, Flag!"delhit" delhit=No.delhit)
  {
    import core.stdc.stdlib : free;
    int off, entoff, thash, kcmp;
    char[DP_STKBUFSIZ] stkey;
    char* tkey;
    assert(head.length >= DP_RHNUM);
    assert(ebuf.length >= DP_ENTBUFSIZ);
    assert(hash >= 0 && bip !is null && offp !is null && entp !is null && eep !is null);
    thash = innerhash(kbuf);
    *bip = thash%m_bnum;
    off = m_buckets[*bip];
    *offp = -1;
    *entp = -1;
    entoff = -1;
    *eep = false;
    while (off != 0) {
      rechead(off, head, ebuf, eep);
      thash = head.ptr[DP_RHIHASH];
      if (hash > thash) {
        entoff = off+DP_RHILEFT*int.sizeof;
        off = head.ptr[DP_RHILEFT];
      } else if (hash < thash) {
        entoff = off+DP_RHIRIGHT*int.sizeof;
        off = head.ptr[DP_RHIRIGHT];
      } else {
        if (*eep && DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ] <= DP_ENTBUFSIZ) {
          immutable ebstart = (DP_RHNUM*int.sizeof);
          kcmp = keycmp(kbuf, ebuf[ebstart..ebstart+head.ptr[DP_RHIKSIZ]]);
        } else if (head.ptr[DP_RHIKSIZ] > DP_STKBUFSIZ) {
          if ((tkey = reckey(off, head)) is null) raise(DP_EFATAL);
          kcmp = keycmp(kbuf, tkey[0..head.ptr[DP_RHIKSIZ]]);
          free(tkey);
        } else {
          try {
            fdseekread(m_fd, off+DP_RHNUM*int.sizeof, stkey[0..head.ptr[DP_RHIKSIZ]]);
          } catch (Exception) {
            raise(DP_EFATAL);
          }
          kcmp = keycmp(kbuf, stkey[0..head.ptr[DP_RHIKSIZ]]);
        }
        if (kcmp > 0) {
          entoff = off+DP_RHILEFT*int.sizeof;
          off = head.ptr[DP_RHILEFT];
        } else if (kcmp < 0) {
          entoff = off+DP_RHIRIGHT*int.sizeof;
          off = head.ptr[DP_RHIRIGHT];
        } else {
          if (!delhit && (head.ptr[DP_RHIFLAGS]&DP_RECFDEL)) {
            entoff = off+DP_RHILEFT*int.sizeof;
            off = head.ptr[DP_RHILEFT];
          } else {
            *offp = off;
            *entp = entoff;
            return true;
          }
        }
      }
    }
    *offp = off;
    *entp = entoff;
    return false;
  }

  /* Overwrite a record.
   *
   * Params:
   *   off = the offset of the database file
   *   rsiz = the size of the existing record
   *   kbuf = the pointer to the region of a key
   *   vbuf = the pointer to the region of a value
   *   hash = the second hash value of the key
   *   left = the offset of the left child
   *   right = the offset of the right child
   *
   * Throws:
   *   DepotException on various errors
   */
  void recrewrite (long off, int rsiz, const(void)[] kbuf, const(void)[] vbuf, int hash, int left, int right) {
    import core.stdc.string : memcpy;
    char[DP_WRTBUFSIZ] ebuf;
    int[DP_RHNUM] head;
    int asiz, hoff, koff, voff, mi, min, size;
    assert(off >= 1 && rsiz > 0);
    head.ptr[DP_RHIFLAGS] = 0;
    head.ptr[DP_RHIHASH] = hash;
    head.ptr[DP_RHIKSIZ] = kbuf.length;
    head.ptr[DP_RHIVSIZ] = vbuf.length;
    head.ptr[DP_RHIPSIZ] = rsiz-head.sizeof-kbuf.length-vbuf.length;
    head.ptr[DP_RHILEFT] = left;
    head.ptr[DP_RHIRIGHT] = right;
    asiz = head.sizeof+kbuf.length+vbuf.length;
    if (m_fbpsiz > DP_FBPOOLSIZ*4 && head.ptr[DP_RHIPSIZ] > asiz) {
      rsiz = (head.ptr[DP_RHIPSIZ]-asiz)/2+asiz;
      head.ptr[DP_RHIPSIZ] -= rsiz;
    } else {
      rsiz = 0;
    }
    if (asiz <= DP_WRTBUFSIZ) {
      memcpy(ebuf.ptr, head.ptr, head.sizeof);
      memcpy(ebuf.ptr+head.sizeof, kbuf.ptr, kbuf.length);
      memcpy(ebuf.ptr+head.sizeof+kbuf.length, vbuf.ptr, vbuf.length);
      fdseekwrite(m_fd, off, ebuf[0..asiz]);
    } else {
      hoff = cast(int)off;
      koff = hoff+head.sizeof;
      voff = koff+kbuf.length;
      fdseekwrite(m_fd, hoff, head[]);
      fdseekwrite(m_fd, koff, kbuf[]);
      fdseekwrite(m_fd, voff, vbuf[]);
    }
    if (rsiz > 0) {
      off += head.sizeof+kbuf.length+vbuf.length+head.ptr[DP_RHIPSIZ];
      head.ptr[DP_RHIFLAGS] = DP_RECFDEL|DP_RECFREUSE;
      head.ptr[DP_RHIHASH] = hash;
      head.ptr[DP_RHIKSIZ] = kbuf.length;
      head.ptr[DP_RHIVSIZ] = vbuf.length;
      head.ptr[DP_RHIPSIZ] = rsiz-head.sizeof-kbuf.length-vbuf.length;
      head.ptr[DP_RHILEFT] = 0;
      head.ptr[DP_RHIRIGHT] = 0;
      fdseekwrite(m_fd, off, head[]);
      size = recsize(head[]);
      mi = -1;
      min = -1;
      for (usize i = 0; i < m_fbpsiz; i += 2) {
        if (m_fbpool[i] == -1) {
          m_fbpool[i] = cast(int)off;
          m_fbpool[i+1] = size;
          fbpoolcoal();
          mi = -1;
          break;
        }
        if (mi == -1 || m_fbpool[i+1] < min) {
          mi = i;
          min = m_fbpool[i+1];
        }
      }
      if (mi >= 0 && size > min) {
        m_fbpool[mi] = cast(int)off;
        m_fbpool[mi+1] = size;
        fbpoolcoal();
      }
    }
  }

  /* Write a record at the end of a database file.
   *
   * Params:
   *   kbuf = the pointer to the region of a key
   *   vbuf = the pointer to the region of a value
   *   hash = the second hash value of the key
   *   left = the offset of the left child
   *   right = the offset of the right child
   *
   * Returns:
   *   The return value is the offset of the record
   *
   * Throws:
   *   DepotException on various errors
   */
  int recappend (const(void)[] kbuf, const(void)[] vbuf, int hash, int left, int right) {
    import core.stdc.string : memcpy, memset;
    import core.stdc.stdlib : free, malloc;
    char[DP_WRTBUFSIZ] ebuf;
    int[DP_RHNUM] head;
    int asiz, psiz;
    long off;
    psiz = padsize(kbuf.length, vbuf.length);
    head.ptr[DP_RHIFLAGS] = 0;
    head.ptr[DP_RHIHASH] = hash;
    head.ptr[DP_RHIKSIZ] = kbuf.length;
    head.ptr[DP_RHIVSIZ] = vbuf.length;
    head.ptr[DP_RHIPSIZ] = psiz;
    head.ptr[DP_RHILEFT] = left;
    head.ptr[DP_RHIRIGHT] = right;
    asiz = head.sizeof+kbuf.length+vbuf.length+psiz;
    off = m_fsiz;
    if (asiz <= DP_WRTBUFSIZ) {
      memcpy(ebuf.ptr, head.ptr, head.sizeof);
      memcpy(ebuf.ptr+head.sizeof, kbuf.ptr, kbuf.length);
      memcpy(ebuf.ptr+head.sizeof+kbuf.length, vbuf.ptr, vbuf.length);
      memset(ebuf.ptr+head.sizeof+kbuf.length+vbuf.length, 0, psiz);
      fdseekwrite(m_fd, off, ebuf[0..asiz]);
    } else {
      auto hbuf = cast(char*)malloc(asiz);
      if (hbuf is null) raise(DP_EALLOC);
      scope(exit) free(hbuf);
      memcpy(hbuf, head.ptr, head.sizeof);
      memcpy(hbuf+head.sizeof, kbuf.ptr, kbuf.length);
      memcpy(hbuf+head.sizeof+kbuf.length, vbuf.ptr, vbuf.length);
      memset(hbuf+head.sizeof+kbuf.length+vbuf.length, 0, psiz);
      fdseekwrite(m_fd, off, hbuf[0..asiz]);
    }
    m_fsiz += asiz;
    return cast(int)off;
  }

  /* Overwrite the value of a record.
   *
   * Params:
   *   off = the offset of the database file
   *   head = the header of the record
   *   vbuf = the pointer to the region of a value
   *   cat = whether it is concatenate mode or not
   *
   * Throws:
   *   DepotException on various errors
   */
  void recover (long off, int[] head, const(void)[] vbuf, Flag!"catmode" catmode) {
    assert(off >= 0 && head.length >= DP_RHNUM);
    for (usize i = 0; i < m_fbpsiz; i += 2) {
      if (this.m_fbpool[i] == off) {
        m_fbpool[i] = m_fbpool[i+1] = -1;
        break;
      }
    }
    head.ptr[DP_RHIFLAGS] = 0;
    long voff = off+DP_RHNUM*int.sizeof+head.ptr[DP_RHIKSIZ];
    if (catmode) {
      head.ptr[DP_RHIPSIZ] -= vbuf.length;
      head.ptr[DP_RHIVSIZ] += vbuf.length;
      voff += head.ptr[DP_RHIVSIZ]-vbuf.length; //k8:???
    } else {
      head.ptr[DP_RHIPSIZ] += head.ptr[DP_RHIVSIZ]-vbuf.length;
      head.ptr[DP_RHIVSIZ] = vbuf.length;
    }
    scope(failure) m_fatal = true; // any failure is fatal here
    fdseekwrite(m_fd, off, head[0..DP_RHNUM]);
    fdseekwrite(m_fd, voff, vbuf[]);
  }

  /* Delete a record.
   *
   * Params:
   *   off = the offset of the database file
   *   head = the header of the record
   *   reusable = whether the region is reusable or not
   *
   * Throws:
   *   DepotException on various errors
   */
  void recdelete (long off, int[] head, Flag!"reusable" reusable) {
    assert(off >= 0 && head.length >= DP_RHNUM);
    if (reusable) {
      auto size = recsize(head[]);
      int mi = -1;
      int min = -1;
      for (usize i = 0; i < m_fbpsiz; i += 2) {
        if (m_fbpool[i] == -1) {
          m_fbpool[i] = cast(int)off;
          m_fbpool[i+1] = size;
          fbpoolcoal();
          mi = -1;
          break;
        }
        if (mi == -1 || m_fbpool[i+1] < min) {
          mi = i;
          min = m_fbpool[i+1];
        }
      }
      if (mi >= 0 && size > min) {
        m_fbpool[mi] = cast(int)off;
        m_fbpool[mi+1] = size;
        fbpoolcoal();
      }
    }
    fdseekwritenum(m_fd, off+DP_RHIFLAGS*int.sizeof, DP_RECFDEL|(reusable ? DP_RECFREUSE : 0));
  }

  /* Make contiguous records of the free block pool coalesce. */
  void fbpoolcoal () @trusted {
    import core.stdc.stdlib : qsort;
    if (m_fbpinc++ <= m_fbpsiz/4) return;
    m_fbpinc = 0;
    qsort(m_fbpool, m_fbpsiz/2, int.sizeof*2, &fbpoolcmp);
    for (usize i = 2; i < m_fbpsiz; i += 2) {
      if (m_fbpool[i-2] > 0 && m_fbpool[i-2]+m_fbpool[i-1]-m_fbpool[i] == 0) {
        m_fbpool[i] = m_fbpool[i-2];
        m_fbpool[i+1] += m_fbpool[i-1];
        m_fbpool[i-2] = m_fbpool[i-1] = -1;
      }
    }
  }

  /* Compare two records of the free block pool.
     a = the pointer to one record.
     b = the pointer to the other record.
     The return value is 0 if two equals, positive if the formar is big, else, negative. */
  static extern(C) int fbpoolcmp (in void* a, in void* b) @trusted nothrow @nogc {
    assert(a && b);
    return *cast(const int*)a - *cast(const int*)b;
  }
}
