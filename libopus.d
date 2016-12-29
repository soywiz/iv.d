/* Copyright (c) 2010-2011 Xiph.Org Foundation, Skype Limited
   Written by Jean-Marc Valin and Koen Vos */
/*
   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions
   are met:

   - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

   - Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
   OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
   EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
   PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
   PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
   NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
module iv.libopus;
pragma(lib, "opus");

extern(C) nothrow @nogc:

/**
   @file opus_types.h
   @brief Opus reference implementation types
*/

alias opus_int16 = short;
alias opus_uint16 = ushort;
alias opus_int32 = int;
alias opus_uint32 = uint;


/**
 * @file opus_defines.h
 * @brief Opus reference implementation constants
 */

/** @defgroup opus_errorcodes Error codes
 * @{
 */
/** No error @hideinitializer*/
enum OPUS_OK = 0;
/** One or more invalid/out of range arguments @hideinitializer*/
enum OPUS_BAD_ARG = -1;
/** Not enough bytes allocated in the buffer @hideinitializer*/
enum OPUS_BUFFER_TOO_SMALL = -2;
/** An internal error was detected @hideinitializer*/
enum OPUS_INTERNAL_ERROR = -3;
/** The compressed data passed is corrupted @hideinitializer*/
enum OPUS_INVALID_PACKET = -4;
/** Invalid/unsupported request number @hideinitializer*/
enum OPUS_UNIMPLEMENTED = -5;
/** An encoder or decoder structure is invalid or already freed @hideinitializer*/
enum OPUS_INVALID_STATE = -6;
/** Memory allocation has failed @hideinitializer*/
enum OPUS_ALLOC_FAIL = -7;
/**@}*/

/** These are the actual Encoder CTL ID numbers.
  * They should not be used directly by applications.
  * In general, SETs should be even and GETs should be odd.*/
enum OPUS_SET_APPLICATION_REQUEST = 4000;
enum OPUS_GET_APPLICATION_REQUEST = 4001;
enum OPUS_SET_BITRATE_REQUEST = 4002;
enum OPUS_GET_BITRATE_REQUEST = 4003;
enum OPUS_SET_MAX_BANDWIDTH_REQUEST = 4004;
enum OPUS_GET_MAX_BANDWIDTH_REQUEST = 4005;
enum OPUS_SET_VBR_REQUEST = 4006;
enum OPUS_GET_VBR_REQUEST = 4007;
enum OPUS_SET_BANDWIDTH_REQUEST = 4008;
enum OPUS_GET_BANDWIDTH_REQUEST = 4009;
enum OPUS_SET_COMPLEXITY_REQUEST = 4010;
enum OPUS_GET_COMPLEXITY_REQUEST = 4011;
enum OPUS_SET_INBAND_FEC_REQUEST = 4012;
enum OPUS_GET_INBAND_FEC_REQUEST = 4013;
enum OPUS_SET_PACKET_LOSS_PERC_REQUEST = 4014;
enum OPUS_GET_PACKET_LOSS_PERC_REQUEST = 4015;
enum OPUS_SET_DTX_REQUEST = 4016;
enum OPUS_GET_DTX_REQUEST = 4017;
enum OPUS_SET_VBR_CONSTRAINT_REQUEST = 4020;
enum OPUS_GET_VBR_CONSTRAINT_REQUEST = 4021;
enum OPUS_SET_FORCE_CHANNELS_REQUEST = 4022;
enum OPUS_GET_FORCE_CHANNELS_REQUEST = 4023;
enum OPUS_SET_SIGNAL_REQUEST = 4024;
enum OPUS_GET_SIGNAL_REQUEST = 4025;
enum OPUS_GET_LOOKAHEAD_REQUEST = 4027;
/* enum OPUS_RESET_STATE = 4028; */
enum OPUS_GET_SAMPLE_RATE_REQUEST = 4029;
enum OPUS_GET_FINAL_RANGE_REQUEST = 4031;
enum OPUS_GET_PITCH_REQUEST = 4033;
enum OPUS_SET_GAIN_REQUEST = 4034;
enum OPUS_GET_GAIN_REQUEST = 4045; /* Should have been 4035 */
enum OPUS_SET_LSB_DEPTH_REQUEST = 4036;
enum OPUS_GET_LSB_DEPTH_REQUEST = 4037;
enum OPUS_GET_LAST_PACKET_DURATION_REQUEST = 4039;
enum OPUS_SET_EXPERT_FRAME_DURATION_REQUEST = 4040;
enum OPUS_GET_EXPERT_FRAME_DURATION_REQUEST = 4041;
enum OPUS_SET_PREDICTION_DISABLED_REQUEST = 4042;
enum OPUS_GET_PREDICTION_DISABLED_REQUEST = 4043;
/* Don't use 4045, it's already taken by OPUS_GET_GAIN_REQUEST */
enum OPUS_SET_PHASE_INVERSION_DISABLED_REQUEST = 4046;
enum OPUS_GET_PHASE_INVERSION_DISABLED_REQUEST = 4047;

/** @defgroup opus_ctlvalues Pre-defined values for CTL interface
  * @see opus_genericctls, opus_encoderctls
  * @{
  */
/* Values for the various encoder CTLs */
enum OPUS_AUTO = -1000; /**<Auto/default setting @hideinitializer*/
enum OPUS_BITRATE_MAX = -1; /**<Maximum bitrate @hideinitializer*/

/** Best for most VoIP/videoconference applications where listening quality and intelligibility matter most
 * @hideinitializer */
enum OPUS_APPLICATION_VOIP = 2048;
/** Best for broadcast/high-fidelity application where the decoded audio should be as close as possible to the input
 * @hideinitializer */
enum OPUS_APPLICATION_AUDIO = 2049;
/** Only use when lowest-achievable latency is what matters most. Voice-optimized modes cannot be used.
 * @hideinitializer */
enum OPUS_APPLICATION_RESTRICTED_LOWDELAY = 2051;

enum OPUS_SIGNAL_VOICE = 3001; /**< Signal being encoded is voice */
enum OPUS_SIGNAL_MUSIC = 3002; /**< Signal being encoded is music */
enum OPUS_BANDWIDTH_NARROWBAND = 1101; /**< 4 kHz bandpass @hideinitializer*/
enum OPUS_BANDWIDTH_MEDIUMBAND = 1102; /**< 6 kHz bandpass @hideinitializer*/
enum OPUS_BANDWIDTH_WIDEBAND = 1103; /**< 8 kHz bandpass @hideinitializer*/
enum OPUS_BANDWIDTH_SUPERWIDEBAND = 1104; /**<12 kHz bandpass @hideinitializer*/
enum OPUS_BANDWIDTH_FULLBAND = 1105; /**<20 kHz bandpass @hideinitializer*/

enum OPUS_FRAMESIZE_ARG = 5000; /**< Select frame size from the argument (default) */
enum OPUS_FRAMESIZE_2_5_MS = 5001; /**< Use 2.5 ms frames */
enum OPUS_FRAMESIZE_5_MS = 5002; /**< Use 5 ms frames */
enum OPUS_FRAMESIZE_10_MS = 5003; /**< Use 10 ms frames */
enum OPUS_FRAMESIZE_20_MS = 5004; /**< Use 20 ms frames */
enum OPUS_FRAMESIZE_40_MS = 5005; /**< Use 40 ms frames */
enum OPUS_FRAMESIZE_60_MS = 5006; /**< Use 60 ms frames */
enum OPUS_FRAMESIZE_80_MS = 5007; /**< Use 80 ms frames */
enum OPUS_FRAMESIZE_100_MS = 5008; /**< Use 100 ms frames */
enum OPUS_FRAMESIZE_120_MS = 5009; /**< Use 120 ms frames */

/**@}*/


/** @defgroup opus_encoderctls Encoder related CTLs
  *
  * These are convenience macros for use with the \c opus_encode_ctl
  * interface. They are used to generate the appropriate series of
  * arguments for that call, passing the correct type, size and so
  * on as expected for each particular request.
  *
  * Some usage examples:
  *
  * @code
  * int ret;
  * ret = opus_encoder_ctl(enc_ctx, OPUS_SET_BANDWIDTH(OPUS_AUTO));
  * if (ret != OPUS_OK) return ret;
  *
  * opus_int32 rate;
  * opus_encoder_ctl(enc_ctx, OPUS_GET_BANDWIDTH(&rate));
  *
  * opus_encoder_ctl(enc_ctx, OPUS_RESET_STATE);
  * @endcode
  *
  * @see opus_genericctls, opus_encoder
  * @{
  */

/+TODO
/** Configures the encoder's computational complexity.
  * The supported range is 0-10 inclusive with 10 representing the highest complexity.
  * @see OPUS_GET_COMPLEXITY
  * @param[in] x <tt>opus_int32</tt>: Allowed values: 0-10, inclusive.
  *
  * @hideinitializer */
#define OPUS_SET_COMPLEXITY(x) OPUS_SET_COMPLEXITY_REQUEST, __opus_check_int(x)
/** Gets the encoder's complexity configuration.
  * @see OPUS_SET_COMPLEXITY
  * @param[out] x <tt>opus_int32 *</tt>: Returns a value in the range 0-10,
  *                                      inclusive.
  * @hideinitializer */
#define OPUS_GET_COMPLEXITY(x) OPUS_GET_COMPLEXITY_REQUEST, __opus_check_int_ptr(x)

/** Configures the bitrate in the encoder.
  * Rates from 500 to 512000 bits per second are meaningful, as well as the
  * special values #OPUS_AUTO and #OPUS_BITRATE_MAX.
  * The value #OPUS_BITRATE_MAX can be used to cause the codec to use as much
  * rate as it can, which is useful for controlling the rate by adjusting the
  * output buffer size.
  * @see OPUS_GET_BITRATE
  * @param[in] x <tt>opus_int32</tt>: Bitrate in bits per second. The default
  *                                   is determined based on the number of
  *                                   channels and the input sampling rate.
  * @hideinitializer */
#define OPUS_SET_BITRATE(x) OPUS_SET_BITRATE_REQUEST, __opus_check_int(x)
/** Gets the encoder's bitrate configuration.
  * @see OPUS_SET_BITRATE
  * @param[out] x <tt>opus_int32 *</tt>: Returns the bitrate in bits per second.
  *                                      The default is determined based on the
  *                                      number of channels and the input
  *                                      sampling rate.
  * @hideinitializer */
#define OPUS_GET_BITRATE(x) OPUS_GET_BITRATE_REQUEST, __opus_check_int_ptr(x)

