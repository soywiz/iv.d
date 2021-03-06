// original code: https://github.com/evanw/csg.js/
//
// Constructive Solid Geometry (CSG) is a modeling technique that uses Boolean
// operations like union and intersection to combine 3D solids. This library
// implements CSG operations on meshes elegantly and concisely using BSP trees,
// and is meant to serve as an easily understandable implementation of the
// algorithm. All edge cases involving overlapping coplanar polygons in both
// solids are correctly handled.
//
// Example usage:
//     auto cube = CSG.cube();
//     auto sphere = CSG.sphere(radius:1.3);
//     auto polygons = cube.opsubtract(sphere).toPolygons();
//
// ## Implementation Details
//
// All CSG operations are implemented in terms of two functions, `clipTo()` and
// `invert()`, which remove parts of a BSP tree inside another BSP tree and swap
// solid and empty space, respectively. To find the union of `a` and `b`, we
// want to remove everything in `a` inside `b` and everything in `b` inside `a`,
// then combine polygons from `a` and `b` into one solid:
//
//     a.clipTo(b);
//     b.clipTo(a);
//     a.build(b.allPolygons());
//
// The only tricky part is handling overlapping coplanar polygons in both trees.
// The code above keeps both copies, but we need to keep them in one tree and
// remove them in the other tree. To remove them from `b` we can clip the
// inverse of `b` against `a`. The code for union now looks like this:
//
//     a.clipTo(b);
//     b.clipTo(a);
//     b.invert();
//     b.clipTo(a);
//     b.invert();
//     a.build(b.allPolygons());
//
// Subtraction and intersection naturally follow from set operations. If
// union is `A | B`, subtraction is `A - B = ~(~A | B)` and intersection is
// `A & B = ~(~A | ~B)` where `~` is the complement operator.
//
// ## License
//
// Copyright (c) 2011 Evan Wallace (http://madebyevan.com/), under the MIT license.
module csg /*is aliced*/;

import iv.alice;
import iv.unarray;
import iv.vmath;

public __gshared bool csg_dump_bsp_stats = false;

//version = csg_vertex_has_normal; // provide `normal` member for `Vertex`; it is not used in BSP building or CSG, though
//version = csg_nonrobust_split; // uncomment this to use non-robust spliting (why?)
//version = csg_use_doubles;

version(csg_use_doubles) {
  alias Vec3 = VecN!(3, double);
  alias Float = Vec3.Float;
  // represents a plane in 3D space
  alias Plane = Plane3!(Float, 0.000001f, false);
} else {
  alias Vec3 = VecN!(3, float);
  alias Float = Vec3.Float;
  // represents a plane in 3D space
  alias Plane = Plane3!(Float, 0.0001f, false); // EPS is 0.0001f, no swizzling
}


public __gshared int BSPBalance = 50; // [0..100]; lower prefers less splits, higher prefers more balance


// ////////////////////////////////////////////////////////////////////////// //
/** Represents a vertex of a polygon.
 *
 * This class provides `normal` so convenience functions like `CSG.sphere()`
 * can return a smooth vertex normal, but `normal` is not used anywhere else. */
struct Vertex {
public:
  string toString () const {
    import std.string : format;
    version(csg_vertex_has_normal) {
      return "(%s,%s,%s{%s,%s,%s})".format(pos.x, pos.y, pos.z, normal.x, normal.y, normal.z);
    } else {
      return "(%s,%s,%s)".format(pos.x, pos.y, pos.z);
    }
  }

public:
  Vec3 pos;
  version(csg_vertex_has_normal) {
    Vec3 normal;
    enum HasNormal = true;
  } else {
    enum HasNormal = false;
  }

public:
nothrow @safe @nogc:
  ///
  this() (in auto ref Vec3 apos) {
    pragma(inline, true);
    pos = apos;
  }

  version(csg_vertex_has_normal) {
    ///
    this() (in auto ref Vec3 apos, in auto ref Vec3 anormal) {
      pragma(inline, true);
      pos = apos;
      normal = anormal;
    }

    ///
    void setNormal() (in auto ref Vec3 anorm) {
      pragma(inline, true);
      normal = anorm;
    }
  } else {
    ///
    void setNormal() (in auto ref Vec3 anorm) {
      pragma(inline, true);
    }
  }

  /** Invert all orientation-specific data (e.g. vertex normal).
   *
   * Called when the orientation of a polygon is flipped.
   */
  void flip () {
    pragma(inline, true);
    version(csg_vertex_has_normal) normal = -normal;
  }

