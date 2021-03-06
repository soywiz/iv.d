// pool of numeric ids, with reusing; based on the code by Emil Persson, A.K.A. Humus ( http://www.humus.name )
// Ported and improved by by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
// Understanding is not required. Only obedience.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License ONLY.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//
// the properties of this system are as follows:
//   * creating a new ID returns the smallest possible unused ID
//   * creating a new range of IDs returns the smallest possible continuous range of the specified size
//   * created IDs remain valid until destroyed
//   * destroying an ID returns it to the pool and may be returned by subsequent allocations
//   * the system is NOT thread-safe
//
// performance properties:
//   * creating an ID is O(1) and generally super-cheap
//   * destroying an ID is also cheap, but O(log(n)), where n is the current number of distinct available ranges
//   * the system merges available ranges when IDs are destroyed, keeping said n generally very small in practice
//   * after warmup, no further memory allocations should be necessary, or be very rare
//   * the system uses very little memory
//   * it is possible to construct a pathological case where fragmentation would cause n to become large; don't do that
module iv.idpool;

alias IdPool16 = IdPoolImpl!ushort; ///
alias IdPool32 = IdPoolImpl!uint; ///


/** eneral IdPool implementation;
 *
 * WARNING! don't use copies of this struct, it WILL ruin everything!
 * copying is not disabled to allow copying when programmer thinks it is necessary.
 * if `allowZero` is true, zero id is valid, otherwise it is never returned.
 * `IDT.max` is ALWAYS invalid, and is used as "error result".
 */
struct IdPoolImpl(IDT, bool allowZero=false) if (is(IDT == ubyte) || is(IDT == ushort) || is(IDT == uint)) {
public:
  alias Type = IDT; ///
  enum Invalid = cast(IDT)IDT.max; /// "invalid id" value

private:
  static align(1) struct Range {
  align(1):
    Type first;
    Type last;
  }

  size_t rangesmem; // sorted array of ranges of free IDs; Range*; use `size_t` to force GC ignoring this struct
  uint rngcount; // number of ranges in list
  uint rngsize; // total capacity of range list (NOT size in bytes!)
  Type idnextmaxid; // next id for `allocNext()`

  @property inout(Range)* ranges () const pure inout nothrow @trusted @nogc { pragma(inline, true); return cast(typeof(return))rangesmem; }

private nothrow @trusted @nogc:
  // will NOT change rngcount if `doChange` is `false`
  void growRangeArray(bool doChange) (uint newcount) {
    enum GrowStep = 128;
    if (newcount <= rngcount) {
      static if (doChange) rngcount = newcount;
      return;
    }
    assert(rngcount <= rngsize);
    if (newcount > rngsize) {
      // need to grow
      import core.stdc.stdlib : realloc;
      if (rngsize >= uint.max/(Range.sizeof+8) || newcount >= uint.max/(Range.sizeof+8)) assert(0, "out of memory");
      rngsize = ((newcount+(GrowStep-1))/GrowStep)*GrowStep;
      size_t newmem = cast(size_t)realloc(cast(void*)rangesmem, rngsize*Range.sizeof);
      if (newmem == 0) assert(0, "out of memory");
      rangesmem = newmem;
    }
    assert(newcount <= rngsize);
    static if (doChange) rngcount = newcount;
  }

  version(unittest) void checkRanges () {
    if (rngcount == 1) {
      if (ranges[0].last+1 == ranges[0].first) return;
    }
    foreach (immutable ridx, const ref Range r; ranges[0..rngcount]) {
      if (r.first > r.last) {
        import core.stdc.stdio; stderr.fprintf("INVALID RANGE #%u (first > last): %u, %u\n", ridx, cast(uint)r.first, cast(uint)r.last);
        dump;
        assert(0, "boom");
      }
      // check if we failed to merge ranges
      if (rngcount-ridx > 1 && r.last >= ranges[ridx+1].first) {
        import core.stdc.stdio; stderr.fprintf("FAILED TO MERGE RANGE #%u: last=%u, next_first=%u\n", ridx, cast(uint)r.last, cast(uint)(ranges[ridx+1].first));
        dump;
        assert(0, "boom");
      }
      if (ridx && r.first <= ranges[ridx-1].last) {
        import core.stdc.stdio; stderr.fprintf("FAILED TO SORT RANGES #%u: last=%u, next_first=%u\n", ridx, cast(uint)r.last, cast(uint)(ranges[ridx+1].first));
        dump;
        assert(0, "boom");
      }
    }
  }

