/* Gilbert-Johnson-Keerthi intersection algorithm with Expanding Polytope Algorithm
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
module iv.vmath_gjk2d_simple;

import iv.vmath;

version = gjk_warnings;

// ////////////////////////////////////////////////////////////////////////// //
/* GJK object should support:
 *   Vec2 position
 *   Vec2 support (Vec2 dir) -- in world space
 *
 * for polyhedra:
 *
 * vec2 position () const { return centroid; }
 *
 * // dumb O(n) support function, just brute force check all points
 * vec2 support() (in auto ref vec2 dir) const {
 *   VT furthestPoint = verts[0];
 *   auto maxDot = furthestPoint.dot(dir);
 *   foreach (const ref v; verts[1..$]) {
 *     auto d = v.dot(dir);
 *     if (d > maxDot) {
 *       maxDot = d;
 *       furthestPoint = v;
 *     }
 *   }
 *   return furthestPoint;
 * }
 */
public template IsGoodGJKObject(T, VT) if ((is(T == struct) || is(T == class)) && IsVectorDim!(VT, 2)) {
  enum IsGoodGJKObject = is(typeof((inout int=0) {
    const o = T.init;
    VT v = o.position;
    v = o.support(VT(0, 0));
  }));
}


// ////////////////////////////////////////////////////////////////////////// //
/// check if two convex shapes are colliding. can optionally return separating vector in `sepmove`.
public bool gjk(CT, VT) (in auto ref CT coll1, in auto ref CT coll2, VT* sepmove=null) if (IsGoodGJKObject!(CT, VT)) {
  VT sdir = coll2.position-coll1.position; // initial search direction
  if (sdir.isZero) sdir = VT(1, 0); // use arbitrary normal if initial direction is zero

  VT[3] spx = void; // simplex; [0] is most recently added, [2] is oldest

  spx.ptr[2] = getSupportPoint(coll1, coll2, sdir);
  if (spx.ptr[2].dot(sdir) <= 0) return false; // past the origin

  sdir = -sdir; // change search direction

  int spxidx = 1;
  for (;;) {
    spx.ptr[spxidx] = getSupportPoint(coll1, coll2, sdir);
    if (spx.ptr[spxidx].dot(sdir) <= 0) return false; // past the origin
    if (checkSimplex(sdir, spx[spxidx..$])) {
      if (sepmove !is null) *sepmove = EPA(coll1, coll2, spx[spxidx..$]);
      return true;
    }
    spxidx = 0;
  }

  return false;
}


