/*

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.

*/
module iv.sdl2.ttf is aliced;
pragma(lib, "SDL2_ttf");

import core.stdc.config; // c_long
import iv.sdl2.sdl;

enum : ubyte {
  SDL_TTF_MAJOR_VERSION = 2,
  SDL_TTF_MINOR_VERSION = 0,
  SDL_TTF_PATCHLEVEL    = 12,
}
alias TTF_MAJOR_VERSION = SDL_TTF_MAJOR_VERSION;
alias TTF_MINOR_VERSION = SDL_TTF_MINOR_VERSION;
alias TTF_PATCHLEVEL = SDL_TTF_PATCHLEVEL;

enum {
  UNICODE_BOM_NATIVE = 0xFEFF,
  UNICODE_BOM_SWAPPED = 0xFFFE,
  TTF_STYLE_NORMAL = 0x00,
  TTF_STYLE_BOLD = 0x01,
  TTF_STYLE_ITALIC = 0x02,
  TTF_STYLE_UNDERLINE = 0x04,
  TTF_STYLE_STRIKETHROUGH = 0x08,
}

enum {
  TTF_HINTING_NORMAL = 0,
  TTF_HINTING_LIGHT = 1,
  TTF_HINTING_MONO = 2,
  TTF_HINTING_NONE = 3,
}

alias TTF_SetError = SDL_SetError;
alias TTF_GetError = SDL_GetError;

struct TTF_Font;

void SDL_TTF_VERSION() (ref SDL_version x) {
  x.major = SDL_TTF_MAJOR_VERSION;
  x.minor = SDL_TTF_MINOR_VERSION;
  x.patch = SDL_TTF_PATCHLEVEL;
}

void TTF_VERSION() (ref SDL_version x) => SDL_TTF_VERSION(x);

extern (C) nothrow @nogc {
  SDL_version* TTF_Linked_Version ();
  void TTF_ByteSwappedUNICODE (int);
  int TTF_Init ();
  TTF_Font* TTF_OpenFont (const(char)*, int);
  TTF_Font* TTF_OpenFontIndex (const(char)*, int, c_long);
  TTF_Font* TTF_OpenFontRW (SDL_RWops*, int, int);
  TTF_Font* TTF_OpenFontIndexRW (SDL_RWops*, int, int, c_long);
  int TTF_GetFontStyle (const(TTF_Font)*);
  void TTF_SetFontStyle (const(TTF_Font)*, int style);
  int TTF_GetFontOutline (const(TTF_Font)*);
  void TTF_SetFontOutline (TTF_Font*, int);
  int TTF_GetFontHinting (const(TTF_Font)*);
  void TTF_SetFontHinting (TTF_Font*, int);
  int TTF_FontHeight (const(TTF_Font)*);
  int TTF_FontAscent (const(TTF_Font)*);
  int TTF_FontDescent (const(TTF_Font)*);
  int TTF_FontLineSkip (const(TTF_Font)*);
  int TTF_GetFontKerning (const(TTF_Font)*);
  void TTF_SetFontKerning (TTF_Font*, int);
  int TTF_FontFaces (const(TTF_Font)*);
  int TTF_FontFaceIsFixedWidth (const(TTF_Font)*);
  char* TTF_FontFaceFamilyName (const(TTF_Font)*);
  char* TTF_FontFaceStyleName (const(TTF_Font)*);
  int TTF_GlyphIsProvided (const(TTF_Font)*, ushort);
  int TTF_GlyphMetrics (TTF_Font*, ushort, int*, int*, int*, int*, int*);
  int TTF_SizeText (TTF_Font*, const(char)*, int*, int*);
  int TTF_SizeUTF8 (TTF_Font*, const(char)*, int*, int*);
  int TTF_SizeUNICODE (TTF_Font*, ushort*, int*, int*);
  SDL_Surface* TTF_RenderText_Solid (TTF_Font*, const(char)*, SDL_Color);
  SDL_Surface* TTF_RenderUTF8_Solid (TTF_Font*, const(char)*, SDL_Color);
  SDL_Surface* TTF_RenderUNICODE_Solid (TTF_Font*, const(ushort)*, SDL_Color);
  SDL_Surface* TTF_RenderGlyph_Solid (TTF_Font*, ushort, SDL_Color);
  SDL_Surface* TTF_RenderText_Shaded (TTF_Font*, const(char)*, SDL_Color, SDL_Color);
  SDL_Surface* TTF_RenderUTF8_Shaded (TTF_Font*, const(char)*, SDL_Color, SDL_Color);
  SDL_Surface* TTF_RenderUNICODE_Shaded (TTF_Font*, const(ushort)*, SDL_Color, SDL_Color);
  SDL_Surface* TTF_RenderGlyph_Shaded (TTF_Font*, ushort, SDL_Color, SDL_Color);
  SDL_Surface* TTF_RenderText_Blended (TTF_Font*, const(char)*, SDL_Color);
  SDL_Surface* TTF_RenderUTF8_Blended (TTF_Font*, const(char)*, SDL_Color);
  SDL_Surface* TTF_RenderUNICODE_Blended (TTF_Font*, const(ushort)*, SDL_Color);
  SDL_Surface* TTF_RenderText_Blended_Wrapped (TTF_Font*, const(char)*, SDL_Color, uint);
  SDL_Surface* TTF_RenderUTF8_Blended_Wrapped (TTF_Font*, const(char)*, SDL_Color, uint);
  SDL_Surface* TTF_RenderUNICODE_Blended_Wrapped (TTF_Font*, const(ushort)*, SDL_Color, uint);
  SDL_Surface* TTF_RenderGlyph_Blended (TTF_Font*, ushort, SDL_Color);
  void TTF_CloseFont (TTF_Font*);
  void TTF_Quit ();
  int TTF_WasInit ();
  int TTF_GetFontKerningSize (TTF_Font*, int, int);
}

alias TTF_RenderText = TTF_RenderText_Shaded;
alias TTF_RenderUTF8 = TTF_RenderUTF8_Shaded;
alias TTF_RenderUNICODE = TTF_RenderUNICODE_Shaded;
