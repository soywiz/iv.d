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
module iv.sdl2.functions;

pragma(lib, "SDL2");

import core.stdc.stdio; // FILE
import core.stdc.stdarg; // va_list
import iv.sdl2.types;


extern(C) @nogc nothrow {
  // SDL.h
  int SDL_Init (uint);
  int SDL_InitSubSystem (uint);
  void SDL_QuitSubSystem (uint);
  uint SDL_WasInit (uint);
  void SDL_Quit ();
  void SDL_free (void* mem);

  // SDL_assert.h
  void SDL_SetAssertionHandler (SDL_AssertionHandler, void*);
  const(SDL_assert_data)* SDL_GetAssertionReport ();
  void SDL_ResetAssertionReport ();

  // SDL_audio.h
  int SDL_GetNumAudioDrivers ();
  const(char)* SDL_GetAudioDriver (int);
  int SDL_AudioInit (const(char)*);
  void SDL_AudioQuit ();
  const(char)* SDL_GetCurrentAudioDriver ();
  int SDL_OpenAudio (SDL_AudioSpec*, SDL_AudioSpec*);
  int SDL_GetNumAudioDevices (int);
  const(char)* SDL_GetAudioDeviceName (int, int);
  SDL_AudioDeviceID SDL_OpenAudioDevice (const(char)*, int, const(SDL_AudioSpec)*, SDL_AudioSpec*, int);
  SDL_AudioStatus SDL_GetAudioStatus ();
  SDL_AudioStatus SDL_GetAudioDeviceStatus (SDL_AudioDeviceID);
  void SDL_PauseAudio (int);
  void SDL_PauseAudioDevice (SDL_AudioDeviceID, int);
  SDL_AudioSpec* SDL_LoadWAV_RW (SDL_RWops*, int, SDL_AudioSpec*, ubyte**, uint*);
  void SDL_FreeWAV (ubyte*);
  int SDL_BuildAudioCVT (SDL_AudioCVT*, SDL_AudioFormat, ubyte, int, SDL_AudioFormat, ubyte, int);
  int SDL_ConvertAudio (SDL_AudioCVT*);
  void SDL_MixAudio (ubyte*, const(ubyte)*, uint, int);
  void SDL_MixAudioFormat (ubyte*, const(ubyte)*, SDL_AudioFormat, uint, int);
  void SDL_LockAudio ();
  void SDL_LockAudioDevice (SDL_AudioDeviceID);
  void SDL_UnlockAudio ();
  void SDL_UnlockAudioDevice (SDL_AudioDeviceID);
  void SDL_CloseAudio ();
  void SDL_CloseAudioDevice ();
  int SDL_AudioDeviceConnected (SDL_AudioDeviceID);

  // SDL_clipboard.h
  int SDL_SetClipboardText (const(char)*);
  char* SDL_GetClipboardText ();
  SDL_bool SDL_HasClipboardText ();

  // SDL_cpuinfo.h
  int SDL_GetCPUCount ();
  int SDL_GetCPUCacheLineSize ();
  SDL_bool SDL_HasRDTSC ();
  SDL_bool SDL_HasAltiVec ();
  SDL_bool SDL_HasMMX ();
  SDL_bool SDL_Has3DNow ();
  SDL_bool SDL_HasSSE ();
  SDL_bool SDL_HasSSE2 ();
  SDL_bool SDL_HasSSE3 ();
  SDL_bool SDL_HasSSE41 ();
  SDL_bool SDL_HasSSE42 ();
  SDL_bool SDL_HasAVX ();
  int SDL_GetSystemRAM ();

  // SDL_error.h
  void SDL_SetError (const(char)*, ...);
  const(char)* SDL_GetError ();
  void SDL_ClearError ();

  // SDL_events.h
  void SDL_PumpEvents ();
  int SDL_PeepEvents (SDL_Event*, int, SDL_eventaction, uint, uint);
  SDL_bool SDL_HasEvent (uint);
  SDL_bool SDL_HasEvents (uint, uint);
  void SDL_FlushEvent (uint);
  void SDL_FlushEvents (uint, uint);
  int SDL_PollEvent (SDL_Event*);
  int SDL_WaitEvent (SDL_Event*);
  int SDL_WaitEventTimeout (SDL_Event*, int);
  int SDL_PushEvent (SDL_Event*);
  void SDL_SetEventFilter (SDL_EventFilter, void*);
  void SDL_GetEventFilter (SDL_EventFilter*, void**);
  void SDL_AddEventWatch (SDL_EventFilter, void*);
  void SDL_DelEventWatch (SDL_EventFilter, void*);
  void SDL_FilterEvents (SDL_EventFilter, void*);
  ubyte SDL_EventState (uint, int);
  uint SDL_RegisterEvents (int);

  // SDL_gamecontroller.h
  int SDL_GameControllerAddMappingsFromRW (SDL_RWops*, int);
  int SDL_GameControllerAddMapping (const(char)*);
  char* SDL_GameControllerMappingForGUID (SDL_JoystickGUID);
  char* SDL_GameControllerMapping (SDL_GameController*);
  SDL_bool SDL_IsGameController (int);
  const(char)* SDL_GameControllerNameForIndex (int);
  SDL_GameController* SDL_GameControllerOpen (int);
  const(char)* SDL_GameControllerName (SDL_GameController*);
  SDL_bool SDL_GameControllerGetAttached (SDL_GameController*);
  SDL_Joystick* SDL_GameControllerGetJoystick (SDL_GameController*);
  int SDL_GameControllerEventState (int);
  void SDL_GameControllerUpdate ();
  SDL_GameControllerAxis SDL_GameControllerGetAxisFromString (const(char)*);
  const(char)* SDL_GameControllerGetStringForAxis (SDL_GameControllerAxis);
  SDL_GameControllerButtonBind SDL_GameControllerGetBindForAxis (SDL_GameController*, SDL_GameControllerAxis);
  short SDL_GameControllerGetAxis (SDL_GameController*, SDL_GameControllerAxis);
  SDL_GameControllerButton SDL_GameControllerGetButtonFromString (const(char*));
  const(char)* SDL_GameControllerGetStringForButton (SDL_GameControllerButton);
  SDL_GameControllerButtonBind SDL_GameControllerGetBindForButton (SDL_GameController*, SDL_GameControllerButton);
  ubyte SDL_GameControllerGetButton (SDL_GameController*, SDL_GameControllerButton);
  void SDL_GameControllerClose (SDL_GameController*);

  // SDL_gesture.h
  int SDL_RecordGesture (SDL_TouchID);
  int SDL_SaveAllDollarTemplates (SDL_RWops*);
  int SDL_SaveDollarTemplate (SDL_GestureID, SDL_RWops*);
  int SDL_LoadDollarTemplates (SDL_TouchID, SDL_RWops*);

  // SDL_haptic.h
  int SDL_NumHaptics ();
  const(char)* SDL_HapticName (int);
  SDL_Haptic* SDL_HapticOpen (int);
  int SDL_HapticOpened (int);
  int SDL_HapticIndex (SDL_Haptic*);
  int SDL_MouseIsHaptic ();
  SDL_Haptic* SDL_HapticOpenFromMouse ();
  int SDL_JoystickIsHaptic (SDL_Joystick*);
  SDL_Haptic* SDL_HapticOpenFromJoystick (SDL_Joystick*);
  int SDL_HapticClose (SDL_Haptic*);
  int SDL_HapticNumEffects (SDL_Haptic*);
  int SDL_HapticNumEffectsPlaying (SDL_Haptic*);
  uint SDL_HapticQuery (SDL_Haptic*);
  int SDL_HapticNumAxes (SDL_Haptic*);
  int SDL_HapticEffectSupported (SDL_Haptic*, SDL_HapticEffect*);
  int SDL_HapticNewEffect (SDL_Haptic*, SDL_HapticEffect*);
  int SDL_HapticUpdateEffect (SDL_Haptic*, int, SDL_HapticEffect*);
  int SDL_HapticRunEffect (SDL_Haptic*, int, SDL_HapticEffect*);
  int SDL_HapticStopEffect (SDL_Haptic*, int);
  int SDL_HapticDestroyEffect (SDL_Haptic*, int);
  int SDL_HapticGetEffectStatus (SDL_Haptic*, int);
  int SDL_HapticSetGain (SDL_Haptic*, int);
  int SDL_HapticSetAutocenter (SDL_Haptic*, int);
  int SDL_HapticPause (SDL_Haptic*);
  int SDL_HapticUnpause (SDL_Haptic*);
  int SDL_HapticStopAll (SDL_Haptic*);
  int SDL_HapticRumbleSupported (SDL_Haptic*);
  int SDL_HapticRumbleInit (SDL_Haptic*);
  int SDL_HapticRumblePlay (SDL_Haptic*, float, uint);
  int SDL_HapticRumbleStop (SDL_Haptic*);

  // SDL_hints.h
  SDL_bool SDL_SetHintWithPriority (const(char)*, const(char)*, SDL_HintPriority);
  SDL_bool SDL_SetHint (const(char)*, const(char)*);
  const(char)* SDL_GetHint (const(char)*);
  void SDL_AddHintCallback (const(char)*, SDL_HintCallback, void*);
  void SDL_DelHintCallback (const(char)*, SDL_HintCallback, void*);
  void SDL_ClearHints ();

  // SDL_input.h
  int SDL_RedetectInputDevices ();
  int SDL_GetNumInputDevices ();
  const(char)* SDL_GetInputDeviceName (int);
  int SDL_IsDeviceDisconnected (int);

  // SDL_joystick.h
  int SDL_NumJoysticks ();
  const(char)* SDL_JoystickNameForIndex (int);
  SDL_Joystick* SDL_JoystickOpen (int);
  const(char)* SDL_JoystickName (SDL_Joystick*);
  JoystickGUID SDL_JoystickGetDeviceGUID (int);
  JoystickGUID SDL_JoystickGetGUID (SDL_Joystick*);
  char* SDL_JoystickGetGUIDString (JoystickGUID);
  JoystickGUID SDL_JoystickGetGUIDFromString (const(char)*);
  SDL_bool SDL_JoystickGetAttached (SDL_Joystick*);
  SDL_JoystickID SDL_JoystickInstanceID (SDL_Joystick*);
  int SDL_JoystickNumAxes (SDL_Joystick*);
  int SDL_JoystickNumBalls (SDL_Joystick*);
  int SDL_JoystickNumHats (SDL_Joystick*);
  int SDL_JoystickNumButtons (SDL_Joystick*);
  int SDL_JoystickUpdate (SDL_Joystick*);
  int SDL_JoystickEventState (int);
  short SDL_JoystickGetAxis (SDL_Joystick*, int);
  ubyte SDL_JoystickGetHat (SDL_Joystick*, int);
  int SDL_JoystickGetBall (SDL_Joystick*, int, int*, int*);
  ubyte SDL_JoystickGetButton (SDL_Joystick*, int);
  void SDL_JoystickClose (SDL_Joystick*);

  // SDL_keyboard.h
  SDL_Window* SDL_GetKeyboardFocus ();
  ubyte* SDL_GetKeyboardState (int*);
  SDL_Keymod SDL_GetModState ();
  void SDL_SetModState (SDL_Keymod);
  SDL_Keycode SDL_GetKeyFromScancode (SDL_Scancode);
  SDL_Scancode SDL_GetScancodeFromKey (SDL_Keycode);
  const(char)* SDL_GetScancodeName (SDL_Scancode);
  SDL_Scancode SDL_GetScancodeFromName (const(char)*);
  const(char)* SDL_GetKeyName (SDL_Keycode);
  SDL_Keycode SDL_GetKeyFromName (const(char)*);
  void SDL_StartTextInput ();
  SDL_bool SDL_IsTextInputActive ();
  void SDL_StopTextInput ();
  void SDL_SetTextInputRect (SDL_Rect*);
  SDL_bool SDL_HasScreenKeyboardSupport ();
  SDL_bool SDL_IsScreenKeyboardShown (SDL_Window*);

  // SDL_loadso.h
  void* SDL_LoadObject (const(char)*);
  void* SDL_LoadFunction (void*, const(char*));
  void SDL_UnloadObject (void*);

  // SDL_log.h
  void SDL_LogSetAllPriority (SDL_LogPriority);
  void SDL_LogSetPriority (int, SDL_LogPriority);
  SDL_LogPriority SDL_LogGetPriority (int);
  void SDL_LogResetPriorities ();
  void SDL_Log (const(char)*, ...);
  void SDL_LogVerbose (int, const(char)*, ...);
  void SDL_LogDebug (int, const(char)*, ...);
  void SDL_LogInfo (int, const(char)*, ...);
  void SDL_LogWarn (int, const(char)*, ...);
  void SDL_LogError (int, const(char)*, ...);
  void SDL_LogCritical (int, const(char)*, ...);
  void SDL_LogMessage (int, SDL_LogPriority, const(char)*, ...);
  void SDL_LogMessageV (int, SDL_LogPriority, const(char)*, va_list);
  void SDL_LogGetOutputFunction (SDL_LogOutputFunction, void**);
  void SDL_LogSetOutputFunction (SDL_LogOutputFunction, void*);

  // SDL_messagebox.h
  int SDL_ShowMessageBox (const(SDL_MessageBoxData)*, int*);
  int SDL_ShowSimpleMessageBox (uint, const(char)*, const(char)*, SDL_Window*);

  // SDL_mouse.h
  SDL_Window* SDL_GetMouseFocus ();
  uint SDL_GetMouseState (int*, int*);
  uint SDL_GetRelativeMouseState (int*, int*);
  void SDL_WarpMouseInWindow (SDL_Window*, int, int);
  int SDL_SetRelativeMouseMode (SDL_bool);
  SDL_bool SDL_GetRelativeMouseMode ();
  SDL_Cursor* SDL_CreateCursor (const(ubyte)*, const(ubyte)*, int, int, int, int);
  SDL_Cursor* SDL_CreateColorCursor (SDL_Surface*, int, int);
  SDL_Cursor* SDL_CreateSystemCursor (SDL_SystemCursor);
  void SDL_SetCursor (SDL_Cursor*);
  SDL_Cursor* SDL_GetCursor ();
  void SDL_FreeCursor (SDL_Cursor*);
  int SDL_ShowCursor (int);

  // SDL_pixels.h
  const(char)* SDL_GetPixelFormatName (uint);
  SDL_bool SDL_PixelFormatEnumToMasks (uint, int*, uint*, uint*, uint*, uint*);
  uint SDL_MasksToPixelFormatEnum (int, uint, uint, uint, uint);
  SDL_PixelFormat* SDL_AllocFormat (uint);
  void SDL_FreeFormat (SDL_PixelFormat*);
  SDL_Palette* SDL_AllocPalette (int);
  int SDL_SetPixelFormatPalette (SDL_PixelFormat*, SDL_Palette*);
  int SDL_SetPaletteColors (SDL_Palette*, const(SDL_Color)*, int, int);
  void SDL_FreePalette (SDL_Palette*);
  uint SDL_MapRGB (const(SDL_PixelFormat)*, ubyte, ubyte, ubyte);
  uint SDL_MapRGBA (const(SDL_PixelFormat)*, ubyte, ubyte, ubyte, ubyte);
  void SDL_GetRGB (uint, const(SDL_PixelFormat)*, ubyte*, ubyte*, ubyte*);
  void SDL_GetRGBA (uint, const(SDL_PixelFormat)*, ubyte*, ubyte*, ubyte*, ubyte*);
  void SDL_CalculateGammaRamp (float, ushort*);

  // SDL_platform.h
  const(char)* SDL_GetPlatform ();

  // SDL_power.h
  SDL_PowerState SDL_GetPowerInfo (int*, int*);

  // SDL_Rect.h
  SDL_bool SDL_HasIntersection (const(SDL_Rect)*, const(SDL_Rect)*);
  SDL_bool SDL_IntersectRect (const(SDL_Rect)*, const(SDL_Rect)*, SDL_Rect*);
  void SDL_UnionRect (const(SDL_Rect)*, const(SDL_Rect)*, SDL_Rect*);
  void SDL_EnclosePoints (const(SDL_Point)*, int, const(SDL_Rect)*, SDL_Rect*);
  SDL_bool SDL_IntersectRectAndLine (const(SDL_Rect)*, int*, int*, int*, int*);

  // SDL_Render.h
  int SDL_GetNumRenderDrivers ();
  int SDL_GetRenderDriverInfo (int, SDL_RendererInfo*);
  int SDL_CreateWindowAndRenderer (int, int, uint, SDL_Window**, SDL_Renderer**);
  SDL_Renderer* SDL_CreateRenderer (SDL_Window*, int, uint);
  SDL_Renderer* SDL_CreateSoftwareRenderer (SDL_Surface*);
  SDL_Renderer* SDL_GetRenderer (SDL_Window*);
  int SDL_GetRendererInfo (SDL_Renderer*, SDL_RendererInfo*);
  SDL_Texture* SDL_CreateTexture (SDL_Renderer*, uint, int, int, int);
  SDL_Texture* SDL_CreateTextureFromSurface (SDL_Renderer*, SDL_Surface*);
  int SDL_QueryTexture (SDL_Texture*, uint*, int*, int*, int*);
  int SDL_SetTextureColorMod (SDL_Texture*, ubyte, ubyte, ubyte);
  int SDL_GetTextureColorMod (SDL_Texture*, ubyte*, ubyte*, ubyte*);
  int SDL_SetTextureAlphaMod (SDL_Texture*, ubyte);
  int SDL_GetTextureAlphaMod (SDL_Texture*, ubyte*);
  int SDL_SetTextureBlendMode (SDL_Texture*, SDL_BlendMode);
  int SDL_GetTextureBlendMode (SDL_Texture*, SDL_BlendMode*);
  int SDL_UpdateTexture (SDL_Texture*, const(SDL_Rect)*, const(void)*, int);
  int SDL_UpdateYUVTexture (SDL_Texture*, const(SDL_Rect)*, const(ubyte)*, int, const(ubyte)*, int, const(ubyte)*, int);
  int SDL_LockTexture (SDL_Texture*, const(SDL_Rect)*, void**, int*);
  int SDL_UnlockTexture (SDL_Texture*);
  SDL_bool SDL_RenderTargetSupported (SDL_Renderer*);
  int SDL_SetRenderTarget (SDL_Renderer*, SDL_Texture*);
  SDL_Texture* SDL_GetRenderTarget (SDL_Renderer*);
  int SDL_RenderSetLogicalSize (SDL_Renderer*, int, int);
  void SDL_RenderGetLogicalSize (SDL_Renderer*, int*, int*);
  int SDL_RenderSetViewport (SDL_Renderer*, const(SDL_Rect)*);
  void SDL_RenderGetViewport (SDL_Renderer*, SDL_Rect*);
  int SDL_RenderSetScale (SDL_Renderer*, float, float);
  int SDL_RenderGetScale (SDL_Renderer*, float*, float*);
  int SDL_SetRenderDrawColor (SDL_Renderer*, ubyte, ubyte, ubyte, ubyte);
  int SDL_GetRenderDrawColor (SDL_Renderer*, ubyte*, ubyte*, ubyte*, ubyte*);
  int SDL_SetRenderDrawBlendMode (SDL_Renderer*, SDL_BlendMode);
  int SDL_GetRenderDrawBlendMode (SDL_Renderer*, SDL_BlendMode*);
  int SDL_RenderClear (SDL_Renderer*);
  int SDL_RenderDrawPoint (SDL_Renderer*, int, int);
  int SDL_RenderDrawPoints (SDL_Renderer*, const(SDL_Point)*, int);
  int SDL_RenderDrawLine (SDL_Renderer*, int, int, int, int);
  int SDL_RenderDrawLines (SDL_Renderer*, const(SDL_Point)*, int);
  int SDL_RenderDrawRect (SDL_Renderer*, const(SDL_Rect)*);
  int SDL_RenderDrawRects (SDL_Renderer*, const(SDL_Rect)*, int);
  int SDL_RenderFillRect (SDL_Renderer*, const(SDL_Rect)*);
  int SDL_RenderFillRects (SDL_Renderer*, const(SDL_Rect)*);
  int SDL_RenderCopy (SDL_Renderer*, SDL_Texture*, const(SDL_Rect)*, const(SDL_Rect*));
  int SDL_RenderCopyEx (SDL_Renderer*, SDL_Texture*, const(SDL_Rect)*, const(SDL_Rect)*, const(double), const(SDL_Point)*, const(SDL_RendererFlip));
  int SDL_RenderReadPixels (SDL_Renderer*, const(SDL_Rect)*, uint, void*, int);
  void SDL_RenderPresent (SDL_Renderer*);
  void SDL_DestroyTexture (SDL_Texture*);
  void SDL_DestroyRenderer (SDL_Renderer*);
  int SDL_GL_BindTexture (SDL_Texture*, float*, float*);
  int SDL_GL_UnbindTexture (SDL_Texture*);

  // SDL_rwops.h
  SDL_RWops* SDL_RWFromFile (const(char)*, const(char)*);
  SDL_RWops* SDL_RWFromFP (FILE*, SDL_bool);
  SDL_RWops* SDL_RWFromMem (void*, int);
  SDL_RWops* SDL_RWFromConstMem (const(void)*, int);
  SDL_RWops* SDL_AllocRW ();
  void SDL_FreeRW (SDL_RWops*);
  ubyte SDL_ReadU8 (SDL_RWops*);
  ushort SDL_ReadLE16 (SDL_RWops*);
  ushort SDL_ReadBE16 (SDL_RWops*);
  uint SDL_ReadLE32 (SDL_RWops*);
  uint SDL_ReadBE32 (SDL_RWops*);
  ulong SDL_ReadLE64 (SDL_RWops*);
  ulong SDL_ReadBE64 (SDL_RWops*);
  usize SDL_WriteU8 (SDL_RWops*, ubyte);
  usize SDL_WriteLE16 (SDL_RWops*, ushort);
  usize SDL_WriteBE16 (SDL_RWops*, ushort);
  usize SDL_WriteLE32 (SDL_RWops*, uint);
  usize SDL_WriteBE32 (SDL_RWops*, uint);
  usize SDL_WriteLE64 (SDL_RWops*, ulong);
  usize SDL_WriteBE64 (SDL_RWops*, ulong);

  // SDL_shape.h
  SDL_Window* SDL_CreateShapedWindow (const(char)*, uint, uint, uint, uint, uint);
  SDL_bool SDL_IsShapedWindow (const(SDL_Window)*);
  int SDL_SetWindowShape (SDL_Window*, SDL_Surface*, SDL_WindowShapeMode*);
  int SDL_GetShapedWindowMode (SDL_Window*, SDL_WindowShapeMode*);

  // SDL_surface.h
  SDL_Surface* SDL_CreateRGBSurface (uint, int, int, int, uint, uint, uint, uint);
  SDL_Surface* SDL_CreateRGBSurfaceFrom (void*, int, int, int, int, uint, uint, uint, uint);
  void SDL_FreeSurface (SDL_Surface*);
  int SDL_SetSurfacePalette (SDL_Surface*, SDL_Palette*);
  int SDL_LockSurface (SDL_Surface*);
  int SDL_UnlockSurface (SDL_Surface*);
  SDL_Surface* SDL_LoadBMP_RW (SDL_RWops*, int);
  int SDL_SaveBMP_RW (SDL_Surface*, SDL_RWops*, int);
  int SDL_SetSurfaceRLE (SDL_Surface*, int);
  int SDL_SetColorKey (SDL_Surface*, int, uint);
  int SDL_GetColorKey (SDL_Surface*, uint*);
  int SDL_SetSurfaceColorMod (SDL_Surface*, ubyte, ubyte, ubyte);
  int SDL_GetSurfaceColorMod (SDL_Surface*, ubyte*, ubyte*, ubyte*);
  int SDL_SetSurfaceAlphaMod (SDL_Surface*, ubyte);
  int SDL_GetSurfaceAlphaMod (SDL_Surface*, ubyte*);
  int SDL_SetSurfaceBlendMode (SDL_Surface*, SDL_BlendMode);
  int SDL_GetSurfaceBlendMode (SDL_Surface*, SDL_BlendMode*);
  SDL_bool SDL_SetClipRect (SDL_Surface*, const(SDL_Rect)*);
  void SDL_GetClipRect (SDL_Surface*, SDL_Rect*);
  SDL_Surface* SDL_ConvertSurface (SDL_Surface*, const(SDL_PixelFormat)*, uint);
  SDL_Surface* SDL_ConvertSurfaceFormat (SDL_Surface*, uint, uint);
  int SDL_ConvertPixels (int, int, uint, const(void)*, int, uint, void*, int);
  int SDL_FillRect (SDL_Surface*, const(SDL_Rect)*, uint);
  int SDL_FillRects (SDL_Surface*, const(SDL_Rect)*, int, uint);
  int SDL_UpperBlit (SDL_Surface*, const(SDL_Rect)*, SDL_Surface*, SDL_Rect*);
  int SDL_LowerBlit (SDL_Surface*, SDL_Rect*, SDL_Surface*, SDL_Rect*);
  int SDL_SoftStretch (SDL_Surface*, const(SDL_Rect)*, SDL_Surface*, const(SDL_Rect)*);
  int SDL_UpperBlitScaled (SDL_Surface*, const(SDL_Rect)*, SDL_Surface*, SDL_Rect*);
  int SDL_LowerBlitScaled (SDL_Surface*, SDL_Rect*, SDL_Surface*, SDL_Rect*);

  alias SDL_BlitSurface = SDL_UpperBlit;
  alias SDL_BlitScaled = SDL_UpperBlitScaled;

  // SDL_syswm.h
  SDL_bool SDL_GetWindowWMInfo (SDL_Window* window, SDL_SysWMinfo * info);

  // SDL_timer.h
  uint SDL_GetTicks ();
  ulong SDL_GetPerformanceCounter ();
  ulong SDL_GetPerformanceFrequency ();
  void SDL_Delay (uint);
  SDL_TimerID SDL_AddTimer (uint, SDL_TimerCallback, void*);
  SDL_bool SDL_RemoveTimer (SDL_TimerID);

  // SDL_touch.h
  int SDL_GetNumTouchDevices ();
  SDL_TouchID SDL_GetTouchDevice (int);
  int SDL_GetNumTouchFingers (SDL_TouchID);
  SDL_Finger* SDL_GetTouchFinger (SDL_TouchID, int);

  // SDL_version.h
  void SDL_GetVersion (SDL_version*);
  const(char)* SDL_GetRevision ();
  int SDL_GetRevisionNumber ();

  // SDL_video.h
  int SDL_GetNumVideoDrivers ();
  const(char)* SDL_GetVideoDriver (int);
  int SDL_VideoInit (const(char)*);
  void SDL_VideoQuit ();
  const(char)* SDL_GetCurrentVideoDriver ();
  int SDL_GetNumVideoDisplays ();
  const(char)* SDL_GetDisplayName (int);
  int SDL_GetDisplayBounds (int, SDL_Rect*);
  int SDL_GetNumDisplayModes (int);
  int SDL_GetDisplayMode (int, int, SDL_DisplayMode*);
  int SDL_GetDesktopDisplayMode (int, SDL_DisplayMode*);
  int SDL_GetCurrentDisplayMode (int, SDL_DisplayMode*);
  SDL_DisplayMode* SDL_GetClosestDisplayMode (int, const(SDL_DisplayMode)*, SDL_DisplayMode*);
  int SDL_GetWindowDisplayIndex (SDL_Window*);
  int SDL_SetWindowDisplayMode (SDL_Window*, const(SDL_DisplayMode)*);
  int SDL_GetWindowDisplayMode (SDL_Window*, SDL_DisplayMode*);
  uint SDL_GetWindowPixelFormat (SDL_Window*);
  SDL_Window* SDL_CreateWindow (const(char)*, int, int, int, int, uint);
  SDL_Window* SDL_CreateWindowFrom (const(void)*);
  uint SDL_GetWindowID (SDL_Window*);
  SDL_Window* SDL_GetWindowFromID (uint);
  uint SDL_GetWindowFlags (SDL_Window*);
  void SDL_SetWindowTitle (SDL_Window*, const(char)*);
  const(char)* SDL_GetWindowTitle (SDL_Window*);
  void SDL_SetWindowIcon (SDL_Window*, SDL_Surface*);
  void* SDL_SetWindowData (SDL_Window*, const(char)*, void*);
  void* SDL_GetWindowData (SDL_Window*, const(char)*);
  void SDL_SetWindowPosition (SDL_Window*, int, int);
  void SDL_GetWindowPosition (SDL_Window*, int*, int*);
  void SDL_SetWindowSize (SDL_Window*, int, int);
  void SDL_GetWindowSize (SDL_Window*, int*, int*);
  void SDL_SetWindowMinimumSize (SDL_Window*, int, int);
  void SDL_GetWindowMinimumSize (SDL_Window*, int*, int*);
  void SDL_SetWindowMaximumSize (SDL_Window*, int, int);
  void SDL_GetWindowMaximumSize (SDL_Window*, int*, int*);
  void SDL_SetWindowBordered (SDL_Window*, SDL_bool);
  void SDL_ShowWindow (SDL_Window*);
  void SDL_HideWindow (SDL_Window*);
  void SDL_RaiseWindow (SDL_Window*);
  void SDL_MaximizeWindow (SDL_Window*);
  void SDL_MinimizeWindow (SDL_Window*);
  void SDL_RestoreWindow (SDL_Window*);
  int SDL_SetWindowFullscreen (SDL_Window*, uint);
  SDL_Surface* SDL_GetWindowSurface (SDL_Window*);
  int SDL_UpdateWindowSurface (SDL_Window*);
  int SDL_UpdateWindowSurfaceRects (SDL_Window*, SDL_Rect*, int);
  void SDL_SetWindowGrab (SDL_Window*, SDL_bool);
  SDL_bool SDL_GetWindowGrab (SDL_Window*);
  int SDL_SetWindowBrightness (SDL_Window*, float);
  float SDL_GetWindowBrightness (SDL_Window*);
  int SDL_SetWindowGammaRamp (SDL_Window*, const(ushort)*, const(ushort)*, const(ushort)*, const(ushort)*);
  int SDL_GetWindowGammaRamp (SDL_Window*, ushort*, ushort*, ushort*, ushort*);
  void SDL_DestroyWindow (SDL_Window*);
  SDL_bool SDL_IsScreenSaverEnabled ();
  void SDL_EnableScreenSaver ();
  void SDL_DisableScreenSaver ();
  int SDL_GL_LoadLibrary (const(char)*);
  void* SDL_GL_GetProcAddress (const(char)*);
  void SDL_GL_UnloadLibrary ();
  SDL_bool SDL_GL_ExtensionSupported (const(char)*);
  void SDL_GL_ResetAttributes ();
  int SDL_GL_SetAttribute (SDL_GLattr, int);
  int SDL_GL_GetAttribute (SDL_GLattr, int*);
  SDL_GLContext SDL_GL_CreateContext (SDL_Window*);
  int SDL_GL_MakeCurrent (SDL_Window*, SDL_GLContext);
  SDL_Window* SDL_GL_GetCurrentWindow ();
  SDL_GLContext SDL_GL_GetCurrentContext ();
  void SDL_GL_GetDrawableSize (SDL_Window*, int*, int*);
  int SDL_GL_SetSwapInterval (int);
  int SDL_GL_GetSwapInterval ();
  void SDL_GL_SwapWindow (SDL_Window*);
  void SDL_GL_DeleteContext (SDL_GLContext);

  // SDL_filesystem.h
  char* SDL_GetBasePath ();
  char* SDL_GetPrefPath (const(char)* org, const(char)* app);

  // This function is not part of the public interface,  but SDL expects it to
  // be called before any subsystems have been intiailized.
  //
  // Normally, this happens via linking with libSDLmain, but since that
  // doesn't happen when using Derelict, then the loader must load this
  // function and call it before the load method returns. Otherwise, bad
  // things can happen.
  //private extern(C) nothrow @nogc alias da_SDL_SetMainReady = void function ();
  void SDL_SetMainReady ();
}