/** Enables or disables variable bitrate (VBR) in the encoder.
  * The configured bitrate may not be met exactly because frames must
  * be an integer number of bytes in length.
  * @see OPUS_GET_VBR
  * @see OPUS_SET_VBR_CONSTRAINT
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>0</dt><dd>Hard CBR. For LPC/hybrid modes at very low bit-rate, this can
  *               cause noticeable quality degradation.</dd>
  * <dt>1</dt><dd>VBR (default). The exact type of VBR is controlled by
  *               #OPUS_SET_VBR_CONSTRAINT.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_VBR(x) OPUS_SET_VBR_REQUEST, __opus_check_int(x)
/** Determine if variable bitrate (VBR) is enabled in the encoder.
  * @see OPUS_SET_VBR
  * @see OPUS_GET_VBR_CONSTRAINT
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>0</dt><dd>Hard CBR.</dd>
  * <dt>1</dt><dd>VBR (default). The exact type of VBR may be retrieved via
  *               #OPUS_GET_VBR_CONSTRAINT.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_VBR(x) OPUS_GET_VBR_REQUEST, __opus_check_int_ptr(x)

/** Enables or disables constrained VBR in the encoder.
  * This setting is ignored when the encoder is in CBR mode.
  * @warning Only the MDCT mode of Opus currently heeds the constraint.
  *  Speech mode ignores it completely, hybrid mode may fail to obey it
  *  if the LPC layer uses more bitrate than the constraint would have
  *  permitted.
  * @see OPUS_GET_VBR_CONSTRAINT
  * @see OPUS_SET_VBR
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>0</dt><dd>Unconstrained VBR.</dd>
  * <dt>1</dt><dd>Constrained VBR (default). This creates a maximum of one
  *               frame of buffering delay assuming a transport with a
  *               serialization speed of the nominal bitrate.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_VBR_CONSTRAINT(x) OPUS_SET_VBR_CONSTRAINT_REQUEST, __opus_check_int(x)
/** Determine if constrained VBR is enabled in the encoder.
  * @see OPUS_SET_VBR_CONSTRAINT
  * @see OPUS_GET_VBR
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>0</dt><dd>Unconstrained VBR.</dd>
  * <dt>1</dt><dd>Constrained VBR (default).</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_VBR_CONSTRAINT(x) OPUS_GET_VBR_CONSTRAINT_REQUEST, __opus_check_int_ptr(x)

/** Configures mono/stereo forcing in the encoder.
  * This can force the encoder to produce packets encoded as either mono or
  * stereo, regardless of the format of the input audio. This is useful when
  * the caller knows that the input signal is currently a mono source embedded
  * in a stereo stream.
  * @see OPUS_GET_FORCE_CHANNELS
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>#OPUS_AUTO</dt><dd>Not forced (default)</dd>
  * <dt>1</dt>         <dd>Forced mono</dd>
  * <dt>2</dt>         <dd>Forced stereo</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_FORCE_CHANNELS(x) OPUS_SET_FORCE_CHANNELS_REQUEST, __opus_check_int(x)
/** Gets the encoder's forced channel configuration.
  * @see OPUS_SET_FORCE_CHANNELS
  * @param[out] x <tt>opus_int32 *</tt>:
  * <dl>
  * <dt>#OPUS_AUTO</dt><dd>Not forced (default)</dd>
  * <dt>1</dt>         <dd>Forced mono</dd>
  * <dt>2</dt>         <dd>Forced stereo</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_FORCE_CHANNELS(x) OPUS_GET_FORCE_CHANNELS_REQUEST, __opus_check_int_ptr(x)

/** Configures the maximum bandpass that the encoder will select automatically.
  * Applications should normally use this instead of #OPUS_SET_BANDWIDTH
  * (leaving that set to the default, #OPUS_AUTO). This allows the
  * application to set an upper bound based on the type of input it is
  * providing, but still gives the encoder the freedom to reduce the bandpass
  * when the bitrate becomes too low, for better overall quality.
  * @see OPUS_GET_MAX_BANDWIDTH
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>OPUS_BANDWIDTH_NARROWBAND</dt>    <dd>4 kHz passband</dd>
  * <dt>OPUS_BANDWIDTH_MEDIUMBAND</dt>    <dd>6 kHz passband</dd>
  * <dt>OPUS_BANDWIDTH_WIDEBAND</dt>      <dd>8 kHz passband</dd>
  * <dt>OPUS_BANDWIDTH_SUPERWIDEBAND</dt><dd>12 kHz passband</dd>
  * <dt>OPUS_BANDWIDTH_FULLBAND</dt>     <dd>20 kHz passband (default)</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_MAX_BANDWIDTH(x) OPUS_SET_MAX_BANDWIDTH_REQUEST, __opus_check_int(x)

/** Gets the encoder's configured maximum allowed bandpass.
  * @see OPUS_SET_MAX_BANDWIDTH
  * @param[out] x <tt>opus_int32 *</tt>: Allowed values:
  * <dl>
  * <dt>#OPUS_BANDWIDTH_NARROWBAND</dt>    <dd>4 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_MEDIUMBAND</dt>    <dd>6 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_WIDEBAND</dt>      <dd>8 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_SUPERWIDEBAND</dt><dd>12 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_FULLBAND</dt>     <dd>20 kHz passband (default)</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_MAX_BANDWIDTH(x) OPUS_GET_MAX_BANDWIDTH_REQUEST, __opus_check_int_ptr(x)

/** Sets the encoder's bandpass to a specific value.
  * This prevents the encoder from automatically selecting the bandpass based
  * on the available bitrate. If an application knows the bandpass of the input
  * audio it is providing, it should normally use #OPUS_SET_MAX_BANDWIDTH
  * instead, which still gives the encoder the freedom to reduce the bandpass
  * when the bitrate becomes too low, for better overall quality.
  * @see OPUS_GET_BANDWIDTH
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>#OPUS_AUTO</dt>                    <dd>(default)</dd>
  * <dt>#OPUS_BANDWIDTH_NARROWBAND</dt>    <dd>4 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_MEDIUMBAND</dt>    <dd>6 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_WIDEBAND</dt>      <dd>8 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_SUPERWIDEBAND</dt><dd>12 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_FULLBAND</dt>     <dd>20 kHz passband</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_BANDWIDTH(x) OPUS_SET_BANDWIDTH_REQUEST, __opus_check_int(x)

/** Configures the type of signal being encoded.
  * This is a hint which helps the encoder's mode selection.
  * @see OPUS_GET_SIGNAL
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>#OPUS_AUTO</dt>        <dd>(default)</dd>
  * <dt>#OPUS_SIGNAL_VOICE</dt><dd>Bias thresholds towards choosing LPC or Hybrid modes.</dd>
  * <dt>#OPUS_SIGNAL_MUSIC</dt><dd>Bias thresholds towards choosing MDCT modes.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_SIGNAL(x) OPUS_SET_SIGNAL_REQUEST, __opus_check_int(x)
/** Gets the encoder's configured signal type.
  * @see OPUS_SET_SIGNAL
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>#OPUS_AUTO</dt>        <dd>(default)</dd>
  * <dt>#OPUS_SIGNAL_VOICE</dt><dd>Bias thresholds towards choosing LPC or Hybrid modes.</dd>
  * <dt>#OPUS_SIGNAL_MUSIC</dt><dd>Bias thresholds towards choosing MDCT modes.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_SIGNAL(x) OPUS_GET_SIGNAL_REQUEST, __opus_check_int_ptr(x)


/** Configures the encoder's intended application.
  * The initial value is a mandatory argument to the encoder_create function.
  * @see OPUS_GET_APPLICATION
  * @param[in] x <tt>opus_int32</tt>: Returns one of the following values:
  * <dl>
  * <dt>#OPUS_APPLICATION_VOIP</dt>
  * <dd>Process signal for improved speech intelligibility.</dd>
  * <dt>#OPUS_APPLICATION_AUDIO</dt>
  * <dd>Favor faithfulness to the original input.</dd>
  * <dt>#OPUS_APPLICATION_RESTRICTED_LOWDELAY</dt>
  * <dd>Configure the minimum possible coding delay by disabling certain modes
  * of operation.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_APPLICATION(x) OPUS_SET_APPLICATION_REQUEST, __opus_check_int(x)
/** Gets the encoder's configured application.
  * @see OPUS_SET_APPLICATION
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>#OPUS_APPLICATION_VOIP</dt>
  * <dd>Process signal for improved speech intelligibility.</dd>
  * <dt>#OPUS_APPLICATION_AUDIO</dt>
  * <dd>Favor faithfulness to the original input.</dd>
  * <dt>#OPUS_APPLICATION_RESTRICTED_LOWDELAY</dt>
  * <dd>Configure the minimum possible coding delay by disabling certain modes
  * of operation.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_APPLICATION(x) OPUS_GET_APPLICATION_REQUEST, __opus_check_int_ptr(x)

/** Gets the total samples of delay added by the entire codec.
  * This can be queried by the encoder and then the provided number of samples can be
  * skipped on from the start of the decoder's output to provide time aligned input
  * and output. From the perspective of a decoding application the real data begins this many
  * samples late.
  *
  * The decoder contribution to this delay is identical for all decoders, but the
  * encoder portion of the delay may vary from implementation to implementation,
  * version to version, or even depend on the encoder's initial configuration.
  * Applications needing delay compensation should call this CTL rather than
  * hard-coding a value.
  * @param[out] x <tt>opus_int32 *</tt>:   Number of lookahead samples
  * @hideinitializer */
#define OPUS_GET_LOOKAHEAD(x) OPUS_GET_LOOKAHEAD_REQUEST, __opus_check_int_ptr(x)

/** Configures the encoder's use of inband forward error correction (FEC).
  * @note This is only applicable to the LPC layer
  * @see OPUS_GET_INBAND_FEC
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>0</dt><dd>Disable inband FEC (default).</dd>
  * <dt>1</dt><dd>Enable inband FEC.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_INBAND_FEC(x) OPUS_SET_INBAND_FEC_REQUEST, __opus_check_int(x)
/** Gets encoder's configured use of inband forward error correction.
  * @see OPUS_SET_INBAND_FEC
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>0</dt><dd>Inband FEC disabled (default).</dd>
  * <dt>1</dt><dd>Inband FEC enabled.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_INBAND_FEC(x) OPUS_GET_INBAND_FEC_REQUEST, __opus_check_int_ptr(x)

/** Configures the encoder's expected packet loss percentage.
  * Higher values trigger progressively more loss resistant behavior in the encoder
  * at the expense of quality at a given bitrate in the absence of packet loss, but
  * greater quality under loss.
  * @see OPUS_GET_PACKET_LOSS_PERC
  * @param[in] x <tt>opus_int32</tt>:   Loss percentage in the range 0-100, inclusive (default: 0).
  * @hideinitializer */
#define OPUS_SET_PACKET_LOSS_PERC(x) OPUS_SET_PACKET_LOSS_PERC_REQUEST, __opus_check_int(x)
/** Gets the encoder's configured packet loss percentage.
  * @see OPUS_SET_PACKET_LOSS_PERC
  * @param[out] x <tt>opus_int32 *</tt>: Returns the configured loss percentage
  *                                      in the range 0-100, inclusive (default: 0).
  * @hideinitializer */
#define OPUS_GET_PACKET_LOSS_PERC(x) OPUS_GET_PACKET_LOSS_PERC_REQUEST, __opus_check_int_ptr(x)

/** Configures the encoder's use of discontinuous transmission (DTX).
  * @note This is only applicable to the LPC layer
  * @see OPUS_GET_DTX
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>0</dt><dd>Disable DTX (default).</dd>
  * <dt>1</dt><dd>Enabled DTX.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_DTX(x) OPUS_SET_DTX_REQUEST, __opus_check_int(x)
/** Gets encoder's configured use of discontinuous transmission.
  * @see OPUS_SET_DTX
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>0</dt><dd>DTX disabled (default).</dd>
  * <dt>1</dt><dd>DTX enabled.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_DTX(x) OPUS_GET_DTX_REQUEST, __opus_check_int_ptr(x)
/** Configures the depth of signal being encoded.
  *
  * This is a hint which helps the encoder identify silence and near-silence.
  * It represents the number of significant bits of linear intensity below
  * which the signal contains ignorable quantization or other noise.
  *
  * For example, OPUS_SET_LSB_DEPTH(14) would be an appropriate setting
  * for G.711 u-law input. OPUS_SET_LSB_DEPTH(16) would be appropriate
  * for 16-bit linear pcm input with opus_encode_float().
  *
  * When using opus_encode() instead of opus_encode_float(), or when libopus
  * is compiled for fixed-point, the encoder uses the minimum of the value
  * set here and the value 16.
  *
  * @see OPUS_GET_LSB_DEPTH
  * @param[in] x <tt>opus_int32</tt>: Input precision in bits, between 8 and 24
  *                                   (default: 24).
  * @hideinitializer */
#define OPUS_SET_LSB_DEPTH(x) OPUS_SET_LSB_DEPTH_REQUEST, __opus_check_int(x)
/** Gets the encoder's configured signal depth.
  * @see OPUS_SET_LSB_DEPTH
  * @param[out] x <tt>opus_int32 *</tt>: Input precision in bits, between 8 and
  *                                      24 (default: 24).
  * @hideinitializer */
#define OPUS_GET_LSB_DEPTH(x) OPUS_GET_LSB_DEPTH_REQUEST, __opus_check_int_ptr(x)

/** Configures the encoder's use of variable duration frames.
  * When variable duration is enabled, the encoder is free to use a shorter frame
  * size than the one requested in the opus_encode*() call.
  * It is then the user's responsibility
  * to verify how much audio was encoded by checking the ToC byte of the encoded
  * packet. The part of the audio that was not encoded needs to be resent to the
  * encoder for the next call. Do not use this option unless you <b>really</b>
  * know what you are doing.
  * @see OPUS_GET_EXPERT_FRAME_DURATION
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>OPUS_FRAMESIZE_ARG</dt><dd>Select frame size from the argument (default).</dd>
  * <dt>OPUS_FRAMESIZE_2_5_MS</dt><dd>Use 2.5 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_5_MS</dt><dd>Use 5 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_10_MS</dt><dd>Use 10 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_20_MS</dt><dd>Use 20 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_40_MS</dt><dd>Use 40 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_60_MS</dt><dd>Use 60 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_80_MS</dt><dd>Use 80 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_100_MS</dt><dd>Use 100 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_120_MS</dt><dd>Use 120 ms frames.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_EXPERT_FRAME_DURATION(x) OPUS_SET_EXPERT_FRAME_DURATION_REQUEST, __opus_check_int(x)
/** Gets the encoder's configured use of variable duration frames.
  * @see OPUS_SET_EXPERT_FRAME_DURATION
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>OPUS_FRAMESIZE_ARG</dt><dd>Select frame size from the argument (default).</dd>
  * <dt>OPUS_FRAMESIZE_2_5_MS</dt><dd>Use 2.5 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_5_MS</dt><dd>Use 5 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_10_MS</dt><dd>Use 10 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_20_MS</dt><dd>Use 20 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_40_MS</dt><dd>Use 40 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_60_MS</dt><dd>Use 60 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_80_MS</dt><dd>Use 80 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_100_MS</dt><dd>Use 100 ms frames.</dd>
  * <dt>OPUS_FRAMESIZE_120_MS</dt><dd>Use 120 ms frames.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_EXPERT_FRAME_DURATION(x) OPUS_GET_EXPERT_FRAME_DURATION_REQUEST, __opus_check_int_ptr(x)

/** If set to 1, disables almost all use of prediction, making frames almost
  * completely independent. This reduces quality.
  * @see OPUS_GET_PREDICTION_DISABLED
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>0</dt><dd>Enable prediction (default).</dd>
  * <dt>1</dt><dd>Disable prediction.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_PREDICTION_DISABLED(x) OPUS_SET_PREDICTION_DISABLED_REQUEST, __opus_check_int(x)
/** Gets the encoder's configured prediction status.
  * @see OPUS_SET_PREDICTION_DISABLED
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>0</dt><dd>Prediction enabled (default).</dd>
  * <dt>1</dt><dd>Prediction disabled.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_PREDICTION_DISABLED(x) OPUS_GET_PREDICTION_DISABLED_REQUEST, __opus_check_int_ptr(x)
+/
/**@}*/