  void insertRange (uint index) {
    growRangeArray!false(rngcount+1);
    if (index < rngcount) {
      // really inserting
      import core.stdc.string : memmove;
      memmove(ranges+index+1, ranges+index, (rngcount-index)*Range.sizeof);
    }
    ++rngcount;
  }

  void destroyRange (uint index) {
    import core.stdc.string : memmove;
    assert(rngcount > 0);
    if (--rngcount > 0) memmove(ranges+index, ranges+index+1, (rngcount-index)*Range.sizeof);
    version(unittest) checkRanges();
  }

public:
  ///
  this (Type aMaxId) { reset(aMaxId); }

  ///
  ~this () {
    if (rangesmem) {
      import core.stdc.stdlib : free;
      free(cast(void*)rangesmem);
    }
  }

  /// checks if the given id is in valid id range.
  static bool isValid (Type id) pure nothrow @safe @nogc {
    pragma(inline, true);
    static if (allowZero) return (id != Invalid); else return (id && id != Invalid);
  }

  /// return next id for `allocNext()`. this is here just for completeness.
  @property nextSeqId () const pure { pragma(inline, true); static if (allowZero) { return idnextmaxid; } else { return (idnextmaxid ? idnextmaxid : 1); } }

  /// remove all allocated ids, and set maximum available id.
  void reset (Type aMaxId=Type.max) {
    if (aMaxId < 1) assert(0, "are you nuts?");
    if (aMaxId == Type.max) --aMaxId; // to ease my life a little
    // start with a single range, from 0/1 to max allowed ID (specified)
    growRangeArray!true(1);
    static if (allowZero) ranges[0].first = 0; else ranges[0].first = 1;
    ranges[0].last = aMaxId;
    idnextmaxid = 0;
  }

  /// allocate lowest unused id.
  /// returns `Invalid` if there are no more ids left.
  Type allocId () {
    if (rngcount == 0) {
      // wasn't inited, init with defaults
      growRangeArray!true(1);
      static if (allowZero) ranges[0].first = 0; else ranges[0].first = 1;
      ranges[0].last = Type.max-1;
    }
    auto rng = ranges;
    Type id = Invalid;
    if (rng.first <= rng.last) {
      id = rng.first;
      // if current range is full and there is another one, that will become the new current range
      if (rng.first == rng.last && rngcount > 1) destroyRange(0); else ++rng.first;
      version(unittest) checkRanges();
    }
    // otherwise we have no ranges left
    if (id != Invalid && id >= idnextmaxid) idnextmaxid = cast(Type)(id+1);
    return id;
  }