  /** Create a new vertex between this vertex and `other` by linearly
   * interpolating all properties using a parameter of `t`.
   */
  Vertex interpolate() (in auto ref Vertex other, Float t) const {
    pragma(inline, true);
    version(csg_vertex_has_normal) {
      return Vertex(
        pos.lerp(other.pos, t),
        normal.lerp(other.normal, t),
      );
    } else {
      return Vertex(
        pos.lerp(other.pos, t),
      );
    }
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/** Represents a convex polygon. The vertices used to initialize a polygon must
 * be coplanar and form a convex loop.
 *
 * Each convex polygon has a `mshared` property, which is shared between all
 * polygons that are clones of each other or were split from the same polygon.
 * This can be used to define per-polygon properties (such as surface color).
 */
final class Polygon {
public:
  override string toString () const {
    import std.string : format;
    string res = "=== VERTS (%s) ===".format(vertices.length);
    foreach (immutable idx, const ref v; vertices) res ~= "\n  %s: %s".format(idx, v.toString);
    return res;
  }

public:
  version(csg_vertex_has_normal) {
    enum HasNormal = true;
  } else {
    enum HasNormal = false;
  }
  Vertex[] vertices;
  Object mshared;
  Plane plane;
  //AABBImpl!Vec3 aabb;

public:
  this (Vertex[] avertices, Object ashared=null) nothrow @trusted {
    assert(avertices.length > 2);
    vertices = avertices;
    mshared = ashared;
    plane.setFromPoints(vertices[0].pos, vertices[1].pos, vertices[2].pos);
    //aabb.reset();
    foreach (immutable idx, const ref v; vertices) {
      if (plane.pointSide(v.pos) != plane.Coplanar) {
        { import core.stdc.stdio : printf; printf("invalid polygon: vertex #%u is bad! (%g, %g)\n", cast(uint)idx, cast(double)plane.pointSideF(v.pos), cast(double)Plane.EPS); }
        assert(0, "invalid polygon");
      }
      //aabb ~= v.pos;
    }
  }

  /// Clone polygon.
  Polygon clone () nothrow @trusted {
    Vertex[] nv;
    nv.unsafeArraySetLength(vertices.length);
    nv[] = vertices[];
    return new Polygon(nv, mshared);
  }

  /// Flip vertices and reverse vertice order. Return new polygon.
  Polygon flipClone () nothrow @trusted {
    auto res = this.clone();
    res.flip();
    return res;
  }

  /// Flip vertices and reverse vertice order. In-place.
  void flip () nothrow @safe @nogc {
    foreach (immutable idx; 0..vertices.length/2) {
      auto vt = vertices[idx];
      vertices[idx] = vertices[$-idx-1];
      vertices[$-idx-1] = vt;
    }
    foreach (ref Vertex v; vertices) v.flip();
    plane.flip();
  }

  /** Classify polygon into one of the four classes.
   *
   * Classes are:
   *   Coplanar
   *   Front
   *   Back
   *   Spanning
   */
  Plane.PType classify() (in auto ref Plane plane) const nothrow @safe @nogc {
    Plane.PType polygonType = Plane.Coplanar;
    foreach (const ref Vertex v; vertices) {
      Plane.PType type = plane.pointSide(v.pos);
      polygonType |= type;
    }
    return polygonType;
  }

  /** Split this polygon by the given plane.
   *
   * Splits this polygon by the given plane if needed, then put the polygon or polygon
   * fragments in the appropriate lists. Coplanar polygons go into either
   * `coplanarFront` or `coplanarBack` depending on their orientation with
   * respect to this plane. Polygons in front or in back of this plane go into
   * either `front` or `back`.
   */
  void splitPolygon (in ref Plane plane, ref Polygon[] coplanarFront, ref Polygon[] coplanarBack, ref Polygon[] front, ref Polygon[] back) nothrow @trusted {
    alias polygon = this;
    mixin(ImportCoreMath!(Plane.Float, "fabs"));
    assert(plane.valid);

    if (polygon.vertices.length < 3) return;

    // classify each point as well as the entire polygon into one of the above four classes
    Plane.PType polygonType = Plane.Coplanar;
    Plane.PType[] types;
    scope(exit) delete types;
    types.unsafeArraySetLength(polygon.vertices.length);

    foreach (immutable vidx, const ref Vertex v; polygon.vertices) {
      Plane.PType type = plane.pointSide(v.pos);
      polygonType |= type;
      //types.unsafeArrayAppend(type);
      types.ptr[vidx] = type;
    }

    Vertex intersectEdgeAgainstPlane() (in auto ref Vertex a, in auto ref Vertex b) {
      Plane.Float t = (plane.w-(plane.normal*a.pos))/(plane.normal*(b.pos-a.pos));
      assert(fabs(t) > Plane.EPS);
      return a.interpolate(b, t);
    }

    // put the polygon in the correct list, splitting it when necessary
    final switch (polygonType) {
      case Plane.Coplanar:
        // dot
        if (plane.normal*polygon.plane.normal > 0) {
          coplanarFront.unsafeArrayAppend(polygon);
        } else {
          coplanarBack.unsafeArrayAppend(polygon);
        }
        break;
      case Plane.Front:
        front.unsafeArrayAppend(polygon);
        break;
      case Plane.Back:
        back.unsafeArrayAppend(polygon);
        break;
      case Plane.Spanning:
        Vertex[] f, b;
        version(csg_nonrobust_split) {
          // non-robust spliting
          foreach (immutable i; 0..polygon.vertices.length) {
            immutable j = (i+1)%polygon.vertices.length;
            auto ti = types[i];
            auto tj = types[j];
            auto vi = polygon.vertices[i];
            auto vj = polygon.vertices[j];
            if (ti != Plane.Back) f.unsafeArrayAppend(vi);
            if (ti != Plane.Front) b.unsafeArrayAppend(vi); //(ti != Back ? vi.dup : vi);
            if ((ti|tj) == Plane.Spanning) {
              Plane.Float t = (plane.w-(plane.normal*vi.pos))/(plane.normal*(vj.pos-vi.pos));
              assert(fabs(t) > Plane.EPS);
              auto v = vi.interpolate(vj, t);
              f.unsafeArrayAppend(v);
              b.unsafeArrayAppend(v); //v.dup;
            }
          }
        } else {
          // robust spliting, taken from "Real-Time Collision Detection" book
          immutable vlen = cast(int)polygon.vertices.length;
          int aidx = cast(int)polygon.vertices.length-1;
          for (int bidx = 0; bidx < vlen; aidx = bidx, ++bidx) {
            immutable atype = types[aidx];
            immutable btype = types[bidx];
            auto va = polygon.vertices[aidx];
            auto vb = polygon.vertices[bidx];
            if (btype == Plane.Front) {
              if (atype == Plane.Back) {
                // edge (a, b) straddles, output intersection point to both sides
                auto i = intersectEdgeAgainstPlane(vb, va); // `(b, a)` for robustness; was (a, b)
                // consistently clip edge as ordered going from in front -> behind
                assert(plane.pointSide(i.pos) == Plane.Coplanar);
                f.unsafeArrayAppend(i);
                b.unsafeArrayAppend(i);
              }
              // in all three cases, output b to the front side
              f.unsafeArrayAppend(vb);
            } else if (btype == Plane.Back) {
              if (atype == Plane.Front) {
                // edge (a, b) straddles plane, output intersection point
                auto i = intersectEdgeAgainstPlane(va, vb);
                assert(plane.pointSide(i.pos) == Plane.Coplanar);
                f.unsafeArrayAppend(i);
                b.unsafeArrayAppend(i);
              } else if (atype == Plane.Coplanar) {
                // output a when edge (a, b) goes from 'on' to 'behind' plane
                b.unsafeArrayAppend(va);
              }
              // in all three cases, output b to the back side
              b.unsafeArrayAppend(vb);
            } else {
              // b is on the plane. In all three cases output b to the front side
              f.unsafeArrayAppend(vb);
              // in one case, also output b to back side
              if (atype == Plane.Back) b.unsafeArrayAppend(vb);
            }
          }
        }
        if (f.length >= 3) front.unsafeArrayAppend(new Polygon(f, polygon.mshared));
        if (b.length >= 3) back.unsafeArrayAppend(new Polygon(b, polygon.mshared));
        break;
    }
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/** Holds a node in a BSP tree.
 *
 * A BSP tree is built from a collection of polygons by picking a polygon
 * to split along. That polygon (and all other coplanar polygons) are added
 * directly to that node and the other polygons are added to the front and/or
 * back subtrees. This is not a leafy BSP tree since there is no distinction
 * between internal and leaf nodes.
 */
final class BSPNode {
public:
  Plane plane; // defaults to invalid
  BSPNode front, back;
  Polygon[] polygons;
  int mPolyCount; // all polys in this node and in all children

public:
  ///
  this () {}

  ///
  this (Polygon[] apolygons) {
    if (apolygons.length) {
      build(apolygons);
      if (csg_dump_bsp_stats) {
        import core.stdc.stdio;
        printf("polys=%d(%d:%d); nodes=%d; maxdepth=%d; pseudo-leaves=%d\n", cast(uint)apolygons.length, mPolyCount, calcPolyCountSlow, calcNodeCount, calcMaxDepth, calcPseudoLeaves);
      }
    }
  }

  /// Clone this node and all its subnodes.
  /// If `deep` is `true`, clones all polygons.
  BSPNode clone(bool deep) () {
    auto res = new BSPNode();
    res.plane = this.plane;
    if (this.polygons.length) {
      static if (deep) {
        res.polygons.reserve(this.polygons.length);
        foreach (Polygon pg; this.polygons) res.polygons ~= pg.clone();
      } else {
        res.polygons.length = this.polygons.length;
        res.polygons[] = this.polygons[];
      }
    }
    res.mPolyCount = this.mPolyCount;
    if (this.front !is null) res.front = this.front.clone!deep();
    if (this.back !is null) res.back = this.back.clone!deep();
    return res;
  }

  ///
  int polyCount () const pure nothrow @safe @nogc { pragma(inline, true); return mPolyCount; }

  ///
  int calcPolyCountSlow () const nothrow @safe @nogc {
    int res = cast(uint)polygons.length;
    if (front !is null) res += front.calcPolyCountSlow();
    if (back !is null) res += back.calcPolyCountSlow();
    return res;
  }

  ///
  int calcNodeCount () const nothrow @safe @nogc {
    int res = 1;
    if (front !is null) res += front.calcNodeCount();
    if (back !is null) res += back.calcNodeCount();
    return res;
  }

  ///
  int calcMaxDepth () const nothrow @safe @nogc {
    int maxdepth = 0, curdepth = 0;
    void walk (const(BSPNode) n) {
      if (n is null) return;
      ++curdepth;
      if (curdepth > maxdepth) maxdepth = curdepth;
      walk(n.front);
      walk(n.back);
      --curdepth;
    }
    walk(this);
    assert(curdepth == 0);
    return maxdepth;
  }

  ///
  int calcPseudoLeaves () const nothrow @safe @nogc {
    bool isOneSided (const(BSPNode) n) {
      if (n is null) return false;
      if (n.front is null && n.back is null) return (mPolyCount != 0);
      if (n.front !is null && n.back !is null && n.front.mPolyCount && n.back.mPolyCount) return false;
      if (n.front !is null && n.front.mPolyCount) return isOneSided(n.front);
      if (n.back !is null && n.back.mPolyCount) return isOneSided(n.back);
      return false;
    }

    int leaves = 0;
    void walk (const(BSPNode) n) {
      if (n is null) return;
      if (isOneSided(n)) {
        if (n.mPolyCount) ++leaves;
      } else {
        walk(n.front);
        walk(n.back);
      }
    }
    walk(this);
    return leaves;
  }

  /// Convert solid space to empty space and empty space to solid space.
  void invert () {
    foreach (Polygon p; polygons) p.flip();
    plane.flip();
    if (front !is null) front.invert();
    if (back !is null) back.invert();
    // swap back and front nodes
    auto temp = front;
    front = back;
    back = temp;
  }

  /// Recursively remove all polygons in `plys` that are inside this BSP tree.
  /// `plys` is not modified.
  Polygon[] clipPolygons (Polygon[] plys) {
    if (!plane.valid) return plys;
    Polygon[] f, b;
    bool keepf = false, keepb = false;
    scope(exit) { if (!keepf) delete f; if (!keepb) delete b; }
    foreach (Polygon p; plys) p.splitPolygon(plane, f, b, f, b);
    if (front !is null) f = front.clipPolygons(f);
    if (back !is null) b = back.clipPolygons(b); else delete b;
    // return concatenation of `f` and `b`
    if (f.length == 0 && b.length == 0) return null;
    // is `f` empty?
    if (f.length == 0) {
      assert(b.length != 0);
      keepb = true;
      return b;
    }
    // is `b` empty?
    if (b.length == 0) {
      assert(f.length != 0);
      keepf = true;
      return f;
    }
    // build new array
    Polygon[] res;
    res.unsafeArraySetLength(f.length+b.length);
    res[0..f.length] = f[];
    res[f.length..$] = b[];
    return res;
  }

  /// Remove all polygons in this BSP tree that are inside the other BSP tree `bsp`.
  /// Will not modify or destroy old polygon list.
  void clipTo (BSPNode bsp) {
    if (bsp is null) return;
    polygons = bsp.clipPolygons(polygons);
    mPolyCount = cast(int)polygons.length;
    if (front !is null) { front.clipTo(bsp); mPolyCount += front.mPolyCount; }
    if (back !is null) { back.clipTo(bsp); mPolyCount += back.mPolyCount; }
    //assert(calcPolyCountSlow == mPolyCount);
  }

  ///
  void merge (BSPNode bsp) {
    if (bsp is null) return;
    build(bsp.allPolygons);
  }

  ///
  void merge (Polygon[] plys) {
    if (plys.length == 0) return;
    build(plys);
  }

  private void collectPolys (ref Polygon[] plys) {
    if (polygons.length) {
      auto clen = plys.length;
      plys.unsafeArraySetLength(clen+polygons.length);
      plys[clen..$] = polygons[];
    }
    if (front !is null) front.collectPolys(plys);
    if (back !is null) back.collectPolys(plys);
  }

  /// Return a list of all polygons in this BSP tree.
  Polygon[] allPolygons () {
    Polygon[] res;
    collectPolys(res);
    return res;
  }

  ///
  void forEachPoly (scope void delegate (const(Polygon) pg) dg) const {
    if (dg is null) return;
    foreach (const Polygon pg; polygons) dg(pg);
    if (front !is null) front.forEachPoly(dg);
    if (back !is null) back.forEachPoly(dg);
  }

  ///
  void forEachPolyNC (scope void delegate (Polygon pg) dg) {
    if (dg is null) return;
    foreach (Polygon pg; polygons) dg(pg);
    if (front !is null) front.forEachPolyNC(dg);
    if (back !is null) back.forEachPolyNC(dg);
  }

  // Build a BSP tree out of `polygons`. When called on an existing tree, the new
  // polygons are filtered down to the bottom of the tree and become new nodes there.
  private static struct BuildInfo {
    BSPNode node;
    Polygon[] plys;
  }

  // Used in CSG class.
  private void build (Polygon[] plys) {
    if (plys.length == 0) return;
    BuildInfo[] nodes;
    nodes.unsafeArrayAppend(BuildInfo(this, plys));
    buildInternal(nodes);
    updatePolyCount();
  }

  private void updatePolyCount () nothrow @safe @nogc {
    mPolyCount = cast(int)polygons.length;
    if (front !is null) { front.updatePolyCount(); mPolyCount += front.mPolyCount; }
    if (back !is null) { back.updatePolyCount();  mPolyCount += back.mPolyCount; }
  }

  private static void buildInternal (ref BuildInfo[] nodes) {
    while (nodes.length > 0) {
      auto node = nodes[0].node;
      Polygon[] plys = nodes[0].plys;
      // remove first node from node list (hacky -- to reuse memory)
      //nodes = nodes[1..$];
      if (nodes.length > 1) {
        import core.stdc.string : memmove;
        memmove(&nodes[0], &nodes[1], nodes[0].sizeof*(nodes.length-1));
        //nodes.length -= 1;
        nodes.unsafeArraySetLength(nodes.length-1);
      } else {
        //nodes.length = 0;
        nodes.unsafeArraySetLength(0);
      }
      //nodes.assumeSafeAppend;
      if (plys.length == 0) continue; // nothing to do
      // process polygons for this node
      Polygon[] fbest, bbest;
      if (!node.plane.valid) {
        // find splitting plane
        usize bestidx = 0;
        if (plys.length > 2) {
          mixin(ImportCoreMath!(float, "fabs"));
          float bestScore = float.infinity;
          foreach (immutable idx, Polygon px; plys) {
            auto pl = px.plane;
            int l = 0, r = 0, s = 0, c = 0;
            foreach (const Polygon p; plys) {
              auto side = p.classify(pl);
                   if (side == Plane.Back) ++l;
              else if (side == Plane.Front) ++r;
              else if (side == Plane.Spanning) ++s;
              else if (side == Plane.Coplanar) ++c;
              else assert(0, "wtf?!");
            }
            float score = (100.0f-cast(float)BSPBalance)*cast(float)s+cast(float)BSPBalance*fabs(cast(float)(r-l));
            if (score < bestScore) {
              bestidx = idx;
              bestScore = score;
            }
          }
        }
        node.plane = plys[bestidx].plane;
      }
      // split polygon list with the splitting plane
      foreach (Polygon p; plys) p.splitPolygon(node.plane, node.polygons, node.polygons, fbest, bbest);
      // if we have something to process, add it
      if (fbest.length != 0) {
        if (node.front is null) node.front = new BSPNode();
        nodes.unsafeArrayAppend(BuildInfo(node.front, fbest));
      }
      if (bbest.length != 0) {
        if (node.back is null) node.back = new BSPNode();
        nodes.unsafeArrayAppend(BuildInfo(node.back, bbest));
      }
    }
  }
}


// ////////////////////////////////////////////////////////////////////////// //
/** Holds a binary space partition tree representing a 3D solid.
 *
 * Two solids can be combined using the `doUnion()`, `doSubtract()`, and `doIntersect()` methods.
 */
final class SolidMesh {
public:
  override string toString () const {
    import std.string : format;
    string res = "=== SolidMesh (%s) ===".format(tree !is null ? tree.polyCount : 0);
    if (tree !is null) {
      int pidx = -1;
      tree.forEachPoly(delegate (const(Polygon) p) {
        ++pidx;
        res ~= "\nPOLY #%d\n".format(pidx);
        res ~= p.toString();
      });
    }
    return res;
  }

private:
  BSPNode tree = null;

private:
  // Takes ownership of `atree`.
  this (BSPNode atree) {
    assert(atree !is null);
    tree = atree;
  }

  this () {}

public:
  /// Construct a CSG solid from a list of `Polygon` instances.
  /// Takes ownership of polygons (but not `aplys`).
  static auto fromPolygons (Polygon[] aplys) {
    assert(aplys.length > 0);
    auto mesh = new SolidMesh();
    mesh.tree = new BSPNode(aplys);
    return mesh;
  }

  /// Clone solid.
  /// Will clone polygons themselves.
  SolidMesh clone () {
    assert(tree !is null);
    auto mesh = new SolidMesh();
    mesh.tree = tree.clone!true(); // deep clone
    return mesh;
  }

  ///
  void forEachPoly (scope void delegate (const(Polygon) pg) dg) const {
    if (dg is null || tree is null) return;
    tree.forEachPoly(dg);
  }

  // Will not clone polygons themselves.
  private BSPNode getClonedBSP () {
    assert(tree !is null);
    return tree.clone!false(); // shallow clone
  }

  // `a` is always a result, `b` can be deleted
  private static void mergeBSP (ref BSPNode a, ref BSPNode b) {
    // always merge smaller tree to the bigger one
    { import iv.cmdcon; conwriteln("apc=", a.calcPolyCountSlow, "; apcFast=", a.mPolyCount, "; bpc=", b.calcPolyCountSlow, "; bpcFast=", b.mPolyCount); }
    if (a.polyCount < b.polyCount) {
      auto tmp = a;
      a = b;
      b = tmp;
    }
    version(none) {
      auto pa = a.allPolygons~b.allPolygons;
      a = new BSPNode(pa);
    } else {
      a.merge(b);
    }
    { import iv.cmdcon; conwriteln("  merged; pseudo-leaves=", a.calcPseudoLeaves); }
  }

  /** Return a new CSG solid representing space in either this solid or in the
   * solid `mesh`. Neither this solid nor the solid `mesh` are modified. */
  SolidMesh opBinary(string op) (SolidMesh mesh) if (op == "+" || op == "|") { return doUnion(mesh); }

  /** Return a new CSG solid representing space in this solid but not in the
   * solid `mesh`. Neither this solid nor the solid `mesh` are modified. */
  SolidMesh opBinary(string op) (SolidMesh mesh) if (op == "-" || op == "&") { return doSubtract(mesh); }

  /** Return a new CSG solid representing space both this solid and in the
   * solid `mesh`. Neither this solid nor the solid `mesh` are modified. */
  SolidMesh opBinary(string op) (SolidMesh mesh) if (op == "%" || op == "^") { return doIntersect(mesh); }

  /// Return a new CSG solid with solid and empty space switched. This solid is not modified.
  SolidMesh opUnary(string op:"~") () { return doInverse(); }

  /** Return a new CSG solid representing space in either this solid or in the
   * solid `mesh`. Neither this solid nor the solid `mesh` are modified. */
  SolidMesh doUnion (SolidMesh mesh) {
    if (mesh is null) return this.clone();
    auto a = this.getClonedBSP(); // this will be used as new CSG
    auto b = mesh.getClonedBSP(); // temporary tree, will be used to do CSG and then discarded
    a.clipTo(b);
    b.clipTo(a);
    b.invert();
    b.clipTo(a);
    b.invert();
    mergeBSP(a, b);
    return new SolidMesh(a);
  }

  /** Return a new CSG solid representing space in this solid but not in the
   * solid `mesh`. Neither this solid nor the solid `mesh` are modified. */
  SolidMesh doSubtract (SolidMesh mesh) {
    if (mesh is null) return this.clone();
    auto a = this.getClonedBSP(); // this will be used as new CSG
    auto b = mesh.getClonedBSP(); // temporary tree, will be used to do CSG and then discarded
    a.invert();
    a.clipTo(b);
    b.clipTo(a);
    b.invert();
    b.clipTo(a);
    b.invert();
    mergeBSP(a, b);
    a.invert();
    return new SolidMesh(a);
  }

  /** Return a new CSG solid representing space both this solid and in the
   * solid `mesh`. Neither this solid nor the solid `mesh` are modified. */
  SolidMesh doIntersect (SolidMesh mesh) {
    if (mesh is null) return this.clone();
    auto a = this.getClonedBSP(); // this will be used as new CSG
    auto b = mesh.getClonedBSP(); // temporary tree, will be used to do CSG and then discarded
    a.invert();
    b.clipTo(a);
    b.invert();
    a.clipTo(b);
    b.clipTo(a);
    mergeBSP(a, b);
    a.invert();
    return new SolidMesh(a);
  }

  /// Return a new CSG solid with solid and empty space switched. This solid is not modified.
  SolidMesh doInverse () {
    auto mesh = new SolidMesh();
    if (tree !is null) {
      mesh.tree = tree.clone!true(); // deep clone
      mesh.tree.invert();
    }
    return mesh;
  }

static:
  /** Construct an axis-aligned solid cuboid.
   *
   * Optional parameters are `center` and `radius`, which default to `[0, 0, 0]` and `[1, 1, 1]`.
   * The radius can be specified using a single number or a list of three numbers, one for each axis.
   */
  SolidMesh Cube (Vec3 center, const(Float)[] radius...) {
    import std.algorithm : map;
    import std.array : array;
    auto c = center;
    Vec3 r = Vec3(1, 1, 1);
    foreach (immutable n, Float f; radius) {
      if (n >= 3) break;
      r[cast(int)n] = f;
    }
    //auto r = (radius > 0 ? Vec3(radius, radius, radius) : Vec3(1, 1, 1));
    return SolidMesh.fromPolygons([
      [[0.0, 4.0, 6.0, 2.0], [-1.0, 0.0, 0.0]],
      [[1.0, 3.0, 7.0, 5.0], [+1.0, 0.0, 0.0]],
      [[0.0, 1.0, 5.0, 4.0], [0.0, -1.0, 0.0]],
      [[2.0, 6.0, 7.0, 3.0], [0.0, +1.0, 0.0]],
      [[0.0, 2.0, 3.0, 1.0], [0.0, 0.0, -1.0]],
      [[4.0, 5.0, 7.0, 6.0], [0.0, 0.0, +1.0]]
    ].map!((info) {
      return new Polygon(info[0].map!((i) {
        auto pos = Vec3(
          c.x+cast(Float)r[0]*cast(Float)(2*(cast(int)i&1 ? 1 : 0)-1),
          c.y+cast(Float)r[1]*cast(Float)(2*(cast(int)i&2 ? 1 : 0)-1),
          c.z+cast(Float)r[2]*cast(Float)(2*(cast(int)i&4 ? 1 : 0)-1),
        );
        version(csg_vertex_has_normal) {
          return Vertex(pos, Vec3(cast(Float)info[1][0], cast(Float)info[1][1], cast(Float)info[1][2]));
        } else {
          return Vertex(pos);
        }
      }).array);
    }).array);
  }

  /// Construct an axis-aligned solid cuboid at origin, and with raduis of 1.
  SolidMesh Cube () { return Cube(Vec3(0, 0, 0)); }

  /** Construct a solid sphere.
   *
   * Optional parameters are `center`, `radius`, `slices`, and `stacks`,
   * which default to `[0, 0, 0]`, `1`, `16`, and `8`.
   * The `slices` and `stacks` parameters control the tessellation along the
   * longitude and latitude directions.
   */
  SolidMesh Sphere (Vec3 center=Vec3(0, 0, 0), Float radius=1, int slices=16, int stacks=8) {
    import std.math;
    auto c = center;
    Polygon[] polygons;
    Vertex[] vertices;
    void vertex (Float theta, Float phi) {
      theta *= PI*2;
      phi *= PI;
      auto dir = Vec3(
        cos(theta)*sin(phi),
        cos(phi),
        sin(theta)*sin(phi),
      );
      version(csg_vertex_has_normal) {
        vertices.unsafeArrayAppend(Vertex(c+(dir*radius), dir));
      } else {
        vertices.unsafeArrayAppend(Vertex(c+(dir*radius)));
      }
    }
    foreach (int i; 0..slices) {
      foreach (int j; 0..stacks) {
        vertices = [];
        vertex(cast(Float)i/slices, cast(Float)j/stacks);
        if (j > 0) vertex(cast(Float)(i+1)/slices, cast(Float)j/stacks);
        if (j < stacks-1) vertex(cast(Float)(i+1)/slices, cast(Float)(j+1)/stacks);
        vertex(cast(Float)i/slices, cast(Float)(j+1)/stacks);
        polygons.unsafeArrayAppend(new Polygon(vertices));
      }
    }
    return SolidMesh.fromPolygons(polygons);
  }

  /** Construct a solid cylinder.
   *
   * Optional parameters are `start`, `end`, `radius`, and `slices`,
   * which default to `[0, -1, 0]`, `[0, 1, 0]`, `1`, and `16`.
   * The `slices` parameter controls the tessellation.
   */
  SolidMesh Cylinder (Vec3 start=Vec3(0, -1, 0), Vec3 end=Vec3(0, 1, 0), Float radius=1, int slices=16) {
    import std.math;
    auto s = start;
    auto e = end;
    auto ray = e-s;
    auto axisZ = ray.normalized;
    auto isY = (abs(axisZ.y) > 0.5 ? 1 : 0);
    auto axisX = (Vec3(isY, !isY, 0)%axisZ).normalized;
    auto axisY = (axisX%axisZ).normalized;
    auto sv = Vertex(s);
    auto ev = Vertex(e);
    version(csg_vertex_has_normal) {
      sv.setNormal(-axisZ);
      ev.setNormal(axisZ.normalized);
    }
    Polygon[] polygons;
    Vertex point (Float stack, Float slice, Float normalBlend) {
      auto angle = slice*PI*2;
      auto o = (axisX*cos(angle))+(axisY*sin(angle));
      auto pos = s+(ray*stack)+(o*radius);
      auto normal = o*(1-abs(normalBlend))+(axisZ*normalBlend);
      auto res = Vertex(pos);
      version(csg_vertex_has_normal) res.setNormal(normal);
      return res;
    }
    foreach (int i; 0..slices) {
      auto t0 = cast(Float)i/slices;
      auto t1 = cast(Float)(i+1)/slices;
      polygons.unsafeArrayAppend(new Polygon([sv, point(0, t0, -1), point(0, t1, -1)]));
      polygons.unsafeArrayAppend(new Polygon([point(0, t1, 0), point(0, t0, 0), point(1, t0, 0), point(1, t1, 0)]));
      polygons.unsafeArrayAppend(new Polygon([ev, point(1, t1, 1), point(1, t0, 1)]));
    }
    return SolidMesh.fromPolygons(polygons);
  }
}


version(csg_test) unittest {
  auto a = SolidMesh.Cube();
  auto b = SolidMesh.Sphere(radius:1.35, stacks:12);
  auto c = SolidMesh.Cylinder(radius: 0.7, start:Vec3(-1, 0, 0), end:Vec3(1, 0, 0));
  auto d = SolidMesh.Cylinder(radius: 0.7, start:Vec3(0, -1, 0), end:Vec3(0, 1, 0));
  auto e = SolidMesh.Cylinder(radius: 0.7, start:Vec3(0, 0, -1), end:Vec3(0, 0, 1));
  auto mesh = a.doIntersect(b).doSubtract(c.doUnion(d).doUnion(e));
}