/** @defgroup opus_genericctls Generic CTLs
  *
  * These macros are used with the \c opus_decoder_ctl and
  * \c opus_encoder_ctl calls to generate a particular
  * request.
  *
  * When called on an \c OpusDecoder they apply to that
  * particular decoder instance. When called on an
  * \c OpusEncoder they apply to the corresponding setting
  * on that encoder instance, if present.
  *
  * Some usage examples:
  *
  * @code
  * int ret;
  * opus_int32 pitch;
  * ret = opus_decoder_ctl(dec_ctx, OPUS_GET_PITCH(&pitch));
  * if (ret == OPUS_OK) return ret;
  *
  * opus_encoder_ctl(enc_ctx, OPUS_RESET_STATE);
  * opus_decoder_ctl(dec_ctx, OPUS_RESET_STATE);
  *
  * opus_int32 enc_bw, dec_bw;
  * opus_encoder_ctl(enc_ctx, OPUS_GET_BANDWIDTH(&enc_bw));
  * opus_decoder_ctl(dec_ctx, OPUS_GET_BANDWIDTH(&dec_bw));
  * if (enc_bw != dec_bw) {
  *   printf("packet bandwidth mismatch!\n");
  * }
  * @endcode
  *
  * @see opus_encoder, opus_decoder_ctl, opus_encoder_ctl, opus_decoderctls, opus_encoderctls
  * @{
  */

/** Resets the codec state to be equivalent to a freshly initialized state.
  * This should be called when switching streams in order to prevent
  * the back to back decoding from giving different results from
  * one at a time decoding.
  * @hideinitializer */
enum OPUS_RESET_STATE = 4028;

/+TODO
/** Gets the final state of the codec's entropy coder.
  * This is used for testing purposes,
  * The encoder and decoder state should be identical after coding a payload
  * (assuming no data corruption or software bugs)
  *
  * @param[out] x <tt>opus_uint32 *</tt>: Entropy coder state
  *
  * @hideinitializer */
#define OPUS_GET_FINAL_RANGE(x) OPUS_GET_FINAL_RANGE_REQUEST, __opus_check_uint_ptr(x)

/** Gets the encoder's configured bandpass or the decoder's last bandpass.
  * @see OPUS_SET_BANDWIDTH
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>#OPUS_AUTO</dt>                    <dd>(default)</dd>
  * <dt>#OPUS_BANDWIDTH_NARROWBAND</dt>    <dd>4 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_MEDIUMBAND</dt>    <dd>6 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_WIDEBAND</dt>      <dd>8 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_SUPERWIDEBAND</dt><dd>12 kHz passband</dd>
  * <dt>#OPUS_BANDWIDTH_FULLBAND</dt>     <dd>20 kHz passband</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_BANDWIDTH(x) OPUS_GET_BANDWIDTH_REQUEST, __opus_check_int_ptr(x)

/** Gets the sampling rate the encoder or decoder was initialized with.
  * This simply returns the <code>Fs</code> value passed to opus_encoder_init()
  * or opus_decoder_init().
  * @param[out] x <tt>opus_int32 *</tt>: Sampling rate of encoder or decoder.
  * @hideinitializer
  */
#define OPUS_GET_SAMPLE_RATE(x) OPUS_GET_SAMPLE_RATE_REQUEST, __opus_check_int_ptr(x)

/** If set to 1, disables the use of phase inversion for intensity stereo,
  * improving the quality of mono downmixes, but slightly reducing normal
  * stereo quality. Disabling phase inversion in the decoder does not comply
  * with RFC 6716, although it does not cause any interoperability issue and
  * is expected to become part of the Opus standard once RFC 6716 is updated
  * by draft-ietf-codec-opus-update.
  * @see OPUS_GET_PHASE_INVERSION_DISABLED
  * @param[in] x <tt>opus_int32</tt>: Allowed values:
  * <dl>
  * <dt>0</dt><dd>Enable phase inversion (default).</dd>
  * <dt>1</dt><dd>Disable phase inversion.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_SET_PHASE_INVERSION_DISABLED(x) OPUS_SET_PHASE_INVERSION_DISABLED_REQUEST, __opus_check_int(x)
/** Gets the encoder's configured phase inversion status.
  * @see OPUS_SET_PHASE_INVERSION_DISABLED
  * @param[out] x <tt>opus_int32 *</tt>: Returns one of the following values:
  * <dl>
  * <dt>0</dt><dd>Stereo phase inversion enabled (default).</dd>
  * <dt>1</dt><dd>Stereo phase inversion disabled.</dd>
  * </dl>
  * @hideinitializer */
#define OPUS_GET_PHASE_INVERSION_DISABLED(x) OPUS_GET_PHASE_INVERSION_DISABLED_REQUEST, __opus_check_int_ptr(x)
+/
/**@}*/

/** @defgroup opus_decoderctls Decoder related CTLs
  * @see opus_genericctls, opus_encoderctls, opus_decoder
  * @{
  */

/+TODO
/** Configures decoder gain adjustment.
  * Scales the decoded output by a factor specified in Q8 dB units.
  * This has a maximum range of -32768 to 32767 inclusive, and returns
  * OPUS_BAD_ARG otherwise. The default is zero indicating no adjustment.
  * This setting survives decoder reset.
  *
  * gain = pow(10, x/(20.0*256))
  *
  * @param[in] x <tt>opus_int32</tt>:   Amount to scale PCM signal by in Q8 dB units.
  * @hideinitializer */
#define OPUS_SET_GAIN(x) OPUS_SET_GAIN_REQUEST, __opus_check_int(x)
/** Gets the decoder's configured gain adjustment. @see OPUS_SET_GAIN
  *
  * @param[out] x <tt>opus_int32 *</tt>: Amount to scale PCM signal by in Q8 dB units.
  * @hideinitializer */
#define OPUS_GET_GAIN(x) OPUS_GET_GAIN_REQUEST, __opus_check_int_ptr(x)

/** Gets the duration (in samples) of the last packet successfully decoded or concealed.
  * @param[out] x <tt>opus_int32 *</tt>: Number of samples (at current sampling rate).
  * @hideinitializer */
#define OPUS_GET_LAST_PACKET_DURATION(x) OPUS_GET_LAST_PACKET_DURATION_REQUEST, __opus_check_int_ptr(x)

/** Gets the pitch of the last decoded frame, if available.
  * This can be used for any post-processing algorithm requiring the use of pitch,
  * e.g. time stretching/shortening. If the last frame was not voiced, or if the
  * pitch was not coded in the frame, then zero is returned.
  *
  * This CTL is only implemented for decoder instances.
  *
  * @param[out] x <tt>opus_int32 *</tt>: pitch period at 48 kHz (or 0 if not available)
  *
  * @hideinitializer */
#define OPUS_GET_PITCH(x) OPUS_GET_PITCH_REQUEST, __opus_check_int_ptr(x)
+/
/**@}*/

/** @defgroup opus_libinfo Opus library information functions
  * @{
  */

/** Converts an opus error code into a human readable string.
  *
  * @param[in] error <tt>int</tt>: Error number
  * @returns Error string
  */
const(char)* opus_strerror (int error);
const(char)[] opus_strerr (int error) {
  auto s = opus_strerror(error);
  if (s !is null) {
    uint len = 0;
    while (s[len]) ++len;
    return s[0..len];
  }
  return null;
}

/** Gets the libopus version string.
  *
  * Applications may look for the substring "-fixed" in the version string to
  * determine whether they have a fixed-point or floating-point build at
  * runtime.
  *
  * @returns Version string
  */
/**@}*/
const(char)* opus_get_version_string ();
const(char)[] opus_get_version_str () {
  auto s = opus_get_version_string();
  if (s !is null) {
    uint len = 0;
    while (s[len]) ++len;
    return s[0..len];
  }
  return null;
}


/**
 * @file opus.h
 * @brief Opus reference implementation API
 */

/**
 * @mainpage Opus
 *
 * The Opus codec is designed for interactive speech and audio transmission over the Internet.
 * It is designed by the IETF Codec Working Group and incorporates technology from
 * Skype's SILK codec and Xiph.Org's CELT codec.
 *
 * The Opus codec is designed to handle a wide range of interactive audio applications,
 * including Voice over IP, videoconferencing, in-game chat, and even remote live music
 * performances. It can scale from low bit-rate narrowband speech to very high quality
 * stereo music. Its main features are:

 * @li Sampling rates from 8 to 48 kHz
 * @li Bit-rates from 6 kb/s to 510 kb/s
 * @li Support for both constant bit-rate (CBR) and variable bit-rate (VBR)
 * @li Audio bandwidth from narrowband to full-band
 * @li Support for speech and music
 * @li Support for mono and stereo
 * @li Support for multichannel (up to 255 channels)
 * @li Frame sizes from 2.5 ms to 60 ms
 * @li Good loss robustness and packet loss concealment (PLC)
 * @li Floating point and fixed-point implementation
 *
 * Documentation sections:
 * @li @ref opus_encoder
 * @li @ref opus_decoder
 * @li @ref opus_repacketizer
 * @li @ref opus_multistream
 * @li @ref opus_libinfo
 * @li @ref opus_custom
 */

/** @defgroup opus_encoder Opus Encoder
  * @{
  *
  * @brief This page describes the process and functions used to encode Opus.
  *
  * Since Opus is a stateful codec, the encoding process starts with creating an encoder
  * state. This can be done with:
  *
  * @code
  * int          error;
  * OpusEncoder *enc;
  * enc = opus_encoder_create(Fs, channels, application, &error);
  * @endcode
  *
  * From this point, @c enc can be used for encoding an audio stream. An encoder state
  * @b must @b not be used for more than one stream at the same time. Similarly, the encoder
  * state @b must @b not be re-initialized for each frame.
  *
  * While opus_encoder_create() allocates memory for the state, it's also possible
  * to initialize pre-allocated memory:
  *
  * @code
  * int          size;
  * int          error;
  * OpusEncoder *enc;
  * size = opus_encoder_get_size(channels);
  * enc = malloc(size);
  * error = opus_encoder_init(enc, Fs, channels, application);
  * @endcode
  *
  * where opus_encoder_get_size() returns the required size for the encoder state. Note that
  * future versions of this code may change the size, so no assuptions should be made about it.
  *
  * The encoder state is always continuous in memory and only a shallow copy is sufficient
  * to copy it (e.g. memcpy())
  *
  * It is possible to change some of the encoder's settings using the opus_encoder_ctl()
  * interface. All these settings already default to the recommended value, so they should
  * only be changed when necessary. The most common settings one may want to change are:
  *
  * @code
  * opus_encoder_ctl(enc, OPUS_SET_BITRATE(bitrate));
  * opus_encoder_ctl(enc, OPUS_SET_COMPLEXITY(complexity));
  * opus_encoder_ctl(enc, OPUS_SET_SIGNAL(signal_type));
  * @endcode
  *
  * where
  *
  * @arg bitrate is in bits per second (b/s)
  * @arg complexity is a value from 1 to 10, where 1 is the lowest complexity and 10 is the highest
  * @arg signal_type is either OPUS_AUTO (default), OPUS_SIGNAL_VOICE, or OPUS_SIGNAL_MUSIC
  *
  * See @ref opus_encoderctls and @ref opus_genericctls for a complete list of parameters that can be set or queried. Most parameters can be set or changed at any time during a stream.
  *
  * To encode a frame, opus_encode() or opus_encode_float() must be called with exactly one frame (2.5, 5, 10, 20, 40 or 60 ms) of audio data:
  * @code
  * len = opus_encode(enc, audio_frame, frame_size, packet, max_packet);
  * @endcode
  *
  * where
  * <ul>
  * <li>audio_frame is the audio data in opus_int16 (or float for opus_encode_float())</li>
  * <li>frame_size is the duration of the frame in samples (per channel)</li>
  * <li>packet is the byte array to which the compressed data is written</li>
  * <li>max_packet is the maximum number of bytes that can be written in the packet (4000 bytes is recommended).
  *     Do not use max_packet to control VBR target bitrate, instead use the #OPUS_SET_BITRATE CTL.</li>
  * </ul>
  *
  * opus_encode() and opus_encode_float() return the number of bytes actually written to the packet.
  * The return value <b>can be negative</b>, which indicates that an error has occurred. If the return value
  * is 2 bytes or less, then the packet does not need to be transmitted (DTX).
  *
  * Once the encoder state if no longer needed, it can be destroyed with
  *
  * @code
  * opus_encoder_destroy(enc);
  * @endcode
  *
  * If the encoder was created with opus_encoder_init() rather than opus_encoder_create(),
  * then no action is required aside from potentially freeing the memory that was manually
  * allocated for it (calling free(enc) for the example above)
  *
  */