  /// allocate the given id.
  /// returns id, or `Invalid` if this id was alrady allocated.
  Type allocId (Type aid) {
    static if (allowZero) {
      if (aid == Invalid) return Invalid;
    } else {
      if (aid == 0 || aid == Invalid) return Invalid;
    }

    if (rngcount == 0) {
      // wasn't inited, create two ranges (before and after this id)
      if (aid >= idnextmaxid) idnextmaxid = cast(Type)(aid+1); // fix next max id
      // but check for special cases first
      static if (allowZero) enum LowestId = 0; else enum LowestId = 1;
      // lowest possible id?
      if (aid == LowestId) {
        growRangeArray!true(1);
        ranges[0].first = cast(Type)(LowestId+1);
        ranges[0].last = Type.max-1;
        version(unittest) checkRanges();
        return aid;
      }
      // highest possible id?
      if (aid == Type.max-1) {
        growRangeArray!true(1);
        ranges[0].first = cast(Type)LowestId;
        ranges[0].last = Type.max-2;
        version(unittest) checkRanges();
        return aid;
      }
      // create two ranges
      growRangeArray!true(2);
      ranges[0].first = cast(Type)LowestId;
      ranges[0].last = cast(Type)(aid-1);
      ranges[1].first = cast(Type)(aid+1);
      ranges[1].last = cast(Type)(Type.max-1);
      version(unittest) checkRanges();
      return aid;
    }
    // already inited, check if the given id is not allocated, and split ranges
    // binary search of the range list
    uint i0 = 0, i1 = rngcount-1;
    for (;;) {
      uint i = (i0+i1)/2; // guaranteed to not overflow, see `growRangeArray()`
      Range* rngi = ranges+i;
      if (aid < rngi.first) {
        if (i == i0) return Invalid; // already allocated
        // cull upper half of list
        i1 = i-1;
      } else if (aid > rngi.last) {
        if (i == i1) return Invalid; // already allocated
        // cull bottom half of list
        i0 = i+1;
      } else {
        // inside a free block, split it
        if (aid >= idnextmaxid) idnextmaxid = cast(Type)(aid+1); // fix next max id (this can be wrong when there are no memory for ranges, but meh)
        // check for corner case: do we want range's starting id?
        if (rngi.first == aid) {
          // if current range is full and there is another one, that will become the new current range
          if (rngi.first == rngi.last && rngcount > 1) destroyRange(i); else ++rngi.first;
          version(unittest) checkRanges();
          return aid;
        }
        // check for corner case: do we want range's ending id?
        if (rngi.last == aid) {
          // if current range is full and there is another one, that will become the new current range
          if (rngi.first == rngi.last) {
            if (rngcount > 1) destroyRange(i); else ++rngi.first; // turn range into invalid
          } else {
            --rngi.last;
          }
          version(unittest) checkRanges();
          return aid;
        }
        // have to split the range in two
        if (rngcount >= uint.max-2) return Invalid; // no room
        insertRange(i+1);
        rngi = ranges+i; // pointer may be invalidated by inserting, so update it
        rngi[1].last = rngi.last;
        rngi[1].first = cast(Type)(aid+1);
        rngi[0].last = cast(Type)(aid-1);
        assert(rngi[0].first <= rngi[0].last);
        assert(rngi[1].first <= rngi[1].last);
        assert(rngi[0].last+2 == rngi[1].first);
        version(unittest) checkRanges();
        return aid;
      }
    }
  }

  /// allocate "next" id. "next" ids are always increasing, and will never duplicate (within the limits).
  /// returns id, or `Invalid` if this id was alrady allocated.
  Type allocNext () {
    static if (!allowZero) {
      if (idnextmaxid == 0) idnextmaxid = 1;
    }
    if (idnextmaxid == Type.max) return Invalid; // no more ids
    return allocId(idnextmaxid); // should never return `Invalid`, and will fix `idnextmaxid` by itself
  }

  /// allocate `count` sequential ids with the lowest possible number.
  /// returns `Invalid` if the request cannot be satisfied.
  Type allocRange (uint count) {
    if (count == 0) return Invalid;
    if (count >= Type.max) return Invalid; // too many
    if (rngcount == 0) {
      // wasn't inited, init with defaults
      growRangeArray!true(1);
      static if (allowZero) ranges[0].first = 0; else ranges[0].first = 1;
      ranges[0].last = Type.max-1;
    }
    uint i = 0;
    do {
      uint rcnt = 1+ranges[i].last-ranges[i].first;
      if (count <= rcnt) {
        Type id = ranges[i].first;
        // if current range is full and there is another one, that will become the new current range
        if (count == rcnt && i+1 < rngcount) destroyRange(i); else ranges[i].first += count;
        version(unittest) checkRanges();
        return id;
      }
    } while (++i < rngcount);
    // no range of free IDs was large enough to create the requested continuous ID sequence
    return Invalid;
  }

  /// release allocated id.
  /// returns `true` if `id` was a valid allocated one.
  bool releaseId (Type id) { return releaseRange(id, 1); }