// ////////////////////////////////////////////////////////////////////////// //
/// return distance between two convex shapes, and separation normal
/// negative distance means that shapes are overlapping, and zero distance means touching (and ops are invalid)
public auto gjkdist(CT, VT) (in auto ref CT coll1, in auto ref CT coll2, VT* op0=null, VT* op1=null, VT* sepnorm=null) if (IsGoodGJKObject!(CT, VT)) {
  static VT segClosestToOrigin() (in auto ref VT segp0, in auto ref VT segp1) {
    immutable oseg = segp1-segp0;
    immutable ab2 = oseg.dot(oseg);
    immutable apab = (-segp0).dot(oseg);
    if (ab2 <= EPSILON!(VT.Float)) return segp0;
    VT.Float t = apab/ab2;
    if (t < 0) t = 0; else if (t > 1) t = 1;
    return segp0+oseg*t;
  }

  enum GetSupport(string smpx) =
    smpx~"p0 = coll1.support(d);\n"~
    smpx~"p1 = coll2.support(-d);\n"~
    smpx~" = "~smpx~"p0-"~smpx~"p1;";

  if (sepnorm !is null) *sepnorm = VT(0, 0);
  if (op0 !is null) *op0 = VT(0, 0);
  if (op1 !is null) *op1 = VT(0, 0);

  VT a, b, c; // simplex
  VT ap0, bp0, cp0; // simplex support points, needed for closest points calculation
  VT ap1, bp1, cp1; // simplex support points, needed for closest points calculation
  // position is centroid, use that fact
  auto d = coll2.position-coll1.position;
  // check for a zero direction vector
  if (d.isZero) return cast(VT.Float)-1; // centroids are the same, not separated
  //getSupport(a, ap0, ap1, d);
  mixin(GetSupport!"a");
  d = -d;
  mixin(GetSupport!"b");
  d = segClosestToOrigin(b, a);
  foreach (immutable iter; 0..100) {
    if (d.lengthSquared <= EPSILON!(VT.Float)) return cast(VT.Float)-1; // if the closest point is the origin, not separated
    d = -d;
    mixin(GetSupport!"c");
    // is simplex triangle contains origin?
    immutable sa = a.cross(b);
    if (sa*b.cross(c) > 0 && sa*c.cross(a) > 0) return cast(VT.Float)-1; // yes, not separated
    if (c.dot(d)-a.dot(d) < EPSILON!(VT.Float)*EPSILON!(VT.Float)) break; // new point is not far enough, we found her!
    auto p0 = segClosestToOrigin(a, c);
    auto p1 = segClosestToOrigin(c, b);
    immutable p0sqlen = p0.lengthSquared;
    immutable p1sqlen = p1.lengthSquared;
    if (p0sqlen <= EPSILON!(VT.Float) || p1sqlen <= EPSILON!(VT.Float)) {
      // origin is very close, but not exactly on edge; assume zero distance (special case)
      if (sepnorm !is null) *sepnorm = d.normalized;
      return cast(VT.Float)0;
    }
    if (p0sqlen < p1sqlen) { b = c; bp0 = cp0; bp1 = cp1; d = p0; } else { a = c; ap0 = cp0; ap1 = cp1; d = p1; }
  }
  // either out of iterations, or new point was not far enough
  d.normalize;
  auto dist = -c.dot(d);
  // get closest points
  if (op0 !is null || op1 !is null) {
    auto l = b-a;
    if (l.isZero) {
      if (op0 !is null) *op0 = ap0;
      if (op1 !is null) *op1 = ap1;
    } else {
      immutable ll = l.dot(l);
      immutable l2 = -l.dot(a)/ll;
      immutable l1 = cast(VT.Float)1-l2;
      if (l1 < 0) {
        if (op0 !is null) *op0 = bp0;
        if (op1 !is null) *op1 = bp1;
      } else if (l2 < 0) {
        if (op0 !is null) *op0 = ap0;
        if (op1 !is null) *op1 = ap1;
      } else {
        if (op0 !is null) *op0 = ap0*l1+bp0*l2;
        if (op1 !is null) *op1 = ap1*l1+bp1*l2;
      }
    }
  }
  if (dist < 0) { d = -d; dist = -dist; }
  if (sepnorm !is null) *sepnorm = d;
  return dist;
}


// ////////////////////////////////////////////////////////////////////////// //
// return the Minkowski sum point (ok, something *like* it, but not Minkowski difference yet ;-)
private VT getSupportPoint(CT, VT) (in ref CT coll1, in ref CT coll2, in ref VT sdir) {
  pragma(inline, true);
  return coll1.support(sdir)-coll2.support(-sdir);
}