/** Opus encoder state.
  * This contains the complete state of an Opus encoder.
  * It is position independent and can be freely copied.
  * @see opus_encoder_create,opus_encoder_init
  */
struct OpusEncoder;

/** Gets the size of an <code>OpusEncoder</code> structure.
  * @param[in] channels <tt>int</tt>: Number of channels.
  *                                   This must be 1 or 2.
  * @returns The size in bytes.
  */
int opus_encoder_get_size (int channels);

/**
 */

/** Allocates and initializes an encoder state.
 * There are three coding modes:
 *
 * @ref OPUS_APPLICATION_VOIP gives best quality at a given bitrate for voice
 *    signals. It enhances the  input signal by high-pass filtering and
 *    emphasizing formants and harmonics. Optionally  it includes in-band
 *    forward error correction to protect against packet loss. Use this
 *    mode for typical VoIP applications. Because of the enhancement,
 *    even at high bitrates the output may sound different from the input.
 *
 * @ref OPUS_APPLICATION_AUDIO gives best quality at a given bitrate for most
 *    non-voice signals like music. Use this mode for music and mixed
 *    (music/voice) content, broadcast, and applications requiring less
 *    than 15 ms of coding delay.
 *
 * @ref OPUS_APPLICATION_RESTRICTED_LOWDELAY configures low-delay mode that
 *    disables the speech-optimized mode in exchange for slightly reduced delay.
 *    This mode can only be set on an newly initialized or freshly reset encoder
 *    because it changes the codec delay.
 *
 * This is useful when the caller knows that the speech-optimized modes will not be needed (use with caution).
 * @param [in] Fs <tt>opus_int32</tt>: Sampling rate of input signal (Hz)
 *                                     This must be one of 8000, 12000, 16000,
 *                                     24000, or 48000.
 * @param [in] channels <tt>int</tt>: Number of channels (1 or 2) in input signal
 * @param [in] application <tt>int</tt>: Coding mode (@ref OPUS_APPLICATION_VOIP/@ref OPUS_APPLICATION_AUDIO/@ref OPUS_APPLICATION_RESTRICTED_LOWDELAY)
 * @param [out] error <tt>int*</tt>: @ref opus_errorcodes
 * @note Regardless of the sampling rate and number channels selected, the Opus encoder
 * can switch to a lower audio bandwidth or number of channels if the bitrate
 * selected is too low. This also means that it is safe to always use 48 kHz stereo input
 * and let the encoder optimize the encoding.
 */
OpusEncoder* opus_encoder_create(
    opus_int32 Fs,
    int channels,
    int application,
    int* error
);

/** Initializes a previously allocated encoder state
  * The memory pointed to by st must be at least the size returned by opus_encoder_get_size().
  * This is intended for applications which use their own allocator instead of malloc.
  * @see opus_encoder_create(),opus_encoder_get_size()
  * To reset a previously initialized state, use the #OPUS_RESET_STATE CTL.
  * @param [in] st <tt>OpusEncoder*</tt>: Encoder state
  * @param [in] Fs <tt>opus_int32</tt>: Sampling rate of input signal (Hz)
 *                                      This must be one of 8000, 12000, 16000,
 *                                      24000, or 48000.
  * @param [in] channels <tt>int</tt>: Number of channels (1 or 2) in input signal
  * @param [in] application <tt>int</tt>: Coding mode (OPUS_APPLICATION_VOIP/OPUS_APPLICATION_AUDIO/OPUS_APPLICATION_RESTRICTED_LOWDELAY)
  * @retval #OPUS_OK Success or @ref opus_errorcodes
  */
int opus_encoder_init(
    OpusEncoder* st,
    opus_int32 Fs,
    int channels,
    int application
) /*OPUS_ARG_NONNULL(1)*/;

/** Encodes an Opus frame.
  * @param [in] st <tt>OpusEncoder*</tt>: Encoder state
  * @param [in] pcm <tt>opus_int16*</tt>: Input signal (interleaved if 2 channels). length is frame_size*channels*sizeof(opus_int16)
  * @param [in] frame_size <tt>int</tt>: Number of samples per channel in the
  *                                      input signal.
  *                                      This must be an Opus frame size for
  *                                      the encoder's sampling rate.
  *                                      For example, at 48 kHz the permitted
  *                                      values are 120, 240, 480, 960, 1920,
  *                                      and 2880.
  *                                      Passing in a duration of less than
  *                                      10 ms (480 samples at 48 kHz) will
  *                                      prevent the encoder from using the LPC
  *                                      or hybrid modes.
  * @param [out] data <tt>ubyte*</tt>: Output payload.
  *                                            This must contain storage for at
  *                                            least \a max_data_bytes.
  * @param [in] max_data_bytes <tt>opus_int32</tt>: Size of the allocated
  *                                                 memory for the output
  *                                                 payload. This may be
  *                                                 used to impose an upper limit on
  *                                                 the instant bitrate, but should
  *                                                 not be used as the only bitrate
  *                                                 control. Use #OPUS_SET_BITRATE to
  *                                                 control the bitrate.
  * @returns The length of the encoded packet (in bytes) on success or a
  *          negative error code (see @ref opus_errorcodes) on failure.
  */