  /// release allocated id range.
  /// returns `true` if the rage was a valid allocated one.
  bool releaseRange (Type id, uint count) {
    if (count == 0 || rngcount == 0) return false;
    if (count >= Type.max) return false; // too many

    static if (allowZero) {
      if (id == Invalid) return false;
    } else {
      if (id == 0 || id == Invalid) return false;
    }

    uint endid = id+count;
    static if (is(Type == uint)) {
      if (endid <= id) return false; // overflow check; fuck you, C!
    } else {
      if (endid <= id || endid > Type.max) return false; // overflow check; fuck you, C!
    }

    // binary search of the range list
    uint i0 = 0, i1 = rngcount-1;
    for (;;) {
      uint i = (i0+i1)/2; // guaranteed to not overflow, see `growRangeArray()`
      Range* rngi = ranges+i;
      if (id < rngi.first) {
        // before current range, check if neighboring
        if (endid >= rngi.first) {
          if (endid != rngi.first) return false; // overlaps a range of free IDs, thus (at least partially) invalid IDs
          // neighbor id, check if neighboring previous range too
          if (i > i0 && id-1 == ranges[i-1].last) {
            // merge with previous range
            ranges[i-1].last = rngi.last;
            destroyRange(i);
          } else {
            // just grow range
            rngi.first = id;
          }
          version(unittest) checkRanges();
          return true;
        } else {
          // non-neighbor id
          if (i != i0) {
            // cull upper half of list
            i1 = i-1;
          } else {
            // found our position in the list, insert the deleted range here
            insertRange(i);
            // refresh pointer
            rngi = ranges+i;
            rngi.first = id;
            rngi.last = cast(Type)(endid-1);
            version(unittest) checkRanges();
            return true;
          }
        }
      } else if (id > rngi.last) {
        // after current range, check if neighboring
        if (id-1 == rngi.last) {
          // neighbor id, check if neighboring next range too
          if (i < i1 && endid == ranges[i+1].first) {
            // merge with next range
            rngi.last = ranges[i+1].last;
            destroyRange(i+1);
          } else {
            // just grow range
            rngi.last += count;
          }
          version(unittest) checkRanges();
          return true;
        } else {
          // non-neighbor id
          if (i != i1) {
            // cull bottom half of list
            i0 = i+1;
          } else {
            // found our position in the list, insert the deleted range here
            insertRange(i+1);
            // get pointer to [i+1]
            rngi = ranges+i+1;
            rngi.first = id;
            rngi.last = cast(Type)(endid-1);
            version(unittest) checkRanges();
            return true;
          }
        }
      } else {
        // inside a free block, not a valid ID
        return false;
      }
    }
  }

  /// is the gived id valid and allocated?
  bool isAllocated (Type id) const {
    if (rngcount == 0) return false; // anyway, 'cause not inited
    static if (allowZero) {
      if (id == Invalid) return false;
    } else {
      if (id == 0 || id == Invalid) return false;
    }
    // binary search of the range list
    uint i0 = 0, i1 = rngcount-1;
    for (;;) {
      uint i = (i0+i1)/2; // guaranteed to not overflow, see `growRangeArray()`
      const(Range)* rngi = ranges+i;
      if (id < rngi.first) {
        if (i == i0) return true;
        // cull upper half of list
        i1 = i-1;
      } else if (id > rngi.last) {
        if (i == i1) return true;
        // cull bottom half of list
        i0 = i+1;
      } else {
        // inside a free block, not a valid ID
        return false;
      }
    }
  }

  /// count number of available free ids.
  uint countAvail () const {
    uint count = rngcount; // we are not keeping empty ranges, so it is safe to start with this
    foreach (const ref Range r; ranges[0..count]) count += r.last-r.first; // `last` is inclusive, but see the previous line
    return count;
  }

  /// get largest available continuous free range.
  uint largestAvailRange () const {
    uint maxCount = 0;
    foreach (const ref Range r; ranges[0..rngcount]) {
      uint count = r.last-r.first+1; // `last` is inclusive
      if (count > maxCount) maxCount = count;
    }
    return maxCount;
  }

  // debug dump
  void dump () const {
    import core.stdc.stdio : stderr, fprintf;
    if (rngcount == 0) { stderr.fprintf("<not-inited>\n"); return; }
    stderr.fprintf("<");
    foreach (immutable ridx, const ref Range r; ranges[0..rngcount]) {
      if (ridx) stderr.fprintf(",");
           if (r.first < r.last) stderr.fprintf("%u-%u", cast(uint)r.first, cast(uint)r.last);
      else if (r.first == r.last) stderr.fprintf("%u", cast(uint)r.first);
      else stderr.fprintf("-");
    }
    stderr.fprintf(">\n");
  }
}


