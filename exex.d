/* coded by Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
 * Understanding is not required. Only obedience.
 *
 *                   INVISIBLE VECTOR PUBLIC LICENSE
 *                       Version 0, August 2014
 *
 * Copyright (C) 2014 Ketmar Dark <ketmar@ketmar.no-ip.org>
 *
 * Everyone is permitted to copy and distribute verbatim or modified
 * copies of this license document, and changing it is allowed as long
 * as the name is changed.
 *
 *                   INVISIBLE VECTOR PUBLIC LICENSE
 *   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
 *
 * 0. You may not use this software in either source or binary form, any
 *    software derived from this software, any library which uses either
 *    this software or code derived from this software in any other
 *    software which uses Windows API, either directly or indirectly
 *    via any chain of libraries.
 *
 * 1. You may not use this software in either source or binary form, any
 *    software derived from this software, any library which uses either
 *    this software or code derived from this software in any other
 *    software which uses MacOS X API, either directly or indirectly via
 *    any chain of libraries.
 *
 * 2. You may not use this software in either source or binary form, any
 *    software derived from this software, any library which uses either
 *    this software or code derived from this software in any other
 *    software on the territory of Russian Federation, either directly or
 *    indirectly via any chain of libraries.
 *
 * 3. Redistributions of this software in either source or binary form must
 *    retain this list of conditions and the following disclaimer.
 *
 * 4. Otherwise, you are allowed to use this software in any way that will
 *    not violate paragraphs 0, 1, 2 and 3 of this license.
 *
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Authors: Ketmar // Invisible Vector <ketmar@ketmar.no-ip.org>
 * License: IVPLv0
 */
module iv.exex /*is aliced*/;


// ////////////////////////////////////////////////////////////////////////// //
mixin template ExceptionCtor() {
  static if (__VERSION__ > 2067) {
    this (string msg, string file=__FILE__, size_t line=__LINE__, Throwable next=null) @safe pure nothrow @nogc {
      super(msg, file, line, next);
    }
  } else {
    this (string msg, string file=__FILE__, size_t line=__LINE__, Throwable next=null) @safe pure nothrow {
      super(msg, file, line, next);
    }
  }
}


// usage:
//   mixin(MyException!"MyEx");
//   mixin(MyException!("MyEx1", "MyEx"));
enum MyException(string name, string base="Exception") = `class `~name~` : `~base~` { mixin ExceptionCtor; }`;


mixin(MyException!"IVException");
mixin(MyException!("IVNamedExceptionBase", "IVException"));
mixin(MyException!("IVNamedException(string name)", "IVNamedExceptionBase"));


version(test_exex)
unittest {
  import iv.writer;

  void testit (void delegate () dg) {
    try {
      dg();
    } catch (IVNamedException!"Alice" e) {
      writeln("from Alice: ", e.msg);
    } catch (IVNamedException!"Miriel" e) {
      writeln("from Miriel: ", e.msg);
    } catch (IVException e) {
      writeln("from IV: ", e.msg);
    }
  }

  testit({ throw new IVException("msg"); });
  testit({ throw new IVNamedException!"Alice"("Hi, I'm Alice!"); });
  testit({ throw new IVNamedException!"Miriel"("Hi, I'm Miriel!"); });
}