opus_int32 opus_encode(
    OpusEncoder* st,
    const(opus_int16)* pcm,
    int frame_size,
    ubyte* data,
    opus_int32 max_data_bytes
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(2)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Encodes an Opus frame from floating point input.
  * @param [in] st <tt>OpusEncoder*</tt>: Encoder state
  * @param [in] pcm <tt>float*</tt>: Input in float format (interleaved if 2 channels), with a normal range of +/-1.0.
  *          Samples with a range beyond +/-1.0 are supported but will
  *          be clipped by decoders using the integer API and should
  *          only be used if it is known that the far end supports
  *          extended dynamic range.
  *          length is frame_size*channels*sizeof(float)
  * @param [in] frame_size <tt>int</tt>: Number of samples per channel in the
  *                                      input signal.
  *                                      This must be an Opus frame size for
  *                                      the encoder's sampling rate.
  *                                      For example, at 48 kHz the permitted
  *                                      values are 120, 240, 480, 960, 1920,
  *                                      and 2880.
  *                                      Passing in a duration of less than
  *                                      10 ms (480 samples at 48 kHz) will
  *                                      prevent the encoder from using the LPC
  *                                      or hybrid modes.
  * @param [out] data <tt>ubyte*</tt>: Output payload.
  *                                            This must contain storage for at
  *                                            least \a max_data_bytes.
  * @param [in] max_data_bytes <tt>opus_int32</tt>: Size of the allocated
  *                                                 memory for the output
  *                                                 payload. This may be
  *                                                 used to impose an upper limit on
  *                                                 the instant bitrate, but should
  *                                                 not be used as the only bitrate
  *                                                 control. Use #OPUS_SET_BITRATE to
  *                                                 control the bitrate.
  * @returns The length of the encoded packet (in bytes) on success or a
  *          negative error code (see @ref opus_errorcodes) on failure.
  */
opus_int32 opus_encode_float(
    OpusEncoder*st,
    const(float)* pcm,
    int frame_size,
    ubyte* data,
    opus_int32 max_data_bytes
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(2)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Frees an <code>OpusEncoder</code> allocated by opus_encoder_create().
  * @param[in] st <tt>OpusEncoder*</tt>: State to be freed.
  */
void opus_encoder_destroy (OpusEncoder* st);

/** Perform a CTL function on an Opus encoder.
  *
  * Generally the request and subsequent arguments are generated
  * by a convenience macro.
  * @param st <tt>OpusEncoder*</tt>: Encoder state.
  * @param request This and all remaining parameters should be replaced by one
  *                of the convenience macros in @ref opus_genericctls or
  *                @ref opus_encoderctls.
  * @see opus_genericctls
  * @see opus_encoderctls
  */
int opus_encoder_ctl (OpusEncoder* st, int request, ...) /*OPUS_ARG_NONNULL(1)*/;
/**@}*/

/** @defgroup opus_decoder Opus Decoder
  * @{
  *
  * @brief This page describes the process and functions used to decode Opus.
  *
  * The decoding process also starts with creating a decoder
  * state. This can be done with:
  * @code
  * int          error;
  * OpusDecoder *dec;
  * dec = opus_decoder_create(Fs, channels, &error);
  * @endcode
  * where
  * @li Fs is the sampling rate and must be 8000, 12000, 16000, 24000, or 48000
  * @li channels is the number of channels (1 or 2)
  * @li error will hold the error code in case of failure (or #OPUS_OK on success)
  * @li the return value is a newly created decoder state to be used for decoding
  *
  * While opus_decoder_create() allocates memory for the state, it's also possible
  * to initialize pre-allocated memory:
  * @code
  * int          size;
  * int          error;
  * OpusDecoder *dec;
  * size = opus_decoder_get_size(channels);
  * dec = malloc(size);
  * error = opus_decoder_init(dec, Fs, channels);
  * @endcode
  * where opus_decoder_get_size() returns the required size for the decoder state. Note that
  * future versions of this code may change the size, so no assuptions should be made about it.
  *
  * The decoder state is always continuous in memory and only a shallow copy is sufficient
  * to copy it (e.g. memcpy())
  *
  * To decode a frame, opus_decode() or opus_decode_float() must be called with a packet of compressed audio data:
  * @code
  * frame_size = opus_decode(dec, packet, len, decoded, max_size, 0);
  * @endcode
  * where
  *
  * @li packet is the byte array containing the compressed data
  * @li len is the exact number of bytes contained in the packet
  * @li decoded is the decoded audio data in opus_int16 (or float for opus_decode_float())
  * @li max_size is the max duration of the frame in samples (per channel) that can fit into the decoded_frame array
  *
  * opus_decode() and opus_decode_float() return the number of samples (per channel) decoded from the packet.
  * If that value is negative, then an error has occurred. This can occur if the packet is corrupted or if the audio
  * buffer is too small to hold the decoded audio.
  *
  * Opus is a stateful codec with overlapping blocks and as a result Opus
  * packets are not coded independently of each other. Packets must be
  * passed into the decoder serially and in the correct order for a correct
  * decode. Lost packets can be replaced with loss concealment by calling
  * the decoder with a null pointer and zero length for the missing packet.
  *
  * A single codec state may only be accessed from a single thread at
  * a time and any required locking must be performed by the caller. Separate
  * streams must be decoded with separate decoder states and can be decoded
  * in parallel unless the library was compiled with NONTHREADSAFE_PSEUDOSTACK
  * defined.
  *
  */

/** Opus decoder state.
  * This contains the complete state of an Opus decoder.
  * It is position independent and can be freely copied.
  * @see opus_decoder_create,opus_decoder_init
  */
struct OpusDecoder;

/** Gets the size of an <code>OpusDecoder</code> structure.
  * @param [in] channels <tt>int</tt>: Number of channels.
  *                                    This must be 1 or 2.
  * @returns The size in bytes.
  */
int opus_decoder_get_size (int channels);

/** Allocates and initializes a decoder state.
  * @param [in] Fs <tt>opus_int32</tt>: Sample rate to decode at (Hz).
  *                                     This must be one of 8000, 12000, 16000,
  *                                     24000, or 48000.
  * @param [in] channels <tt>int</tt>: Number of channels (1 or 2) to decode
  * @param [out] error <tt>int*</tt>: #OPUS_OK Success or @ref opus_errorcodes
  *
  * Internally Opus stores data at 48000 Hz, so that should be the default
  * value for Fs. However, the decoder can efficiently decode to buffers
  * at 8, 12, 16, and 24 kHz so if for some reason the caller cannot use
  * data at the full sample rate, or knows the compressed data doesn't
  * use the full frequency range, it can request decoding at a reduced
  * rate. Likewise, the decoder is capable of filling in either mono or
  * interleaved stereo pcm buffers, at the caller's request.
  */
OpusDecoder* opus_decoder_create(
    opus_int32 Fs,
    int channels,
    int* error
);

/** Initializes a previously allocated decoder state.
  * The state must be at least the size returned by opus_decoder_get_size().
  * This is intended for applications which use their own allocator instead of malloc. @see opus_decoder_create,opus_decoder_get_size
  * To reset a previously initialized state, use the #OPUS_RESET_STATE CTL.
  * @param [in] st <tt>OpusDecoder*</tt>: Decoder state.
  * @param [in] Fs <tt>opus_int32</tt>: Sampling rate to decode to (Hz).
  *                                     This must be one of 8000, 12000, 16000,
  *                                     24000, or 48000.
  * @param [in] channels <tt>int</tt>: Number of channels (1 or 2) to decode
  * @retval #OPUS_OK Success or @ref opus_errorcodes
  */
int opus_decoder_init(
    OpusDecoder* st,
    opus_int32 Fs,
    int channels
) /*OPUS_ARG_NONNULL(1)*/;

/** Decode an Opus packet.
  * @param [in] st <tt>OpusDecoder*</tt>: Decoder state
  * @param [in] data <tt>char*</tt>: Input payload. Use a NULL pointer to indicate packet loss
  * @param [in] len <tt>opus_int32</tt>: Number of bytes in payload*
  * @param [out] pcm <tt>opus_int16*</tt>: Output signal (interleaved if 2 channels). length
  *  is frame_size*channels*sizeof(opus_int16)
  * @param [in] frame_size Number of samples per channel of available space in \a pcm.
  *  If this is less than the maximum packet duration (120ms; 5760 for 48kHz), this function will
  *  not be capable of decoding some packets. In the case of PLC (data==NULL) or FEC (decode_fec=1),
  *  then frame_size needs to be exactly the duration of audio that is missing, otherwise the
  *  decoder will not be in the optimal state to decode the next incoming packet. For the PLC and
  *  FEC cases, frame_size <b>must</b> be a multiple of 2.5 ms.
  * @param [in] decode_fec <tt>int</tt>: Flag (0 or 1) to request that any in-band forward error correction data be
  *  decoded. If no such data is available, the frame is decoded as if it were lost.
  * @returns Number of decoded samples or @ref opus_errorcodes
  */
int opus_decode(
    OpusDecoder*st,
    const(ubyte)* data,
    opus_int32 len,
    opus_int16* pcm,
    int frame_size,
    int decode_fec
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Decode an Opus packet with floating point output.
  * @param [in] st <tt>OpusDecoder*</tt>: Decoder state
  * @param [in] data <tt>char*</tt>: Input payload. Use a NULL pointer to indicate packet loss
  * @param [in] len <tt>opus_int32</tt>: Number of bytes in payload
  * @param [out] pcm <tt>float*</tt>: Output signal (interleaved if 2 channels). length
  *  is frame_size*channels*sizeof(float)
  * @param [in] frame_size Number of samples per channel of available space in \a pcm.
  *  If this is less than the maximum packet duration (120ms; 5760 for 48kHz), this function will
  *  not be capable of decoding some packets. In the case of PLC (data==NULL) or FEC (decode_fec=1),
  *  then frame_size needs to be exactly the duration of audio that is missing, otherwise the
  *  decoder will not be in the optimal state to decode the next incoming packet. For the PLC and
  *  FEC cases, frame_size <b>must</b> be a multiple of 2.5 ms.
  * @param [in] decode_fec <tt>int</tt>: Flag (0 or 1) to request that any in-band forward error correction data be
  *  decoded. If no such data is available the frame is decoded as if it were lost.
  * @returns Number of decoded samples or @ref opus_errorcodes
  */
int opus_decode_float(
    OpusDecoder*st,
    const(ubyte)* data,
    opus_int32 len,
    float* pcm,
    int frame_size,
    int decode_fec
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Perform a CTL function on an Opus decoder.
  *
  * Generally the request and subsequent arguments are generated
  * by a convenience macro.
  * @param st <tt>OpusDecoder*</tt>: Decoder state.
  * @param request This and all remaining parameters should be replaced by one
  *                of the convenience macros in @ref opus_genericctls or
  *                @ref opus_decoderctls.
  * @see opus_genericctls
  * @see opus_decoderctls
  */
int opus_decoder_ctl (OpusDecoder* st, int request, ...) /*OPUS_ARG_NONNULL(1)*/;

/** Frees an <code>OpusDecoder</code> allocated by opus_decoder_create().
  * @param[in] st <tt>OpusDecoder*</tt>: State to be freed.
  */
void opus_decoder_destroy (OpusDecoder* st);

/** Parse an opus packet into one or more frames.
  * Opus_decode will perform this operation internally so most applications do
  * not need to use this function.
  * This function does not copy the frames, the returned pointers are pointers into
  * the input packet.
  * @param [in] data <tt>char*</tt>: Opus packet to be parsed
  * @param [in] len <tt>opus_int32</tt>: size of data
  * @param [out] out_toc <tt>char*</tt>: TOC pointer
  * @param [out] frames <tt>char*[48]</tt> encapsulated frames
  * @param [out] size <tt>opus_int16[48]</tt> sizes of the encapsulated frames
  * @param [out] payload_offset <tt>int*</tt>: returns the position of the payload within the packet (in bytes)
  * @returns number of frames
  */
int opus_packet_parse(
   const(ubyte)* data,
   opus_int32 len,
   ubyte* out_toc,
   const(ubyte)** frames/*[48]*/,
   opus_int16* size/*[48]*/,
   int* payload_offset
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Gets the bandwidth of an Opus packet.
  * @param [in] data <tt>char*</tt>: Opus packet
  * @retval OPUS_BANDWIDTH_NARROWBAND Narrowband (4kHz bandpass)
  * @retval OPUS_BANDWIDTH_MEDIUMBAND Mediumband (6kHz bandpass)
  * @retval OPUS_BANDWIDTH_WIDEBAND Wideband (8kHz bandpass)
  * @retval OPUS_BANDWIDTH_SUPERWIDEBAND Superwideband (12kHz bandpass)
  * @retval OPUS_BANDWIDTH_FULLBAND Fullband (20kHz bandpass)
  * @retval OPUS_INVALID_PACKET The compressed data passed is corrupted or of an unsupported type
  */
int opus_packet_get_bandwidth (const(ubyte)* data) /*OPUS_ARG_NONNULL(1)*/;

/** Gets the number of samples per frame from an Opus packet.
  * @param [in] data <tt>char*</tt>: Opus packet.
  *                                  This must contain at least one byte of
  *                                  data.
  * @param [in] Fs <tt>opus_int32</tt>: Sampling rate in Hz.
  *                                     This must be a multiple of 400, or
  *                                     inaccurate results will be returned.
  * @returns Number of samples per frame.
  */
int opus_packet_get_samples_per_frame (const(ubyte)* data, opus_int32 Fs) /*OPUS_ARG_NONNULL(1)*/;

/** Gets the number of channels from an Opus packet.
  * @param [in] data <tt>char*</tt>: Opus packet
  * @returns Number of channels
  * @retval OPUS_INVALID_PACKET The compressed data passed is corrupted or of an unsupported type
  */
int opus_packet_get_nb_channels (const(ubyte)* data) /*OPUS_ARG_NONNULL(1)*/;

/** Gets the number of frames in an Opus packet.
  * @param [in] packet <tt>char*</tt>: Opus packet
  * @param [in] len <tt>opus_int32</tt>: Length of packet
  * @returns Number of frames
  * @retval OPUS_BAD_ARG Insufficient data was passed to the function
  * @retval OPUS_INVALID_PACKET The compressed data passed is corrupted or of an unsupported type
  */
int opus_packet_get_nb_frames (const(ubyte)* packet, opus_int32 len) /*OPUS_ARG_NONNULL(1)*/;

/** Gets the number of samples of an Opus packet.
  * @param [in] packet <tt>char*</tt>: Opus packet
  * @param [in] len <tt>opus_int32</tt>: Length of packet
  * @param [in] Fs <tt>opus_int32</tt>: Sampling rate in Hz.
  *                                     This must be a multiple of 400, or
  *                                     inaccurate results will be returned.
  * @returns Number of samples
  * @retval OPUS_BAD_ARG Insufficient data was passed to the function
  * @retval OPUS_INVALID_PACKET The compressed data passed is corrupted or of an unsupported type
  */
int opus_packet_get_nb_samples (const(ubyte)* packet, opus_int32 len, opus_int32 Fs) /*OPUS_ARG_NONNULL(1)*/;

/** Gets the number of samples of an Opus packet.
  * @param [in] dec <tt>OpusDecoder*</tt>: Decoder state
  * @param [in] packet <tt>char*</tt>: Opus packet
  * @param [in] len <tt>opus_int32</tt>: Length of packet
  * @returns Number of samples
  * @retval OPUS_BAD_ARG Insufficient data was passed to the function
  * @retval OPUS_INVALID_PACKET The compressed data passed is corrupted or of an unsupported type
  */
int opus_decoder_get_nb_samples (const(OpusDecoder)* dec, const(ubyte)* packet, opus_int32 len) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(2)*/;

/** Applies soft-clipping to bring a float signal within the [-1,1] range. If
  * the signal is already in that range, nothing is done. If there are values
  * outside of [-1,1], then the signal is clipped as smoothly as possible to
  * both fit in the range and avoid creating excessive distortion in the
  * process.
  * @param [in,out] pcm <tt>float*</tt>: Input PCM and modified PCM
  * @param [in] frame_size <tt>int</tt> Number of samples per channel to process
  * @param [in] channels <tt>int</tt>: Number of channels
  * @param [in,out] softclip_mem <tt>float*</tt>: State memory for the soft clipping process (one float per channel, initialized to zero)
  */
void opus_pcm_soft_clip (float* pcm, int frame_size, int channels, float* softclip_mem);


/**@}*/

/** @defgroup opus_repacketizer Repacketizer
  * @{
  *
  * The repacketizer can be used to merge multiple Opus packets into a single
  * packet or alternatively to split Opus packets that have previously been
  * merged. Splitting valid Opus packets is always guaranteed to succeed,
  * whereas merging valid packets only succeeds if all frames have the same
  * mode, bandwidth, and frame size, and when the total duration of the merged
  * packet is no more than 120 ms. The 120 ms limit comes from the
  * specification and limits decoder memory requirements at a point where
  * framing overhead becomes negligible.
  *
  * The repacketizer currently only operates on elementary Opus
  * streams. It will not manipualte multistream packets successfully, except in
  * the degenerate case where they consist of data from a single stream.
  *
  * The repacketizing process starts with creating a repacketizer state, either
  * by calling opus_repacketizer_create() or by allocating the memory yourself,
  * e.g.,
  * @code
  * OpusRepacketizer *rp;
  * rp = (OpusRepacketizer*)malloc(opus_repacketizer_get_size());
  * if (rp != NULL)
  *     opus_repacketizer_init(rp);
  * @endcode
  *
  * Then the application should submit packets with opus_repacketizer_cat(),
  * extract new packets with opus_repacketizer_out() or
  * opus_repacketizer_out_range(), and then reset the state for the next set of
  * input packets via opus_repacketizer_init().
  *
  * For example, to split a sequence of packets into individual frames:
  * @code
  * ubyte *data;
  * int len;
  * while (get_next_packet(&data, &len))
  * {
  *   ubyte out[1276];
  *   opus_int32 out_len;
  *   int nb_frames;
  *   int err;
  *   int i;
  *   err = opus_repacketizer_cat(rp, data, len);
  *   if (err != OPUS_OK)
  *   {
  *     release_packet(data);
  *     return err;
  *   }
  *   nb_frames = opus_repacketizer_get_nb_frames(rp);
  *   for (i = 0; i < nb_frames; i++)
  *   {
  *     out_len = opus_repacketizer_out_range(rp, i, i+1, out, sizeof(out));
  *     if (out_len < 0)
  *     {
  *        release_packet(data);
  *        return (int)out_len;
  *     }
  *     output_next_packet(out, out_len);
  *   }
  *   opus_repacketizer_init(rp);
  *   release_packet(data);
  * }
  * @endcode
  *
  * Alternatively, to combine a sequence of frames into packets that each
  * contain up to <code>TARGET_DURATION_MS</code> milliseconds of data:
  * @code
  * // The maximum number of packets with duration TARGET_DURATION_MS occurs
  * // when the frame size is 2.5 ms, for a total of (TARGET_DURATION_MS*2/5)
  * // packets.
  * ubyte *data[(TARGET_DURATION_MS*2/5)+1];
  * opus_int32 len[(TARGET_DURATION_MS*2/5)+1];
  * int nb_packets;
  * ubyte out[1277*(TARGET_DURATION_MS*2/2)];
  * opus_int32 out_len;
  * int prev_toc;
  * nb_packets = 0;
  * while (get_next_packet(data+nb_packets, len+nb_packets))
  * {
  *   int nb_frames;
  *   int err;
  *   nb_frames = opus_packet_get_nb_frames(data[nb_packets], len[nb_packets]);
  *   if (nb_frames < 1)
  *   {
  *     release_packets(data, nb_packets+1);
  *     return nb_frames;
  *   }
  *   nb_frames += opus_repacketizer_get_nb_frames(rp);
  *   // If adding the next packet would exceed our target, or it has an
  *   // incompatible TOC sequence, output the packets we already have before
  *   // submitting it.
  *   // N.B., The nb_packets > 0 check ensures we've submitted at least one
  *   // packet since the last call to opus_repacketizer_init(). Otherwise a
  *   // single packet longer than TARGET_DURATION_MS would cause us to try to
  *   // output an (invalid) empty packet. It also ensures that prev_toc has
  *   // been set to a valid value. Additionally, len[nb_packets] > 0 is
  *   // guaranteed by the call to opus_packet_get_nb_frames() above, so the
  *   // reference to data[nb_packets][0] should be valid.
  *   if (nb_packets > 0 && (
  *       ((prev_toc & 0xFC) != (data[nb_packets][0] & 0xFC)) ||
  *       opus_packet_get_samples_per_frame(data[nb_packets], 48000)*nb_frames >
  *       TARGET_DURATION_MS*48))
  *   {
  *     out_len = opus_repacketizer_out(rp, out, sizeof(out));
  *     if (out_len < 0)
  *     {
  *        release_packets(data, nb_packets+1);
  *        return (int)out_len;
  *     }
  *     output_next_packet(out, out_len);
  *     opus_repacketizer_init(rp);
  *     release_packets(data, nb_packets);
  *     data[0] = data[nb_packets];
  *     len[0] = len[nb_packets];
  *     nb_packets = 0;
  *   }
  *   err = opus_repacketizer_cat(rp, data[nb_packets], len[nb_packets]);
  *   if (err != OPUS_OK)
  *   {
  *     release_packets(data, nb_packets+1);
  *     return err;
  *   }
  *   prev_toc = data[nb_packets][0];
  *   nb_packets++;
  * }
  * // Output the final, partial packet.
  * if (nb_packets > 0)
  * {
  *   out_len = opus_repacketizer_out(rp, out, sizeof(out));
  *   release_packets(data, nb_packets);
  *   if (out_len < 0)
  *     return (int)out_len;
  *   output_next_packet(out, out_len);
  * }
  * @endcode
  *
  * An alternate way of merging packets is to simply call opus_repacketizer_cat()
  * unconditionally until it fails. At that point, the merged packet can be
  * obtained with opus_repacketizer_out() and the input packet for which
  * opus_repacketizer_cat() needs to be re-added to a newly reinitialized
  * repacketizer state.
  */

struct OpusRepacketizer;

/** Gets the size of an <code>OpusRepacketizer</code> structure.
  * @returns The size in bytes.
  */
int opus_repacketizer_get_size ();

/** (Re)initializes a previously allocated repacketizer state.
  * The state must be at least the size returned by opus_repacketizer_get_size().
  * This can be used for applications which use their own allocator instead of
  * malloc().
  * It must also be called to reset the queue of packets waiting to be
  * repacketized, which is necessary if the maximum packet duration of 120 ms
  * is reached or if you wish to submit packets with a different Opus
  * configuration (coding mode, audio bandwidth, frame size, or channel count).
  * Failure to do so will prevent a new packet from being added with
  * opus_repacketizer_cat().
  * @see opus_repacketizer_create
  * @see opus_repacketizer_get_size
  * @see opus_repacketizer_cat
  * @param rp <tt>OpusRepacketizer*</tt>: The repacketizer state to
  *                                       (re)initialize.
  * @returns A pointer to the same repacketizer state that was passed in.
  */
OpusRepacketizer* opus_repacketizer_init (OpusRepacketizer* rp) /*OPUS_ARG_NONNULL(1)*/;

/** Allocates memory and initializes the new repacketizer with
 * opus_repacketizer_init().
  */
OpusRepacketizer* opus_repacketizer_create ();

/** Frees an <code>OpusRepacketizer</code> allocated by
  * opus_repacketizer_create().
  * @param[in] rp <tt>OpusRepacketizer*</tt>: State to be freed.
  */
void opus_repacketizer_destroy (OpusRepacketizer* rp);

/** Add a packet to the current repacketizer state.
  * This packet must match the configuration of any packets already submitted
  * for repacketization since the last call to opus_repacketizer_init().
  * This means that it must have the same coding mode, audio bandwidth, frame
  * size, and channel count.
  * This can be checked in advance by examining the top 6 bits of the first
  * byte of the packet, and ensuring they match the top 6 bits of the first
  * byte of any previously submitted packet.
  * The total duration of audio in the repacketizer state also must not exceed
  * 120 ms, the maximum duration of a single packet, after adding this packet.
  *
  * The contents of the current repacketizer state can be extracted into new
  * packets using opus_repacketizer_out() or opus_repacketizer_out_range().
  *
  * In order to add a packet with a different configuration or to add more
  * audio beyond 120 ms, you must clear the repacketizer state by calling
  * opus_repacketizer_init().
  * If a packet is too large to add to the current repacketizer state, no part
  * of it is added, even if it contains multiple frames, some of which might
  * fit.
  * If you wish to be able to add parts of such packets, you should first use
  * another repacketizer to split the packet into pieces and add them
  * individually.
  * @see opus_repacketizer_out_range
  * @see opus_repacketizer_out
  * @see opus_repacketizer_init
  * @param rp <tt>OpusRepacketizer*</tt>: The repacketizer state to which to
  *                                       add the packet.
  * @param[in] data <tt>const ubyte*</tt>: The packet data.
  *                                                The application must ensure
  *                                                this pointer remains valid
  *                                                until the next call to
  *                                                opus_repacketizer_init() or
  *                                                opus_repacketizer_destroy().
  * @param len <tt>opus_int32</tt>: The number of bytes in the packet data.
  * @returns An error code indicating whether or not the operation succeeded.
  * @retval #OPUS_OK The packet's contents have been added to the repacketizer
  *                  state.
  * @retval #OPUS_INVALID_PACKET The packet did not have a valid TOC sequence,
  *                              the packet's TOC sequence was not compatible
  *                              with previously submitted packets (because
  *                              the coding mode, audio bandwidth, frame size,
  *                              or channel count did not match), or adding
  *                              this packet would increase the total amount of
  *                              audio stored in the repacketizer state to more
  *                              than 120 ms.
  */
int opus_repacketizer_cat (OpusRepacketizer* rp, const(ubyte)* data, opus_int32 len) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(2)*/;


/** Construct a new packet from data previously submitted to the repacketizer
  * state via opus_repacketizer_cat().
  * @param rp <tt>OpusRepacketizer*</tt>: The repacketizer state from which to
  *                                       construct the new packet.
  * @param begin <tt>int</tt>: The index of the first frame in the current
  *                            repacketizer state to include in the output.
  * @param end <tt>int</tt>: One past the index of the last frame in the
  *                          current repacketizer state to include in the
  *                          output.
  * @param[out] data <tt>const ubyte*</tt>: The buffer in which to
  *                                                 store the output packet.
  * @param maxlen <tt>opus_int32</tt>: The maximum number of bytes to store in
  *                                    the output buffer. In order to guarantee
  *                                    success, this should be at least
  *                                    <code>1276</code> for a single frame,
  *                                    or for multiple frames,
  *                                    <code>1277*(end-begin)</code>.
  *                                    However, <code>1*(end-begin)</code> plus
  *                                    the size of all packet data submitted to
  *                                    the repacketizer since the last call to
  *                                    opus_repacketizer_init() or
  *                                    opus_repacketizer_create() is also
  *                                    sufficient, and possibly much smaller.
  * @returns The total size of the output packet on success, or an error code
  *          on failure.
  * @retval #OPUS_BAD_ARG <code>[begin,end)</code> was an invalid range of
  *                       frames (begin < 0, begin >= end, or end >
  *                       opus_repacketizer_get_nb_frames()).
  * @retval #OPUS_BUFFER_TOO_SMALL \a maxlen was insufficient to contain the
  *                                complete output packet.
  */
opus_int32 opus_repacketizer_out_range (OpusRepacketizer* rp, int begin, int end, ubyte* data, opus_int32 maxlen) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Return the total number of frames contained in packet data submitted to
  * the repacketizer state so far via opus_repacketizer_cat() since the last
  * call to opus_repacketizer_init() or opus_repacketizer_create().
  * This defines the valid range of packets that can be extracted with
  * opus_repacketizer_out_range() or opus_repacketizer_out().
  * @param rp <tt>OpusRepacketizer*</tt>: The repacketizer state containing the
  *                                       frames.
  * @returns The total number of frames contained in the packet data submitted
  *          to the repacketizer state.
  */
int opus_repacketizer_get_nb_frames (OpusRepacketizer* rp) /*OPUS_ARG_NONNULL(1)*/;

/** Construct a new packet from data previously submitted to the repacketizer
  * state via opus_repacketizer_cat().
  * This is a convenience routine that returns all the data submitted so far
  * in a single packet.
  * It is equivalent to calling
  * @code
  * opus_repacketizer_out_range(rp, 0, opus_repacketizer_get_nb_frames(rp),
  *                             data, maxlen)
  * @endcode
  * @param rp <tt>OpusRepacketizer*</tt>: The repacketizer state from which to
  *                                       construct the new packet.
  * @param[out] data <tt>const ubyte*</tt>: The buffer in which to
  *                                                 store the output packet.
  * @param maxlen <tt>opus_int32</tt>: The maximum number of bytes to store in
  *                                    the output buffer. In order to guarantee
  *                                    success, this should be at least
  *                                    <code>1277*opus_repacketizer_get_nb_frames(rp)</code>.
  *                                    However,
  *                                    <code>1*opus_repacketizer_get_nb_frames(rp)</code>
  *                                    plus the size of all packet data
  *                                    submitted to the repacketizer since the
  *                                    last call to opus_repacketizer_init() or
  *                                    opus_repacketizer_create() is also
  *                                    sufficient, and possibly much smaller.
  * @returns The total size of the output packet on success, or an error code
  *          on failure.
  * @retval #OPUS_BUFFER_TOO_SMALL \a maxlen was insufficient to contain the
  *                                complete output packet.
  */
opus_int32 opus_repacketizer_out (OpusRepacketizer* rp, ubyte* data, opus_int32 maxlen) /*OPUS_ARG_NONNULL(1)*/;

/** Pads a given Opus packet to a larger size (possibly changing the TOC sequence).
  * @param[in,out] data <tt>const ubyte*</tt>: The buffer containing the
  *                                                   packet to pad.
  * @param len <tt>opus_int32</tt>: The size of the packet.
  *                                 This must be at least 1.
  * @param new_len <tt>opus_int32</tt>: The desired size of the packet after padding.
  *                                 This must be at least as large as len.
  * @returns an error code
  * @retval #OPUS_OK \a on success.
  * @retval #OPUS_BAD_ARG \a len was less than 1 or new_len was less than len.
  * @retval #OPUS_INVALID_PACKET \a data did not contain a valid Opus packet.
  */
int opus_packet_pad (ubyte* data, opus_int32 len, opus_int32 new_len);

/** Remove all padding from a given Opus packet and rewrite the TOC sequence to
  * minimize space usage.
  * @param[in,out] data <tt>const ubyte*</tt>: The buffer containing the
  *                                                   packet to strip.
  * @param len <tt>opus_int32</tt>: The size of the packet.
  *                                 This must be at least 1.
  * @returns The new size of the output packet on success, or an error code
  *          on failure.
  * @retval #OPUS_BAD_ARG \a len was less than 1.
  * @retval #OPUS_INVALID_PACKET \a data did not contain a valid Opus packet.
  */
opus_int32 opus_packet_unpad (ubyte* data, opus_int32 len);

/** Pads a given Opus multi-stream packet to a larger size (possibly changing the TOC sequence).
  * @param[in,out] data <tt>const ubyte*</tt>: The buffer containing the
  *                                                   packet to pad.
  * @param len <tt>opus_int32</tt>: The size of the packet.
  *                                 This must be at least 1.
  * @param new_len <tt>opus_int32</tt>: The desired size of the packet after padding.
  *                                 This must be at least 1.
  * @param nb_streams <tt>opus_int32</tt>: The number of streams (not channels) in the packet.
  *                                 This must be at least as large as len.
  * @returns an error code
  * @retval #OPUS_OK \a on success.
  * @retval #OPUS_BAD_ARG \a len was less than 1.
  * @retval #OPUS_INVALID_PACKET \a data did not contain a valid Opus packet.
  */
int opus_multistream_packet_pad (ubyte* data, opus_int32 len, opus_int32 new_len, int nb_streams);

/** Remove all padding from a given Opus multi-stream packet and rewrite the TOC sequence to
  * minimize space usage.
  * @param[in,out] data <tt>const ubyte*</tt>: The buffer containing the
  *                                                   packet to strip.
  * @param len <tt>opus_int32</tt>: The size of the packet.
  *                                 This must be at least 1.
  * @param nb_streams <tt>opus_int32</tt>: The number of streams (not channels) in the packet.
  *                                 This must be at least 1.
  * @returns The new size of the output packet on success, or an error code
  *          on failure.
  * @retval #OPUS_BAD_ARG \a len was less than 1 or new_len was less than len.
  * @retval #OPUS_INVALID_PACKET \a data did not contain a valid Opus packet.
  */
opus_int32 opus_multistream_packet_unpad (ubyte* data, opus_int32 len, int nb_streams);

/**@}*/


/**
 * @file opus_multistream.h
 * @brief Opus reference implementation multistream API
 */


/** These are the actual encoder and decoder CTL ID numbers.
  * They should not be used directly by applications.
  * In general, SETs should be even and GETs should be odd.*/
/**@{*/
enum OPUS_MULTISTREAM_GET_ENCODER_STATE_REQUEST = 5120;
enum OPUS_MULTISTREAM_GET_DECODER_STATE_REQUEST = 5122;
/**@}*/

/** @endcond */

/** @defgroup opus_multistream_ctls Multistream specific encoder and decoder CTLs
  *
  * These are convenience macros that are specific to the
  * opus_multistream_encoder_ctl() and opus_multistream_decoder_ctl()
  * interface.
  * The CTLs from @ref opus_genericctls, @ref opus_encoderctls, and
  * @ref opus_decoderctls may be applied to a multistream encoder or decoder as
  * well.
  * In addition, you may retrieve the encoder or decoder state for an specific
  * stream via #OPUS_MULTISTREAM_GET_ENCODER_STATE or
  * #OPUS_MULTISTREAM_GET_DECODER_STATE and apply CTLs to it individually.
  */
/**@{*/

/+TODO
/** Gets the encoder state for an individual stream of a multistream encoder.
  * @param[in] x <tt>opus_int32</tt>: The index of the stream whose encoder you
  *                                   wish to retrieve.
  *                                   This must be non-negative and less than
  *                                   the <code>streams</code> parameter used
  *                                   to initialize the encoder.
  * @param[out] y <tt>OpusEncoder**</tt>: Returns a pointer to the given
  *                                       encoder state.
  * @retval OPUS_BAD_ARG The index of the requested stream was out of range.
  * @hideinitializer
  */
#define OPUS_MULTISTREAM_GET_ENCODER_STATE(x,y) OPUS_MULTISTREAM_GET_ENCODER_STATE_REQUEST, __opus_check_int(x), __opus_check_encstate_ptr(y)

/** Gets the decoder state for an individual stream of a multistream decoder.
  * @param[in] x <tt>opus_int32</tt>: The index of the stream whose decoder you
  *                                   wish to retrieve.
  *                                   This must be non-negative and less than
  *                                   the <code>streams</code> parameter used
  *                                   to initialize the decoder.
  * @param[out] y <tt>OpusDecoder**</tt>: Returns a pointer to the given
  *                                       decoder state.
  * @retval OPUS_BAD_ARG The index of the requested stream was out of range.
  * @hideinitializer
  */
#define OPUS_MULTISTREAM_GET_DECODER_STATE(x,y) OPUS_MULTISTREAM_GET_DECODER_STATE_REQUEST, __opus_check_int(x), __opus_check_decstate_ptr(y)
+/
/**@}*/

/** @defgroup opus_multistream Opus Multistream API
  * @{
  *
  * The multistream API allows individual Opus streams to be combined into a
  * single packet, enabling support for up to 255 channels. Unlike an
  * elementary Opus stream, the encoder and decoder must negotiate the channel
  * configuration before the decoder can successfully interpret the data in the
  * packets produced by the encoder. Some basic information, such as packet
  * duration, can be computed without any special negotiation.
  *
  * The format for multistream Opus packets is defined in
  * <a href="https://tools.ietf.org/html/rfc7845">RFC 7845</a>
  * and is based on the self-delimited Opus framing described in Appendix B of
  * <a href="https://tools.ietf.org/html/rfc6716">RFC 6716</a>.
  * Normal Opus packets are just a degenerate case of multistream Opus packets,
  * and can be encoded or decoded with the multistream API by setting
  * <code>streams</code> to <code>1</code> when initializing the encoder or
  * decoder.
  *
  * Multistream Opus streams can contain up to 255 elementary Opus streams.
  * These may be either "uncoupled" or "coupled", indicating that the decoder
  * is configured to decode them to either 1 or 2 channels, respectively.
  * The streams are ordered so that all coupled streams appear at the
  * beginning.
  *
  * A <code>mapping</code> table defines which decoded channel <code>i</code>
  * should be used for each input/output (I/O) channel <code>j</code>. This table is
  * typically provided as an ubyte array.
  * Let <code>i = mapping[j]</code> be the index for I/O channel <code>j</code>.
  * If <code>i < 2*coupled_streams</code>, then I/O channel <code>j</code> is
  * encoded as the left channel of stream <code>(i/2)</code> if <code>i</code>
  * is even, or  as the right channel of stream <code>(i/2)</code> if
  * <code>i</code> is odd. Otherwise, I/O channel <code>j</code> is encoded as
  * mono in stream <code>(i - coupled_streams)</code>, unless it has the special
  * value 255, in which case it is omitted from the encoding entirely (the
  * decoder will reproduce it as silence). Each value <code>i</code> must either
  * be the special value 255 or be less than <code>streams + coupled_streams</code>.
  *
  * The output channels specified by the encoder
  * should use the
  * <a href="https://www.xiph.org/vorbis/doc/Vorbis_I_spec.html#x1-810004.3.9">Vorbis
  * channel ordering</a>. A decoder may wish to apply an additional permutation
  * to the mapping the encoder used to achieve a different output channel
  * order (e.g. for outputing in WAV order).
  *
  * Each multistream packet contains an Opus packet for each stream, and all of
  * the Opus packets in a single multistream packet must have the same
  * duration. Therefore the duration of a multistream packet can be extracted
  * from the TOC sequence of the first stream, which is located at the
  * beginning of the packet, just like an elementary Opus stream:
  *
  * @code
  * int nb_samples;
  * int nb_frames;
  * nb_frames = opus_packet_get_nb_frames(data, len);
  * if (nb_frames < 1)
  *   return nb_frames;
  * nb_samples = opus_packet_get_samples_per_frame(data, 48000) * nb_frames;
  * @endcode
  *
  * The general encoding and decoding process proceeds exactly the same as in
  * the normal @ref opus_encoder and @ref opus_decoder APIs.
  * See their documentation for an overview of how to use the corresponding
  * multistream functions.
  */

/** Opus multistream encoder state.
  * This contains the complete state of a multistream Opus encoder.
  * It is position independent and can be freely copied.
  * @see opus_multistream_encoder_create
  * @see opus_multistream_encoder_init
  */
struct OpusMSEncoder;

/** Opus multistream decoder state.
  * This contains the complete state of a multistream Opus decoder.
  * It is position independent and can be freely copied.
  * @see opus_multistream_decoder_create
  * @see opus_multistream_decoder_init
  */
struct OpusMSDecoder;

/**\name Multistream encoder functions */
/**@{*/

/** Gets the size of an OpusMSEncoder structure.
  * @param streams <tt>int</tt>: The total number of streams to encode from the
  *                              input.
  *                              This must be no more than 255.
  * @param coupled_streams <tt>int</tt>: Number of coupled (2 channel) streams
  *                                      to encode.
  *                                      This must be no larger than the total
  *                                      number of streams.
  *                                      Additionally, The total number of
  *                                      encoded channels (<code>streams +
  *                                      coupled_streams</code>) must be no
  *                                      more than 255.
  * @returns The size in bytes on success, or a negative error code
  *          (see @ref opus_errorcodes) on error.
  */
opus_int32 opus_multistream_encoder_get_size(
  int streams,
  int coupled_streams
);

opus_int32 opus_multistream_surround_encoder_get_size(
  int channels,
  int mapping_family
);


/** Allocates and initializes a multistream encoder state.
  * Call opus_multistream_encoder_destroy() to release
  * this object when finished.
  * @param Fs <tt>opus_int32</tt>: Sampling rate of the input signal (in Hz).
  *                                This must be one of 8000, 12000, 16000,
  *                                24000, or 48000.
  * @param channels <tt>int</tt>: Number of channels in the input signal.
  *                               This must be at most 255.
  *                               It may be greater than the number of
  *                               coded channels (<code>streams +
  *                               coupled_streams</code>).
  * @param streams <tt>int</tt>: The total number of streams to encode from the
  *                              input.
  *                              This must be no more than the number of channels.
  * @param coupled_streams <tt>int</tt>: Number of coupled (2 channel) streams
  *                                      to encode.
  *                                      This must be no larger than the total
  *                                      number of streams.
  *                                      Additionally, The total number of
  *                                      encoded channels (<code>streams +
  *                                      coupled_streams</code>) must be no
  *                                      more than the number of input channels.
  * @param[in] mapping <code>const ubyte[channels]</code>: Mapping from
  *                    encoded channels to input channels, as described in
  *                    @ref opus_multistream. As an extra constraint, the
  *                    multistream encoder does not allow encoding coupled
  *                    streams for which one channel is unused since this
  *                    is never a good idea.
  * @param application <tt>int</tt>: The target encoder application.
  *                                  This must be one of the following:
  * <dl>
  * <dt>#OPUS_APPLICATION_VOIP</dt>
  * <dd>Process signal for improved speech intelligibility.</dd>
  * <dt>#OPUS_APPLICATION_AUDIO</dt>
  * <dd>Favor faithfulness to the original input.</dd>
  * <dt>#OPUS_APPLICATION_RESTRICTED_LOWDELAY</dt>
  * <dd>Configure the minimum possible coding delay by disabling certain modes
  * of operation.</dd>
  * </dl>
  * @param[out] error <tt>int *</tt>: Returns #OPUS_OK on success, or an error
  *                                   code (see @ref opus_errorcodes) on
  *                                   failure.
  */
OpusMSEncoder* opus_multistream_encoder_create(
  opus_int32 Fs,
  int channels,
  int streams,
  int coupled_streams,
  const(ubyte)* mapping,
  int application,
  int* error
) /*OPUS_ARG_NONNULL(5)*/;

OpusMSEncoder* opus_multistream_surround_encoder_create(
  opus_int32 Fs,
  int channels,
  int mapping_family,
  int* streams,
  int* coupled_streams,
  ubyte* mapping,
  int application,
  int* error
) /*OPUS_ARG_NONNULL(5)*/;

/** Initialize a previously allocated multistream encoder state.
  * The memory pointed to by \a st must be at least the size returned by
  * opus_multistream_encoder_get_size().
  * This is intended for applications which use their own allocator instead of
  * malloc.
  * To reset a previously initialized state, use the #OPUS_RESET_STATE CTL.
  * @see opus_multistream_encoder_create
  * @see opus_multistream_encoder_get_size
  * @param st <tt>OpusMSEncoder*</tt>: Multistream encoder state to initialize.
  * @param Fs <tt>opus_int32</tt>: Sampling rate of the input signal (in Hz).
  *                                This must be one of 8000, 12000, 16000,
  *                                24000, or 48000.
  * @param channels <tt>int</tt>: Number of channels in the input signal.
  *                               This must be at most 255.
  *                               It may be greater than the number of
  *                               coded channels (<code>streams +
  *                               coupled_streams</code>).
  * @param streams <tt>int</tt>: The total number of streams to encode from the
  *                              input.
  *                              This must be no more than the number of channels.
  * @param coupled_streams <tt>int</tt>: Number of coupled (2 channel) streams
  *                                      to encode.
  *                                      This must be no larger than the total
  *                                      number of streams.
  *                                      Additionally, The total number of
  *                                      encoded channels (<code>streams +
  *                                      coupled_streams</code>) must be no
  *                                      more than the number of input channels.
  * @param[in] mapping <code>const ubyte[channels]</code>: Mapping from
  *                    encoded channels to input channels, as described in
  *                    @ref opus_multistream. As an extra constraint, the
  *                    multistream encoder does not allow encoding coupled
  *                    streams for which one channel is unused since this
  *                    is never a good idea.
  * @param application <tt>int</tt>: The target encoder application.
  *                                  This must be one of the following:
  * <dl>
  * <dt>#OPUS_APPLICATION_VOIP</dt>
  * <dd>Process signal for improved speech intelligibility.</dd>
  * <dt>#OPUS_APPLICATION_AUDIO</dt>
  * <dd>Favor faithfulness to the original input.</dd>
  * <dt>#OPUS_APPLICATION_RESTRICTED_LOWDELAY</dt>
  * <dd>Configure the minimum possible coding delay by disabling certain modes
  * of operation.</dd>
  * </dl>
  * @returns #OPUS_OK on success, or an error code (see @ref opus_errorcodes)
  *          on failure.
  */
int opus_multistream_encoder_init(
  OpusMSEncoder* st,
  opus_int32 Fs,
  int channels,
  int streams,
  int coupled_streams,
  const(ubyte)* mapping,
  int application
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(6)*/;

int opus_multistream_surround_encoder_init(
  OpusMSEncoder* st,
  opus_int32 Fs,
  int channels,
  int mapping_family,
  int* streams,
  int* coupled_streams,
  ubyte* mapping,
  int application
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(6)*/;

/** Encodes a multistream Opus frame.
  * @param st <tt>OpusMSEncoder*</tt>: Multistream encoder state.
  * @param[in] pcm <tt>const opus_int16*</tt>: The input signal as interleaved
  *                                            samples.
  *                                            This must contain
  *                                            <code>frame_size*channels</code>
  *                                            samples.
  * @param frame_size <tt>int</tt>: Number of samples per channel in the input
  *                                 signal.
  *                                 This must be an Opus frame size for the
  *                                 encoder's sampling rate.
  *                                 For example, at 48 kHz the permitted values
  *                                 are 120, 240, 480, 960, 1920, and 2880.
  *                                 Passing in a duration of less than 10 ms
  *                                 (480 samples at 48 kHz) will prevent the
  *                                 encoder from using the LPC or hybrid modes.
  * @param[out] data <tt>ubyte*</tt>: Output payload.
  *                                           This must contain storage for at
  *                                           least \a max_data_bytes.
  * @param [in] max_data_bytes <tt>opus_int32</tt>: Size of the allocated
  *                                                 memory for the output
  *                                                 payload. This may be
  *                                                 used to impose an upper limit on
  *                                                 the instant bitrate, but should
  *                                                 not be used as the only bitrate
  *                                                 control. Use #OPUS_SET_BITRATE to
  *                                                 control the bitrate.
  * @returns The length of the encoded packet (in bytes) on success or a
  *          negative error code (see @ref opus_errorcodes) on failure.
  */
int opus_multistream_encode(
  OpusMSEncoder* st,
  const(opus_int16)* pcm,
  int frame_size,
  ubyte* data,
  opus_int32 max_data_bytes
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(2)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Encodes a multistream Opus frame from floating point input.
  * @param st <tt>OpusMSEncoder*</tt>: Multistream encoder state.
  * @param[in] pcm <tt>const float*</tt>: The input signal as interleaved
  *                                       samples with a normal range of
  *                                       +/-1.0.
  *                                       Samples with a range beyond +/-1.0
  *                                       are supported but will be clipped by
  *                                       decoders using the integer API and
  *                                       should only be used if it is known
  *                                       that the far end supports extended
  *                                       dynamic range.
  *                                       This must contain
  *                                       <code>frame_size*channels</code>
  *                                       samples.
  * @param frame_size <tt>int</tt>: Number of samples per channel in the input
  *                                 signal.
  *                                 This must be an Opus frame size for the
  *                                 encoder's sampling rate.
  *                                 For example, at 48 kHz the permitted values
  *                                 are 120, 240, 480, 960, 1920, and 2880.
  *                                 Passing in a duration of less than 10 ms
  *                                 (480 samples at 48 kHz) will prevent the
  *                                 encoder from using the LPC or hybrid modes.
  * @param[out] data <tt>ubyte*</tt>: Output payload.
  *                                           This must contain storage for at
  *                                           least \a max_data_bytes.
  * @param [in] max_data_bytes <tt>opus_int32</tt>: Size of the allocated
  *                                                 memory for the output
  *                                                 payload. This may be
  *                                                 used to impose an upper limit on
  *                                                 the instant bitrate, but should
  *                                                 not be used as the only bitrate
  *                                                 control. Use #OPUS_SET_BITRATE to
  *                                                 control the bitrate.
  * @returns The length of the encoded packet (in bytes) on success or a
  *          negative error code (see @ref opus_errorcodes) on failure.
  */
int opus_multistream_encode_float(
  OpusMSEncoder* st,
  const(float)* pcm,
  int frame_size,
  ubyte* data,
  opus_int32 max_data_bytes
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(2)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Frees an <code>OpusMSEncoder</code> allocated by
  * opus_multistream_encoder_create().
  * @param st <tt>OpusMSEncoder*</tt>: Multistream encoder state to be freed.
  */
void opus_multistream_encoder_destroy (OpusMSEncoder* st);

/** Perform a CTL function on a multistream Opus encoder.
  *
  * Generally the request and subsequent arguments are generated by a
  * convenience macro.
  * @param st <tt>OpusMSEncoder*</tt>: Multistream encoder state.
  * @param request This and all remaining parameters should be replaced by one
  *                of the convenience macros in @ref opus_genericctls,
  *                @ref opus_encoderctls, or @ref opus_multistream_ctls.
  * @see opus_genericctls
  * @see opus_encoderctls
  * @see opus_multistream_ctls
  */
int opus_multistream_encoder_ctl (OpusMSEncoder* st, int request, ...) /*OPUS_ARG_NONNULL(1)*/;

/**@}*/

/**\name Multistream decoder functions */
/**@{*/

/** Gets the size of an <code>OpusMSDecoder</code> structure.
  * @param streams <tt>int</tt>: The total number of streams coded in the
  *                              input.
  *                              This must be no more than 255.
  * @param coupled_streams <tt>int</tt>: Number streams to decode as coupled
  *                                      (2 channel) streams.
  *                                      This must be no larger than the total
  *                                      number of streams.
  *                                      Additionally, The total number of
  *                                      coded channels (<code>streams +
  *                                      coupled_streams</code>) must be no
  *                                      more than 255.
  * @returns The size in bytes on success, or a negative error code
  *          (see @ref opus_errorcodes) on error.
  */
opus_int32 opus_multistream_decoder_get_size(
  int streams,
  int coupled_streams
);

/** Allocates and initializes a multistream decoder state.
  * Call opus_multistream_decoder_destroy() to release
  * this object when finished.
  * @param Fs <tt>opus_int32</tt>: Sampling rate to decode at (in Hz).
  *                                This must be one of 8000, 12000, 16000,
  *                                24000, or 48000.
  * @param channels <tt>int</tt>: Number of channels to output.
  *                               This must be at most 255.
  *                               It may be different from the number of coded
  *                               channels (<code>streams +
  *                               coupled_streams</code>).
  * @param streams <tt>int</tt>: The total number of streams coded in the
  *                              input.
  *                              This must be no more than 255.
  * @param coupled_streams <tt>int</tt>: Number of streams to decode as coupled
  *                                      (2 channel) streams.
  *                                      This must be no larger than the total
  *                                      number of streams.
  *                                      Additionally, The total number of
  *                                      coded channels (<code>streams +
  *                                      coupled_streams</code>) must be no
  *                                      more than 255.
  * @param[in] mapping <code>const ubyte[channels]</code>: Mapping from
  *                    coded channels to output channels, as described in
  *                    @ref opus_multistream.
  * @param[out] error <tt>int *</tt>: Returns #OPUS_OK on success, or an error
  *                                   code (see @ref opus_errorcodes) on
  *                                   failure.
  */
OpusMSDecoder* opus_multistream_decoder_create(
  opus_int32 Fs,
  int channels,
  int streams,
  int coupled_streams,
  const(ubyte)* mapping,
  int* error
) /*OPUS_ARG_NONNULL(5)*/;

/** Intialize a previously allocated decoder state object.
  * The memory pointed to by \a st must be at least the size returned by
  * opus_multistream_encoder_get_size().
  * This is intended for applications which use their own allocator instead of
  * malloc.
  * To reset a previously initialized state, use the #OPUS_RESET_STATE CTL.
  * @see opus_multistream_decoder_create
  * @see opus_multistream_deocder_get_size
  * @param st <tt>OpusMSEncoder*</tt>: Multistream encoder state to initialize.
  * @param Fs <tt>opus_int32</tt>: Sampling rate to decode at (in Hz).
  *                                This must be one of 8000, 12000, 16000,
  *                                24000, or 48000.
  * @param channels <tt>int</tt>: Number of channels to output.
  *                               This must be at most 255.
  *                               It may be different from the number of coded
  *                               channels (<code>streams +
  *                               coupled_streams</code>).
  * @param streams <tt>int</tt>: The total number of streams coded in the
  *                              input.
  *                              This must be no more than 255.
  * @param coupled_streams <tt>int</tt>: Number of streams to decode as coupled
  *                                      (2 channel) streams.
  *                                      This must be no larger than the total
  *                                      number of streams.
  *                                      Additionally, The total number of
  *                                      coded channels (<code>streams +
  *                                      coupled_streams</code>) must be no
  *                                      more than 255.
  * @param[in] mapping <code>const ubyte[channels]</code>: Mapping from
  *                    coded channels to output channels, as described in
  *                    @ref opus_multistream.
  * @returns #OPUS_OK on success, or an error code (see @ref opus_errorcodes)
  *          on failure.
  */
int opus_multistream_decoder_init(
  OpusMSDecoder* st,
  opus_int32 Fs,
  int channels,
  int streams,
  int coupled_streams,
  const(ubyte)* mapping
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(6)*/;

/** Decode a multistream Opus packet.
  * @param st <tt>OpusMSDecoder*</tt>: Multistream decoder state.
  * @param[in] data <tt>const ubyte*</tt>: Input payload.
  *                                                Use a <code>NULL</code>
  *                                                pointer to indicate packet
  *                                                loss.
  * @param len <tt>opus_int32</tt>: Number of bytes in payload.
  * @param[out] pcm <tt>opus_int16*</tt>: Output signal, with interleaved
  *                                       samples.
  *                                       This must contain room for
  *                                       <code>frame_size*channels</code>
  *                                       samples.
  * @param frame_size <tt>int</tt>: The number of samples per channel of
  *                                 available space in \a pcm.
  *                                 If this is less than the maximum packet duration
  *                                 (120 ms; 5760 for 48kHz), this function will not be capable
  *                                 of decoding some packets. In the case of PLC (data==NULL)
  *                                 or FEC (decode_fec=1), then frame_size needs to be exactly
  *                                 the duration of audio that is missing, otherwise the
  *                                 decoder will not be in the optimal state to decode the
  *                                 next incoming packet. For the PLC and FEC cases, frame_size
  *                                 <b>must</b> be a multiple of 2.5 ms.
  * @param decode_fec <tt>int</tt>: Flag (0 or 1) to request that any in-band
  *                                 forward error correction data be decoded.
  *                                 If no such data is available, the frame is
  *                                 decoded as if it were lost.
  * @returns Number of samples decoded on success or a negative error code
  *          (see @ref opus_errorcodes) on failure.
  */
int opus_multistream_decode(
  OpusMSDecoder* st,
  const(ubyte)* data,
  opus_int32 len,
  opus_int16* pcm,
  int frame_size,
  int decode_fec
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Decode a multistream Opus packet with floating point output.
  * @param st <tt>OpusMSDecoder*</tt>: Multistream decoder state.
  * @param[in] data <tt>const ubyte*</tt>: Input payload.
  *                                                Use a <code>NULL</code>
  *                                                pointer to indicate packet
  *                                                loss.
  * @param len <tt>opus_int32</tt>: Number of bytes in payload.
  * @param[out] pcm <tt>opus_int16*</tt>: Output signal, with interleaved
  *                                       samples.
  *                                       This must contain room for
  *                                       <code>frame_size*channels</code>
  *                                       samples.
  * @param frame_size <tt>int</tt>: The number of samples per channel of
  *                                 available space in \a pcm.
  *                                 If this is less than the maximum packet duration
  *                                 (120 ms; 5760 for 48kHz), this function will not be capable
  *                                 of decoding some packets. In the case of PLC (data==NULL)
  *                                 or FEC (decode_fec=1), then frame_size needs to be exactly
  *                                 the duration of audio that is missing, otherwise the
  *                                 decoder will not be in the optimal state to decode the
  *                                 next incoming packet. For the PLC and FEC cases, frame_size
  *                                 <b>must</b> be a multiple of 2.5 ms.
  * @param decode_fec <tt>int</tt>: Flag (0 or 1) to request that any in-band
  *                                 forward error correction data be decoded.
  *                                 If no such data is available, the frame is
  *                                 decoded as if it were lost.
  * @returns Number of samples decoded on success or a negative error code
  *          (see @ref opus_errorcodes) on failure.
  */
int opus_multistream_decode_float(
  OpusMSDecoder* st,
  const(ubyte)* data,
  opus_int32 len,
  float* pcm,
  int frame_size,
  int decode_fec
) /*OPUS_ARG_NONNULL(1)*/ /*OPUS_ARG_NONNULL(4)*/;

/** Perform a CTL function on a multistream Opus decoder.
  *
  * Generally the request and subsequent arguments are generated by a
  * convenience macro.
  * @param st <tt>OpusMSDecoder*</tt>: Multistream decoder state.
  * @param request This and all remaining parameters should be replaced by one
  *                of the convenience macros in @ref opus_genericctls,
  *                @ref opus_decoderctls, or @ref opus_multistream_ctls.
  * @see opus_genericctls
  * @see opus_decoderctls
  * @see opus_multistream_ctls
  */
int opus_multistream_decoder_ctl (OpusMSDecoder* st, int request, ...) /*OPUS_ARG_NONNULL(1)*/;

/** Frees an <code>OpusMSDecoder</code> allocated by
  * opus_multistream_decoder_create().
  * @param st <tt>OpusMSDecoder</tt>: Multistream decoder state to be freed.
  */
void opus_multistream_decoder_destroy (OpusMSDecoder* st);

/**@}*/

/**@}*/