nothrow:
@nogc:
// SDL_audio.h
SDL_AudioSpec* SDL_LoadWAV (const(char)* file, SDL_AudioSpec* spec, ubyte** audio_buf, uint* len) {
  return SDL_LoadWAV_RW(SDL_RWFromFile(file, "rb"), 1, spec, audio_buf, len);
}

// SDL_events.h
ubyte SDL_GetEventState (uint type) {
  return SDL_EventState(type, SDL_QUERY);
}

// SDL_GameController.h
int SDL_GameControllerAddMappingsFromFile (const(char)* file) {
  return SDL_GameControllerAddMappingsFromRW(SDL_RWFromFile (file, "rb"), 1);
}

// SDL_quit.h
bool SDL_QuitRequested() {
  SDL_PumpEvents();
  return SDL_PeepEvents(null, 0, SDL_PEEKEVENT, SDL_QUIT, SDL_QUIT) > 0;
}

// SDL_surface.h
SDL_Surface* SDL_LoadBMP (const(char)* file) {
  return SDL_LoadBMP_RW(SDL_RWFromFile (file, "rb"), 1);
}

int SDL_SaveBMP (SDL_Surface* surface, const(char)* file) {
  return SDL_SaveBMP_RW(surface, SDL_RWFromFile (file, "wb"), 1);
}


// SDL_init will fail if SDL_SetMainReady has not been called.
// Since there's no SDL_main on the D side, it needs to be handled
// manually. My understanding that this is fine on the platforms
// that D is currently available on. If we ever get on to Android
// or iPhone, though, this will need to be versioned.
// I've wrapped it in a try/catch because it seem the function is
// not always exported on Linux. See issue #153
// https://github.com/aldacron/Derelict3/issues/153
shared static this () {
  SDL_SetMainReady();
}