version(iv_unittest_idpool) unittest {
  import iv.prng.pcg32;
  import iv.prng.seeder;

  {
    IdPool16 xpool;
    { import core.stdc.stdio; printf("next max=%u\n", xpool.nextSeqId); }

    ulong zseed = getUlongSeed;
    { import core.stdc.stdio; printf("phase 0 seed: %llu\n", zseed); }
    PCG32 zprng;
    zprng.seed(zseed, 42);

    foreach (immutable oit; 0..5) {
      xpool.reset();
      foreach (immutable itr; 0..60000) {
        auto id = xpool.allocNext();
        assert(id == itr+1);
        assert(id == xpool.nextSeqId-1);
        // free random id
        auto rid = cast(xpool.Type)(zprng.front%(id+1));
        if (xpool.isAllocated(rid)) xpool.releaseId(rid);
        assert(!xpool.isAllocated(rid));
        if (rid == id) assert(!xpool.isAllocated(id)); else assert(xpool.isAllocated(id));
      }
    }
  }

  IdPool16 pool;
  static bool[pool.Type.max+1] alloced = false;

  // two invalid ids
  alloced[0] = true;
  alloced[pool.Invalid] = true;
  uint acount = 0;
  foreach (immutable _; 0..1_000_000) {
    auto xid = pool.allocId();
    if (!pool.isValid(xid)) {
      if (acount == pool.Type.max-1) break;
      assert(0, "fuuuuu");
    }
    ++acount;
    if (alloced[xid]) {
      { import core.stdc.stdio; printf("%u allocated twice\n", cast(uint)xid); }
      assert(0, "fuuuuuuuu");
    }
    alloced[xid] = true;
    //{ import core.stdc.stdio; printf("allocated: %u\n", cast(uint)xid); }
  }
  { import core.stdc.stdio; printf("phase 1 stats: acount=%u; rngcount=%u; rngsize=%u; avail=%u\n", acount, pool.rngcount, pool.rngsize, pool.countAvail); }
  assert(pool.countAvail == 0);
  assert(!pool.isAllocated(0));
  assert(!pool.isAllocated(pool.Invalid));
  foreach (immutable pool.Type n; 1..pool.Type.max) assert(pool.isAllocated(n));

  ulong xseed = getUlongSeed;
  //xseed = 1102831282614566469UL;
  //xseed = 10585134441705064158UL;
  //xseed = 6483023210891954504UL;
  { import core.stdc.stdio; printf("phase 2 seed: %llu\n", xseed); }
  PCG32 prng;
  prng.seed(xseed, 42);

  // two invalid ids
  pool.reset();
  alloced[] = false;
  alloced[0] = true;
  alloced[pool.Invalid] = true;
  acount = 0;
  uint getCount = 0, relCount = 0;
  //{ import core.stdc.stdio; printf("phase 2...\n"); }
  foreach (immutable nn; 0..10_000_000) {
    //{ import core.stdc.stdio; printf("nn=%u\n", nn); }
    pool.Type xid = cast(pool.Type)prng.front;
    prng.popFront();
    if (!pool.isValid(xid)) {
      assert(xid == 0 || xid == pool.Invalid);
      continue;
    }
    if (pool.isAllocated(xid)) {
      // release
      //if (nn == 145915) { import core.stdc.stdio; printf("RELEASING %u\n", cast(uint)xid); }
      assert(alloced[xid]);
      if (!pool.releaseId(xid)) assert(0, "fuuuu");
      alloced[xid] = false;
      assert(acount > 0);
      --acount;
      ++relCount;
    } else {
      // allocate new id
      xid = pool.allocId;
      assert(pool.isValid(xid));
      if (!pool.isAllocated(xid)) { import core.stdc.stdio; printf("failed at step %u; xid %u is not marked as allocated\n", nn, cast(uint)xid); }
      //assert(pool.isAllocated(xid));
      if (alloced[xid]) { import core.stdc.stdio; printf("failed at step %u; xid %u is already alloced\n", nn, cast(uint)xid); }
      assert(!alloced[xid]);
      ++acount;
      alloced[xid] = true;
      ++getCount;
    }
  }
  { import core.stdc.stdio; printf("phase 2 stats: getCount=%u; relCount=%u; acount=%u; rngcount=%u; rngsize=%u\n", getCount, relCount, acount, pool.rngcount, pool.rngsize); }
  // check if pool is consistent
  assert(pool.countAvail == pool.Type.max-1-acount);
  assert(!pool.isAllocated(0));
  assert(!pool.isAllocated(pool.Invalid));
  foreach (immutable pool.Type n; 1..pool.Type.max) assert(pool.isAllocated(n) == alloced[n]);
}