// check if simplex contains origin, update sdir, and possibly update simplex
private bool checkSimplex(VT) (ref VT sdir, VT[] spx) {
  assert(spx.length == 2 || spx.length == 3);
  if (spx.length == 3) {
    // simplex has 3 elements
    auto a = spx.ptr[0]; // last added point
    auto ao = -a; // to origin
    // get the edges
    auto ab = spx.ptr[1]-a;
    auto ac = spx.ptr[2]-a;
    // get the edge normals
    auto abn = ac.tripleProduct(ab, ab);
    auto acn = ab.tripleProduct(ac, ac);
    // see where the origin is at
    auto acloc = acn.dot(ao);
    if (acloc >= 0) {
      // remove middle element
      spx.ptr[1] = spx.ptr[0];
      sdir = acn;
    } else {
      auto abloc = abn.dot(ao);
      if (abloc < 0) return true; // intersection
      // remove last element
      spx.ptr[2] = spx.ptr[1];
      spx.ptr[1] = spx.ptr[0];
      sdir = abn;
    }
  } else {
    // simplex has 2 elements
    auto a = spx.ptr[0]; // last added point
    auto ao = -a; // to origin
    auto ab = spx.ptr[1]-a;
    sdir = ab.tripleProduct(ao, ab);
    if (sdir.lengthSquared <= EPSILON!(VT.Float)) sdir = sdir.rperp; // bad direction, use any normal
  }
  return false;
}


// ////////////////////////////////////////////////////////////////////////// //
// Expanding Polytope Algorithm
// find minimum translation vector to resolve collision
// using the final simplex obtained with the GJK algorithm
private VT EPA(CT, VT) (in ref CT coll1, in ref CT coll2, const(VT)[] spx...) {
  enum MaxIterations = 100;
  enum MaxFaces = MaxIterations*3;

  static struct SxEdge {
    VT p0, p1;
    VT normal;
    VT.Float dist;

  nothrow @safe @nogc:
    void calcNormDist (int winding) {
      pragma(inline, true);
      mixin(ImportCoreMath!(VT.Float, "fabs"));
      normal = p1-p0;
      if (winding < 0) normal = normal.perp; else normal = normal.rperp;
      normal.normalize();
      dist = fabs(p0.dot(normal));
    }

    void set (in ref VT ap0, in ref VT ap1, int winding) {
      p0 = ap0;
      p1 = ap1;
      calcNormDist(winding);
    }

    this (in ref VT ap0, in ref VT ap1, int winding) { pragma(inline, true); set(ap0, ap1, winding); }
  }

  // as this cannot be called recursive, we can use thread-local static here
  static SxEdge[MaxFaces] faces = void;
  int faceCount;

  // compute the winding
  int winding = 0;
  VT prevv = spx[$-1];
  foreach (const ref v; spx[]) {
    auto cp = prevv.cross(v);
    if (cp > 0) { winding = 1; break; }
    if (cp < 0) { winding = -1; break; }
    prevv = v;
  }

  // build the initial edge queue
  prevv = spx[$-1];
  foreach (const ref v; spx[]) {
    faces.ptr[faceCount++].set(prevv, v, winding);
    prevv = v;
  }

  void extractClosestEdge (ref SxEdge eres) {
    import core.stdc.string : memmove;
    int res = 0;
    auto lastDist = VT.Float.infinity;
    foreach (immutable idx, const ref SxEdge e; faces[0..faceCount]) {
      if (e.dist < lastDist) { res = cast(int)idx; lastDist = e.dist; }
    }
    eres = faces.ptr[res];
    if (faceCount-res > 1) memmove(faces.ptr+res, faces.ptr+res+1, (faceCount-res-1)*SxEdge.sizeof);
    --faceCount;
  }

  SxEdge e;
  VT p;
  foreach (immutable i; 0..MaxIterations) {
    extractClosestEdge(e);
    p = getSupportPoint(coll1, coll2, e.normal);
    immutable proj = p.dot(e.normal);
    if (proj-e.dist < EPSILON!(VT.Float)/* *EPSILON!(VT.Float) */) return e.normal*proj;
    if (faces.length-faceCount < 2) assert(0, "out of memory in GJK-EPA");
    faces.ptr[faceCount++].set(e.p0, p, winding);
    faces.ptr[faceCount++].set(p, e.p1, winding);
  }
  version(gjk_warnings) { import core.stdc.stdio; stderr.fprintf("EPA: out of iterations!\n"); }
  return e.normal*p.dot(e.normal);
}
