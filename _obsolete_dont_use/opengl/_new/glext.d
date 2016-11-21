module c.gl.glext;

/*
 ** License Applicability. Except to the extent portions of this file are
 ** made subject to an alternative license as permitted in the SGI Free
 ** Software License B, Version 1.1 (the "License"), the contents of this
 ** file are subject only to the provisions of the License. You may not use
 ** this file except in compliance with the License. You may obtain a copy
 ** of the License at Silicon Graphics, Inc., attn: Legal Services, 1600
 ** Amphitheatre Parkway, Mountain View, CA 94043-1351, or at:
 **
 ** http://oss.sgi.com/projects/FreeB
 **
 ** Note that, as provided in the License, the Software is distributed on an
 ** "AS IS" basis, with ALL EXPRESS AND IMPLIED WARRANTIES AND CONDITIONS
 ** DISCLAIMED, INCLUDING, WITHOUT LIMITATION, ANY IMPLIED WARRANTIES AND
 ** CONDITIONS OF MERCHANTABILITY, SATISFACTORY QUALITY, FITNESS FOR A
 ** PARTICULAR PURPOSE, AND NON-INFRINGEMENT.
 **
 ** Original Code. The Original Code is: OpenGL Sample Implementation,
 ** Version 1.2.1, released January 26, 2000, developed by Silicon Graphics,
 ** Inc. The Original Code is Copyright (c) 1991-2004 Silicon Graphics, Inc.
 ** Copyright in any portions created by third parties is as indicated
 ** elsewhere herein. All Rights Reserved.
 **
 ** Additional Notice Provisions: This software was created using the
 ** OpenGL(R) version 1.2.1 Sample Implementation published by SGI, but has
 ** not been independently verified as being compliant with the OpenGL(R)
 ** version 1.2.1 Specification.
 */

private import c.gl.gl;
private import std.loader;

/*
 * Constants
 */
/*
 * ARB Extensions
 */
// 1 - GL_ARB_multitexture
const GLuint GL_TEXTURE0_ARB        = 0x84C0;
const GLuint GL_TEXTURE1_ARB        = 0x84C1;
const GLuint GL_TEXTURE2_ARB        = 0x84C2;
const GLuint GL_TEXTURE3_ARB        = 0x84C3;
const GLuint GL_TEXTURE4_ARB        = 0x84C4;
const GLuint GL_TEXTURE5_ARB        = 0x84C5;
const GLuint GL_TEXTURE6_ARB        = 0x84C6;
const GLuint GL_TEXTURE7_ARB        = 0x84C7;
const GLuint GL_TEXTURE8_ARB        = 0x84C8;
const GLuint GL_TEXTURE9_ARB        = 0x84C9;
const GLuint GL_TEXTURE10_ARB       = 0x84CA;
const GLuint GL_TEXTURE11_ARB       = 0x84CB;
const GLuint GL_TEXTURE12_ARB       = 0x84CC;
const GLuint GL_TEXTURE13_ARB       = 0x84CD;
const GLuint GL_TEXTURE14_ARB       = 0x84CE;
const GLuint GL_TEXTURE15_ARB       = 0x84CF;
const GLuint GL_TEXTURE16_ARB       = 0x84D0;
const GLuint GL_TEXTURE17_ARB       = 0x84D1;
const GLuint GL_TEXTURE18_ARB       = 0x84D2;
const GLuint GL_TEXTURE19_ARB       = 0x84D3;
const GLuint GL_TEXTURE20_ARB       = 0x84D4;
const GLuint GL_TEXTURE21_ARB       = 0x84D5;
const GLuint GL_TEXTURE22_ARB       = 0x84D6;
const GLuint GL_TEXTURE23_ARB       = 0x84D7;
const GLuint GL_TEXTURE24_ARB       = 0x84D8;
const GLuint GL_TEXTURE25_ARB       = 0x84D9;
const GLuint GL_TEXTURE26_ARB       = 0x84DA;
const GLuint GL_TEXTURE27_ARB       = 0x84DB;
const GLuint GL_TEXTURE28_ARB       = 0x84DC;
const GLuint GL_TEXTURE29_ARB       = 0x84DD;
const GLuint GL_TEXTURE30_ARB       = 0x84DE;
const GLuint GL_TEXTURE31_ARB       = 0x84DF;
const GLuint GL_ACTIVE_TEXTURE_ARB      = 0x84E0;
const GLuint GL_CLIENT_ACTIVE_TEXTURE_ARB   = 0x84E1;
const GLuint GL_MAX_TEXTURE_UNITS_ARB     = 0x84E2;

// 2 - GL_ARB_transpose_matrix
const GLuint GL_TRANSPOSE_MODELVIEW_MATRIX_ARB    = 0x84E3;
const GLuint GL_TRANSPOSE_PROJECTION_MATRIX_ARB   = 0x84E4;
const GLuint GL_TRANSPOSE_TEXTURE_MATRIX_ARB    = 0x84E5;
const GLuint GL_TRANSPOSE_COLOR_MATRIX_ARB    = 0x84E6;

// 5 - GL_ARB_multisample
const GLuint GL_MULTISAMPLE_ARB       = 0x809D;
const GLuint GL_SAMPLE_ALPHA_TO_COVERAGE_ARB    = 0x809E;
const GLuint GL_SAMPLE_ALPHA_TO_ONE_ARB     = 0x809F;
const GLuint GL_SAMPLE_COVERAGE_ARB     = 0x80A0;
const GLuint GL_SAMPLE_BUFFERS_ARB      = 0x80A8;
const GLuint GL_SAMPLES_ARB       = 0x80A9;
const GLuint GL_SAMPLE_COVERAGE_VALUE_ARB   = 0x80AA;
const GLuint GL_SAMPLE_COVERAGE_INVERT_ARB    = 0x80AB;
const GLuint GL_MULTISAMPLE_BIT_ARB     = 0x20000000;

// 7 - GL_ARB_texture_cube_map
const GLuint GL_NORMAL_MAP_ARB        = 0x8511;
const GLuint GL_REFLECTION_MAP_ARB      = 0x8512;
const GLuint GL_TEXTURE_CUBE_MAP_ARB      = 0x8513;
const GLuint GL_TEXTURE_BINDING_CUBE_MAP_ARB    = 0x8514;
const GLuint GL_TEXTURE_CUBE_MAP_POSITIVE_X_ARB   = 0x8515;
const GLuint GL_TEXTURE_CUBE_MAP_NEGATIVE_X_ARB   = 0x8516;
const GLuint GL_TEXTURE_CUBE_MAP_POSITIVE_Y_ARB   = 0x8517;
const GLuint GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_ARB   = 0x8518;
const GLuint GL_TEXTURE_CUBE_MAP_POSITIVE_Z_ARB   = 0x8519;
const GLuint GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_ARB   = 0x851A;
const GLuint GL_PROXY_TEXTURE_CUBE_MAP_ARB    = 0x851B;
const GLuint GL_MAX_CUBE_MAP_TEXTURE_SIZE_ARB   = 0x851C;

// 12 - GL_ARB_texture_compression
const GLuint GL_COMPRESSED_ALPHA_ARB      = 0x84E9;
const GLuint GL_COMPRESSED_LUMINANCE_ARB    = 0x84EA;
const GLuint GL_COMPRESSED_LUMINANCE_ALPHA_ARB    = 0x84EB;
const GLuint GL_COMPRESSED_INTENSITY_ARB    = 0x84EC;
const GLuint GL_COMPRESSED_RGB_ARB      = 0x84ED;
const GLuint GL_COMPRESSED_RGBA_ARB     = 0x84EE;
const GLuint GL_TEXTURE_COMPRESSION_HINT_ARB    = 0x84EF;
const GLuint GL_TEXTURE_COMPRESSED_IMAGE_SIZE_ARB = 0x86A0;
const GLuint GL_TEXTURE_COMPRESSED_ARB      = 0x86A1;
const GLuint GL_NUM_COMPRESSED_TEXTURE_FORMATS_ARB  = 0x86A2;
const GLuint GL_COMPRESSED_TEXTURE_FORMATS_ARB    = 0x86A3;

// 13 - GL_ARB_texture_border_clamp
const GLuint GL_CLAMP_TO_BORDER_ARB     = 0x812D;

// 14 - GL_ARB_point_parameters
const GLuint GL_POINT_SIZE_MIN_ARB      = 0x8126;
const GLuint GL_POINT_SIZE_MAX_ARB      = 0x8127;
const GLuint GL_POINT_FADE_THRESHOLD_SIZE_ARB   = 0x8128;
const GLuint GL_POINT_DISTANCE_ATTENUATION_ARB    = 0x8129;

// 15 - GL_ARB_vertex_blend
const GLuint GL_MAX_VERTEX_UNITS_ARB      = 0x86A4;
const GLuint GL_ACTIVE_VERTEX_UNITS_ARB     = 0x86A5;
const GLuint GL_WEIGHT_SUM_UNITY_ARB      = 0x86A6;
const GLuint GL_VERTEX_BLEND_ARB      = 0x86A7;
const GLuint GL_CURRENT_WEIGHT_ARB      = 0x86A8;
const GLuint GL_WEIGHT_ARRAY_TYPE_ARB     = 0x86A9;
const GLuint GL_WEIGHT_ARRAY_STRIDE_ARB     = 0x86AA;
const GLuint GL_WEIGHT_ARRAY_SIZE_ARB     = 0x86AB;
const GLuint GL_WEIGHT_ARRAY_POINTER_ARB    = 0x86AC;
const GLuint GL_WEIGHT_ARRAY_ARB      = 0x86AD;
const GLuint GL_MODELVIEW0_ARB        = 0x1700;
const GLuint GL_MODELVIEW1_ARB        = 0x850A;
const GLuint GL_MODELVIEW2_ARB        = 0x8722;
const GLuint GL_MODELVIEW3_ARB        = 0x8723;
const GLuint GL_MODELVIEW4_ARB        = 0x8724;
const GLuint GL_MODELVIEW5_ARB        = 0x8725;
const GLuint GL_MODELVIEW6_ARB        = 0x8726;
const GLuint GL_MODELVIEW7_ARB        = 0x8727;
const GLuint GL_MODELVIEW8_ARB        = 0x8728;
const GLuint GL_MODELVIEW9_ARB        = 0x8729;
const GLuint GL_MODELVIEW10_ARB       = 0x872A;
const GLuint GL_MODELVIEW11_ARB       = 0x872B;
const GLuint GL_MODELVIEW12_ARB       = 0x872C;
const GLuint GL_MODELVIEW13_ARB       = 0x872D;
const GLuint GL_MODELVIEW14_ARB       = 0x872E;
const GLuint GL_MODELVIEW15_ARB       = 0x872F;
const GLuint GL_MODELVIEW16_ARB       = 0x8730;
const GLuint GL_MODELVIEW17_ARB       = 0x8731;
const GLuint GL_MODELVIEW18_ARB       = 0x8732;
const GLuint GL_MODELVIEW19_ARB       = 0x8733;
const GLuint GL_MODELVIEW20_ARB       = 0x8734;
const GLuint GL_MODELVIEW21_ARB       = 0x8735;
const GLuint GL_MODELVIEW22_ARB       = 0x8736;
const GLuint GL_MODELVIEW23_ARB       = 0x8737;
const GLuint GL_MODELVIEW24_ARB       = 0x8738;
const GLuint GL_MODELVIEW25_ARB       = 0x8739;
const GLuint GL_MODELVIEW26_ARB       = 0x873A;
const GLuint GL_MODELVIEW27_ARB       = 0x873B;
const GLuint GL_MODELVIEW28_ARB       = 0x873C;
const GLuint GL_MODELVIEW29_ARB       = 0x873D;
const GLuint GL_MODELVIEW30_ARB       = 0x873E;
const GLuint GL_MODELVIEW31_ARB       = 0x873F;

// 16 - GL_ARB_matrix_palette
const GLuint GL_MATRIX_PALETTE_ARB      = 0x8840;
const GLuint GL_MAX_MATRIX_PALETTE_STACK_DEPTH_ARB  = 0x8841;
const GLuint GL_MAX_PALETTE_MATRICES_ARB    = 0x8842;
const GLuint GL_CURRENT_PALETTE_MATRIX_ARB    = 0x8843;
const GLuint GL_MATRIX_INDEX_ARRAY_ARB      = 0x8844;
const GLuint GL_CURRENT_MATRIX_INDEX_ARB    = 0x8845;
const GLuint GL_MATRIX_INDEX_ARRAY_SIZE_ARB   = 0x8846;
const GLuint GL_MATRIX_INDEX_ARRAY_TYPE_ARB   = 0x8847;
const GLuint GL_MATRIX_INDEX_ARRAY_STRIDE_ARB   = 0x8848;
const GLuint GL_MATRIX_INDEX_ARRAY_POINTER_ARB    = 0x8849;

// 17 - GL_ARB_texture_env_combine
const GLuint GL_COMBINE_ARB       = 0x8570;
const GLuint GL_COMBINE_RGB_ARB       = 0x8571;
const GLuint GL_COMBINE_ALPHA_ARB     = 0x8572;
const GLuint GL_SOURCE0_RGB_ARB       = 0x8580;
const GLuint GL_SOURCE1_RGB_ARB       = 0x8581;
const GLuint GL_SOURCE2_RGB_ARB       = 0x8582;
const GLuint GL_SOURCE0_ALPHA_ARB     = 0x8588;
const GLuint GL_SOURCE1_ALPHA_ARB     = 0x8589;
const GLuint GL_SOURCE2_ALPHA_ARB     = 0x858A;
const GLuint GL_OPERAND0_RGB_ARB      = 0x8590;
const GLuint GL_OPERAND1_RGB_ARB      = 0x8591;
const GLuint GL_OPERAND2_RGB_ARB      = 0x8592;
const GLuint GL_OPERAND0_ALPHA_ARB      = 0x8598;
const GLuint GL_OPERAND1_ALPHA_ARB      = 0x8599;
const GLuint GL_OPERAND2_ALPHA_ARB      = 0x859A;
const GLuint GL_RGB_SCALE_ARB       = 0x8573;
const GLuint GL_ADD_SIGNED_ARB        = 0x8574;
const GLuint GL_INTERPOLATE_ARB       = 0x8575;
const GLuint GL_SUBTRACT_ARB        = 0x84E7;
const GLuint GL_CONSTANT_ARB        = 0x8576;
const GLuint GL_PRIMARY_COLOR_ARB     = 0x8577;
const GLuint GL_PREVIOUS_ARB        = 0x8578;

// 19 - GL_ARB_texture_env_dot3
const GLuint GL_DOT3_RGB_ARB        = 0x86AE;
const GLuint GL_DOT3_RGBA_ARB       = 0x86AF;

// 21 - GL_ARB_texture_mirrored_repeat
const GLuint GL_MIRRORED_REPEAT_ARB     = 0x8370;

// 22 - GL_ARB_depth_texture
const GLuint GL_DEPTH_COMPONENT16_ARB     = 0x81A5;
const GLuint GL_DEPTH_COMPONENT24_ARB     = 0x81A6;
const GLuint GL_DEPTH_COMPONENT32_ARB     = 0x81A7;
const GLuint GL_TEXTURE_DEPTH_SIZE_ARB      = 0x884A;
const GLuint GL_DEPTH_TEXTURE_MODE_ARB      = 0x884B;

// 23 - GL_ARB_shadow
const GLuint GL_TEXTURE_COMPARE_MODE_ARB    = 0x884C;
const GLuint GL_TEXTURE_COMPARE_FUNC_ARB    = 0x884D;
const GLuint GL_COMPARE_R_TO_TEXTURE_ARB    = 0x884E;

// 24 - GL_ARB_shadow_ambient
const GLuint GL_TEXTURE_COMPARE_FAIL_VALUE_ARB    = 0x80BF;

// 26 - GL_ARB_vertex_program
const GLuint GL_COLOR_SUM_ARB       = 0x8458;
const GLuint GL_VERTEX_PROGRAM_ARB      = 0x8620;
const GLuint GL_VERTEX_ATTRIB_ARRAY_ENABLED_ARB   = 0x8622;
const GLuint GL_VERTEX_ATTRIB_ARRAY_SIZE_ARB    = 0x8623;
const GLuint GL_VERTEX_ATTRIB_ARRAY_STRIDE_ARB    = 0x8624;
const GLuint GL_VERTEX_ATTRIB_ARRAY_TYPE_ARB    = 0x8625;
const GLuint GL_CURRENT_VERTEX_ATTRIB_ARB   = 0x8626;
const GLuint GL_PROGRAM_LENGTH_ARB      = 0x8627;
const GLuint GL_PROGRAM_STRING_ARB      = 0x8628;
const GLuint GL_MAX_PROGRAM_MATRIX_STACK_DEPTH_ARB  = 0x862E;
const GLuint GL_MAX_PROGRAM_MATRICES_ARB    = 0x862F;
const GLuint GL_CURRENT_MATRIX_STACK_DEPTH_ARB    = 0x8640;
const GLuint GL_CURRENT_MATRIX_ARB      = 0x8641;
const GLuint GL_VERTEX_PROGRAM_POINT_SIZE_ARB   = 0x8642;
const GLuint GL_VERTEX_PROGRAM_TWO_SIDE_ARB   = 0x8643;
const GLuint GL_VERTEX_ATTRIB_ARRAY_POINTER_ARB   = 0x8645;
const GLuint GL_PROGRAM_ERROR_POSITION_ARB    = 0x864B;
const GLuint GL_PROGRAM_BINDING_ARB     = 0x8677;
const GLuint GL_MAX_VERTEX_ATTRIBS_ARB      = 0x8869;
const GLuint GL_VERTEX_ATTRIB_ARRAY_NORMALIZED_ARB  = 0x886A;
const GLuint GL_PROGRAM_ERROR_STRING_ARB    = 0x8874;
const GLuint GL_PROGRAM_FORMAT_ASCII_ARB    = 0x8875;
const GLuint GL_PROGRAM_FORMAT_ARB      = 0x8876;
const GLuint GL_PROGRAM_INSTRUCTIONS_ARB    = 0x88A0;
const GLuint GL_MAX_PROGRAM_INSTRUCTIONS_ARB    = 0x88A1;
const GLuint GL_PROGRAM_NATIVE_INSTRUCTIONS_ARB   = 0x88A2;
const GLuint GL_MAX_PROGRAM_NATIVE_INSTRUCTIONS_ARB = 0x88A3;
const GLuint GL_PROGRAM_TEMPORARIES_ARB     = 0x88A4;
const GLuint GL_MAX_PROGRAM_TEMPORARIES_ARB   = 0x88A5;
const GLuint GL_PROGRAM_NATIVE_TEMPORARIES_ARB    = 0x88A6;
const GLuint GL_MAX_PROGRAM_NATIVE_TEMPORARIES_ARB  = 0x88A7;
const GLuint GL_PROGRAM_PARAMETERS_ARB      = 0x88A8;
const GLuint GL_MAX_PROGRAM_PARAMETERS_ARB    = 0x88A9;
const GLuint GL_PROGRAM_NATIVE_PARAMETERS_ARB   = 0x88AA;
const GLuint GL_MAX_PROGRAM_NATIVE_PARAMETERS_ARB = 0x88AB;
const GLuint GL_PROGRAM_ATTRIBS_ARB     = 0x88AC;
const GLuint GL_MAX_PROGRAM_ATTRIBS_ARB     = 0x88AD;
const GLuint GL_PROGRAM_NATIVE_ATTRIBS_ARB    = 0x88AE;
const GLuint GL_MAX_PROGRAM_NATIVE_ATTRIBS_ARB    = 0x88AF;
const GLuint GL_PROGRAM_ADDRESS_REGISTERS_ARB   =  0x88B0;
const GLuint GL_MAX_PROGRAM_ADDRESS_REGISTERS_ARB = 0x88B1;
const GLuint GL_PROGRAM_NATIVE_ADDRESS_REGISTERS_ARB  = 0x88B2;
const GLuint GL_MAX_PROGRAM_NATIVE_ADDRESS_REGISTERS_ARB= 0x88B3;
const GLuint GL_MAX_PROGRAM_LOCAL_PARAMETERS_ARB  = 0x88B4;
const GLuint GL_MAX_PROGRAM_ENV_PARAMETERS_ARB    = 0x88B5;
const GLuint GL_PROGRAM_UNDER_NATIVE_LIMITS_ARB   = 0x88B6;
const GLuint GL_TRANSPOSE_CURRENT_MATRIX_ARB    = 0x88B7;
const GLuint GL_MATRIX0_ARB       = 0x88C0;
const GLuint GL_MATRIX1_ARB       = 0x88C1;
const GLuint GL_MATRIX2_ARB       = 0x88C2;
const GLuint GL_MATRIX3_ARB       = 0x88C3;
const GLuint GL_MATRIX4_ARB       = 0x88C4;
const GLuint GL_MATRIX5_ARB       = 0x88C5;
const GLuint GL_MATRIX6_ARB       = 0x88C6;
const GLuint GL_MATRIX7_ARB       = 0x88C7;
const GLuint GL_MATRIX8_ARB       = 0x88C8;
const GLuint GL_MATRIX9_ARB       = 0x88C9;
const GLuint GL_MATRIX10_ARB        = 0x88CA;
const GLuint GL_MATRIX11_ARB        = 0x88CB;
const GLuint GL_MATRIX12_ARB        = 0x88CC;
const GLuint GL_MATRIX13_ARB        = 0x88CD;
const GLuint GL_MATRIX14_ARB        = 0x88CE;
const GLuint GL_MATRIX15_ARB        = 0x88CF;
const GLuint GL_MATRIX16_ARB        = 0x88D0;
const GLuint GL_MATRIX17_ARB        = 0x88D1;
const GLuint GL_MATRIX18_ARB        = 0x88D2;
const GLuint GL_MATRIX19_ARB        = 0x88D3;
const GLuint GL_MATRIX20_ARB        = 0x88D4;
const GLuint GL_MATRIX21_ARB        = 0x88D5;
const GLuint GL_MATRIX22_ARB        = 0x88D6;
const GLuint GL_MATRIX23_ARB        = 0x88D7;
const GLuint GL_MATRIX24_ARB        = 0x88D8;
const GLuint GL_MATRIX25_ARB        = 0x88D9;
const GLuint GL_MATRIX26_ARB        = 0x88DA;
const GLuint GL_MATRIX27_ARB        = 0x88DB;
const GLuint GL_MATRIX28_ARB        = 0x88DC;
const GLuint GL_MATRIX29_ARB        = 0x88DD;
const GLuint GL_MATRIX30_ARB        = 0x88DE;
const GLuint GL_MATRIX31_ARB        = 0x88DF;

// 27 - GL_ARB_fragment_program
const GLuint GL_FRAGMENT_PROGRAM_ARB      = 0x8804;
const GLuint GL_PROGRAM_ALU_INSTRUCTIONS_ARB    = 0x8805;
const GLuint GL_PROGRAM_TEX_INSTRUCTIONS_ARB    = 0x8806;
const GLuint GL_PROGRAM_TEX_INDIRECTIONS_ARB    = 0x8807;
const GLuint GL_PROGRAM_NATIVE_ALU_INSTRUCTIONS_ARB = 0x8808;
const GLuint GL_PROGRAM_NATIVE_TEX_INSTRUCTIONS_ARB = 0x8809;
const GLuint GL_PROGRAM_NATIVE_TEX_INDIRECTIONS_ARB = 0x880A;
const GLuint GL_MAX_PROGRAM_ALU_INSTRUCTIONS_ARB  = 0x880B;
const GLuint GL_MAX_PROGRAM_TEX_INSTRUCTIONS_ARB  = 0x880C;
const GLuint GL_MAX_PROGRAM_TEX_INDIRECTIONS_ARB  = 0x880D;
const GLuint GL_MAX_PROGRAM_NATIVE_ALU_INSTRUCTIONS_ARB = 0x880E;
const GLuint GL_MAX_PROGRAM_NATIVE_TEX_INSTRUCTIONS_ARB = 0x880F;
const GLuint GL_MAX_PROGRAM_NATIVE_TEX_INDIRECTIONS_ARB = 0x8810;
const GLuint GL_MAX_TEXTURE_COORDS_ARB      = 0x8871;
const GLuint GL_MAX_TEXTURE_IMAGE_UNITS_ARB   = 0x8872;

// 28 - GL_ARB_vertex_buffer_object
const GLuint GL_BUFFER_SIZE_ARB       = 0x8764;
const GLuint GL_BUFFER_USAGE_ARB      = 0x8765;
const GLuint GL_ARRAY_BUFFER_ARB      = 0x8892;
const GLuint GL_ELEMENT_ARRAY_BUFFER_ARB    = 0x8893;
const GLuint GL_ARRAY_BUFFER_BINDING_ARB    = 0x8894;
const GLuint GL_ELEMENT_ARRAY_BUFFER_BINDING_ARB  = 0x8895;
const GLuint GL_VERTEX_ARRAY_BUFFER_BINDING_ARB   = 0x8896;
const GLuint GL_NORMAL_ARRAY_BUFFER_BINDING_ARB   = 0x8897;
const GLuint GL_COLOR_ARRAY_BUFFER_BINDING_ARB    = 0x8898;
const GLuint GL_INDEX_ARRAY_BUFFER_BINDING_ARB    = 0x8899;
const GLuint GL_TEXTURE_COORD_ARRAY_BUFFER_BINDING_ARB  = 0x889A;
const GLuint GL_EDGE_FLAG_ARRAY_BUFFER_BINDING_ARB  = 0x889B;
const GLuint GL_SECONDARY_COLOR_ARRAY_BUFFER_BINDING_ARB= 0x889C;
const GLuint GL_FOG_COORDINATE_ARRAY_BUFFER_BINDING_ARB = 0x889D;
const GLuint GL_WEIGHT_ARRAY_BUFFER_BINDING_ARB   = 0x889E;
const GLuint GL_VERTEX_ATTRIB_ARRAY_BUFFER_BINDING_ARB  = 0x889F;
const GLuint GL_READ_ONLY_ARB       = 0x88B8;
const GLuint GL_WRITE_ONLY_ARB        = 0x88B9;
const GLuint GL_READ_WRITE_ARB        = 0x88BA;
const GLuint GL_BUFFER_ACCESS_ARB     = 0x88BB;
const GLuint GL_BUFFER_MAPPED_ARB     = 0x88BC;
const GLuint GL_BUFFER_MAP_POINTER_ARB      = 0x88BD;
const GLuint GL_STREAM_DRAW_ARB       = 0x88E0;
const GLuint GL_STREAM_READ_ARB       = 0x88E1;
const GLuint GL_STREAM_COPY_ARB       = 0x88E2;
const GLuint GL_STATIC_DRAW_ARB       = 0x88E4;
const GLuint GL_STATIC_READ_ARB       = 0x88E5;
const GLuint GL_STATIC_COPY_ARB       = 0x88E6;
const GLuint GL_DYNAMIC_DRAW_ARB      = 0x88E8;
const GLuint GL_DYNAMIC_READ_ARB      = 0x88E9;
const GLuint GL_DYNAMIC_COPY_ARB      = 0x88EA;

// 29 - GL_ARB_occlusion_query
const GLuint GL_QUERY_COUNTER_BITS_ARB      = 0x8864;
const GLuint GL_CURRENT_QUERY_ARB     = 0x8865;
const GLuint GL_QUERY_RESULT_ARB      = 0x8866;
const GLuint GL_QUERY_RESULT_AVAILABLE_ARB    = 0x8867;
const GLuint GL_SAMPLES_PASSED_ARB      = 0x8914;

// 30 - GL_ARB_shader_objects
const GLuint GL_PROGRAM_OBJECT_ARB      = 0x8B40;
const GLuint GL_SHADER_OBJECT_ARB     = 0x8B48;
const GLuint GL_OBJECT_TYPE_ARB       = 0x8B4E;
const GLuint GL_OBJECT_SUBTYPE_ARB      = 0x8B4F;
const GLuint GL_FLOAT_VEC2_ARB        = 0x8B50;
const GLuint GL_FLOAT_VEC3_ARB        = 0x8B51;
const GLuint GL_FLOAT_VEC4_ARB        = 0x8B52;
const GLuint GL_INT_VEC2_ARB        = 0x8B53;
const GLuint GL_INT_VEC3_ARB        = 0x8B54;
const GLuint GL_INT_VEC4_ARB        = 0x8B55;
const GLuint GL_BOOL_ARB        = 0x8B56;
const GLuint GL_BOOL_VEC2_ARB       = 0x8B57;
const GLuint GL_BOOL_VEC3_ARB       = 0x8B58;
const GLuint GL_BOOL_VEC4_ARB       = 0x8B59;
const GLuint GL_FLOAT_MAT2_ARB        = 0x8B5A;
const GLuint GL_FLOAT_MAT3_ARB        = 0x8B5B;
const GLuint GL_FLOAT_MAT4_ARB        = 0x8B5C;
const GLuint GL_SAMPLER_1D_ARB        = 0x8B5D;
const GLuint GL_SAMPLER_2D_ARB        = 0x8B5E;
const GLuint GL_SAMPLER_3D_ARB        = 0x8B5F;
const GLuint GL_SAMPLER_CUBE_ARB      = 0x8B60;
const GLuint GL_SAMPLER_1D_SHADOW_ARB     = 0x8B61;
const GLuint GL_SAMPLER_2D_SHADOW_ARB     = 0x8B62;
const GLuint GL_SAMPLER_2D_RECT_ARB     = 0x8B63;
const GLuint GL_SAMPLER_2D_RECT_SHADOW_ARB    = 0x8B64;
const GLuint GL_OBJECT_DELETE_STATUS_ARB    = 0x8B80;
const GLuint GL_OBJECT_COMPILE_STATUS_ARB   = 0x8B81;
const GLuint GL_OBJECT_LINK_STATUS_ARB      = 0x8B82;
const GLuint GL_OBJECT_VALIDATE_STATUS_ARB    = 0x8B83;
const GLuint GL_OBJECT_INFO_LOG_LENGTH_ARB    = 0x8B84;
const GLuint GL_OBJECT_ATTACHED_OBJECTS_ARB   = 0x8B85;
const GLuint GL_OBJECT_ACTIVE_UNIFORMS_ARB    = 0x8B86;
const GLuint GL_OBJECT_ACTIVE_UNIFORM_MAX_LENGTH_ARB  = 0x8B87;
const GLuint GL_OBJECT_SHADER_SOURCE_LENGTH_ARB   = 0x8B88;

// 31 - GL_ARB_vertex_shader
const GLuint GL_VERTEX_SHADER_ARB     = 0x8B31;
const GLuint GL_MAX_VERTEX_UNIFORM_COMPONENTS_ARB = 0x8B4A;
const GLuint GL_MAX_VARYING_FLOATS_ARB      = 0x8B4B;
const GLuint GL_MAX_VERTEX_TEXTURE_IMAGE_UNITS_ARB  = 0x8B4C;
const GLuint GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS_ARB  = 0x8B4D;
const GLuint GL_OBJECT_ACTIVE_ATTRIBUTES_ARB    = 0x8B89;
const GLuint GL_OBJECT_ACTIVE_ATTRIBUTE_MAX_LENGTH_ARB  = 0x8B8A;

// 32 - GL_ARB_fragment_shader
const GLuint GL_FRAGMENT_SHADER_ARB     = 0x8B30;
const GLuint GL_MAX_FRAGMENT_UNIFORM_COMPONENTS_ARB = 0x8B49;
const GLuint GL_FRAGMENT_SHADER_DERIVATIVE_HINT_ARB = 0x8B8B;

// 33 - GL_ARB_shading_language_100
const GLuint GL_SHADING_LANGUAGE_VERSION_ARB    = 0x8B8C;

// 35 - GL_ARB_point_sprite
const GLuint GL_POINT_SPRITE_ARB      = 0x8861;
const GLuint GL_COORD_REPLACE_ARB     = 0x8862;

// 37 - GL_ARB_draw_buffers
const GLuint GL_MAX_DRAW_BUFFERS_ARB      = 0x8824;
const GLuint GL_DRAW_BUFFER0_ARB      = 0x8825;
const GLuint GL_DRAW_BUFFER1_ARB      = 0x8826;
const GLuint GL_DRAW_BUFFER2_ARB      = 0x8827;
const GLuint GL_DRAW_BUFFER3_ARB      = 0x8828;
const GLuint GL_DRAW_BUFFER4_ARB      = 0x8829;
const GLuint GL_DRAW_BUFFER5_ARB      = 0x882A;
const GLuint GL_DRAW_BUFFER6_ARB      = 0x882B;
const GLuint GL_DRAW_BUFFER7_ARB      = 0x882C;
const GLuint GL_DRAW_BUFFER8_ARB      = 0x882D;
const GLuint GL_DRAW_BUFFER9_ARB      = 0x882E;
const GLuint GL_DRAW_BUFFER10_ARB     = 0x882F;
const GLuint GL_DRAW_BUFFER11_ARB     = 0x8830;
const GLuint GL_DRAW_BUFFER12_ARB     = 0x8831;
const GLuint GL_DRAW_BUFFER13_ARB     = 0x8832;
const GLuint GL_DRAW_BUFFER14_ARB     = 0x8833;
const GLuint GL_DRAW_BUFFER15_ARB     = 0x8834;

// 38 - GL_ARB_texture_rectangle
const GLuint GL_TEXTURE_RECTANGLE_ARB     = 0x84F5;
const GLuint GL_TEXTURE_BINDING_RECTANGLE_ARB   = 0x84F6;
const GLuint GL_PROXY_TEXTURE_RECTANGLE_ARB   = 0x84F7;
const GLuint GL_MAX_RECTANGLE_TEXTURE_SIZE_ARB    = 0x84F8;

// 39 - GL_ARB_color_buffer_float
const GLuint GL_RGBA_FLOAT_MODE_ARB     = 0x8820;
const GLuint GL_CLAMP_VERTEX_COLOR_ARB      = 0x891A;
const GLuint GL_CLAMP_FRAGMENT_COLOR_ARB    = 0x891B;
const GLuint GL_CLAMP_READ_COLOR_ARB      = 0x891C;
const GLuint GL_FIXED_ONLY_ARB        = 0x891D;

// 40 - GL_ARB_half_float_pixel
const GLuint GL_HALF_FLOAT_ARB        = 0x140B;

// 41 - GL_ARB_texture_float
const GLuint GL_TEXTURE_RED_TYPE_ARB      = 0x8C10;
const GLuint GL_TEXTURE_GREEN_TYPE_ARB      = 0x8C11;
const GLuint GL_TEXTURE_BLUE_TYPE_ARB     = 0x8C12;
const GLuint GL_TEXTURE_ALPHA_TYPE_ARB      = 0x8C13;
const GLuint GL_TEXTURE_LUMINANCE_TYPE_ARB    = 0x8C14;
const GLuint GL_TEXTURE_INTENSITY_TYPE_ARB    = 0x8C15;
const GLuint GL_TEXTURE_DEPTH_TYPE_ARB      = 0x8C16;
const GLuint GL_UNSIGNED_NORMALIZED_ARB     = 0x8C17;
const GLuint GL_RGBA32F_ARB       = 0x8814;
const GLuint GL_RGB32F_ARB        = 0x8815;
const GLuint GL_ALPHA32F_ARB        = 0x8816;
const GLuint GL_INTENSITY32F_ARB      = 0x8817;
const GLuint GL_LUMINANCE32F_ARB      = 0x8818;
const GLuint GL_LUMINANCE_ALPHA32F_ARB      = 0x8819;
const GLuint GL_RGBA16F_ARB       = 0x881A;
const GLuint GL_RGB16F_ARB        = 0x881B;
const GLuint GL_ALPHA16F_ARB        = 0x881C;
const GLuint GL_INTENSITY16F_ARB      = 0x881D;
const GLuint GL_LUMINANCE16F_ARB      = 0x881E;
const GLuint GL_LUMINANCE_ALPHA16F_ARB      = 0x881F;

// 42 - GL_ARB_pixel_buffer_object
const GLuint GL_PIXEL_PACK_BUFFER_ARB     = 0x88EB;
const GLuint GL_PIXEL_UNPACK_BUFFER_ARB     = 0x88EC;
const GLuint GL_PIXEL_PACK_BUFFER_BINDING_ARB   = 0x88ED;
const GLuint GL_PIXEL_UNPACK_BUFFER_BINDING_ARB   = 0x88EF;

/*
 * Non-ARB Extensions
 */
// 1 - GL_EXT_abgr
const GLuint GL_ABGR_EXT        = 0x8000;

// 2 - GL_EXT_blend_color
const GLuint GL_CONSTANT_COLOR_EXT      = 0x8001;
const GLuint GL_ONE_MINUS_CONSTANT_COLOR_EXT    = 0x8002;
const GLuint GL_CONSTANT_ALPHA_EXT      = 0x8003;
const GLuint GL_ONE_MINUS_CONSTANT_ALPHA_EXT    = 0x8004;
const GLuint GL_BLEND_COLOR_EXT       = 0x8005;

// 3 - GL_EXT_polygon_offset
const GLuint GL_POLYGON_OFFSET_EXT      = 0x8037;
const GLuint GL_POLYGON_OFFSET_FACTOR_EXT   = 0x8038;
const GLuint GL_POLYGON_OFFSET_BIAS_EXT     = 0x8039;

// 4 - GL_EXT_texture
const GLuint GL_ALPHA4_EXT        = 0x803B;
const GLuint GL_ALPHA8_EXT        = 0x803C;
const GLuint GL_ALPHA12_EXT       = 0x803D;
const GLuint GL_ALPHA16_EXT       = 0x803E;
const GLuint GL_LUMINANCE4_EXT        = 0x803F;
const GLuint GL_LUMINANCE8_EXT        = 0x8040;
const GLuint GL_LUMINANCE12_EXT       = 0x8041;
const GLuint GL_LUMINANCE16_EXT       = 0x8042;
const GLuint GL_LUMINANCE4_ALPHA4_EXT     = 0x8043;
const GLuint GL_LUMINANCE6_ALPHA2_EXT     = 0x8044;
const GLuint GL_LUMINANCE8_ALPHA8_EXT     = 0x8045;
const GLuint GL_LUMINANCE12_ALPHA4_EXT      = 0x8046;
const GLuint GL_LUMINANCE12_ALPHA12_EXT     = 0x8047;
const GLuint GL_LUMINANCE16_ALPHA16_EXT     = 0x8048;
const GLuint GL_INTENSITY_EXT       = 0x8049;
const GLuint GL_INTENSITY4_EXT        = 0x804A;
const GLuint GL_INTENSITY8_EXT        = 0x804B;
const GLuint GL_INTENSITY12_EXT       = 0x804C;
const GLuint GL_INTENSITY16_EXT       = 0x804D;
const GLuint GL_RGB2_EXT        = 0x804E;
const GLuint GL_RGB4_EXT        = 0x804F;
const GLuint GL_RGB5_EXT        = 0x8050;
const GLuint GL_RGB8_EXT        = 0x8051;
const GLuint GL_RGB10_EXT       = 0x8052;
const GLuint GL_RGB12_EXT       = 0x8053;
const GLuint GL_RGB16_EXT       = 0x8054;
const GLuint GL_RGBA2_EXT       = 0x8055;
const GLuint GL_RGBA4_EXT       = 0x8056;
const GLuint GL_RGB5_A1_EXT       = 0x8057;
const GLuint GL_RGBA8_EXT       = 0x8058;
const GLuint GL_RGB10_A2_EXT        = 0x8059;
const GLuint GL_RGBA12_EXT        = 0x805A;
const GLuint GL_RGBA16_EXT        = 0x805B;
const GLuint GL_TEXTURE_RED_SIZE_EXT      = 0x805C;
const GLuint GL_TEXTURE_GREEN_SIZE_EXT      = 0x805D;
const GLuint GL_TEXTURE_BLUE_SIZE_EXT     = 0x805E;
const GLuint GL_TEXTURE_ALPHA_SIZE_EXT      = 0x805F;
const GLuint GL_TEXTURE_LUMINANCE_SIZE_EXT    = 0x8060;
const GLuint GL_TEXTURE_INTENSITY_SIZE_EXT    = 0x8061;
const GLuint GL_REPLACE_EXT       = 0x8062;
const GLuint GL_PROXY_TEXTURE_1D_EXT      = 0x8063;
const GLuint GL_PROXY_TEXTURE_2D_EXT      = 0x8064;
const GLuint GL_TEXTURE_TOO_LARGE_EXT     = 0x8065;

// 6 - GL_EXT_texture3D
const GLuint GL_PACK_SKIP_IMAGES_EXT      = 0x806B;
const GLuint GL_PACK_IMAGE_HEIGHT_EXT     = 0x806C;
const GLuint GL_UNPACK_SKIP_IMAGES_EXT      = 0x806D;
const GLuint GL_UNPACK_IMAGE_HEIGHT_EXT     = 0x806E;
const GLuint GL_TEXTURE_3D_EXT        = 0x806F;
const GLuint GL_PROXY_TEXTURE_3D_EXT      = 0x8070;
const GLuint GL_TEXTURE_DEPTH_EXT     = 0x8071;
const GLuint GL_TEXTURE_WRAP_R_EXT      = 0x8072;
const GLuint GL_MAX_3D_TEXTURE_SIZE_EXT     = 0x8073;

// 7 - GL_SGIS_texture_filter4
const GLuint GL_FILTER4_SGIS        = 0x8146;
const GLuint GL_TEXTURE_FILTER4_SIZE_SGIS   = 0x8147;

// 11 - GL_EXT_histogram
const GLuint GL_HISTOGRAM_EXT       = 0x8024;
const GLuint GL_PROXY_HISTOGRAM_EXT     = 0x8025;
const GLuint GL_HISTOGRAM_WIDTH_EXT     = 0x8026;
const GLuint GL_HISTOGRAM_FORMAT_EXT      = 0x8027;
const GLuint GL_HISTOGRAM_RED_SIZE_EXT      = 0x8028;
const GLuint GL_HISTOGRAM_GREEN_SIZE_EXT    = 0x8029;
const GLuint GL_HISTOGRAM_BLUE_SIZE_EXT     = 0x802A;
const GLuint GL_HISTOGRAM_ALPHA_SIZE_EXT    = 0x802B;
const GLuint GL_HISTOGRAM_LUMINANCE_SIZE_EXT    = 0x802C;
const GLuint GL_HISTOGRAM_SINK_EXT      = 0x802D;
const GLuint GL_MINMAX_EXT        = 0x802E;
const GLuint GL_MINMAX_FORMAT_EXT     = 0x802F;
const GLuint GL_MINMAX_SINK_EXT       = 0x8030;
const GLuint GL_TABLE_TOO_LARGE_EXT     = 0x8031;

// 12 - GL_EXT_convolution
const GLuint GL_CONVOLUTION_1D_EXT      = 0x8010;
const GLuint GL_CONVOLUTION_2D_EXT      = 0x8011;
const GLuint GL_SEPARABLE_2D_EXT      = 0x8012;
const GLuint GL_CONVOLUTION_BORDER_MODE_EXT   = 0x8013;
const GLuint GL_CONVOLUTION_FILTER_SCALE_EXT    = 0x8014;
const GLuint GL_CONVOLUTION_FILTER_BIAS_EXT   = 0x8015;
const GLuint GL_REDUCE_EXT        = 0x8016;
const GLuint GL_CONVOLUTION_FORMAT_EXT      = 0x8017;
const GLuint GL_CONVOLUTION_WIDTH_EXT     = 0x8018;
const GLuint GL_CONVOLUTION_HEIGHT_EXT      = 0x8019;
const GLuint GL_MAX_CONVOLUTION_WIDTH_EXT   = 0x801A;
const GLuint GL_MAX_CONVOLUTION_HEIGHT_EXT    = 0x801B;
const GLuint GL_POST_CONVOLUTION_RED_SCALE_EXT    = 0x801C;
const GLuint GL_POST_CONVOLUTION_GREEN_SCALE_EXT  = 0x801D;
const GLuint GL_POST_CONVOLUTION_BLUE_SCALE_EXT   = 0x801E;
const GLuint GL_POST_CONVOLUTION_ALPHA_SCALE_EXT  = 0x801F;
const GLuint GL_POST_CONVOLUTION_RED_BIAS_EXT   = 0x8020;
const GLuint GL_POST_CONVOLUTION_GREEN_BIAS_EXT   = 0x8021;
const GLuint GL_POST_CONVOLUTION_BLUE_BIAS_EXT    = 0x8022;
const GLuint GL_POST_CONVOLUTION_ALPHA_BIAS_EXT   = 0x8023;

// 13 - GL_SGI_color_matrix
const GLuint GL_COLOR_MATRIX_SGI      = 0x80B1;
const GLuint GL_COLOR_MATRIX_STACK_DEPTH_SGI    = 0x80B2;
const GLuint GL_MAX_COLOR_MATRIX_STACK_DEPTH_SGI  = 0x80B3;
const GLuint GL_POST_COLOR_MATRIX_RED_SCALE_SGI   = 0x80B4;
const GLuint GL_POST_COLOR_MATRIX_GREEN_SCALE_SGI = 0x80B5;
const GLuint GL_POST_COLOR_MATRIX_BLUE_SCALE_SGI  = 0x80B6;
const GLuint GL_POST_COLOR_MATRIX_ALPHA_SCALE_SGI = 0x80B7;
const GLuint GL_POST_COLOR_MATRIX_RED_BIAS_SGI    = 0x80B8;
const GLuint GL_POST_COLOR_MATRIX_GREEN_BIAS_SGI  = 0x80B9;
const GLuint GL_POST_COLOR_MATRIX_BLUE_BIAS_SGI   = 0x80BA;
const GLuint GL_POST_COLOR_MATRIX_ALPHA_BIAS_SGI  = 0x80BB;

// 14 - GL_SGI_color_table
const GLuint GL_COLOR_TABLE_SGI       = 0x80D0;
const GLuint GL_POST_CONVOLUTION_COLOR_TABLE_SGI  = 0x80D1;
const GLuint GL_POST_COLOR_MATRIX_COLOR_TABLE_SGI = 0x80D2;
const GLuint GL_PROXY_COLOR_TABLE_SGI     = 0x80D3;
const GLuint GL_PROXY_POST_CONVOLUTION_COLOR_TABLE_SGI  = 0x80D4;
const GLuint GL_PROXY_POST_COLOR_MATRIX_COLOR_TABLE_SGI = 0x80D5;
const GLuint GL_COLOR_TABLE_SCALE_SGI     = 0x80D6;
const GLuint GL_COLOR_TABLE_BIAS_SGI      = 0x80D7;
const GLuint GL_COLOR_TABLE_FORMAT_SGI      = 0x80D8;
const GLuint GL_COLOR_TABLE_WIDTH_SGI     = 0x80D9;
const GLuint GL_COLOR_TABLE_RED_SIZE_SGI    = 0x80DA;
const GLuint GL_COLOR_TABLE_GREEN_SIZE_SGI    = 0x80DB;
const GLuint GL_COLOR_TABLE_BLUE_SIZE_SGI   = 0x80DC;
const GLuint GL_COLOR_TABLE_ALPHA_SIZE_SGI    = 0x80DD;
const GLuint GL_COLOR_TABLE_LUMINANCE_SIZE_SGI    = 0x80DE;
const GLuint GL_COLOR_TABLE_INTENSITY_SIZE_SGI    = 0x80DF;

// 15 - GL_SGIS_pixel_texture
const GLuint GL_PIXEL_TEXTURE_SGIS      = 0x8353;
const GLuint GL_PIXEL_FRAGMENT_RGB_SOURCE_SGIS    = 0x8354;
const GLuint GL_PIXEL_FRAGMENT_ALPHA_SOURCE_SGIS  = 0x8355;
const GLuint GL_PIXEL_GROUP_COLOR_SGIS      = 0x8356;

// 15a - GL_SGIX_pixel_texture
const GLuint GL_PIXEL_TEX_GEN_SGIX      = 0x8139;
const GLuint GL_PIXEL_TEX_GEN_MODE_SGIX     = 0x832B;

// 16 - GL_SGIS_texture4D
const GLuint GL_PACK_SKIP_VOLUMES_SGIS      = 0x8130;
const GLuint GL_PACK_IMAGE_DEPTH_SGIS     = 0x8131;
const GLuint GL_UNPACK_SKIP_VOLUMES_SGIS    = 0x8132;
const GLuint GL_UNPACK_IMAGE_DEPTH_SGIS     = 0x8133;
const GLuint GL_TEXTURE_4D_SGIS       = 0x8134;
const GLuint GL_PROXY_TEXTURE_4D_SGIS     = 0x8135;
const GLuint GL_TEXTURE_4DSIZE_SGIS     = 0x8136;
const GLuint GL_TEXTURE_WRAP_Q_SGIS     = 0x8137;
const GLuint GL_MAX_4D_TEXTURE_SIZE_SGIS    = 0x8138;
const GLuint GL_TEXTURE_4D_BINDING_SGIS     = 0x814F;

// 17 - GL_SGI_texture_color_table
const GLuint GL_TEXTURE_COLOR_TABLE_SGI     = 0x80BC;
const GLuint GL_PROXY_TEXTURE_COLOR_TABLE_SGI   = 0x80BD;

// 18 - GL_EXT_cmyka
const GLuint GL_CMYK_EXT        = 0x800C;
const GLuint GL_CMYKA_EXT       = 0x800D;
const GLuint GL_PACK_CMYK_HINT_EXT      = 0x800E;
const GLuint GL_UNPACK_CMYK_HINT_EXT      = 0x800F;

// 20 - GL_EXT_texture_object
const GLuint GL_TEXTURE_PRIORITY_EXT      = 0x8066;
const GLuint GL_TEXTURE_RESIDENT_EXT      = 0x8067;
const GLuint GL_TEXTURE_1D_BINDING_EXT      = 0x8068;
const GLuint GL_TEXTURE_2D_BINDING_EXT      = 0x8069;
const GLuint GL_TEXTURE_3D_BINDING_EXT      = 0x806A;

// 21 - GL_SGIS_detail_texture
const GLuint GL_DETAIL_TEXTURE_2D_SGIS      = 0x8095;
const GLuint GL_DETAIL_TEXTURE_2D_BINDING_SGIS    = 0x8096;
const GLuint GL_LINEAR_DETAIL_SGIS      = 0x8097;
const GLuint GL_LINEAR_DETAIL_ALPHA_SGIS    = 0x8098;
const GLuint GL_LINEAR_DETAIL_COLOR_SGIS    = 0x8099;
const GLuint GL_DETAIL_TEXTURE_LEVEL_SGIS   = 0x809A;
const GLuint GL_DETAIL_TEXTURE_MODE_SGIS    = 0x809B;
const GLuint GL_DETAIL_TEXTURE_FUNC_POINTS_SGIS   = 0x809C;

// 22 - GL_SGIS_sharpen_texture
const GLuint GL_LINEAR_SHARPEN_SGIS     = 0x80AD;
const GLuint GL_LINEAR_SHARPEN_ALPHA_SGIS   = 0x80AE;
const GLuint GL_LINEAR_SHARPEN_COLOR_SGIS   = 0x80AF;
const GLuint GL_SHARPEN_TEXTURE_FUNC_POINTS_SGIS  = 0x80B0;

// 23 - GL_EXT_packed_pixels
const GLuint GL_UNSIGNED_BYTE_3_3_2_EXT     = 0x8032;
const GLuint GL_UNSIGNED_SHORT_4_4_4_4_EXT    = 0x8033;
const GLuint GL_UNSIGNED_SHORT_5_5_5_1_EXT    = 0x8034;
const GLuint GL_UNSIGNED_INT_8_8_8_8_EXT    = 0x8035;
const GLuint GL_UNSIGNED_INT_10_10_10_2_EXT   = 0x8036;

// 24 - GL_SGIS_texture_lod
const GLuint GL_TEXTURE_MIN_LOD_SGIS      = 0x813A;
const GLuint GL_TEXTURE_MAX_LOD_SGIS      = 0x813B;
const GLuint GL_TEXTURE_BASE_LEVEL_SGIS     = 0x813C;
const GLuint GL_TEXTURE_MAX_LEVEL_SGIS      = 0x813D;

// 25 - GL_SGIS_multisample
const GLuint GL_MULTISAMPLE_SGIS      = 0x809D;
const GLuint GL_SAMPLE_ALPHA_TO_MASK_SGIS   = 0x809E;
const GLuint GL_SAMPLE_ALPHA_TO_ONE_SGIS    = 0x809F;
const GLuint GL_SAMPLE_MASK_SGIS      = 0x80A0;
const GLuint GL_1PASS_SGIS        = 0x80A1;
const GLuint GL_2PASS_0_SGIS        = 0x80A2;
const GLuint GL_2PASS_1_SGIS        = 0x80A3;
const GLuint GL_4PASS_0_SGIS        = 0x80A4;
const GLuint GL_4PASS_1_SGIS        = 0x80A5;
const GLuint GL_4PASS_2_SGIS        = 0x80A6;
const GLuint GL_4PASS_3_SGIS        = 0x80A7;
const GLuint GL_SAMPLE_BUFFERS_SGIS     = 0x80A8;
const GLuint GL_SAMPLES_SGIS        = 0x80A9;
const GLuint GL_SAMPLE_MASK_VALUE_SGIS      = 0x80AA;
const GLuint GL_SAMPLE_MASK_INVERT_SGIS     = 0x80AB;
const GLuint GL_SAMPLE_PATTERN_SGIS     = 0x80AC;

// 27 - GL_EXT_rescale_normal
const GLuint GL_RESCALE_NORMAL_EXT      = 0x803A;

// 30 - GL_EXT_vertex_array
const GLuint GL_VERTEX_ARRAY_EXT      = 0x8074;
const GLuint GL_NORMAL_ARRAY_EXT      = 0x8075;
const GLuint GL_COLOR_ARRAY_EXT       = 0x8076;
const GLuint GL_INDEX_ARRAY_EXT       = 0x8077;
const GLuint GL_TEXTURE_COORD_ARRAY_EXT     = 0x8078;
const GLuint GL_EDGE_FLAG_ARRAY_EXT     = 0x8079;
const GLuint GL_VERTEX_ARRAY_SIZE_EXT     = 0x807A;
const GLuint GL_VERTEX_ARRAY_TYPE_EXT     = 0x807B;
const GLuint GL_VERTEX_ARRAY_STRIDE_EXT     = 0x807C;
const GLuint GL_VERTEX_ARRAY_COUNT_EXT      = 0x807D;
const GLuint GL_NORMAL_ARRAY_TYPE_EXT     = 0x807E;
const GLuint GL_NORMAL_ARRAY_STRIDE_EXT     = 0x807F;
const GLuint GL_NORMAL_ARRAY_COUNT_EXT      = 0x8080;
const GLuint GL_COLOR_ARRAY_SIZE_EXT      = 0x8081;
const GLuint GL_COLOR_ARRAY_TYPE_EXT      = 0x8082;
const GLuint GL_COLOR_ARRAY_STRIDE_EXT      = 0x8083;
const GLuint GL_COLOR_ARRAY_COUNT_EXT     = 0x8084;
const GLuint GL_INDEX_ARRAY_TYPE_EXT      = 0x8085;
const GLuint GL_INDEX_ARRAY_STRIDE_EXT      = 0x8086;
const GLuint GL_INDEX_ARRAY_COUNT_EXT     = 0x8087;
const GLuint GL_TEXTURE_COORD_ARRAY_SIZE_EXT    = 0x8088;
const GLuint GL_TEXTURE_COORD_ARRAY_TYPE_EXT    = 0x8089;
const GLuint GL_TEXTURE_COORD_ARRAY_STRIDE_EXT    = 0x808A;
const GLuint GL_TEXTURE_COORD_ARRAY_COUNT_EXT   = 0x808B;
const GLuint GL_EDGE_FLAG_ARRAY_STRIDE_EXT    = 0x808C;
const GLuint GL_EDGE_FLAG_ARRAY_COUNT_EXT   = 0x808D;
const GLuint GL_VERTEX_ARRAY_POINTER_EXT    = 0x808E;
const GLuint GL_NORMAL_ARRAY_POINTER_EXT    = 0x808F;
const GLuint GL_COLOR_ARRAY_POINTER_EXT     = 0x8090;
const GLuint GL_INDEX_ARRAY_POINTER_EXT     = 0x8091;
const GLuint GL_TEXTURE_COORD_ARRAY_POINTER_EXT   = 0x8092;
const GLuint GL_EDGE_FLAG_ARRAY_POINTER_EXT   = 0x8093;

// 32 - GL_SGIS_generate_mipmap
const GLuint GL_GENERATE_MIPMAP_SGIS      = 0x8191;
const GLuint GL_GENERATE_MIPMAP_HINT_SGIS   = 0x8192;

// 33 - GL_SGIX_clipmap
const GLuint GL_LINEAR_CLIPMAP_LINEAR_SGIX    = 0x8170;
const GLuint GL_TEXTURE_CLIPMAP_CENTER_SGIX   = 0x8171;
const GLuint GL_TEXTURE_CLIPMAP_FRAME_SGIX    = 0x8172;
const GLuint GL_TEXTURE_CLIPMAP_OFFSET_SGIX   = 0x8173;
const GLuint GL_TEXTURE_CLIPMAP_VIRTUAL_DEPTH_SGIX  = 0x8174;
const GLuint GL_TEXTURE_CLIPMAP_LOD_OFFSET_SGIX   = 0x8175;
const GLuint GL_TEXTURE_CLIPMAP_DEPTH_SGIX    = 0x8176;
const GLuint GL_MAX_CLIPMAP_DEPTH_SGIX      = 0x8177;
const GLuint GL_MAX_CLIPMAP_VIRTUAL_DEPTH_SGIX    = 0x8178;
const GLuint GL_NEAREST_CLIPMAP_NEAREST_SGIX    = 0x844D;
const GLuint GL_NEAREST_CLIPMAP_LINEAR_SGIX   = 0x844E;
const GLuint GL_LINEAR_CLIPMAP_NEAREST_SGIX   = 0x844F;

// 34 - GL_SGIX_shadow
const GLuint GL_TEXTURE_COMPARE_SGIX      = 0x819A;
const GLuint GL_TEXTURE_COMPARE_OPERATOR_SGIX   = 0x819B;
const GLuint GL_TEXTURE_LEQUAL_R_SGIX     = 0x819C;
const GLuint GL_TEXTURE_GEQUAL_R_SGIX     = 0x819D;

// 35 - GL_SGIS_texture_edge_clamp
const GLuint GL_CLAMP_TO_EDGE_SGIS      = 0x812F;

// 36 - GL_SGIS_texture_border_clamp
const GLuint GL_CLAMP_TO_BORDER_SGIS      = 0x812D;

// 37 - GL_EXT_blend_minmax
const GLuint GL_FUNC_ADD_EXT        = 0x8006;
const GLuint GL_MIN_EXT         = 0x8007;
const GLuint GL_MAX_EXT         = 0x8008;
const GLuint GL_BLEND_EQUATION_EXT      = 0x8009;

// 38 - GL_EXT_blend_subtract
const GLuint GL_FUNC_SUBTRACT_EXT     = 0x800A;
const GLuint GL_FUNC_REVERSE_SUBTRACT_EXT   = 0x800B;

// 45 - GL_SGIX_interlace
const GLuint GL_INTERLACE_SGIX        = 0x8094;

// ? - GL_SGIX_pixel_tiles
const GLuint GL_PIXEL_TILE_BEST_ALIGNMENT_SGIX    = 0x813E;
const GLuint GL_PIXEL_TILE_CACHE_INCREMENT_SGIX   = 0x813F;
const GLuint GL_PIXEL_TILE_WIDTH_SGIX     = 0x8140;
const GLuint GL_PIXEL_TILE_HEIGHT_SGIX      = 0x8141;
const GLuint GL_PIXEL_TILE_GRID_WIDTH_SGIX    = 0x8142;
const GLuint GL_PIXEL_TILE_GRID_HEIGHT_SGIX   = 0x8143;
const GLuint GL_PIXEL_TILE_GRID_DEPTH_SGIX    = 0x8144;
const GLuint GL_PIXEL_TILE_CACHE_SIZE_SGIX    = 0x8145;

// 51 - GL_SGIS_texture_select
const GLuint GL_DUAL_ALPHA4_SGIS      = 0x8110;
const GLuint GL_DUAL_ALPHA8_SGIS      = 0x8111;
const GLuint GL_DUAL_ALPHA12_SGIS     = 0x8112;
const GLuint GL_DUAL_ALPHA16_SGIS     = 0x8113;
const GLuint GL_DUAL_LUMINANCE4_SGIS      = 0x8114;
const GLuint GL_DUAL_LUMINANCE8_SGIS      = 0x8115;
const GLuint GL_DUAL_LUMINANCE12_SGIS     = 0x8116;
const GLuint GL_DUAL_LUMINANCE16_SGIS     = 0x8117;
const GLuint GL_DUAL_INTENSITY4_SGIS      = 0x8118;
const GLuint GL_DUAL_INTENSITY8_SGIS      = 0x8119;
const GLuint GL_DUAL_INTENSITY12_SGIS     = 0x811A;
const GLuint GL_DUAL_INTENSITY16_SGIS     = 0x811B;
const GLuint GL_DUAL_LUMINANCE_ALPHA4_SGIS    = 0x811C;
const GLuint GL_DUAL_LUMINANCE_ALPHA8_SGIS    = 0x811D;
const GLuint GL_QUAD_ALPHA4_SGIS      = 0x811E;
const GLuint GL_QUAD_ALPHA8_SGIS      = 0x811F;
const GLuint GL_QUAD_LUMINANCE4_SGIS      = 0x8120;
const GLuint GL_QUAD_LUMINANCE8_SGIS      = 0x8121;
const GLuint GL_QUAD_INTENSITY4_SGIS      = 0x8122;
const GLuint GL_QUAD_INTENSITY8_SGIS      = 0x8123;
const GLuint GL_DUAL_TEXTURE_SELECT_SGIS    = 0x8124;
const GLuint GL_QUAD_TEXTURE_SELECT_SGIS    = 0x8125;

// 52 - GL_SGIX_sprite
const GLuint GL_SPRITE_SGIX       = 0x8148;
const GLuint GL_SPRITE_MODE_SGIX      = 0x8149;
const GLuint GL_SPRITE_AXIS_SGIX      = 0x814A;
const GLuint GL_SPRITE_TRANSLATION_SGIX     = 0x814B;
const GLuint GL_SPRITE_AXIAL_SGIX     = 0x814C;
const GLuint GL_SPRITE_OBJECT_ALIGNED_SGIX    = 0x814D;
const GLuint GL_SPRITE_EYE_ALIGNED_SGIX     = 0x814E;

// 53 - GL_SGIX_texture_multi_buffer
const GLuint GL_TEXTURE_MULTI_BUFFER_HINT_SGIX    = 0x812E;

// 54 - GL_EXT_point_parameters
const GLuint GL_POINT_SIZE_MIN_EXT      = 0x8126;
const GLuint GL_POINT_SIZE_MAX_EXT      = 0x8127;
const GLuint GL_POINT_FADE_THRESHOLD_SIZE_EXT   = 0x8128;
const GLuint GL_DISTANCE_ATTENUATION_EXT    = 0x8129;

// ? - GL_SGIS_point_parameters
const GLuint GL_POINT_SIZE_MIN_SGIS     = 0x8126;
const GLuint GL_POINT_SIZE_MAX_SGIS     = 0x8127;
const GLuint GL_POINT_FADE_THRESHOLD_SIZE_SGIS    = 0x8128;
const GLuint GL_DISTANCE_ATTENUATION_SGIS   = 0x8129;

// 55 - GL_SGIX_instruments
const GLuint GL_INSTRUMENT_BUFFER_POINTER_SGIX    = 0x8180;
const GLuint GL_INSTRUMENT_MEASUREMENTS_SGIX    = 0x8181;

// 56 - GL_SGIX_texture_scale_bias
const GLuint GL_POST_TEXTURE_FILTER_BIAS_SGIX   = 0x8179;
const GLuint GL_POST_TEXTURE_FILTER_SCALE_SGIX    = 0x817A;
const GLuint GL_POST_TEXTURE_FILTER_BIAS_RANGE_SGIX = 0x817B;
const GLuint GL_POST_TEXTURE_FILTER_SCALE_RANGE_SGIX  = 0x817C;

// 57 - GL_SGIX_framezoom
const GLuint GL_FRAMEZOOM_SGIX        = 0x818B;
const GLuint GL_FRAMEZOOM_FACTOR_SGIX     = 0x818C;
const GLuint GL_MAX_FRAMEZOOM_FACTOR_SGIX   = 0x818D;

// ? - GL_FfdMaskSGIX
const GLuint GL_TEXTURE_DEFORMATION_BIT_SGIX    = 0x00000001;
const GLuint GL_GEOMETRY_DEFORMATION_BIT_SGIX   = 0x00000002;

// ? - GL_SGIX_polynomial_ffd
const GLuint GL_GEOMETRY_DEFORMATION_SGIX   = 0x8194;
const GLuint GL_TEXTURE_DEFORMATION_SGIX    = 0x8195;
const GLuint GL_DEFORMATIONS_MASK_SGIX      = 0x8196;
const GLuint GL_MAX_DEFORMATION_ORDER_SGIX    = 0x8197;

// 60 - GL_SGIX_reference_plane
const GLuint GL_REFERENCE_PLANE_SGIX      = 0x817D;
const GLuint GL_REFERENCE_PLANE_EQUATION_SGIX   = 0x817E;

// 63 - GL_SGIX_depth_texture
const GLuint GL_DEPTH_COMPONENT16_SGIX      = 0x81A5;
const GLuint GL_DEPTH_COMPONENT24_SGIX      = 0x81A6;
const GLuint GL_DEPTH_COMPONENT32_SGIX      = 0x81A7;

// 64 - GL_SGIS_fog_function
const GLuint GL_FOG_FUNC_SGIS       = 0x812A;
const GLuint GL_FOG_FUNC_POINTS_SGIS      = 0x812B;
const GLuint GL_MAX_FOG_FUNC_POINTS_SGIS    = 0x812C;

// 65 - GL_SGIX_fog_offset
const GLuint GL_FOG_OFFSET_SGIX       = 0x8198;
const GLuint GL_FOG_OFFSET_VALUE_SGIX     = 0x8199;

// 66 - GL_HP_image_transform
const GLuint GL_IMAGE_SCALE_X_HP      = 0x8155;
const GLuint GL_IMAGE_SCALE_Y_HP      = 0x8156;
const GLuint GL_IMAGE_TRANSLATE_X_HP      = 0x8157;
const GLuint GL_IMAGE_TRANSLATE_Y_HP      = 0x8158;
const GLuint GL_IMAGE_ROTATE_ANGLE_HP     = 0x8159;
const GLuint GL_IMAGE_ROTATE_ORIGIN_X_HP    = 0x815A;
const GLuint GL_IMAGE_ROTATE_ORIGIN_Y_HP    = 0x815B;
const GLuint GL_IMAGE_MAG_FILTER_HP     = 0x815C;
const GLuint GL_IMAGE_MIN_FILTER_HP     = 0x815D;
const GLuint GL_IMAGE_CUBIC_WEIGHT_HP     = 0x815E;
const GLuint GL_CUBIC_HP        = 0x815F;
const GLuint GL_AVERAGE_HP        = 0x8160;
const GLuint GL_IMAGE_TRANSFORM_2D_HP     = 0x8161;
const GLuint GL_POST_IMAGE_TRANSFORM_COLOR_TABLE_HP = 0x8162;
const GLuint GL_PROXY_POST_IMAGE_TRANSFORM_COLOR_TABLE_HP= 0x8163;

// 67 - GL_HP_convolution_border_modes
const GLuint GL_IGNORE_BORDER_HP      = 0x8150;
const GLuint GL_CONSTANT_BORDER_HP      = 0x8151;
const GLuint GL_REPLICATE_BORDER_HP     = 0x8153;
const GLuint GL_CONVOLUTION_BORDER_COLOR_HP   = 0x8154;

// 69 - GL_SGIX_texture_add_env
const GLuint GL_TEXTURE_ENV_BIAS_SGIX     = 0x80BE;

// 76 - GL_PGI_vertex_hints
const GLuint GL_VERTEX_DATA_HINT_PGI      = 0x1A22A;
const GLuint GL_VERTEX_CONSISTENT_HINT_PGI    = 0x1A22B;
const GLuint GL_MATERIAL_SIDE_HINT_PGI      = 0x1A22C;
const GLuint GL_MAX_VERTEX_HINT_PGI     = 0x1A22D;
const GLuint GL_COLOR3_BIT_PGI        = 0x00010000;
const GLuint GL_COLOR4_BIT_PGI        = 0x00020000;
const GLuint GL_EDGEFLAG_BIT_PGI      = 0x00040000;
const GLuint GL_INDEX_BIT_PGI       = 0x00080000;
const GLuint GL_MAT_AMBIENT_BIT_PGI     = 0x00100000;
const GLuint GL_MAT_AMBIENT_AND_DIFFUSE_BIT_PGI   = 0x00200000;
const GLuint GL_MAT_DIFFUSE_BIT_PGI     = 0x00400000;
const GLuint GL_MAT_EMISSION_BIT_PGI      = 0x00800000;
const GLuint GL_MAT_COLOR_INDEXES_BIT_PGI   = 0x01000000;
const GLuint GL_MAT_SHININESS_BIT_PGI     = 0x02000000;
const GLuint GL_MAT_SPECULAR_BIT_PGI      = 0x04000000;
const GLuint GL_NORMAL_BIT_PGI        = 0x08000000;
const GLuint GL_TEXCOORD1_BIT_PGI     = 0x10000000;
const GLuint GL_TEXCOORD2_BIT_PGI     = 0x20000000;
const GLuint GL_TEXCOORD3_BIT_PGI     = 0x40000000;
const GLuint GL_TEXCOORD4_BIT_PGI     = 0x80000000;
const GLuint GL_VERTEX23_BIT_PGI      = 0x00000004;
const GLuint GL_VERTEX4_BIT_PGI       = 0x00000008;

// 77 - GL_PGI_misc_hints
const GLuint GL_PREFER_DOUBLEBUFFER_HINT_PGI    = 0x1A1F8;
const GLuint GL_CONSERVE_MEMORY_HINT_PGI    = 0x1A1FD;
const GLuint GL_RECLAIM_MEMORY_HINT_PGI     = 0x1A1FE;
const GLuint GL_NATIVE_GRAPHICS_HANDLE_PGI    = 0x1A202;
const GLuint GL_NATIVE_GRAPHICS_BEGIN_HINT_PGI    = 0x1A203;
const GLuint GL_NATIVE_GRAPHICS_END_HINT_PGI    = 0x1A204;
const GLuint GL_ALWAYS_FAST_HINT_PGI      = 0x1A20C;
const GLuint GL_ALWAYS_SOFT_HINT_PGI      = 0x1A20D;
const GLuint GL_ALLOW_DRAW_OBJ_HINT_PGI     = 0x1A20E;
const GLuint GL_ALLOW_DRAW_WIN_HINT_PGI     = 0x1A20F;
const GLuint GL_ALLOW_DRAW_FRG_HINT_PGI     = 0x1A210;
const GLuint GL_ALLOW_DRAW_MEM_HINT_PGI     = 0x1A211;
const GLuint GL_STRICT_DEPTHFUNC_HINT_PGI   = 0x1A216;
const GLuint GL_STRICT_LIGHTING_HINT_PGI    = 0x1A217;
const GLuint GL_STRICT_SCISSOR_HINT_PGI     = 0x1A218;
const GLuint GL_FULL_STIPPLE_HINT_PGI     = 0x1A219;
const GLuint GL_CLIP_NEAR_HINT_PGI      = 0x1A220;
const GLuint GL_CLIP_FAR_HINT_PGI     = 0x1A221;
const GLuint GL_WIDE_LINE_HINT_PGI      = 0x1A222;
const GLuint GL_BACK_NORMALS_HINT_PGI     = 0x1A223;

// 78 - GL_EXT_paletted_texture
const GLuint GL_COLOR_INDEX1_EXT      = 0x80E2;
const GLuint GL_COLOR_INDEX2_EXT      = 0x80E3;
const GLuint GL_COLOR_INDEX4_EXT      = 0x80E4;
const GLuint GL_COLOR_INDEX8_EXT      = 0x80E5;
const GLuint GL_COLOR_INDEX12_EXT     = 0x80E6;
const GLuint GL_COLOR_INDEX16_EXT     = 0x80E7;
const GLuint GL_TEXTURE_INDEX_SIZE_EXT      = 0x80ED;

// 79 - GL_EXT_clip_volume_hint
const GLuint GL_CLIP_VOLUME_CLIPPING_HINT_EXT   = 0x80F0;

// 80 - GL_SGIX_list_priority
const GLuint GL_LIST_PRIORITY_SGIX      = 0x8182;

// 81 - GL_SGIX_ir_instrument1
const GLuint GL_IR_INSTRUMENT1_SGIX     = 0x817F;

// ? - GL_SGIX_calligraphic_fragment
const GLuint GL_CALLIGRAPHIC_FRAGMENT_SGIX    = 0x8183;

// 84 - GL_SGIX_texture_lod_bias
const GLuint GL_TEXTURE_LOD_BIAS_S_SGIX     = 0x818E;
const GLuint GL_TEXTURE_LOD_BIAS_T_SGIX     = 0x818F;
const GLuint GL_TEXTURE_LOD_BIAS_R_SGIX     = 0x8190;

// 90 - GL_SGIX_shadow_ambient
const GLuint GL_SHADOW_AMBIENT_SGIX     = 0x80BF;

// 94 - GL_EXT_index_material
const GLuint GL_INDEX_MATERIAL_EXT      = 0x81B8;
const GLuint GL_INDEX_MATERIAL_PARAMETER_EXT    = 0x81B9;
const GLuint GL_INDEX_MATERIAL_FACE_EXT     = 0x81BA;

// 95 - GL_EXT_index_func
const GLuint GL_INDEX_TEST_EXT        = 0x81B5;
const GLuint GL_INDEX_TEST_FUNC_EXT     = 0x81B6;
const GLuint GL_INDEX_TEST_REF_EXT      = 0x81B7;

// 96 - GL_EXT_index_array_formats
const GLuint GL_IUI_V2F_EXT       = 0x81AD;
const GLuint GL_IUI_V3F_EXT       = 0x81AE;
const GLuint GL_IUI_N3F_V2F_EXT       = 0x81AF;
const GLuint GL_IUI_N3F_V3F_EXT       = 0x81B0;
const GLuint GL_T2F_IUI_V2F_EXT       = 0x81B1;
const GLuint GL_T2F_IUI_V3F_EXT       = 0x81B2;
const GLuint GL_T2F_IUI_N3F_V2F_EXT     = 0x81B3;
const GLuint GL_T2F_IUI_N3F_V3F_EXT     = 0x81B4;

// 97 - GL_EXT_compiled_vertex_array
const GLuint GL_ARRAY_ELEMENT_LOCK_FIRST_EXT    = 0x81A8;
const GLuint GL_ARRAY_ELEMENT_LOCK_COUNT_EXT    = 0x81A9;

// 98 - GL_EXT_cull_vertex
const GLuint GL_CULL_VERTEX_EXT       = 0x81AA;
const GLuint GL_CULL_VERTEX_EYE_POSITION_EXT    = 0x81AB;
const GLuint GL_CULL_VERTEX_OBJECT_POSITION_EXT   = 0x81AC;

// 101 - GL_SGIX_ycrcb
const GLuint GL_YCRCB_422_SGIX        = 0x81BB;
const GLuint GL_YCRCB_444_SGIX        = 0x81BC;

// 102 - GL_SGIX_fragment_lighting
const GLuint GL_FRAGMENT_LIGHTING_SGIX      = 0x8400;
const GLuint GL_FRAGMENT_COLOR_MATERIAL_SGIX    = 0x8401;
const GLuint GL_FRAGMENT_COLOR_MATERIAL_FACE_SGIX = 0x8402;
const GLuint GL_FRAGMENT_COLOR_MATERIAL_PARAMETER_SGIX  = 0x8403;
const GLuint GL_MAX_FRAGMENT_LIGHTS_SGIX    = 0x8404;
const GLuint GL_MAX_ACTIVE_LIGHTS_SGIX      = 0x8405;
const GLuint GL_CURRENT_RASTER_NORMAL_SGIX    = 0x8406;
const GLuint GL_LIGHT_ENV_MODE_SGIX     = 0x8407;
const GLuint GL_FRAGMENT_LIGHT_MODEL_LOCAL_VIEWER_SGIX  = 0x8408;
const GLuint GL_FRAGMENT_LIGHT_MODEL_TWO_SIDE_SGIX  = 0x8409;
const GLuint GL_FRAGMENT_LIGHT_MODEL_AMBIENT_SGIX = 0x840A;
const GLuint GL_FRAGMENT_LIGHT_MODEL_NORMAL_INTERPOLATION_SGIX= 0x840B;
const GLuint GL_FRAGMENT_LIGHT0_SGIX      = 0x840C;
const GLuint GL_FRAGMENT_LIGHT1_SGIX      = 0x840D;
const GLuint GL_FRAGMENT_LIGHT2_SGIX      = 0x840E;
const GLuint GL_FRAGMENT_LIGHT3_SGIX      = 0x840F;
const GLuint GL_FRAGMENT_LIGHT4_SGIX      = 0x8410;
const GLuint GL_FRAGMENT_LIGHT5_SGIX      = 0x8411;
const GLuint GL_FRAGMENT_LIGHT6_SGIX      = 0x8412;
const GLuint GL_FRAGMENT_LIGHT7_SGIX      = 0x8413;

// 110 - GL_IBM_rasterpos_clip
const GLuint GL_RASTER_POSITION_UNCLIPPED_IBM   = 0x19262;

// 111 - GL_HP_texture_lighting
const GLuint GL_TEXTURE_LIGHTING_MODE_HP    = 0x8167;
const GLuint GL_TEXTURE_POST_SPECULAR_HP    = 0x8168;
const GLuint GL_TEXTURE_PRE_SPECULAR_HP     = 0x8169;

// 112 - GL_EXT_draw_range_elements
const GLuint GL_MAX_ELEMENTS_VERTICES_EXT   = 0x80E8;
const GLuint GL_MAX_ELEMENTS_INDICES_EXT    = 0x80E9;

// 113 - GL_WIN_phong_shading
const GLuint GL_PHONG_WIN       = 0x80EA;
const GLuint GL_PHONG_HINT_WIN        = 0x80EB;

// 114 - GL_WIN_specular_fog
const GLuint GL_FOG_SPECULAR_TEXTURE_WIN    = 0x80EC;

// 117 - GL_EXT_light_texture
const GLuint GL_FRAGMENT_MATERIAL_EXT     = 0x8349;
const GLuint GL_FRAGMENT_NORMAL_EXT     = 0x834A;
const GLuint GL_FRAGMENT_COLOR_EXT      = 0x834C;
const GLuint GL_ATTENUATION_EXT       = 0x834D;
const GLuint GL_SHADOW_ATTENUATION_EXT      = 0x834E;
const GLuint GL_TEXTURE_APPLICATION_MODE_EXT    = 0x834F;
const GLuint GL_TEXTURE_LIGHT_EXT     = 0x8350;
const GLuint GL_TEXTURE_MATERIAL_FACE_EXT   = 0x8351;
const GLuint GL_TEXTURE_MATERIAL_PARAMETER_EXT    = 0x8352;

// 119 - GL_SGIX_blend_alpha_minmax
const GLuint GL_ALPHA_MIN_SGIX        = 0x8320;
const GLuint GL_ALPHA_MAX_SGIX        = 0x8321;

// ? - GL_SGIX_impact_pixel_texture
const GLuint GL_PIXEL_TEX_GEN_Q_CEILING_SGIX    = 0x8184;
const GLuint GL_PIXEL_TEX_GEN_Q_ROUND_SGIX    = 0x8185;
const GLuint GL_PIXEL_TEX_GEN_Q_FLOOR_SGIX    = 0x8186;
const GLuint GL_PIXEL_TEX_GEN_ALPHA_REPLACE_SGIX  = 0x8187;
const GLuint GL_PIXEL_TEX_GEN_ALPHA_NO_REPLACE_SGIX = 0x8188;
const GLuint GL_PIXEL_TEX_GEN_ALPHA_LS_SGIX   = 0x8189;
const GLuint GL_PIXEL_TEX_GEN_ALPHA_MS_SGIX   = 0x818A;

// 129 - GL_EXT_bgra
const GLuint GL_BGR_EXT         = 0x80E0;
const GLuint GL_BGRA_EXT        = 0x80E1;

// 132 - GL_SGIX_async
const GLuint GL_ASYNC_MARKER_SGIX     = 0x8329;

// 133 - GL_SGIX_async_pixel
const GLuint GL_ASYNC_TEX_IMAGE_SGIX      = 0x835C;
const GLuint GL_ASYNC_DRAW_PIXELS_SGIX      = 0x835D;
const GLuint GL_ASYNC_READ_PIXELS_SGIX      = 0x835E;
const GLuint GL_MAX_ASYNC_TEX_IMAGE_SGIX    = 0x835F;
const GLuint GL_MAX_ASYNC_DRAW_PIXELS_SGIX    = 0x8360;
const GLuint GL_MAX_ASYNC_READ_PIXELS_SGIX    = 0x8361;

// 134 - GL_SGIX_async_histogram
const GLuint GL_ASYNC_HISTOGRAM_SGIX      = 0x832C;
const GLuint GL_MAX_ASYNC_HISTOGRAM_SGIX    = 0x832D;

// 136 - GL_INTEL_parallel_arrays
const GLuint GL_PARALLEL_ARRAYS_INTEL     = 0x83F4;
const GLuint GL_VERTEX_ARRAY_PARALLEL_POINTERS_INTEL  = 0x83F5;
const GLuint GL_NORMAL_ARRAY_PARALLEL_POINTERS_INTEL  = 0x83F6;
const GLuint GL_COLOR_ARRAY_PARALLEL_POINTERS_INTEL = 0x83F7;
const GLuint GL_TEXTURE_COORD_ARRAY_PARALLEL_POINTERS_INTEL= 0x83F8;

// 137 - GL_HP_occlusion_test
const GLuint GL_OCCLUSION_TEST_HP     = 0x8165;
const GLuint GL_OCCLUSION_TEST_RESULT_HP    = 0x8166;

// 138 - GL_EXT_pixel_transform
const GLuint GL_PIXEL_TRANSFORM_2D_EXT      = 0x8330;
const GLuint GL_PIXEL_MAG_FILTER_EXT      = 0x8331;
const GLuint GL_PIXEL_MIN_FILTER_EXT      = 0x8332;
const GLuint GL_PIXEL_CUBIC_WEIGHT_EXT      = 0x8333;
const GLuint GL_CUBIC_EXT       = 0x8334;
const GLuint GL_AVERAGE_EXT       = 0x8335;
const GLuint GL_PIXEL_TRANSFORM_2D_STACK_DEPTH_EXT  = 0x8336;
const GLuint GL_MAX_PIXEL_TRANSFORM_2D_STACK_DEPTH_EXT  = 0x8337;
const GLuint GL_PIXEL_TRANSFORM_2D_MATRIX_EXT   = 0x8338;

// 141 - GL_EXT_shared_texture_palette
const GLuint GL_SHARED_TEXTURE_PALETTE_EXT    = 0x81FB;

// 144 - GL_EXT_separate_specular_color
const GLuint GL_LIGHT_MODEL_COLOR_CONTROL_EXT   = 0x81F8;
const GLuint GL_SINGLE_COLOR_EXT      = 0x81F9;
const GLuint GL_SEPARATE_SPECULAR_COLOR_EXT   = 0x81FA;

// 145 - GL_EXT_secondary_color
const GLuint GL_COLOR_SUM_EXT       = 0x8458;
const GLuint GL_CURRENT_SECONDARY_COLOR_EXT   = 0x8459;
const GLuint GL_SECONDARY_COLOR_ARRAY_SIZE_EXT    = 0x845A;
const GLuint GL_SECONDARY_COLOR_ARRAY_TYPE_EXT    = 0x845B;
const GLuint GL_SECONDARY_COLOR_ARRAY_STRIDE_EXT  = 0x845C;
const GLuint GL_SECONDARY_COLOR_ARRAY_POINTER_EXT = 0x845D;
const GLuint GL_SECONDARY_COLOR_ARRAY_EXT   = 0x845E;

// 147 - GL_EXT_texture_perturb_normal
const GLuint GL_PERTURB_EXT       = 0x85AE;
const GLuint GL_TEXTURE_NORMAL_EXT      = 0x85AF;

// 149 GL_EXT_fog_coord
const GLuint GL_FOG_COORDINATE_SOURCE_EXT   = 0x8450;
const GLuint GL_FOG_COORDINATE_EXT      = 0x8451;
const GLuint GL_FRAGMENT_DEPTH_EXT      = 0x8452;
const GLuint GL_CURRENT_FOG_COORDINATE_EXT    = 0x8453;
const GLuint GL_FOG_COORDINATE_ARRAY_TYPE_EXT   = 0x8454;
const GLuint GL_FOG_COORDINATE_ARRAY_STRIDE_EXT   = 0x8455;
const GLuint GL_FOG_COORDINATE_ARRAY_POINTER_EXT  = 0x8456;
const GLuint GL_FOG_COORDINATE_ARRAY_EXT    = 0x8457;

// 155 - GL_REND_screen_coordinates
const GLuint GL_SCREEN_COORDINATES_REND     = 0x8490;
const GLuint GL_INVERTED_SCREEN_W_REND      = 0x8491;

// 156 - GL_EXT_coordinate_frame
const GLuint GL_TANGENT_ARRAY_EXT     = 0x8439;
const GLuint GL_BINORMAL_ARRAY_EXT      = 0x843A;
const GLuint GL_CURRENT_TANGENT_EXT     = 0x843B;
const GLuint GL_CURRENT_BINORMAL_EXT      = 0x843C;
const GLuint GL_TANGENT_ARRAY_TYPE_EXT      = 0x843E;
const GLuint GL_TANGENT_ARRAY_STRIDE_EXT    = 0x843F;
const GLuint GL_BINORMAL_ARRAY_TYPE_EXT     = 0x8440;
const GLuint GL_BINORMAL_ARRAY_STRIDE_EXT   = 0x8441;
const GLuint GL_TANGENT_ARRAY_POINTER_EXT   = 0x8442;
const GLuint GL_BINORMAL_ARRAY_POINTER_EXT    = 0x8443;
const GLuint GL_MAP1_TANGENT_EXT      = 0x8444;
const GLuint GL_MAP2_TANGENT_EXT      = 0x8445;
const GLuint GL_MAP1_BINORMAL_EXT     = 0x8446;
const GLuint GL_MAP2_BINORMAL_EXT     = 0x8447;

// 158 - GL_EXT_texture_env_combine
const GLuint GL_COMBINE_EXT       = 0x8570;
const GLuint GL_COMBINE_RGB_EXT       = 0x8571;
const GLuint GL_COMBINE_ALPHA_EXT     = 0x8572;
const GLuint GL_RGB_SCALE_EXT       = 0x8573;
const GLuint GL_ADD_SIGNED_EXT        = 0x8574;
const GLuint GL_INTERPOLATE_EXT       = 0x8575;
const GLuint GL_CONSTANT_EXT        = 0x8576;
const GLuint GL_PRIMARY_COLOR_EXT     = 0x8577;
const GLuint GL_PREVIOUS_EXT        = 0x8578;
const GLuint GL_SOURCE0_RGB_EXT       = 0x8580;
const GLuint GL_SOURCE1_RGB_EXT       = 0x8581;
const GLuint GL_SOURCE2_RGB_EXT       = 0x8582;
const GLuint GL_SOURCE0_ALPHA_EXT     = 0x8588;
const GLuint GL_SOURCE1_ALPHA_EXT     = 0x8589;
const GLuint GL_SOURCE2_ALPHA_EXT     = 0x858A;
const GLuint GL_OPERAND0_RGB_EXT      = 0x8590;
const GLuint GL_OPERAND1_RGB_EXT      = 0x8591;
const GLuint GL_OPERAND2_RGB_EXT      = 0x8592;
const GLuint GL_OPERAND0_ALPHA_EXT      = 0x8598;
const GLuint GL_OPERAND1_ALPHA_EXT      = 0x8599;
const GLuint GL_OPERAND2_ALPHA_EXT      = 0x859A;

// 159 - GL_APPLE_specular_vector
const GLuint GL_LIGHT_MODEL_SPECULAR_VECTOR_APPLE = 0x85B0;

// 160 - GL_APPLE_transform_hint
const GLuint GL_TRANSFORM_HINT_APPLE      = 0x85B1;

// ? - GL_SGIX_fog_scale
const GLuint GL_FOG_SCALE_SGIX        = 0x81FC;
const GLuint GL_FOG_SCALE_VALUE_SGIX      = 0x81FD;

// 163 - GL_SUNX_constant_data
const GLuint GL_UNPACK_CONSTANT_DATA_SUNX   = 0x81D5;
const GLuint GL_TEXTURE_CONSTANT_DATA_SUNX    = 0x81D6;

// 164 - GL_SUN_global_alpha
const GLuint GL_GLOBAL_ALPHA_SUN      = 0x81D9;
const GLuint GL_GLOBAL_ALPHA_FACTOR_SUN     = 0x81DA;

// 165 - GL_SUN_triangle_list
const GLuint GL_RESTART_SUN       = 0x0001;
const GLuint GL_REPLACE_MIDDLE_SUN      = 0x0002;
const GLuint GL_REPLACE_OLDEST_SUN      = 0x0003;
const GLuint GL_TRIANGLE_LIST_SUN     = 0x81D7;
const GLuint GL_REPLACEMENT_CODE_SUN      = 0x81D8;
const GLuint GL_REPLACEMENT_CODE_ARRAY_SUN    = 0x85C0;
const GLuint GL_REPLACEMENT_CODE_ARRAY_TYPE_SUN   = 0x85C1;
const GLuint GL_REPLACEMENT_CODE_ARRAY_STRIDE_SUN = 0x85C2;
const GLuint GL_REPLACEMENT_CODE_ARRAY_POINTER_SUN  = 0x85C3;
const GLuint GL_R1UI_V3F_SUN        = 0x85C4;
const GLuint GL_R1UI_C4UB_V3F_SUN     = 0x85C5;
const GLuint GL_R1UI_C3F_V3F_SUN      = 0x85C6;
const GLuint GL_R1UI_N3F_V3F_SUN      = 0x85C7;
const GLuint GL_R1UI_C4F_N3F_V3F_SUN      = 0x85C8;
const GLuint GL_R1UI_T2F_V3F_SUN      = 0x85C9;
const GLuint GL_R1UI_T2F_N3F_V3F_SUN      = 0x85CA;
const GLuint GL_R1UI_T2F_C4F_N3F_V3F_SUN    = 0x85CB;

// 173 - GL_EXT_blend_func_separate
const GLuint GL_BLEND_DST_RGB_EXT     = 0x80C8;
const GLuint GL_BLEND_SRC_RGB_EXT     = 0x80C9;
const GLuint GL_BLEND_DST_ALPHA_EXT     = 0x80CA;
const GLuint GL_BLEND_SRC_ALPHA_EXT     = 0x80CB;

// 174 - GL_INGR_color_clamp
const GLuint GL_RED_MIN_CLAMP_INGR      = 0x8560;
const GLuint GL_GREEN_MIN_CLAMP_INGR      = 0x8561;
const GLuint GL_BLUE_MIN_CLAMP_INGR     = 0x8562;
const GLuint GL_ALPHA_MIN_CLAMP_INGR      = 0x8563;
const GLuint GL_RED_MAX_CLAMP_INGR      = 0x8564;
const GLuint GL_GREEN_MAX_CLAMP_INGR      = 0x8565;
const GLuint GL_BLUE_MAX_CLAMP_INGR     = 0x8566;
const GLuint GL_ALPHA_MAX_CLAMP_INGR      = 0x8567;

// 175 - GL_INGR_interlace_read
const GLuint GL_INTERLACE_READ_INGR     = 0x8568;

// 176 - GL_EXT_stencil_wrap
const GLuint GL_INCR_WRAP_EXT       = 0x8507;
const GLuint GL_DECR_WRAP_EXT       = 0x8508;

// 178 - GL_EXT_422_pixels
const GLuint GL_422_EXT         = 0x80CC;
const GLuint GL_422_REV_EXT       = 0x80CD;
const GLuint GL_422_AVERAGE_EXT       = 0x80CE;
const GLuint GL_422_REV_AVERAGE_EXT     = 0x80CF;

// 179 - GL_NV_texgen_reflection
const GLuint GL_NORMAL_MAP_NV       = 0x8511;
const GLuint GL_REFLECTION_MAP_NV     = 0x8512;

// ? - GL_EXT_texture_cube_map
const GLuint GL_NORMAL_MAP_EXT        = 0x8511;
const GLuint GL_REFLECTION_MAP_EXT      = 0x8512;
const GLuint GL_TEXTURE_CUBE_MAP_EXT      = 0x8513;
const GLuint GL_TEXTURE_BINDING_CUBE_MAP_EXT    = 0x8514;
const GLuint GL_TEXTURE_CUBE_MAP_POSITIVE_X_EXT   = 0x8515;
const GLuint GL_TEXTURE_CUBE_MAP_NEGATIVE_X_EXT   = 0x8516;
const GLuint GL_TEXTURE_CUBE_MAP_POSITIVE_Y_EXT   = 0x8517;
const GLuint GL_TEXTURE_CUBE_MAP_NEGATIVE_Y_EXT   = 0x8518;
const GLuint GL_TEXTURE_CUBE_MAP_POSITIVE_Z_EXT   = 0x8519;
const GLuint GL_TEXTURE_CUBE_MAP_NEGATIVE_Z_EXT   = 0x851A;
const GLuint GL_PROXY_TEXTURE_CUBE_MAP_EXT    = 0x851B;
const GLuint GL_MAX_CUBE_MAP_TEXTURE_SIZE_EXT   = 0x851C;

// 182 - GL_SUN_convolution_border_modes
const GLuint GL_WRAP_BORDER_SUN       = 0x81D4;

// 186 - GL_EXT_texture_lod_bias
const GLuint GL_MAX_TEXTURE_LOD_BIAS_EXT    = 0x84FD;
const GLuint GL_TEXTURE_FILTER_CONTROL_EXT    = 0x8500;
const GLuint GL_TEXTURE_LOD_BIAS_EXT      = 0x8501;

// 187 - GL_EXT_texture_filter_anisotropic
const GLuint GL_TEXTURE_MAX_ANISOTROPY_EXT    = 0x84FE;
const GLuint GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT    = 0x84FF;

// 188 - GL_EXT_vertex_weighting
const GLuint GL_MODELVIEW0_STACK_DEPTH_EXT    = GL_MODELVIEW_STACK_DEPTH;
const GLuint GL_MODELVIEW1_STACK_DEPTH_EXT    = 0x8502;
const GLuint GL_MODELVIEW0_MATRIX_EXT     = GL_MODELVIEW_MATRIX;
const GLuint GL_MODELVIEW1_MATRIX_EXT     = 0x8506;
const GLuint GL_VERTEX_WEIGHTING_EXT      = 0x8509;
const GLuint GL_MODELVIEW0_EXT        = GL_MODELVIEW;
const GLuint GL_MODELVIEW1_EXT        = 0x850A;
const GLuint GL_CURRENT_VERTEX_WEIGHT_EXT   = 0x850B;
const GLuint GL_VERTEX_WEIGHT_ARRAY_EXT     = 0x850C;
const GLuint GL_VERTEX_WEIGHT_ARRAY_SIZE_EXT    = 0x850D;
const GLuint GL_VERTEX_WEIGHT_ARRAY_TYPE_EXT    = 0x850E;
const GLuint GL_VERTEX_WEIGHT_ARRAY_STRIDE_EXT    = 0x850F;
const GLuint GL_VERTEX_WEIGHT_ARRAY_POINTER_EXT   = 0x8510;

// 189 - GL_NV_light_max_exponent
const GLuint GL_MAX_SHININESS_NV      = 0x8504;
const GLuint GL_MAX_SPOT_EXPONENT_NV      = 0x8505;

// 190 - GL_NV_vertex_array_range
const GLuint GL_VERTEX_ARRAY_RANGE_NV     = 0x851D;
const GLuint GL_VERTEX_ARRAY_RANGE_LENGTH_NV    = 0x851E;
const GLuint GL_VERTEX_ARRAY_RANGE_VALID_NV   = 0x851F;
const GLuint GL_MAX_VERTEX_ARRAY_RANGE_ELEMENT_NV = 0x8520;
const GLuint GL_VERTEX_ARRAY_RANGE_POINTER_NV   = 0x8521;

// 191 - GL_NV_register_combiners
const GLuint GL_REGISTER_COMBINERS_NV     = 0x8522;
const GLuint GL_VARIABLE_A_NV       = 0x8523;
const GLuint GL_VARIABLE_B_NV       = 0x8524;
const GLuint GL_VARIABLE_C_NV       = 0x8525;
const GLuint GL_VARIABLE_D_NV       = 0x8526;
const GLuint GL_VARIABLE_E_NV       = 0x8527;
const GLuint GL_VARIABLE_F_NV       = 0x8528;
const GLuint GL_VARIABLE_G_NV       = 0x8529;
const GLuint GL_CONSTANT_COLOR0_NV      = 0x852A;
const GLuint GL_CONSTANT_COLOR1_NV      = 0x852B;
const GLuint GL_PRIMARY_COLOR_NV      = 0x852C;
const GLuint GL_SECONDARY_COLOR_NV      = 0x852D;
const GLuint GL_SPARE0_NV       = 0x852E;
const GLuint GL_SPARE1_NV       = 0x852F;
const GLuint GL_DISCARD_NV        = 0x8530;
const GLuint GL_E_TIMES_F_NV        = 0x8531;
const GLuint GL_SPARE0_PLUS_SECONDARY_COLOR_NV    = 0x8532;
const GLuint GL_UNSIGNED_IDENTITY_NV      = 0x8536;
const GLuint GL_UNSIGNED_INVERT_NV      = 0x8537;
const GLuint GL_EXPAND_NORMAL_NV      = 0x8538;
const GLuint GL_EXPAND_NEGATE_NV      = 0x8539;
const GLuint GL_HALF_BIAS_NORMAL_NV     = 0x853A;
const GLuint GL_HALF_BIAS_NEGATE_NV     = 0x853B;
const GLuint GL_SIGNED_IDENTITY_NV      = 0x853C;
const GLuint GL_SIGNED_NEGATE_NV      = 0x853D;
const GLuint GL_SCALE_BY_TWO_NV       = 0x853E;
const GLuint GL_SCALE_BY_FOUR_NV      = 0x853F;
const GLuint GL_SCALE_BY_ONE_HALF_NV      = 0x8540;
const GLuint GL_BIAS_BY_NEGATIVE_ONE_HALF_NV    = 0x8541;
const GLuint GL_COMBINER_INPUT_NV     = 0x8542;
const GLuint GL_COMBINER_MAPPING_NV     = 0x8543;
const GLuint GL_COMBINER_COMPONENT_USAGE_NV   = 0x8544;
const GLuint GL_COMBINER_AB_DOT_PRODUCT_NV    = 0x8545;
const GLuint GL_COMBINER_CD_DOT_PRODUCT_NV    = 0x8546;
const GLuint GL_COMBINER_MUX_SUM_NV     = 0x8547;
const GLuint GL_COMBINER_SCALE_NV     = 0x8548;
const GLuint GL_COMBINER_BIAS_NV      = 0x8549;
const GLuint GL_COMBINER_AB_OUTPUT_NV     = 0x854A;
const GLuint GL_COMBINER_CD_OUTPUT_NV     = 0x854B;
const GLuint GL_COMBINER_SUM_OUTPUT_NV      = 0x854C;
const GLuint GL_MAX_GENERAL_COMBINERS_NV    = 0x854D;
const GLuint GL_NUM_GENERAL_COMBINERS_NV    = 0x854E;
const GLuint GL_COLOR_SUM_CLAMP_NV      = 0x854F;
const GLuint GL_COMBINER0_NV        = 0x8550;
const GLuint GL_COMBINER1_NV        = 0x8551;
const GLuint GL_COMBINER2_NV        = 0x8552;
const GLuint GL_COMBINER3_NV        = 0x8553;
const GLuint GL_COMBINER4_NV        = 0x8554;
const GLuint GL_COMBINER5_NV        = 0x8555;
const GLuint GL_COMBINER6_NV        = 0x8556;
const GLuint GL_COMBINER7_NV        = 0x8557;

// 192 - GL_NV_fog_distance
const GLuint GL_FOG_DISTANCE_MODE_NV      = 0x855A;
const GLuint GL_EYE_RADIAL_NV       = 0x855B;
const GLuint GL_EYE_PLANE_ABSOLUTE_NV     = 0x855C;

// 193 - GL_NV_texgen_emboss
const GLuint GL_EMBOSS_LIGHT_NV       = 0x855D;
const GLuint GL_EMBOSS_CONSTANT_NV      = 0x855E;
const GLuint GL_EMBOSS_MAP_NV       = 0x855F;

// 195 - GL_NV_texture_env_combine4
const GLuint GL_COMBINE4_NV       = 0x8503;
const GLuint GL_SOURCE3_RGB_NV        = 0x8583;
const GLuint GL_SOURCE3_ALPHA_NV      = 0x858B;
const GLuint GL_OPERAND3_RGB_NV       = 0x8593;
const GLuint GL_OPERAND3_ALPHA_NV     = 0x859B;

// 198 - GL_EXT_texture_compression_s3tc
const GLuint GL_COMPRESSED_RGB_S3TC_DXT1_EXT    = 0x83F0;
const GLuint GL_COMPRESSED_RGBA_S3TC_DXT1_EXT   = 0x83F1;
const GLuint GL_COMPRESSED_RGBA_S3TC_DXT3_EXT   = 0x83F2;
const GLuint GL_COMPRESSED_RGBA_S3TC_DXT5_EXT   = 0x83F3;

// 199 - GL_IBM_cull_vertex
const GLuint GL_CULL_VERTEX_IBM       = 103050;

// 201 - GL_IBM_vertex_array_lists
const GLuint GL_VERTEX_ARRAY_LIST_IBM     = 103070;
const GLuint GL_NORMAL_ARRAY_LIST_IBM     = 103071;
const GLuint GL_COLOR_ARRAY_LIST_IBM      = 103072;
const GLuint GL_INDEX_ARRAY_LIST_IBM      = 103073;
const GLuint GL_TEXTURE_COORD_ARRAY_LIST_IBM    = 103074;
const GLuint GL_EDGE_FLAG_ARRAY_LIST_IBM    = 103075;
const GLuint GL_FOG_COORDINATE_ARRAY_LIST_IBM   = 103076;
const GLuint GL_SECONDARY_COLOR_ARRAY_LIST_IBM    = 103077;
const GLuint GL_VERTEX_ARRAY_LIST_STRIDE_IBM    = 103080;
const GLuint GL_NORMAL_ARRAY_LIST_STRIDE_IBM    = 103081;
const GLuint GL_COLOR_ARRAY_LIST_STRIDE_IBM   = 103082;
const GLuint GL_INDEX_ARRAY_LIST_STRIDE_IBM   = 103083;
const GLuint GL_TEXTURE_COORD_ARRAY_LIST_STRIDE_IBM = 103084;
const GLuint GL_EDGE_FLAG_ARRAY_LIST_STRIDE_IBM   = 103085;
const GLuint GL_FOG_COORDINATE_ARRAY_LIST_STRIDE_IBM  = 103086;
const GLuint GL_SECONDARY_COLOR_ARRAY_LIST_STRIDE_IBM = 103087;

// ? - GL_SGIX_subsample
const GLuint GL_PACK_SUBSAMPLE_RATE_SGIX    = 0x85A0;
const GLuint GL_UNPACK_SUBSAMPLE_RATE_SGIX    = 0x85A1;
const GLuint GL_PIXEL_SUBSAMPLE_4444_SGIX   = 0x85A2;
const GLuint GL_PIXEL_SUBSAMPLE_2424_SGIX   = 0x85A3;
const GLuint GL_PIXEL_SUBSAMPLE_4242_SGIX   = 0x85A4;

// ? - GL_SGIX_ycrcba
const GLuint GL_YCRCB_SGIX        = 0x8318;
const GLuint GL_YCRCBA_SGIX       = 0x8319;

// ? - GL_SGI_depth_pass_instrument
const GLuint GL_DEPTH_PASS_INSTRUMENT_SGIX    = 0x8310;
const GLuint GL_DEPTH_PASS_INSTRUMENT_COUNTERS_SGIX = 0x8311;
const GLuint GL_DEPTH_PASS_INSTRUMENT_MAX_SGIX    = 0x8312;

// 206 - GL_3DFX_texture_compression_FXT1
const GLuint GL_COMPRESSED_RGB_FXT1_3DFX    = 0x86B0;
const GLuint GL_COMPRESSED_RGBA_FXT1_3DFX   = 0x86B1;

// 207 - GL_3DFX_multisample
const GLuint GL_MULTISAMPLE_3DFX      = 0x86B2;
const GLuint GL_SAMPLE_BUFFERS_3DFX     = 0x86B3;
const GLuint GL_SAMPLES_3DFX        = 0x86B4;
const GLuint GL_MULTISAMPLE_BIT_3DFX      = 0x20000000;

// 209 - GL_EXT_multisample
const GLuint GL_MULTISAMPLE_EXT       = 0x809D;
const GLuint GL_SAMPLE_ALPHA_TO_MASK_EXT    = 0x809E;
const GLuint GL_SAMPLE_ALPHA_TO_ONE_EXT     = 0x809F;
const GLuint GL_SAMPLE_MASK_EXT       = 0x80A0;
const GLuint GL_1PASS_EXT       = 0x80A1;
const GLuint GL_2PASS_0_EXT       = 0x80A2;
const GLuint GL_2PASS_1_EXT       = 0x80A3;
const GLuint GL_4PASS_0_EXT       = 0x80A4;
const GLuint GL_4PASS_1_EXT       = 0x80A5;
const GLuint GL_4PASS_2_EXT       = 0x80A6;
const GLuint GL_4PASS_3_EXT       = 0x80A7;
const GLuint GL_SAMPLE_BUFFERS_EXT      = 0x80A8;
const GLuint GL_SAMPLES_EXT       = 0x80A9;
const GLuint GL_SAMPLE_MASK_VALUE_EXT     = 0x80AA;
const GLuint GL_SAMPLE_MASK_INVERT_EXT      = 0x80AB;
const GLuint GL_SAMPLE_PATTERN_EXT      = 0x80AC;
const GLuint GL_MULTISAMPLE_BIT_EXT     = 0x20000000;

// 210 - GL_SGIX_vertex_preclip
const GLuint GL_VERTEX_PRECLIP_SGIX     = 0x83EE;
const GLuint GL_VERTEX_PRECLIP_HINT_SGIX    = 0x83EF;

// ? - GL_SGIX_convolution_accuracy
const GLuint GL_CONVOLUTION_HINT_SGIX     = 0x8316;

// 212 - GL_SGIX_resample
const GLuint GL_PACK_RESAMPLE_SGIX      = 0x842C;
const GLuint GL_UNPACK_RESAMPLE_SGIX      = 0x842D;
const GLuint GL_RESAMPLE_REPLICATE_SGIX     = 0x842E;
const GLuint GL_RESAMPLE_ZERO_FILL_SGIX     = 0x842F;
const GLuint GL_RESAMPLE_DECIMATE_SGIX      = 0x8430;

// ? - GL_SGIS_point_line_texgen
const GLuint GL_EYE_DISTANCE_TO_POINT_SGIS    = 0x81F0;
const GLuint GL_OBJECT_DISTANCE_TO_POINT_SGIS   = 0x81F1;
const GLuint GL_EYE_DISTANCE_TO_LINE_SGIS   = 0x81F2;
const GLuint GL_OBJECT_DISTANCE_TO_LINE_SGIS    = 0x81F3;
const GLuint GL_EYE_POINT_SGIS        = 0x81F4;
const GLuint GL_OBJECT_POINT_SGIS     = 0x81F5;
const GLuint GL_EYE_LINE_SGIS       = 0x81F6;
const GLuint GL_OBJECT_LINE_SGIS      = 0x81F7;

// 214 - GL_SGIS_texture_color_mask
const GLuint GL_TEXTURE_COLOR_WRITEMASK_SGIS    = 0x81EF;

// 220 - GL_EXT_texture_env_dot3
const GLuint GL_DOT3_RGB_EXT        = 0x8740;
const GLuint GL_DOT3_RGBA_EXT       = 0x8741;

// 221 - GL_ATI_texture_mirror_once
const GLuint GL_MIRROR_CLAMP_ATI      = 0x8742;
const GLuint GL_MIRROR_CLAMP_TO_EDGE_ATI    = 0x8743;

// 222 - GL_NV_fence
const GLuint GL_ALL_COMPLETED_NV      = 0x84F2;
const GLuint GL_FENCE_STATUS_NV       = 0x84F3;
const GLuint GL_FENCE_CONDITION_NV      = 0x84F4;

// 224 - GL_IBM_texture_mirrored_repeat
const GLuint GL_MIRRORED_REPEAT_IBM     = 0x8370;

// 225 - GL_NV_evaluators
const GLuint GL_EVAL_2D_NV        = 0x86C0;
const GLuint GL_EVAL_TRIANGULAR_2D_NV     = 0x86C1;
const GLuint GL_MAP_TESSELLATION_NV     = 0x86C2;
const GLuint GL_MAP_ATTRIB_U_ORDER_NV     = 0x86C3;
const GLuint GL_MAP_ATTRIB_V_ORDER_NV     = 0x86C4;
const GLuint GL_EVAL_FRACTIONAL_TESSELLATION_NV   = 0x86C5;
const GLuint GL_EVAL_VERTEX_ATTRIB0_NV      = 0x86C6;
const GLuint GL_EVAL_VERTEX_ATTRIB1_NV      = 0x86C7;
const GLuint GL_EVAL_VERTEX_ATTRIB2_NV      = 0x86C8;
const GLuint GL_EVAL_VERTEX_ATTRIB3_NV      = 0x86C9;
const GLuint GL_EVAL_VERTEX_ATTRIB4_NV      = 0x86CA;
const GLuint GL_EVAL_VERTEX_ATTRIB5_NV      = 0x86CB;
const GLuint GL_EVAL_VERTEX_ATTRIB6_NV      = 0x86CC;
const GLuint GL_EVAL_VERTEX_ATTRIB7_NV      = 0x86CD;
const GLuint GL_EVAL_VERTEX_ATTRIB8_NV      = 0x86CE;
const GLuint GL_EVAL_VERTEX_ATTRIB9_NV      = 0x86CF;
const GLuint GL_EVAL_VERTEX_ATTRIB10_NV     = 0x86D0;
const GLuint GL_EVAL_VERTEX_ATTRIB11_NV     = 0x86D1;
const GLuint GL_EVAL_VERTEX_ATTRIB12_NV     = 0x86D2;
const GLuint GL_EVAL_VERTEX_ATTRIB13_NV     = 0x86D3;
const GLuint GL_EVAL_VERTEX_ATTRIB14_NV     = 0x86D4;
const GLuint GL_EVAL_VERTEX_ATTRIB15_NV     = 0x86D5;
const GLuint GL_MAX_MAP_TESSELLATION_NV     = 0x86D6;
const GLuint GL_MAX_RATIONAL_EVAL_ORDER_NV    = 0x86D7;

// 226 - GL_NV_packed_depth_stencil
const GLuint GL_DEPTH_STENCIL_NV      = 0x84F9;
const GLuint GL_UNSIGNED_INT_24_8_NV      = 0x84FA;

// 227 - GL_NV_register_combiners2
const GLuint GL_PER_STAGE_CONSTANTS_NV      = 0x8535;

// 229 - GL_NV_texture_rectangle
const GLuint GL_TEXTURE_RECTANGLE_NV      = 0x84F5;
const GLuint GL_TEXTURE_BINDING_RECTANGLE_NV    = 0x84F6;
const GLuint GL_PROXY_TEXTURE_RECTANGLE_NV    = 0x84F7;
const GLuint GL_MAX_RECTANGLE_TEXTURE_SIZE_NV   = 0x84F8;

// 230 - GL_NV_texture_shader
const GLuint GL_OFFSET_TEXTURE_RECTANGLE_NV   = 0x864C;
const GLuint GL_OFFSET_TEXTURE_RECTANGLE_SCALE_NV = 0x864D;
const GLuint GL_DOT_PRODUCT_TEXTURE_RECTANGLE_NV  = 0x864E;
const GLuint GL_RGBA_UNSIGNED_DOT_PRODUCT_MAPPING_NV  = 0x86D9;
const GLuint GL_UNSIGNED_INT_S8_S8_8_8_NV   = 0x86DA;
const GLuint GL_UNSIGNED_INT_8_8_S8_S8_REV_NV   = 0x86DB;
const GLuint GL_DSDT_MAG_INTENSITY_NV     = 0x86DC;
const GLuint GL_SHADER_CONSISTENT_NV      = 0x86DD;
const GLuint GL_TEXTURE_SHADER_NV     = 0x86DE;
const GLuint GL_SHADER_OPERATION_NV     = 0x86DF;
const GLuint GL_CULL_MODES_NV       = 0x86E0;
const GLuint GL_OFFSET_TEXTURE_MATRIX_NV    = 0x86E1;
const GLuint GL_OFFSET_TEXTURE_SCALE_NV     = 0x86E2;
const GLuint GL_OFFSET_TEXTURE_BIAS_NV      = 0x86E3;
const GLuint GL_OFFSET_TEXTURE_2D_MATRIX_NV   = GL_OFFSET_TEXTURE_MATRIX_NV;
const GLuint GL_OFFSET_TEXTURE_2D_SCALE_NV    = GL_OFFSET_TEXTURE_SCALE_NV;
const GLuint GL_OFFSET_TEXTURE_2D_BIAS_NV   = GL_OFFSET_TEXTURE_BIAS_NV;
const GLuint GL_PREVIOUS_TEXTURE_INPUT_NV   = 0x86E4;
const GLuint GL_CONST_EYE_NV        = 0x86E5;
const GLuint GL_PASS_THROUGH_NV       = 0x86E6;
const GLuint GL_CULL_FRAGMENT_NV      = 0x86E7;
const GLuint GL_OFFSET_TEXTURE_2D_NV      = 0x86E8;
const GLuint GL_DEPENDENT_AR_TEXTURE_2D_NV    = 0x86E9;
const GLuint GL_DEPENDENT_GB_TEXTURE_2D_NV    = 0x86EA;
const GLuint GL_DOT_PRODUCT_NV        = 0x86EC;
const GLuint GL_DOT_PRODUCT_DEPTH_REPLACE_NV    = 0x86ED;
const GLuint GL_DOT_PRODUCT_TEXTURE_2D_NV   = 0x86EE;
const GLuint GL_DOT_PRODUCT_TEXTURE_CUBE_MAP_NV   = 0x86F0;
const GLuint GL_DOT_PRODUCT_DIFFUSE_CUBE_MAP_NV   = 0x86F1;
const GLuint GL_DOT_PRODUCT_REFLECT_CUBE_MAP_NV   = 0x86F2;
const GLuint GL_DOT_PRODUCT_CONST_EYE_REFLECT_CUBE_MAP_NV= 0x86F3;
const GLuint GL_HILO_NV         = 0x86F4;
const GLuint GL_DSDT_NV         = 0x86F5;
const GLuint GL_DSDT_MAG_NV       = 0x86F6;
const GLuint GL_DSDT_MAG_VIB_NV       = 0x86F7;
const GLuint GL_HILO16_NV       = 0x86F8;
const GLuint GL_SIGNED_HILO_NV        = 0x86F9;
const GLuint GL_SIGNED_HILO16_NV      = 0x86FA;
const GLuint GL_SIGNED_RGBA_NV        = 0x86FB;
const GLuint GL_SIGNED_RGBA8_NV       = 0x86FC;
const GLuint GL_SIGNED_RGB_NV       = 0x86FE;
const GLuint GL_SIGNED_RGB8_NV        = 0x86FF;
const GLuint GL_SIGNED_LUMINANCE_NV     = 0x8701;
const GLuint GL_SIGNED_LUMINANCE8_NV      = 0x8702;
const GLuint GL_SIGNED_LUMINANCE_ALPHA_NV   = 0x8703;
const GLuint GL_SIGNED_LUMINANCE8_ALPHA8_NV   = 0x8704;
const GLuint GL_SIGNED_ALPHA_NV       = 0x8705;
const GLuint GL_SIGNED_ALPHA8_NV      = 0x8706;
const GLuint GL_SIGNED_INTENSITY_NV     = 0x8707;
const GLuint GL_SIGNED_INTENSITY8_NV      = 0x8708;
const GLuint GL_DSDT8_NV        = 0x8709;
const GLuint GL_DSDT8_MAG8_NV       = 0x870A;
const GLuint GL_DSDT8_MAG8_INTENSITY8_NV    = 0x870B;
const GLuint GL_SIGNED_RGB_UNSIGNED_ALPHA_NV    = 0x870C;
const GLuint GL_SIGNED_RGB8_UNSIGNED_ALPHA8_NV    = 0x870D;
const GLuint GL_HI_SCALE_NV       = 0x870E;
const GLuint GL_LO_SCALE_NV       = 0x870F;
const GLuint GL_DS_SCALE_NV       = 0x8710;
const GLuint GL_DT_SCALE_NV       = 0x8711;
const GLuint GL_MAGNITUDE_SCALE_NV      = 0x8712;
const GLuint GL_VIBRANCE_SCALE_NV     = 0x8713;
const GLuint GL_HI_BIAS_NV        = 0x8714;
const GLuint GL_LO_BIAS_NV        = 0x8715;
const GLuint GL_DS_BIAS_NV        = 0x8716;
const GLuint GL_DT_BIAS_NV        = 0x8717;
const GLuint GL_MAGNITUDE_BIAS_NV     = 0x8718;
const GLuint GL_VIBRANCE_BIAS_NV      = 0x8719;
const GLuint GL_TEXTURE_BORDER_VALUES_NV    = 0x871A;
const GLuint GL_TEXTURE_HI_SIZE_NV      = 0x871B;
const GLuint GL_TEXTURE_LO_SIZE_NV      = 0x871C;
const GLuint GL_TEXTURE_DS_SIZE_NV      = 0x871D;
const GLuint GL_TEXTURE_DT_SIZE_NV      = 0x871E;
const GLuint GL_TEXTURE_MAG_SIZE_NV     = 0x871F;

// 231 - GL_NV_texture_shader2
const GLuint GL_DOT_PRODUCT_TEXTURE_3D_NV   = 0x86EF;

// 232 - GL_NV_vertex_array_range2
const GLuint GL_VERTEX_ARRAY_RANGE_WITHOUT_FLUSH_NV = 0x8533;

// 233 - GL_NV_vertex_program
const GLuint GL_VERTEX_PROGRAM_NV     = 0x8620;
const GLuint GL_VERTEX_STATE_PROGRAM_NV     = 0x8621;
const GLuint GL_ATTRIB_ARRAY_SIZE_NV      = 0x8623;
const GLuint GL_ATTRIB_ARRAY_STRIDE_NV      = 0x8624;
const GLuint GL_ATTRIB_ARRAY_TYPE_NV      = 0x8625;
const GLuint GL_CURRENT_ATTRIB_NV     = 0x8626;
const GLuint GL_PROGRAM_LENGTH_NV     = 0x8627;
const GLuint GL_PROGRAM_STRING_NV     = 0x8628;
const GLuint GL_MODELVIEW_PROJECTION_NV     = 0x8629;
const GLuint GL_IDENTITY_NV       = 0x862A;
const GLuint GL_INVERSE_NV        = 0x862B;
const GLuint GL_TRANSPOSE_NV        = 0x862C;
const GLuint GL_INVERSE_TRANSPOSE_NV      = 0x862D;
const GLuint GL_MAX_TRACK_MATRIX_STACK_DEPTH_NV   = 0x862E;
const GLuint GL_MAX_TRACK_MATRICES_NV     = 0x862F;
const GLuint GL_MATRIX0_NV        = 0x8630;
const GLuint GL_MATRIX1_NV        = 0x8631;
const GLuint GL_MATRIX2_NV        = 0x8632;
const GLuint GL_MATRIX3_NV        = 0x8633;
const GLuint GL_MATRIX4_NV        = 0x8634;
const GLuint GL_MATRIX5_NV        = 0x8635;
const GLuint GL_MATRIX6_NV        = 0x8636;
const GLuint GL_MATRIX7_NV        = 0x8637;
const GLuint GL_CURRENT_MATRIX_STACK_DEPTH_NV   = 0x8640;
const GLuint GL_CURRENT_MATRIX_NV     = 0x8641;
const GLuint GL_VERTEX_PROGRAM_POINT_SIZE_NV    = 0x8642;
const GLuint GL_VERTEX_PROGRAM_TWO_SIDE_NV    = 0x8643;
const GLuint GL_PROGRAM_PARAMETER_NV      = 0x8644;
const GLuint GL_ATTRIB_ARRAY_POINTER_NV     = 0x8645;
const GLuint GL_PROGRAM_TARGET_NV     = 0x8646;
const GLuint GL_PROGRAM_RESIDENT_NV     = 0x8647;
const GLuint GL_TRACK_MATRIX_NV       = 0x8648;
const GLuint GL_TRACK_MATRIX_TRANSFORM_NV   = 0x8649;
const GLuint GL_VERTEX_PROGRAM_BINDING_NV   = 0x864A;
const GLuint GL_PROGRAM_ERROR_POSITION_NV   = 0x864B;
const GLuint GL_VERTEX_ATTRIB_ARRAY0_NV     = 0x8650;
const GLuint GL_VERTEX_ATTRIB_ARRAY1_NV     = 0x8651;
const GLuint GL_VERTEX_ATTRIB_ARRAY2_NV     = 0x8652;
const GLuint GL_VERTEX_ATTRIB_ARRAY3_NV     = 0x8653;
const GLuint GL_VERTEX_ATTRIB_ARRAY4_NV     = 0x8654;
const GLuint GL_VERTEX_ATTRIB_ARRAY5_NV     = 0x8655;
const GLuint GL_VERTEX_ATTRIB_ARRAY6_NV     = 0x8656;
const GLuint GL_VERTEX_ATTRIB_ARRAY7_NV     = 0x8657;
const GLuint GL_VERTEX_ATTRIB_ARRAY8_NV     = 0x8658;
const GLuint GL_VERTEX_ATTRIB_ARRAY9_NV     = 0x8659;
const GLuint GL_VERTEX_ATTRIB_ARRAY10_NV    = 0x865A;
const GLuint GL_VERTEX_ATTRIB_ARRAY11_NV    = 0x865B;
const GLuint GL_VERTEX_ATTRIB_ARRAY12_NV    = 0x865C;
const GLuint GL_VERTEX_ATTRIB_ARRAY13_NV    = 0x865D;
const GLuint GL_VERTEX_ATTRIB_ARRAY14_NV    = 0x865E;
const GLuint GL_VERTEX_ATTRIB_ARRAY15_NV    = 0x865F;
const GLuint GL_MAP1_VERTEX_ATTRIB0_4_NV    = 0x8660;
const GLuint GL_MAP1_VERTEX_ATTRIB1_4_NV    = 0x8661;
const GLuint GL_MAP1_VERTEX_ATTRIB2_4_NV    = 0x8662;
const GLuint GL_MAP1_VERTEX_ATTRIB3_4_NV    = 0x8663;
const GLuint GL_MAP1_VERTEX_ATTRIB4_4_NV    = 0x8664;
const GLuint GL_MAP1_VERTEX_ATTRIB5_4_NV    = 0x8665;
const GLuint GL_MAP1_VERTEX_ATTRIB6_4_NV    = 0x8666;
const GLuint GL_MAP1_VERTEX_ATTRIB7_4_NV    = 0x8667;
const GLuint GL_MAP1_VERTEX_ATTRIB8_4_NV    = 0x8668;
const GLuint GL_MAP1_VERTEX_ATTRIB9_4_NV    = 0x8669;
const GLuint GL_MAP1_VERTEX_ATTRIB10_4_NV   = 0x866A;
const GLuint GL_MAP1_VERTEX_ATTRIB11_4_NV   = 0x866B;
const GLuint GL_MAP1_VERTEX_ATTRIB12_4_NV   = 0x866C;
const GLuint GL_MAP1_VERTEX_ATTRIB13_4_NV   = 0x866D;
const GLuint GL_MAP1_VERTEX_ATTRIB14_4_NV   = 0x866E;
const GLuint GL_MAP1_VERTEX_ATTRIB15_4_NV   = 0x866F;
const GLuint GL_MAP2_VERTEX_ATTRIB0_4_NV    = 0x8670;
const GLuint GL_MAP2_VERTEX_ATTRIB1_4_NV    = 0x8671;
const GLuint GL_MAP2_VERTEX_ATTRIB2_4_NV    = 0x8672;
const GLuint GL_MAP2_VERTEX_ATTRIB3_4_NV    = 0x8673;
const GLuint GL_MAP2_VERTEX_ATTRIB4_4_NV    = 0x8674;
const GLuint GL_MAP2_VERTEX_ATTRIB5_4_NV    = 0x8675;
const GLuint GL_MAP2_VERTEX_ATTRIB6_4_NV    = 0x8676;
const GLuint GL_MAP2_VERTEX_ATTRIB7_4_NV    = 0x8677;
const GLuint GL_MAP2_VERTEX_ATTRIB8_4_NV    = 0x8678;
const GLuint GL_MAP2_VERTEX_ATTRIB9_4_NV    = 0x8679;
const GLuint GL_MAP2_VERTEX_ATTRIB10_4_NV   = 0x867A;
const GLuint GL_MAP2_VERTEX_ATTRIB11_4_NV   = 0x867B;
const GLuint GL_MAP2_VERTEX_ATTRIB12_4_NV   = 0x867C;
const GLuint GL_MAP2_VERTEX_ATTRIB13_4_NV   = 0x867D;
const GLuint GL_MAP2_VERTEX_ATTRIB14_4_NV   = 0x867E;
const GLuint GL_MAP2_VERTEX_ATTRIB15_4_NV   = 0x867F;

// 235 - GL_SGIX_texture_coordinate_clamp
const GLuint GL_TEXTURE_MAX_CLAMP_S_SGIX    = 0x8369;
const GLuint GL_TEXTURE_MAX_CLAMP_T_SGIX    = 0x836A;
const GLuint GL_TEXTURE_MAX_CLAMP_R_SGIX    = 0x836B;

// ? - GL_SGIX_scalebias_hint
const GLuint GL_SCALEBIAS_HINT_SGIX     = 0x8322;

// 239 - GL_OML_interlace
const GLuint GL_INTERLACE_OML       = 0x8980;
const GLuint GL_INTERLACE_READ_OML      = 0x8981;

// 240 - GL_OML_subsample
const GLuint GL_FORMAT_SUBSAMPLE_24_24_OML    = 0x8982;
const GLuint GL_FORMAT_SUBSAMPLE_244_244_OML    = 0x8983;

// 241 - GL_OML_resample
const GLuint GL_PACK_RESAMPLE_OML     = 0x8984;
const GLuint GL_UNPACK_RESAMPLE_OML     = 0x8985;
const GLuint GL_RESAMPLE_REPLICATE_OML      = 0x8986;
const GLuint GL_RESAMPLE_ZERO_FILL_OML      = 0x8987;
const GLuint GL_RESAMPLE_AVERAGE_OML      = 0x8988;
const GLuint GL_RESAMPLE_DECIMATE_OML     = 0x8989;

// 243 - GL_NV_copy_depth_to_color
const GLuint GL_DEPTH_STENCIL_TO_RGBA_NV    = 0x886E;
const GLuint GL_DEPTH_STENCIL_TO_BGRA_NV    = 0x886F;

// 244 - GL_ATI_envmap_bumpmap
const GLuint GL_BUMP_ROT_MATRIX_ATI     = 0x8775;
const GLuint GL_BUMP_ROT_MATRIX_SIZE_ATI    = 0x8776;
const GLuint GL_BUMP_NUM_TEX_UNITS_ATI      = 0x8777;
const GLuint GL_BUMP_TEX_UNITS_ATI      = 0x8778;
const GLuint GL_DUDV_ATI        = 0x8779;
const GLuint GL_DU8DV8_ATI        = 0x877A;
const GLuint GL_BUMP_ENVMAP_ATI       = 0x877B;
const GLuint GL_BUMP_TARGET_ATI       = 0x877C;

// 245 - GL_ATI_fragment_shader
const GLuint GL_FRAGMENT_SHADER_ATI     = 0x8920;
const GLuint GL_REG_0_ATI       = 0x8921;
const GLuint GL_REG_1_ATI       = 0x8922;
const GLuint GL_REG_2_ATI       = 0x8923;
const GLuint GL_REG_3_ATI       = 0x8924;
const GLuint GL_REG_4_ATI       = 0x8925;
const GLuint GL_REG_5_ATI       = 0x8926;
const GLuint GL_REG_6_ATI       = 0x8927;
const GLuint GL_REG_7_ATI       = 0x8928;
const GLuint GL_REG_8_ATI       = 0x8929;
const GLuint GL_REG_9_ATI       = 0x892A;
const GLuint GL_REG_10_ATI        = 0x892B;
const GLuint GL_REG_11_ATI        = 0x892C;
const GLuint GL_REG_12_ATI        = 0x892D;
const GLuint GL_REG_13_ATI        = 0x892E;
const GLuint GL_REG_14_ATI        = 0x892F;
const GLuint GL_REG_15_ATI        = 0x8930;
const GLuint GL_REG_16_ATI        = 0x8931;
const GLuint GL_REG_17_ATI        = 0x8932;
const GLuint GL_REG_18_ATI        = 0x8933;
const GLuint GL_REG_19_ATI        = 0x8934;
const GLuint GL_REG_20_ATI        = 0x8935;
const GLuint GL_REG_21_ATI        = 0x8936;
const GLuint GL_REG_22_ATI        = 0x8937;
const GLuint GL_REG_23_ATI        = 0x8938;
const GLuint GL_REG_24_ATI        = 0x8939;
const GLuint GL_REG_25_ATI        = 0x893A;
const GLuint GL_REG_26_ATI        = 0x893B;
const GLuint GL_REG_27_ATI        = 0x893C;
const GLuint GL_REG_28_ATI        = 0x893D;
const GLuint GL_REG_29_ATI        = 0x893E;
const GLuint GL_REG_30_ATI        = 0x893F;
const GLuint GL_REG_31_ATI        = 0x8940;
const GLuint GL_CON_0_ATI       = 0x8941;
const GLuint GL_CON_1_ATI       = 0x8942;
const GLuint GL_CON_2_ATI       = 0x8943;
const GLuint GL_CON_3_ATI       = 0x8944;
const GLuint GL_CON_4_ATI       = 0x8945;
const GLuint GL_CON_5_ATI       = 0x8946;
const GLuint GL_CON_6_ATI       = 0x8947;
const GLuint GL_CON_7_ATI       = 0x8948;
const GLuint GL_CON_8_ATI       = 0x8949;
const GLuint GL_CON_9_ATI       = 0x894A;
const GLuint GL_CON_10_ATI        = 0x894B;
const GLuint GL_CON_11_ATI        = 0x894C;
const GLuint GL_CON_12_ATI        = 0x894D;
const GLuint GL_CON_13_ATI        = 0x894E;
const GLuint GL_CON_14_ATI        = 0x894F;
const GLuint GL_CON_15_ATI        = 0x8950;
const GLuint GL_CON_16_ATI        = 0x8951;
const GLuint GL_CON_17_ATI        = 0x8952;
const GLuint GL_CON_18_ATI        = 0x8953;
const GLuint GL_CON_19_ATI        = 0x8954;
const GLuint GL_CON_20_ATI        = 0x8955;
const GLuint GL_CON_21_ATI        = 0x8956;
const GLuint GL_CON_22_ATI        = 0x8957;
const GLuint GL_CON_23_ATI        = 0x8958;
const GLuint GL_CON_24_ATI        = 0x8959;
const GLuint GL_CON_25_ATI        = 0x895A;
const GLuint GL_CON_26_ATI        = 0x895B;
const GLuint GL_CON_27_ATI        = 0x895C;
const GLuint GL_CON_28_ATI        = 0x895D;
const GLuint GL_CON_29_ATI        = 0x895E;
const GLuint GL_CON_30_ATI        = 0x895F;
const GLuint GL_CON_31_ATI        = 0x8960;
const GLuint GL_MOV_ATI         = 0x8961;
const GLuint GL_ADD_ATI         = 0x8963;
const GLuint GL_MUL_ATI         = 0x8964;
const GLuint GL_SUB_ATI         = 0x8965;
const GLuint GL_DOT3_ATI        = 0x8966;
const GLuint GL_DOT4_ATI        = 0x8967;
const GLuint GL_MAD_ATI         = 0x8968;
const GLuint GL_LERP_ATI        = 0x8969;
const GLuint GL_CND_ATI         = 0x896A;
const GLuint GL_CND0_ATI        = 0x896B;
const GLuint GL_DOT2_ADD_ATI        = 0x896C;
const GLuint GL_SECONDARY_INTERPOLATOR_ATI    = 0x896D;
const GLuint GL_NUM_FRAGMENT_REGISTERS_ATI    = 0x896E;
const GLuint GL_NUM_FRAGMENT_CONSTANTS_ATI    = 0x896F;
const GLuint GL_NUM_PASSES_ATI        = 0x8970;
const GLuint GL_NUM_INSTRUCTIONS_PER_PASS_ATI   = 0x8971;
const GLuint GL_NUM_INSTRUCTIONS_TOTAL_ATI    = 0x8972;
const GLuint GL_NUM_INPUT_INTERPOLATOR_COMPONENTS_ATI = 0x8973;
const GLuint GL_NUM_LOOPBACK_COMPONENTS_ATI   = 0x8974;
const GLuint GL_COLOR_ALPHA_PAIRING_ATI     = 0x8975;
const GLuint GL_SWIZZLE_STR_ATI       = 0x8976;
const GLuint GL_SWIZZLE_STQ_ATI       = 0x8977;
const GLuint GL_SWIZZLE_STR_DR_ATI      = 0x8978;
const GLuint GL_SWIZZLE_STQ_DQ_ATI      = 0x8979;
const GLuint GL_SWIZZLE_STRQ_ATI      = 0x897A;
const GLuint GL_SWIZZLE_STRQ_DQ_ATI     = 0x897B;
const GLuint GL_RED_BIT_ATI       = 0x00000001;
const GLuint GL_GREEN_BIT_ATI       = 0x00000002;
const GLuint GL_BLUE_BIT_ATI        = 0x00000004;
const GLuint GL_2X_BIT_ATI        = 0x00000001;
const GLuint GL_4X_BIT_ATI        = 0x00000002;
const GLuint GL_8X_BIT_ATI        = 0x00000004;
const GLuint GL_HALF_BIT_ATI        = 0x00000008;
const GLuint GL_QUARTER_BIT_ATI       = 0x00000010;
const GLuint GL_EIGHTH_BIT_ATI        = 0x00000020;
const GLuint GL_SATURATE_BIT_ATI      = 0x00000040;
const GLuint GL_COMP_BIT_ATI        = 0x00000002;
const GLuint GL_NEGATE_BIT_ATI        = 0x00000004;
const GLuint GL_BIAS_BIT_ATI        = 0x00000008;

// 246 - GL_ATI_pn_triangles
const GLuint GL_PN_TRIANGLES_ATI      = 0x87F0;
const GLuint GL_MAX_PN_TRIANGLES_TESSELATION_LEVEL_ATI  = 0x87F1;
const GLuint GL_PN_TRIANGLES_POINT_MODE_ATI   = 0x87F2;
const GLuint GL_PN_TRIANGLES_NORMAL_MODE_ATI    = 0x87F3;
const GLuint GL_PN_TRIANGLES_TESSELATION_LEVEL_ATI  = 0x87F4;
const GLuint GL_PN_TRIANGLES_POINT_MODE_LINEAR_ATI  = 0x87F5;
const GLuint GL_PN_TRIANGLES_POINT_MODE_CUBIC_ATI = 0x87F6;
const GLuint GL_PN_TRIANGLES_NORMAL_MODE_LINEAR_ATI = 0x87F7;
const GLuint GL_PN_TRIANGLES_NORMAL_MODE_QUADRATIC_ATI  = 0x87F8;

// 247 - GL_ATI_vertex_array_object
const GLuint GL_STATIC_ATI        = 0x8760;
const GLuint GL_DYNAMIC_ATI       = 0x8761;
const GLuint GL_PRESERVE_ATI        = 0x8762;
const GLuint GL_DISCARD_ATI       = 0x8763;
const GLuint GL_OBJECT_BUFFER_SIZE_ATI      = 0x8764;
const GLuint GL_OBJECT_BUFFER_USAGE_ATI     = 0x8765;
const GLuint GL_ARRAY_OBJECT_BUFFER_ATI     = 0x8766;
const GLuint GL_ARRAY_OBJECT_OFFSET_ATI     = 0x8767;

// 248 - GL_EXT_vertex_shader
const GLuint GL_VERTEX_SHADER_EXT     = 0x8780;
const GLuint GL_VERTEX_SHADER_BINDING_EXT   = 0x8781;
const GLuint GL_OP_INDEX_EXT        = 0x8782;
const GLuint GL_OP_NEGATE_EXT       = 0x8783;
const GLuint GL_OP_DOT3_EXT       = 0x8784;
const GLuint GL_OP_DOT4_EXT       = 0x8785;
const GLuint GL_OP_MUL_EXT        = 0x8786;
const GLuint GL_OP_ADD_EXT        = 0x8787;
const GLuint GL_OP_MADD_EXT       = 0x8788;
const GLuint GL_OP_FRAC_EXT       = 0x8789;
const GLuint GL_OP_MAX_EXT        = 0x878A;
const GLuint GL_OP_MIN_EXT        = 0x878B;
const GLuint GL_OP_SET_GE_EXT       = 0x878C;
const GLuint GL_OP_SET_LT_EXT       = 0x878D;
const GLuint GL_OP_CLAMP_EXT        = 0x878E;
const GLuint GL_OP_FLOOR_EXT        = 0x878F;
const GLuint GL_OP_ROUND_EXT        = 0x8790;
const GLuint GL_OP_EXP_BASE_2_EXT     = 0x8791;
const GLuint GL_OP_LOG_BASE_2_EXT     = 0x8792;
const GLuint GL_OP_POWER_EXT        = 0x8793;
const GLuint GL_OP_RECIP_EXT        = 0x8794;
const GLuint GL_OP_RECIP_SQRT_EXT     = 0x8795;
const GLuint GL_OP_SUB_EXT        = 0x8796;
const GLuint GL_OP_CROSS_PRODUCT_EXT      = 0x8797;
const GLuint GL_OP_MULTIPLY_MATRIX_EXT      = 0x8798;
const GLuint GL_OP_MOV_EXT        = 0x8799;
const GLuint GL_OUTPUT_VERTEX_EXT     = 0x879A;
const GLuint GL_OUTPUT_COLOR0_EXT     = 0x879B;
const GLuint GL_OUTPUT_COLOR1_EXT     = 0x879C;
const GLuint GL_OUTPUT_TEXTURE_COORD0_EXT   = 0x879D;
const GLuint GL_OUTPUT_TEXTURE_COORD1_EXT   = 0x879E;
const GLuint GL_OUTPUT_TEXTURE_COORD2_EXT   = 0x879F;
const GLuint GL_OUTPUT_TEXTURE_COORD3_EXT   = 0x87A0;
const GLuint GL_OUTPUT_TEXTURE_COORD4_EXT   = 0x87A1;
const GLuint GL_OUTPUT_TEXTURE_COORD5_EXT   = 0x87A2;
const GLuint GL_OUTPUT_TEXTURE_COORD6_EXT   = 0x87A3;
const GLuint GL_OUTPUT_TEXTURE_COORD7_EXT   = 0x87A4;
const GLuint GL_OUTPUT_TEXTURE_COORD8_EXT   = 0x87A5;
const GLuint GL_OUTPUT_TEXTURE_COORD9_EXT   = 0x87A6;
const GLuint GL_OUTPUT_TEXTURE_COORD10_EXT    = 0x87A7;
const GLuint GL_OUTPUT_TEXTURE_COORD11_EXT    = 0x87A8;
const GLuint GL_OUTPUT_TEXTURE_COORD12_EXT    = 0x87A9;
const GLuint GL_OUTPUT_TEXTURE_COORD13_EXT    = 0x87AA;
const GLuint GL_OUTPUT_TEXTURE_COORD14_EXT    = 0x87AB;
const GLuint GL_OUTPUT_TEXTURE_COORD15_EXT    = 0x87AC;
const GLuint GL_OUTPUT_TEXTURE_COORD16_EXT    = 0x87AD;
const GLuint GL_OUTPUT_TEXTURE_COORD17_EXT    = 0x87AE;
const GLuint GL_OUTPUT_TEXTURE_COORD18_EXT    = 0x87AF;
const GLuint GL_OUTPUT_TEXTURE_COORD19_EXT    = 0x87B0;
const GLuint GL_OUTPUT_TEXTURE_COORD20_EXT    = 0x87B1;
const GLuint GL_OUTPUT_TEXTURE_COORD21_EXT    = 0x87B2;
const GLuint GL_OUTPUT_TEXTURE_COORD22_EXT    = 0x87B3;
const GLuint GL_OUTPUT_TEXTURE_COORD23_EXT    = 0x87B4;
const GLuint GL_OUTPUT_TEXTURE_COORD24_EXT    = 0x87B5;
const GLuint GL_OUTPUT_TEXTURE_COORD25_EXT    = 0x87B6;
const GLuint GL_OUTPUT_TEXTURE_COORD26_EXT    = 0x87B7;
const GLuint GL_OUTPUT_TEXTURE_COORD27_EXT    = 0x87B8;
const GLuint GL_OUTPUT_TEXTURE_COORD28_EXT    = 0x87B9;
const GLuint GL_OUTPUT_TEXTURE_COORD29_EXT    = 0x87BA;
const GLuint GL_OUTPUT_TEXTURE_COORD30_EXT    = 0x87BB;
const GLuint GL_OUTPUT_TEXTURE_COORD31_EXT    = 0x87BC;
const GLuint GL_OUTPUT_FOG_EXT        = 0x87BD;
const GLuint GL_SCALAR_EXT        = 0x87BE;
const GLuint GL_VECTOR_EXT        = 0x87BF;
const GLuint GL_MATRIX_EXT        = 0x87C0;
const GLuint GL_VARIANT_EXT       = 0x87C1;
const GLuint GL_INVARIANT_EXT       = 0x87C2;
const GLuint GL_LOCAL_CONSTANT_EXT      = 0x87C3;
const GLuint GL_LOCAL_EXT       = 0x87C4;
const GLuint GL_MAX_VERTEX_SHADER_INSTRUCTIONS_EXT  = 0x87C5;
const GLuint GL_MAX_VERTEX_SHADER_VARIANTS_EXT    = 0x87C6;
const GLuint GL_MAX_VERTEX_SHADER_INVARIANTS_EXT  = 0x87C7;
const GLuint GL_MAX_VERTEX_SHADER_LOCAL_CONSTANTS_EXT = 0x87C8;
const GLuint GL_MAX_VERTEX_SHADER_LOCALS_EXT    = 0x87C9;
const GLuint GL_MAX_OPTIMIZED_VERTEX_SHADER_INSTRUCTIONS_EXT= 0x87CA;
const GLuint GL_MAX_OPTIMIZED_VERTEX_SHADER_VARIANTS_EXT= 0x87CB;
const GLuint GL_MAX_OPTIMIZED_VERTEX_SHADER_LOCAL_CONSTANTS_EXT= 0x87CC;
const GLuint GL_MAX_OPTIMIZED_VERTEX_SHADER_INVARIANTS_EXT= 0x87CD;
const GLuint GL_MAX_OPTIMIZED_VERTEX_SHADER_LOCALS_EXT  = 0x87CE;
const GLuint GL_VERTEX_SHADER_INSTRUCTIONS_EXT    = 0x87CF;
const GLuint GL_VERTEX_SHADER_VARIANTS_EXT    = 0x87D0;
const GLuint GL_VERTEX_SHADER_INVARIANTS_EXT    = 0x87D1;
const GLuint GL_VERTEX_SHADER_LOCAL_CONSTANTS_EXT = 0x87D2;
const GLuint GL_VERTEX_SHADER_LOCALS_EXT    = 0x87D3;
const GLuint GL_VERTEX_SHADER_OPTIMIZED_EXT   = 0x87D4;
const GLuint GL_X_EXT         = 0x87D5;
const GLuint GL_Y_EXT         = 0x87D6;
const GLuint GL_Z_EXT         = 0x87D7;
const GLuint GL_W_EXT         = 0x87D8;
const GLuint GL_NEGATIVE_X_EXT        = 0x87D9;
const GLuint GL_NEGATIVE_Y_EXT        = 0x87DA;
const GLuint GL_NEGATIVE_Z_EXT        = 0x87DB;
const GLuint GL_NEGATIVE_W_EXT        = 0x87DC;
const GLuint GL_ZERO_EXT        = 0x87DD;
const GLuint GL_ONE_EXT         = 0x87DE;
const GLuint GL_NEGATIVE_ONE_EXT      = 0x87DF;
const GLuint GL_NORMALIZED_RANGE_EXT      = 0x87E0;
const GLuint GL_FULL_RANGE_EXT        = 0x87E1;
const GLuint GL_CURRENT_VERTEX_EXT      = 0x87E2;
const GLuint GL_MVP_MATRIX_EXT        = 0x87E3;
const GLuint GL_VARIANT_VALUE_EXT     = 0x87E4;
const GLuint GL_VARIANT_DATATYPE_EXT      = 0x87E5;
const GLuint GL_VARIANT_ARRAY_STRIDE_EXT    = 0x87E6;
const GLuint GL_VARIANT_ARRAY_TYPE_EXT      = 0x87E7;
const GLuint GL_VARIANT_ARRAY_EXT     = 0x87E8;
const GLuint GL_VARIANT_ARRAY_POINTER_EXT   = 0x87E9;
const GLuint GL_INVARIANT_VALUE_EXT     = 0x87EA;
const GLuint GL_INVARIANT_DATATYPE_EXT      = 0x87EB;
const GLuint GL_LOCAL_CONSTANT_VALUE_EXT    = 0x87EC;
const GLuint GL_LOCAL_CONSTANT_DATATYPE_EXT   = 0x87ED;

// 249 - GL_ATI_vertex_streams
const GLuint GL_MAX_VERTEX_STREAMS_ATI      = 0x876B;
const GLuint GL_VERTEX_STREAM0_ATI      = 0x876C;
const GLuint GL_VERTEX_STREAM1_ATI      = 0x876D;
const GLuint GL_VERTEX_STREAM2_ATI      = 0x876E;
const GLuint GL_VERTEX_STREAM3_ATI      = 0x876F;
const GLuint GL_VERTEX_STREAM4_ATI      = 0x8770;
const GLuint GL_VERTEX_STREAM5_ATI      = 0x8771;
const GLuint GL_VERTEX_STREAM6_ATI      = 0x8772;
const GLuint GL_VERTEX_STREAM7_ATI      = 0x8773;
const GLuint GL_VERTEX_SOURCE_ATI     = 0x8774;

// 256 - GL_ATI_element_array
const GLuint GL_ELEMENT_ARRAY_ATI     = 0x8768;
const GLuint GL_ELEMENT_ARRAY_TYPE_ATI      = 0x8769;
const GLuint GL_ELEMENT_ARRAY_POINTER_ATI   = 0x876A;

// 257 - GL_SUN_mesh_array
const GLuint GL_QUAD_MESH_SUN       = 0x8614;
const GLuint GL_TRIANGLE_MESH_SUN     = 0x8615;

// 258 - GL_SUN_slice_accum
const GLuint GL_SLICE_ACCUM_SUN       = 0x85CC;

// 259 - GL_NV_multisample_filter_hint
const GLuint GL_MULTISAMPLE_FILTER_HINT_NV    = 0x8534;

// 260 - GL_NV_depth_clamp
const GLuint GL_DEPTH_CLAMP_NV        = 0x864F;

// 261 - GL_NV_occlusion_query
const GLuint GL_PIXEL_COUNTER_BITS_NV     = 0x8864;
const GLuint GL_CURRENT_OCCLUSION_QUERY_ID_NV   = 0x8865;
const GLuint GL_PIXEL_COUNT_NV        = 0x8866;
const GLuint GL_PIXEL_COUNT_AVAILABLE_NV    = 0x8867;

// 262 - GL_NV_point_sprite
const GLuint GL_POINT_SPRITE_NV       = 0x8861;
const GLuint GL_COORD_REPLACE_NV      = 0x8862;
const GLuint GL_POINT_SPRITE_R_MODE_NV      = 0x8863;

// 265 - GL_NV_texture_shader3
const GLuint GL_OFFSET_PROJECTIVE_TEXTURE_2D_NV   = 0x8850;
const GLuint GL_OFFSET_PROJECTIVE_TEXTURE_2D_SCALE_NV = 0x8851;
const GLuint GL_OFFSET_PROJECTIVE_TEXTURE_RECTANGLE_NV  = 0x8852;
const GLuint GL_OFFSET_PROJECTIVE_TEXTURE_RECTANGLE_SCALE_NV= 0x8853;
const GLuint GL_OFFSET_HILO_TEXTURE_2D_NV   = 0x8854;
const GLuint GL_OFFSET_HILO_TEXTURE_RECTANGLE_NV  = 0x8855;
const GLuint GL_OFFSET_HILO_PROJECTIVE_TEXTURE_2D_NV  = 0x8856;
const GLuint GL_OFFSET_HILO_PROJECTIVE_TEXTURE_RECTANGLE_NV= 0x8857;
const GLuint GL_DEPENDENT_HILO_TEXTURE_2D_NV    = 0x8858;
const GLuint GL_DEPENDENT_RGB_TEXTURE_3D_NV   = 0x8859;
const GLuint GL_DEPENDENT_RGB_TEXTURE_CUBE_MAP_NV = 0x885A;
const GLuint GL_DOT_PRODUCT_PASS_THROUGH_NV   = 0x885B;
const GLuint GL_DOT_PRODUCT_TEXTURE_1D_NV   = 0x885C;
const GLuint GL_DOT_PRODUCT_AFFINE_DEPTH_REPLACE_NV = 0x885D;
const GLuint GL_HILO8_NV        = 0x885E;
const GLuint GL_SIGNED_HILO8_NV       = 0x885F;
const GLuint GL_FORCE_BLUE_TO_ONE_NV      = 0x8860;

// 268 - GL_EXT_stencil_two_side
const GLuint GL_STENCIL_TEST_TWO_SIDE_EXT   = 0x8910;
const GLuint GL_ACTIVE_STENCIL_FACE_EXT     = 0x8911;

// 269 - GL_ATI_text_fragment_shader
const GLuint GL_TEXT_FRAGMENT_SHADER_ATI    = 0x8200;

// 270 - GL_APPLE_client_storage
const GLuint GL_UNPACK_CLIENT_STORAGE_APPLE   = 0x85B2;

// 271 - GL_APPLE_element_array
const GLuint GL_ELEMENT_ARRAY_APPLE     = 0x8768;
const GLuint GL_ELEMENT_ARRAY_TYPE_APPLE    = 0x8769;
const GLuint GL_ELEMENT_ARRAY_POINTER_APPLE   = 0x876A;

// 272 - GL_APPLE_fence
const GLuint GL_DRAW_PIXELS_APPLE     = 0x8A0A;
const GLuint GL_FENCE_APPLE       = 0x8A0B;

// 273 - GL_APPLE_vertex_array_object
const GLuint GL_VERTEX_ARRAY_BINDING_APPLE    = 0x85B5;

// 274 - GL_APPLE_vertex_array_range
const GLuint GL_VERTEX_ARRAY_RANGE_APPLE    = 0x851D;
const GLuint GL_VERTEX_ARRAY_RANGE_LENGTH_APPLE   = 0x851E;
const GLuint GL_VERTEX_ARRAY_STORAGE_HINT_APPLE   = 0x851F;
const GLuint GL_VERTEX_ARRAY_RANGE_POINTER_APPLE  = 0x8521;
const GLuint GL_STORAGE_CACHED_APPLE      = 0x85BE;
const GLuint GL_STORAGE_SHARED_APPLE      = 0x85BF;

// 275 - GL_APPLE_ycbcr_422
const GLuint GL_YCBCR_422_APPLE       = 0x85B9;
const GLuint GL_UNSIGNED_SHORT_8_8_APPLE    = 0x85BA;
const GLuint GL_UNSIGNED_SHORT_8_8_REV_APPLE    = 0x85BB;

// 276 - GL_S3_s3tc
const GLuint GL_RGB_S3TC        = 0x83A0;
const GLuint GL_RGB4_S3TC       = 0x83A1;
const GLuint GL_RGBA_S3TC       = 0x83A2;
const GLuint GL_RGBA4_S3TC        = 0x83A3;

// 277 - GL_ATI_draw_buffers
const GLuint GL_MAX_DRAW_BUFFERS_ATI      = 0x8824;
const GLuint GL_DRAW_BUFFER0_ATI      = 0x8825;
const GLuint GL_DRAW_BUFFER1_ATI      = 0x8826;
const GLuint GL_DRAW_BUFFER2_ATI      = 0x8827;
const GLuint GL_DRAW_BUFFER3_ATI      = 0x8828;
const GLuint GL_DRAW_BUFFER4_ATI      = 0x8829;
const GLuint GL_DRAW_BUFFER5_ATI      = 0x882A;
const GLuint GL_DRAW_BUFFER6_ATI      = 0x882B;
const GLuint GL_DRAW_BUFFER7_ATI      = 0x882C;
const GLuint GL_DRAW_BUFFER8_ATI      = 0x882D;
const GLuint GL_DRAW_BUFFER9_ATI      = 0x882E;
const GLuint GL_DRAW_BUFFER10_ATI     = 0x882F;
const GLuint GL_DRAW_BUFFER11_ATI     = 0x8830;
const GLuint GL_DRAW_BUFFER12_ATI     = 0x8831;
const GLuint GL_DRAW_BUFFER13_ATI     = 0x8832;
const GLuint GL_DRAW_BUFFER14_ATI     = 0x8833;
const GLuint GL_DRAW_BUFFER15_ATI     = 0x8834;

// 278 - GL_ATI_pixel_format_float
const GLuint GL_TYPE_RGBA_FLOAT_ATI     = 0x8820;
const GLuint GL_COLOR_CLEAR_UNCLAMPED_VALUE_ATI   = 0x8835;

// 279 - GL_ATI_texture_env_combine3
const GLuint GL_MODULATE_ADD_ATI      = 0x8744;
const GLuint GL_MODULATE_SIGNED_ADD_ATI     = 0x8745;
const GLuint GL_MODULATE_SUBTRACT_ATI     = 0x8746;

// 280 - GL_ATI_texture_float
const GLuint GL_RGBA_FLOAT32_ATI      = 0x8814;
const GLuint GL_RGB_FLOAT32_ATI       = 0x8815;
const GLuint GL_ALPHA_FLOAT32_ATI     = 0x8816;
const GLuint GL_INTENSITY_FLOAT32_ATI     = 0x8817;
const GLuint GL_LUMINANCE_FLOAT32_ATI     = 0x8818;
const GLuint GL_LUMINANCE_ALPHA_FLOAT32_ATI   = 0x8819;
const GLuint GL_RGBA_FLOAT16_ATI      = 0x881A;
const GLuint GL_RGB_FLOAT16_ATI       = 0x881B;
const GLuint GL_ALPHA_FLOAT16_ATI     = 0x881C;
const GLuint GL_INTENSITY_FLOAT16_ATI     = 0x881D;
const GLuint GL_LUMINANCE_FLOAT16_ATI     = 0x881E;
const GLuint GL_LUMINANCE_ALPHA_FLOAT16_ATI   = 0x881F;

// 281 - GL_NV_float_buffer
const GLuint GL_FLOAT_R_NV        = 0x8880;
const GLuint GL_FLOAT_RG_NV       = 0x8881;
const GLuint GL_FLOAT_RGB_NV        = 0x8882;
const GLuint GL_FLOAT_RGBA_NV       = 0x8883;
const GLuint GL_FLOAT_R16_NV        = 0x8884;
const GLuint GL_FLOAT_R32_NV        = 0x8885;
const GLuint GL_FLOAT_RG16_NV       = 0x8886;
const GLuint GL_FLOAT_RG32_NV       = 0x8887;
const GLuint GL_FLOAT_RGB16_NV        = 0x8888;
const GLuint GL_FLOAT_RGB32_NV        = 0x8889;
const GLuint GL_FLOAT_RGBA16_NV       = 0x888A;
const GLuint GL_FLOAT_RGBA32_NV       = 0x888B;
const GLuint GL_TEXTURE_FLOAT_COMPONENTS_NV   = 0x888C;
const GLuint GL_FLOAT_CLEAR_COLOR_VALUE_NV    = 0x888D;
const GLuint GL_FLOAT_RGBA_MODE_NV      = 0x888E;

// 282 - GL_NV_fragment_program
const GLuint GL_MAX_FRAGMENT_PROGRAM_LOCAL_PARAMETERS_NV= 0x8868;
const GLuint GL_FRAGMENT_PROGRAM_NV     = 0x8870;
const GLuint GL_MAX_TEXTURE_COORDS_NV     = 0x8871;
const GLuint GL_MAX_TEXTURE_IMAGE_UNITS_NV    = 0x8872;
const GLuint GL_FRAGMENT_PROGRAM_BINDING_NV   = 0x8873;
const GLuint GL_PROGRAM_ERROR_STRING_NV     = 0x8874;

// 283 - GL_NV_half_float
const GLuint GL_HALF_FLOAT_NV       = 0x140B;

// 284 - GL_NV_pixel_data_range
const GLuint GL_WRITE_PIXEL_DATA_RANGE_NV   = 0x8878;
const GLuint GL_READ_PIXEL_DATA_RANGE_NV    = 0x8879;
const GLuint GL_WRITE_PIXEL_DATA_RANGE_LENGTH_NV  = 0x887A;
const GLuint GL_READ_PIXEL_DATA_RANGE_LENGTH_NV   = 0x887B;
const GLuint GL_WRITE_PIXEL_DATA_RANGE_POINTER_NV = 0x887C;
const GLuint GL_READ_PIXEL_DATA_RANGE_POINTER_NV  = 0x887D;

// 285 - GL_NV_primitive_restart
const GLuint GL_PRIMITIVE_RESTART_NV      = 0x8558;
const GLuint GL_PRIMITIVE_RESTART_INDEX_NV    = 0x8559;

// 286 - GL_NV_texture_expand_normal
const GLuint GL_TEXTURE_UNSIGNED_REMAP_MODE_NV    = 0x888F;

// 289 - GL_ATI_separate_stencil
const GLuint GL_STENCIL_BACK_FUNC_ATI     = 0x8800;
const GLuint GL_STENCIL_BACK_FAIL_ATI     = 0x8801;
const GLuint GL_STENCIL_BACK_PASS_DEPTH_FAIL_ATI  = 0x8802;
const GLuint GL_STENCIL_BACK_PASS_DEPTH_PASS_ATI  = 0x8803;

// 295 - GL_OES_read_format
const GLuint GL_IMPLEMENTATION_COLOR_READ_TYPE_OES  = 0x8B9A;
const GLuint GL_IMPLEMENTATION_COLOR_READ_FORMAT_OES  = 0x8B9B;

// 297 - GL_EXT_depth_bounds_test
const GLuint GL_DEPTH_BOUNDS_TEST_EXT     = 0x8890;
const GLuint GL_DEPTH_BOUNDS_EXT      = 0x8891;

// 298 - GL_EXT_texture_mirror_clamp
const GLuint GL_MIRROR_CLAMP_EXT      = 0x8742;
const GLuint GL_MIRROR_CLAMP_TO_EDGE_EXT    = 0x8743;
const GLuint GL_MIRROR_CLAMP_TO_BORDER_EXT    = 0x8912;

// 299 - GL_EXT_blend_equation_separate
const GLuint GL_BLEND_EQUATION_RGB_EXT      = GL_BLEND_EQUATION;
const GLuint GL_BLEND_EQUATION_ALPHA_EXT    = 0x883D;

// 300 - GL_MESA_pack_invert
const GLuint GL_PACK_INVERT_MESA      = 0x8758;

// 301 - GL_MESA_ycbcr_texture
const GLuint GL_UNSIGNED_SHORT_8_8_MESA     = 0x85BA;
const GLuint GL_UNSIGNED_SHORT_8_8_REV_MESA   = 0x85BB;
const GLuint GL_YCBCR_MESA        = 0x8757;

// 302 - GL_EXT_pixel_buffer_object
const GLuint GL_PIXEL_PACK_BUFFER_EXT     = 0x88EB;
const GLuint GL_PIXEL_UNPACK_BUFFER_EXT     = 0x88EC;
const GLuint GL_PIXEL_PACK_BUFFER_BINDING_EXT   = 0x88ED;
const GLuint GL_PIXEL_UNPACK_BUFFER_BINDING_EXT   = 0x88EF;

// 304 - GL_NV_fragment_program2
const GLuint GL_MAX_PROGRAM_EXEC_INSTRUCTIONS_NV  = 0x88F4;
const GLuint GL_MAX_PROGRAM_CALL_DEPTH_NV   = 0x88F5;
const GLuint GL_MAX_PROGRAM_IF_DEPTH_NV     = 0x88F6;
const GLuint GL_MAX_PROGRAM_LOOP_DEPTH_NV   = 0x88F7;
const GLuint GL_MAX_PROGRAM_LOOP_COUNT_NV   = 0x88F8;

// 310 - GL_EXT_framebuffer_object
const GLuint GL_INVALID_FRAMEBUFFER_OPERATION_EXT = 0x0506;
const GLuint GL_MAX_RENDERBUFFER_SIZE_EXT   = 0x84E8;
const GLuint GL_FRAMEBUFFER_BINDING_EXT     = 0x8CA6;
const GLuint GL_RENDERBUFFER_BINDING_EXT    = 0x8CA7;
const GLuint GL_FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE_EXT  = 0x8CD0;
const GLuint GL_FRAMEBUFFER_ATTACHMENT_OBJECT_NAME_EXT  = 0x8CD1;
const GLuint GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL_EXT= 0x8CD2;
const GLuint GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE_EXT= 0x8CD3;
const GLuint GL_FRAMEBUFFER_ATTACHMENT_TEXTURE_3D_ZOFFSET_EXT= 0x8CD4;
const GLuint GL_FRAMEBUFFER_COMPLETE_EXT    = 0x8CD5;
const GLuint GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT_EXT = 0x8CD6;
const GLuint GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT_EXT= 0x8CD7;
const GLuint GL_FRAMEBUFFER_INCOMPLETE_DUPLICATE_ATTACHMENT_EXT= 0x8CD8;
const GLuint GL_FRAMEBUFFER_INCOMPLETE_DIMENSIONS_EXT = 0x8CD9;
const GLuint GL_FRAMEBUFFER_INCOMPLETE_FORMATS_EXT  = 0x8CDA;
const GLuint GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER_EXT  = 0x8CDB;
const GLuint GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER_EXT  = 0x8CDC;
const GLuint GL_FRAMEBUFFER_UNSUPPORTED_EXT   = 0x8CDD;
const GLuint GL_MAX_COLOR_ATTACHMENTS_EXT   = 0x8CDF;
const GLuint GL_COLOR_ATTACHMENT0_EXT     = 0x8CE0;
const GLuint GL_COLOR_ATTACHMENT1_EXT     = 0x8CE1;
const GLuint GL_COLOR_ATTACHMENT2_EXT     = 0x8CE2;
const GLuint GL_COLOR_ATTACHMENT3_EXT     = 0x8CE3;
const GLuint GL_COLOR_ATTACHMENT4_EXT     = 0x8CE4;
const GLuint GL_COLOR_ATTACHMENT5_EXT     = 0x8CE5;
const GLuint GL_COLOR_ATTACHMENT6_EXT     = 0x8CE6;
const GLuint GL_COLOR_ATTACHMENT7_EXT     = 0x8CE7;
const GLuint GL_COLOR_ATTACHMENT8_EXT     = 0x8CE8;
const GLuint GL_COLOR_ATTACHMENT9_EXT     = 0x8CE9;
const GLuint GL_COLOR_ATTACHMENT10_EXT      = 0x8CEA;
const GLuint GL_COLOR_ATTACHMENT11_EXT      = 0x8CEB;
const GLuint GL_COLOR_ATTACHMENT12_EXT      = 0x8CEC;
const GLuint GL_COLOR_ATTACHMENT13_EXT      = 0x8CED;
const GLuint GL_COLOR_ATTACHMENT14_EXT      = 0x8CEE;
const GLuint GL_COLOR_ATTACHMENT15_EXT      = 0x8CEF;
const GLuint GL_DEPTH_ATTACHMENT_EXT      = 0x8D00;
const GLuint GL_STENCIL_ATTACHMENT_EXT      = 0x8D20;
const GLuint GL_FRAMEBUFFER_EXT       = 0x8D40;
const GLuint GL_RENDERBUFFER_EXT      = 0x8D41;
const GLuint GL_RENDERBUFFER_WIDTH_EXT      = 0x8D42;
const GLuint GL_RENDERBUFFER_HEIGHT_EXT     = 0x8D43;
const GLuint GL_RENDERBUFFER_INTERNAL_FORMAT_EXT  = 0x8D44;
const GLuint GL_STENCIL_INDEX1_EXT      = 0x8D46;
const GLuint GL_STENCIL_INDEX4_EXT      = 0x8D47;
const GLuint GL_STENCIL_INDEX8_EXT      = 0x8D48;
const GLuint GL_STENCIL_INDEX16_EXT     = 0x8D49;
const GLuint GL_RENDERBUFFER_RED_SIZE_EXT   = 0x8D50;
const GLuint GL_RENDERBUFFER_GREEN_SIZE_EXT   = 0x8D51;
const GLuint GL_RENDERBUFFER_BLUE_SIZE_EXT    = 0x8D52;
const GLuint GL_RENDERBUFFER_ALPHA_SIZE_EXT   = 0x8D53;
const GLuint GL_RENDERBUFFER_DEPTH_SIZE_EXT   = 0x8D54;
const GLuint GL_RENDERBUFFER_STENCIL_SIZE_EXT   = 0x8D55;

// 314 - GL_EXT_stencil_clear_tag
const GLuint GL_STENCIL_TAG_BITS_EXT      = 0x88F2;
const GLuint GL_STENCIL_CLEAR_TAG_VALUE_EXT   = 0x88F3;

// 315 - GL_EXT_texture_sRGB
const GLuint SRGB_EXT         = 0x8C40;
const GLuint SRGB8_EXT          = 0x8C41;
const GLuint SRGB_ALPHA_EXT       = 0x8C42;
const GLuint SRGB8_ALPHA8_EXT       = 0x8C43;
const GLuint SLUMINANCE_ALPHA_EXT     = 0x8C44;
const GLuint SLUMINANCE8_ALPHA8_EXT     = 0x8C45;
const GLuint SLUMINANCE_EXT       = 0x8C46;
const GLuint SLUMINANCE8_EXT        = 0x8C47;
const GLuint COMPRESSED_SRGB_EXT      = 0x8C48;
const GLuint COMPRESSED_SRGB_ALPHA_EXT      = 0x8C49;
const GLuint COMPRESSED_SLUMINANCE_EXT      = 0x8C4A;
const GLuint COMPRESSED_SLUMINANCE_ALPHA_EXT    = 0x8C4B;
const GLuint COMPRESSED_SRGB_S3TC_DXT1_EXT    = 0x8C4C;
const GLuint COMPRESSED_SRGB_ALPHA_S3TC_DXT1_EXT  = 0x8C4D;
const GLuint COMPRESSED_SRGB_ALPHA_S3TC_DXT3_EXT  = 0x8C4E;
const GLuint COMPRESSED_SRGB_ALPHA_S3TC_DXT5_EXT  = 0x8C4F;

// 316 - GL_EXT_framebuffer_blit
const GLuint READ_FRAMEBUFFER_EXT     = 0x8CA8;
const GLuint DRAW_FRAMEBUFFER_EXT     = 0x8CA9;
const GLuint DRAW_FRAMEBUFFER_BINDING_EXT   = 0x8CA6;
const GLuint READ_FRAMEBUFFER_BINDING_EXT   = 0x8CAA;
const GLuint FRAMEBUFFER_BINDING_EXT      = DRAW_FRAMEBUFFER_BINDING_EXT;

// 317 - GL_EXT_framebuffer_multisample
const GLuint RENDERBUFFER_SAMPLES_EXT     = 0x8CAB;

// 318 - GL_MESAX_texture_stack
const GLuint TEXTURE_1D_STACK_MESAX     = 0x8759;
const GLuint TEXTURE_2D_STACK_MESAX     = 0x875A;
const GLuint PROXY_TEXTURE_1D_STACK_MESAX   = 0x875B;
const GLuint PROXY_TEXTURE_2D_STACK_MESAX   = 0x875C;
const GLuint TEXTURE_1D_STACK_BINDING_MESAX   = 0x875D;
const GLuint TEXTURE_2D_STACK_BINDING_MESAX   = 0x875E;

// 319 - GL_EXT_timer_query
const GLuint TIME_ELAPSED_EXT       = 0x88BF;

// 321 - GL_APPLE_flush_buffer_range
const GLuint BUFFER_SERIALIZED_MODIFY_APPLE   = 0x8A12;
const GLuint BUFFER_FLUSHING_UNMAP_APPLE    = 0x8A13;

/*
 * Types
 */
alias ptrdiff_t GLintptrARB;
alias ptrdiff_t GLsizeiptrARB;

alias char GLcharARB;
alias uint GLhandleARB;

alias ushort GLhalfARB;

alias ushort GLhalfNV;

/*
 * Functions
 */
private HXModule glextdrv;

private void* getProc (char[] procname) {
  void* symbol = ExeModule_GetSymbol(glextdrv, procname);
  if (symbol is null) {
    printf (("Failed to load OpenGL proc address " ~ procname ~ ".\n\0").ptr);
  }
  return symbol;
}

static this () {
  version (Windows) {
    glextdrv = ExeModule_Load("OpenGL32.dll");
  } else version (linux) {
    glextdrv = ExeModule_Load("libGL.so");
  }
  glActiveTextureARB = cast(pfglActiveTextureARB)getProc("glActiveTextureARB");
  glClientActiveTextureARB = cast(pfglClientActiveTextureARB)getProc("glClientActiveTextureARB");
  glMultiTexCoord1dARB = cast(pfglMultiTexCoord1dARB)getProc("glMultiTexCoord1dARB");
  glMultiTexCoord1dvARB = cast(pfglMultiTexCoord1dvARB)getProc("glMultiTexCoord1dvARB");
  glMultiTexCoord1fARB = cast(pfglMultiTexCoord1fARB)getProc("glMultiTexCoord1fARB");
  glMultiTexCoord1fvARB = cast(pfglMultiTexCoord1fvARB)getProc("glMultiTexCoord1fvARB");
  glMultiTexCoord1iARB = cast(pfglMultiTexCoord1iARB)getProc("glMultiTexCoord1iARB");
  glMultiTexCoord1ivARB = cast(pfglMultiTexCoord1ivARB)getProc("glMultiTexCoord1ivARB");
  glMultiTexCoord1sARB = cast(pfglMultiTexCoord1sARB)getProc("glMultiTexCoord1sARB");
  glMultiTexCoord1svARB = cast(pfglMultiTexCoord1svARB)getProc("glMultiTexCoord1svARB");
  glMultiTexCoord2dARB = cast(pfglMultiTexCoord2dARB)getProc("glMultiTexCoord2dARB");
  glMultiTexCoord2dvARB = cast(pfglMultiTexCoord2dvARB)getProc("glMultiTexCoord2dvARB");
  glMultiTexCoord2fARB = cast(pfglMultiTexCoord2fARB)getProc("glMultiTexCoord2fARB");
  glMultiTexCoord2fvARB = cast(pfglMultiTexCoord2fvARB)getProc("glMultiTexCoord2fvARB");
  glMultiTexCoord2iARB = cast(pfglMultiTexCoord2iARB)getProc("glMultiTexCoord2iARB");
  glMultiTexCoord2ivARB = cast(pfglMultiTexCoord2ivARB)getProc("glMultiTexCoord2ivARB");
  glMultiTexCoord2sARB = cast(pfglMultiTexCoord2sARB)getProc("glMultiTexCoord2sARB");
  glMultiTexCoord2svARB = cast(pfglMultiTexCoord2svARB)getProc("glMultiTexCoord2svARB");
  glMultiTexCoord3dARB = cast(pfglMultiTexCoord3dARB)getProc("glMultiTexCoord3dARB");
  glMultiTexCoord3dvARB = cast(pfglMultiTexCoord3dvARB)getProc("glMultiTexCoord3dvARB");
  glMultiTexCoord3fARB = cast(pfglMultiTexCoord3fARB)getProc("glMultiTexCoord3fARB");
  glMultiTexCoord3fvARB = cast(pfglMultiTexCoord3fvARB)getProc("glMultiTexCoord3fvARB");
  glMultiTexCoord3iARB = cast(pfglMultiTexCoord3iARB)getProc("glMultiTexCoord3iARB");
  glMultiTexCoord3ivARB = cast(pfglMultiTexCoord3ivARB)getProc("glMultiTexCoord3ivARB");
  glMultiTexCoord3sARB = cast(pfglMultiTexCoord3sARB)getProc("glMultiTexCoord3sARB");
  glMultiTexCoord3svARB = cast(pfglMultiTexCoord3svARB)getProc("glMultiTexCoord3svARB");
  glMultiTexCoord4dARB = cast(pfglMultiTexCoord4dARB)getProc("glMultiTexCoord4dARB");
  glMultiTexCoord4dvARB = cast(pfglMultiTexCoord4dvARB)getProc("glMultiTexCoord4dvARB");
  glMultiTexCoord4fARB = cast(pfglMultiTexCoord4fARB)getProc("glMultiTexCoord4fARB");
  glMultiTexCoord4fvARB = cast(pfglMultiTexCoord4fvARB)getProc("glMultiTexCoord4fvARB");
  glMultiTexCoord4iARB = cast(pfglMultiTexCoord4iARB)getProc("glMultiTexCoord4iARB");
  glMultiTexCoord4ivARB = cast(pfglMultiTexCoord4ivARB)getProc("glMultiTexCoord4ivARB");
  glMultiTexCoord4sARB = cast(pfglMultiTexCoord4sARB)getProc("glMultiTexCoord4sARB");
  glMultiTexCoord4svARB = cast(pfglMultiTexCoord4svARB)getProc("glMultiTexCoord4svARB");

  glLoadTransposeMatrixfARB = cast(pfglLoadTransposeMatrixfARB)getProc("glLoadTransposeMatrixfARB");
  glLoadTransposeMatrixdARB = cast(pfglLoadTransposeMatrixdARB)getProc("glLoadTransposeMatrixdARB");
  glMultTransposeMatrixfARB = cast(pfglMultTransposeMatrixfARB)getProc("glMultTransposeMatrixfARB");
  glMultTransposeMatrixdARB = cast(pfglMultTransposeMatrixdARB)getProc("glMultTransposeMatrixdARB");

  glSampleCoverageARB = cast(pfglSampleCoverageARB)getProc("glSampleCoverageARB");

  glCompressedTexImage3DARB = cast(pfglCompressedTexImage3DARB)getProc("glCompressedTexImage3DARB");
  glCompressedTexImage2DARB = cast(pfglCompressedTexImage2DARB)getProc("glCompressedTexImage2DARB");
  glCompressedTexImage1DARB = cast(pfglCompressedTexImage1DARB)getProc("glCompressedTexImage1DARB");
  glCompressedTexSubImage3DARB = cast(pfglCompressedTexSubImage3DARB)getProc("glCompressedTexSubImage3DARB");
  glCompressedTexSubImage2DARB = cast(pfglCompressedTexSubImage2DARB)getProc("glCompressedTexSubImage2DARB");
  glCompressedTexSubImage1DARB = cast(pfglCompressedTexSubImage1DARB)getProc("glCompressedTexSubImage1DARB");
  glGetCompressedTexImageARB = cast(pfglGetCompressedTexImageARB)getProc("glGetCompressedTexImageARB");

  glPointParameterfARB = cast(pfglPointParameterfARB)getProc("glPointParameterfARB");
  glPointParameterfvARB = cast(pfglPointParameterfvARB)getProc("glPointParameterfvARB");

  glWeightbvARB = cast(pfglWeightbvARB)getProc("glWeightbvARB");
  glWeightsvARB = cast(pfglWeightsvARB)getProc("glWeightsvARB");
  glWeightivARB = cast(pfglWeightivARB)getProc("glWeightivARB");
  glWeightfvARB = cast(pfglWeightfvARB)getProc("glWeightfvARB");
  glWeightdvARB = cast(pfglWeightdvARB)getProc("glWeightdvARB");
  glWeightubvARB = cast(pfglWeightubvARB)getProc("glWeightubvARB");
  glWeightusvARB = cast(pfglWeightusvARB)getProc("glWeightusvARB");
  glWeightuivARB = cast(pfglWeightuivARB)getProc("glWeightuivARB");
  glWeightPointerARB = cast(pfglWeightPointerARB)getProc("glWeightPointerARB");
  glVertexBlendARB = cast(pfglVertexBlendARB)getProc("glVertexBlendARB");

  glCurrentPaletteMatrixARB = cast(pfglCurrentPaletteMatrixARB)getProc("glCurrentPaletteMatrixARB");
  glMatrixIndexubvARB = cast(pfglMatrixIndexubvARB)getProc("glMatrixIndexubvARB");
  glMatrixIndexusvARB = cast(pfglMatrixIndexusvARB)getProc("glMatrixIndexusvARB");
  glMatrixIndexuivARB = cast(pfglMatrixIndexuivARB)getProc("glMatrixIndexuivARB");
  glMatrixIndexPointerARB = cast(pfglMatrixIndexPointerARB)getProc("glMatrixIndexPointerARB");

  glWindowPos2dARB = cast(pfglWindowPos2dARB)getProc("glWindowPos2dARB");
  glWindowPos2dvARB = cast(pfglWindowPos2dvARB)getProc("glWindowPos2dvARB");
  glWindowPos2fARB = cast(pfglWindowPos2fARB)getProc("glWindowPos2fARB");
  glWindowPos2fvARB = cast(pfglWindowPos2fvARB)getProc("glWindowPos2fvARB");
  glWindowPos2iARB = cast(pfglWindowPos2iARB)getProc("glWindowPos2iARB");
  glWindowPos2ivARB = cast(pfglWindowPos2ivARB)getProc("glWindowPos2ivARB");
  glWindowPos2sARB = cast(pfglWindowPos2sARB)getProc("glWindowPos2sARB");
  glWindowPos2svARB = cast(pfglWindowPos2svARB)getProc("glWindowPos2svARB");
  glWindowPos3dARB = cast(pfglWindowPos3dARB)getProc("glWindowPos3dARB");
  glWindowPos3dvARB = cast(pfglWindowPos3dvARB)getProc("glWindowPos3dvARB");
  glWindowPos3fARB = cast(pfglWindowPos3fARB)getProc("glWindowPos3fARB");
  glWindowPos3fvARB = cast(pfglWindowPos3fvARB)getProc("glWindowPos3fvARB");
  glWindowPos3iARB = cast(pfglWindowPos3iARB)getProc("glWindowPos3iARB");
  glWindowPos3ivARB = cast(pfglWindowPos3ivARB)getProc("glWindowPos3ivARB");
  glWindowPos3sARB = cast(pfglWindowPos3sARB)getProc("glWindowPos3sARB");
  glWindowPos3svARB = cast(pfglWindowPos3svARB)getProc("glWindowPos3svARB");

  glVertexAttrib1dARB = cast(pfglVertexAttrib1dARB)getProc("glVertexAttrib1dARB");
  glVertexAttrib1dvARB = cast(pfglVertexAttrib1dvARB)getProc("glVertexAttrib1dvARB");
  glVertexAttrib1fARB = cast(pfglVertexAttrib1fARB)getProc("glVertexAttrib1fARB");
  glVertexAttrib1fvARB = cast(pfglVertexAttrib1fvARB)getProc("glVertexAttrib1fvARB");
  glVertexAttrib1sARB = cast(pfglVertexAttrib1sARB)getProc("glVertexAttrib1sARB");
  glVertexAttrib1svARB = cast(pfglVertexAttrib1svARB)getProc("glVertexAttrib1svARB");
  glVertexAttrib2dARB = cast(pfglVertexAttrib2dARB)getProc("glVertexAttrib2dARB");
  glVertexAttrib2dvARB = cast(pfglVertexAttrib2dvARB)getProc("glVertexAttrib2dvARB");
  glVertexAttrib2fARB = cast(pfglVertexAttrib2fARB)getProc("glVertexAttrib2fARB");
  glVertexAttrib2fvARB = cast(pfglVertexAttrib2fvARB)getProc("glVertexAttrib2fvARB");
  glVertexAttrib2sARB = cast(pfglVertexAttrib2sARB)getProc("glVertexAttrib2sARB");
  glVertexAttrib2svARB = cast(pfglVertexAttrib2svARB)getProc("glVertexAttrib2svARB");
  glVertexAttrib3dARB = cast(pfglVertexAttrib3dARB)getProc("glVertexAttrib3dARB");
  glVertexAttrib3dvARB = cast(pfglVertexAttrib3dvARB)getProc("glVertexAttrib3dvARB");
  glVertexAttrib3fARB = cast(pfglVertexAttrib3fARB)getProc("glVertexAttrib3fARB");
  glVertexAttrib3fvARB = cast(pfglVertexAttrib3fvARB)getProc("glVertexAttrib3fvARB");
  glVertexAttrib3sARB = cast(pfglVertexAttrib3sARB)getProc("glVertexAttrib3sARB");
  glVertexAttrib3svARB = cast(pfglVertexAttrib3svARB)getProc("glVertexAttrib3svARB");
  glVertexAttrib4NbvARB = cast(pfglVertexAttrib4NbvARB)getProc("glVertexAttrib4NbvARB");
  glVertexAttrib4NivARB = cast(pfglVertexAttrib4NivARB)getProc("glVertexAttrib4NivARB");
  glVertexAttrib4NsvARB = cast(pfglVertexAttrib4NsvARB)getProc("glVertexAttrib4NsvARB");
  glVertexAttrib4NubARB = cast(pfglVertexAttrib4NubARB)getProc("glVertexAttrib4NubARB");
  glVertexAttrib4NubvARB = cast(pfglVertexAttrib4NubvARB)getProc("glVertexAttrib4NubvARB");
  glVertexAttrib4NuivARB = cast(pfglVertexAttrib4NuivARB)getProc("glVertexAttrib4NuivARB");
  glVertexAttrib4NusvARB = cast(pfglVertexAttrib4NusvARB)getProc("glVertexAttrib4NusvARB");
  glVertexAttrib4bvARB = cast(pfglVertexAttrib4bvARB)getProc("glVertexAttrib4bvARB");
  glVertexAttrib4dARB = cast(pfglVertexAttrib4dARB)getProc("glVertexAttrib4dARB");
  glVertexAttrib4dvARB = cast(pfglVertexAttrib4dvARB)getProc("glVertexAttrib4dvARB");
  glVertexAttrib4fARB = cast(pfglVertexAttrib4fARB)getProc("glVertexAttrib4fARB");
  glVertexAttrib4fvARB = cast(pfglVertexAttrib4fvARB)getProc("glVertexAttrib4fvARB");
  glVertexAttrib4ivARB = cast(pfglVertexAttrib4ivARB)getProc("glVertexAttrib4ivARB");
  glVertexAttrib4sARB = cast(pfglVertexAttrib4sARB)getProc("glVertexAttrib4sARB");
  glVertexAttrib4svARB = cast(pfglVertexAttrib4svARB)getProc("glVertexAttrib4svARB");
  glVertexAttrib4ubvARB = cast(pfglVertexAttrib4ubvARB)getProc("glVertexAttrib4ubvARB");
  glVertexAttrib4uivARB = cast(pfglVertexAttrib4uivARB)getProc("glVertexAttrib4uivARB");
  glVertexAttrib4usvARB = cast(pfglVertexAttrib4usvARB)getProc("glVertexAttrib4usvARB");
  glVertexAttribPointerARB = cast(pfglVertexAttribPointerARB)getProc("glVertexAttribPointerARB");
  glEnableVertexAttribArrayARB = cast(pfglEnableVertexAttribArrayARB)getProc("glEnableVertexAttribArrayARB");
  glDisableVertexAttribArrayARB = cast(pfglDisableVertexAttribArrayARB)getProc("glDisableVertexAttribArrayARB");
  glProgramStringARB = cast(pfglProgramStringARB)getProc("glProgramStringARB");
  glBindProgramARB = cast(pfglBindProgramARB)getProc("glBindProgramARB");
  glDeleteProgramsARB = cast(pfglDeleteProgramsARB)getProc("glDeleteProgramsARB");
  glGenProgramsARB = cast(pfglGenProgramsARB)getProc("glGenProgramsARB");
  glProgramEnvParameter4dARB = cast(pfglProgramEnvParameter4dARB)getProc("glProgramEnvParameter4dARB");
  glProgramEnvParameter4dvARB = cast(pfglProgramEnvParameter4dvARB)getProc("glProgramEnvParameter4dvARB");
  glProgramEnvParameter4fARB = cast(pfglProgramEnvParameter4fARB)getProc("glProgramEnvParameter4fARB");
  glProgramEnvParameter4fvARB = cast(pfglProgramEnvParameter4fvARB)getProc("glProgramEnvParameter4fvARB");
  glProgramLocalParameter4dARB = cast(pfglProgramLocalParameter4dARB)getProc("glProgramLocalParameter4dARB");
  glProgramLocalParameter4dvARB = cast(pfglProgramLocalParameter4dvARB)getProc("glProgramLocalParameter4dvARB");
  glProgramLocalParameter4fARB = cast(pfglProgramLocalParameter4fARB)getProc("glProgramLocalParameter4fARB");
  glProgramLocalParameter4fvARB = cast(pfglProgramLocalParameter4fvARB)getProc("glProgramLocalParameter4fvARB");
  glGetProgramEnvParameterdvARB = cast(pfglGetProgramEnvParameterdvARB)getProc("glGetProgramEnvParameterdvARB");
  glGetProgramEnvParameterfvARB = cast(pfglGetProgramEnvParameterfvARB)getProc("glGetProgramEnvParameterfvARB");
  glGetProgramLocalParameterdvARB = cast(pfglGetProgramLocalParameterdvARB)getProc("glGetProgramLocalParameterdvARB");
  glGetProgramLocalParameterfvARB = cast(pfglGetProgramLocalParameterfvARB)getProc("glGetProgramLocalParameterfvARB");
  glGetProgramivARB = cast(pfglGetProgramivARB)getProc("glGetProgramivARB");
  glGetProgramStringARB = cast(pfglGetProgramStringARB)getProc("glGetProgramStringARB");
  glGetVertexAttribdvARB = cast(pfglGetVertexAttribdvARB)getProc("glGetVertexAttribdvARB");
  glGetVertexAttribfvARB = cast(pfglGetVertexAttribfvARB)getProc("glGetVertexAttribfvARB");
  glGetVertexAttribivARB = cast(pfglGetVertexAttribivARB)getProc("glGetVertexAttribivARB");
  glGetVertexAttribPointervARB = cast(pfglGetVertexAttribPointervARB)getProc("glGetVertexAttribPointervARB");
  glIsProgramARB = cast(pfglIsProgramARB)getProc("glIsProgramARB");

  glBindBufferARB = cast(pfglBindBufferARB)getProc("glBindBufferARB");
  glDeleteBuffersARB = cast(pfglDeleteBuffersARB)getProc("glDeleteBuffersARB");
  glGenBuffersARB = cast(pfglGenBuffersARB)getProc("glGenBuffersARB");
  glIsBufferARB = cast(pfglIsBufferARB)getProc("glIsBufferARB");
  glBufferDataARB = cast(pfglBufferDataARB)getProc("glBufferDataARB");
  glBufferSubDataARB = cast(pfglBufferSubDataARB)getProc("glBufferSubDataARB");
  glGetBufferSubDataARB = cast(pfglGetBufferSubDataARB)getProc("glGetBufferSubDataARB");
  glMapBufferARB = cast(pfglMapBufferARB)getProc("glMapBufferARB");
  glUnmapBufferARB = cast(pfglUnmapBufferARB)getProc("glUnmapBufferARB");
  glGetBufferParameterivARB = cast(pfglGetBufferParameterivARB)getProc("glGetBufferParameterivARB");
  glGetBufferPointervARB = cast(pfglGetBufferPointervARB)getProc("glGetBufferPointervARB");

  glGenQueriesARB = cast(pfglGenQueriesARB)getProc("glGenQueriesARB");
  glDeleteQueriesARB = cast(pfglDeleteQueriesARB)getProc("glDeleteQueriesARB");
  glIsQueryARB = cast(pfglIsQueryARB)getProc("glIsQueryARB");
  glBeginQueryARB = cast(pfglBeginQueryARB)getProc("glBeginQueryARB");
  glEndQueryARB = cast(pfglEndQueryARB)getProc("glEndQueryARB");
  glGetQueryivARB = cast(pfglGetQueryivARB)getProc("glGetQueryivARB");
  glGetQueryObjectivARB = cast(pfglGetQueryObjectivARB)getProc("glGetQueryObjectivARB");
  glGetQueryObjectuivARB = cast(pfglGetQueryObjectuivARB)getProc("glGetQueryObjectuivARB");

  glDeleteObjectARB = cast(pfglDeleteObjectARB)getProc("glDeleteObjectARB");
  glGetHandleARB = cast(pfglGetHandleARB)getProc("glGetHandleARB");
  glDetachObjectARB = cast(pfglDetachObjectARB)getProc("glDetachObjectARB");
  glCreateShaderObjectARB = cast(pfglCreateShaderObjectARB)getProc("glCreateShaderObjectARB");
  glShaderSourceARB = cast(pfglShaderSourceARB)getProc("glShaderSourceARB");
  glCompileShaderARB = cast(pfglCompileShaderARB)getProc("glCompileShaderARB");
  glCreateProgramObjectARB = cast(pfglCreateProgramObjectARB)getProc("glCreateProgramObjectARB");
  glAttachObjectARB = cast(pfglAttachObjectARB)getProc("glAttachObjectARB");
  glLinkProgramARB = cast(pfglLinkProgramARB)getProc("glLinkProgramARB");
  glUseProgramObjectARB = cast(pfglUseProgramObjectARB)getProc("glUseProgramObjectARB");
  glValidateProgramARB = cast(pfglValidateProgramARB)getProc("glValidateProgramARB");
  glUniform1fARB = cast(pfglUniform1fARB)getProc("glUniform1fARB");
  glUniform2fARB = cast(pfglUniform2fARB)getProc("glUniform2fARB");
  glUniform3fARB = cast(pfglUniform3fARB)getProc("glUniform3fARB");
  glUniform4fARB = cast(pfglUniform4fARB)getProc("glUniform4fARB");
  glUniform1iARB = cast(pfglUniform1iARB)getProc("glUniform1iARB");
  glUniform2iARB = cast(pfglUniform2iARB)getProc("glUniform2iARB");
  glUniform3iARB = cast(pfglUniform3iARB)getProc("glUniform3iARB");
  glUniform4iARB = cast(pfglUniform4iARB)getProc("glUniform4iARB");
  glUniform1fvARB = cast(pfglUniform1fvARB)getProc("glUniform1fvARB");
  glUniform2fvARB = cast(pfglUniform2fvARB)getProc("glUniform2fvARB");
  glUniform3fvARB = cast(pfglUniform3fvARB)getProc("glUniform3fvARB");
  glUniform4fvARB = cast(pfglUniform4fvARB)getProc("glUniform4fvARB");
  glUniform1ivARB = cast(pfglUniform1ivARB)getProc("glUniform1ivARB");
  glUniform2ivARB = cast(pfglUniform2ivARB)getProc("glUniform2ivARB");
  glUniform3ivARB = cast(pfglUniform3ivARB)getProc("glUniform3ivARB");
  glUniform4ivARB = cast(pfglUniform4ivARB)getProc("glUniform4ivARB");
  glUniformMatrix2fvARB = cast(pfglUniformMatrix2fvARB)getProc("glUniformMatrix2fvARB");
  glUniformMatrix3fvARB = cast(pfglUniformMatrix3fvARB)getProc("glUniformMatrix3fvARB");
  glUniformMatrix4fvARB = cast(pfglUniformMatrix4fvARB)getProc("glUniformMatrix4fvARB");
  glGetObjectParameterfvARB = cast(pfglGetObjectParameterfvARB)getProc("glGetObjectParameterfvARB");
  glGetObjectParameterivARB = cast(pfglGetObjectParameterivARB)getProc("glGetObjectParameterivARB");
  glGetInfoLogARB = cast(pfglGetInfoLogARB)getProc("glGetInfoLogARB");
  glGetAttachedObjectsARB = cast(pfglGetAttachedObjectsARB)getProc("glGetAttachedObjectsARB");
  glGetUniformLocationARB = cast(pfglGetUniformLocationARB)getProc("glGetUniformLocationARB");
  glGetActiveUniformARB = cast(pfglGetActiveUniformARB)getProc("glGetActiveUniformARB");
  glGetUniformfvARB = cast(pfglGetUniformfvARB)getProc("glGetUniformfvARB");
  glGetUniformivARB = cast(pfglGetUniformivARB)getProc("glGetUniformivARB");
  glGetShaderSourceARB = cast(pfglGetShaderSourceARB)getProc("glGetShaderSourceARB");

  glBindAttribLocationARB = cast(pfglBindAttribLocationARB)getProc("glBindAttribLocationARB");
  glGetActiveAttribARB = cast(pfglGetActiveAttribARB)getProc("glGetActiveAttribARB");
  glGetAttribLocationARB = cast(pfglGetAttribLocationARB)getProc("glGetAttribLocationARB");

  glDrawBuffersARB = cast(pfglDrawBuffersARB)getProc("glDrawBuffersARB");

  glClampColorARB = cast(pfglClampColorARB)getProc("glClampColorARB");

  glBlendColorEXT = cast(pfglBlendColorEXT)getProc("glBlendColorEXT");

  glPolygonOffsetEXT = cast(pfglPolygonOffsetEXT)getProc("glPolygonOffsetEXT");

  glTexImage3DEXT = cast(pfglTexImage3DEXT)getProc("glTexImage3DEXT");
  glTexSubImage3DEXT = cast(pfglTexSubImage3DEXT)getProc("glTexSubImage3DEXT");

  glGetTexFilterFuncSGIS = cast(pfglGetTexFilterFuncSGIS)getProc("glGetTexFilterFuncSGIS");
  glTexFilterFuncSGIS = cast(pfglTexFilterFuncSGIS)getProc("glTexFilterFuncSGIS");

  glTexSubImage1DEXT = cast(pfglTexSubImage1DEXT)getProc("glTexSubImage1DEXT");
  glTexSubImage2DEXT = cast(pfglTexSubImage2DEXT)getProc("glTexSubImage2DEXT");

  glCopyTexImage1DEXT = cast(pfglCopyTexImage1DEXT)getProc("glCopyTexImage1DEXT");
  glCopyTexImage2DEXT = cast(pfglCopyTexImage2DEXT)getProc("glCopyTexImage2DEXT");
  glCopyTexSubImage1DEXT = cast(pfglCopyTexSubImage1DEXT)getProc("glCopyTexSubImage1DEXT");
  glCopyTexSubImage2DEXT = cast(pfglCopyTexSubImage2DEXT)getProc("glCopyTexSubImage2DEXT");
  glCopyTexSubImage3DEXT = cast(pfglCopyTexSubImage3DEXT)getProc("glCopyTexSubImage3DEXT");

  glGetHistogramEXT = cast(pfglGetHistogramEXT)getProc("glGetHistogramEXT");
  glGetHistogramParameterfvEXT = cast(pfglGetHistogramParameterfvEXT)getProc("glGetHistogramParameterfvEXT");
  glGetHistogramParameterivEXT = cast(pfglGetHistogramParameterivEXT)getProc("glGetHistogramParameterivEXT");
  glGetMinmaxEXT = cast(pfglGetMinmaxEXT)getProc("glGetMinmaxEXT");
  glGetMinmaxParameterfvEXT = cast(pfglGetMinmaxParameterfvEXT)getProc("glGetMinmaxParameterfvEXT");
  glGetMinmaxParameterivEXT = cast(pfglGetMinmaxParameterivEXT)getProc("glGetMinmaxParameterivEXT");
  glHistogramEXT = cast(pfglHistogramEXT)getProc("glHistogramEXT");
  glMinmaxEXT = cast(pfglMinmaxEXT)getProc("glMinmaxEXT");
  glResetHistogramEXT = cast(pfglResetHistogramEXT)getProc("glResetHistogramEXT");
  glResetMinmaxEXT = cast(pfglResetMinmaxEXT)getProc("glResetMinmaxEXT");

  glConvolutionFilter1DEXT = cast(pfglConvolutionFilter1DEXT)getProc("glConvolutionFilter1DEXT");
  glConvolutionFilter2DEXT = cast(pfglConvolutionFilter2DEXT)getProc("glConvolutionFilter2DEXT");
  glConvolutionParameterfEXT = cast(pfglConvolutionParameterfEXT)getProc("glConvolutionParameterfEXT");
  glConvolutionParameterfvEXT = cast(pfglConvolutionParameterfvEXT)getProc("glConvolutionParameterfvEXT");
  glConvolutionParameteriEXT = cast(pfglConvolutionParameteriEXT)getProc("glConvolutionParameteriEXT");
  glConvolutionParameterivEXT = cast(pfglConvolutionParameterivEXT)getProc("glConvolutionParameterivEXT");
  glCopyConvolutionFilter1DEXT = cast(pfglCopyConvolutionFilter1DEXT)getProc("glCopyConvolutionFilter1DEXT");
  glCopyConvolutionFilter2DEXT = cast(pfglCopyConvolutionFilter2DEXT)getProc("glCopyConvolutionFilter2DEXT");
  glGetConvolutionFilterEXT = cast(pfglGetConvolutionFilterEXT)getProc("glGetConvolutionFilterEXT");
  glGetConvolutionParameterfvEXT = cast(pfglGetConvolutionParameterfvEXT)getProc("glGetConvolutionParameterfvEXT");
  glGetConvolutionParameterivEXT = cast(pfglGetConvolutionParameterivEXT)getProc("glGetConvolutionParameterivEXT");
  glGetSeparableFilterEXT = cast(pfglGetSeparableFilterEXT)getProc("glGetSeparableFilterEXT");
  glSeparableFilter2DEXT = cast(pfglSeparableFilter2DEXT)getProc("glSeparableFilter2DEXT");

  glColorTableSGI = cast(pfglColorTableSGI)getProc("glColorTableSGI");
  glColorTableParameterfvSGI = cast(pfglColorTableParameterfvSGI)getProc("glColorTableParameterfvSGI");
  glColorTableParameterivSGI = cast(pfglColorTableParameterivSGI)getProc("glColorTableParameterivSGI");
  glCopyColorTableSGI = cast(pfglCopyColorTableSGI)getProc("glCopyColorTableSGI");
  glGetColorTableSGI = cast(pfglGetColorTableSGI)getProc("glGetColorTableSGI");
  glGetColorTableParameterfvSGI = cast(pfglGetColorTableParameterfvSGI)getProc("glGetColorTableParameterfvSGI");
  glGetColorTableParameterivSGI = cast(pfglGetColorTableParameterivSGI)getProc("glGetColorTableParameterivSGI");

  glPixelTexGenParameteriSGIS = cast(pfglPixelTexGenParameteriSGIS)getProc("glPixelTexGenParameteriSGIS");
  glPixelTexGenParameterivSGIS = cast(pfglPixelTexGenParameterivSGIS)getProc("glPixelTexGenParameterivSGIS");
  glPixelTexGenParameterfSGIS = cast(pfglPixelTexGenParameterfSGIS)getProc("glPixelTexGenParameterfSGIS");
  glPixelTexGenParameterfvSGIS = cast(pfglPixelTexGenParameterfvSGIS)getProc("glPixelTexGenParameterfvSGIS");
  glGetPixelTexGenParameterivSGIS = cast(pfglGetPixelTexGenParameterivSGIS)getProc("glGetPixelTexGenParameterivSGIS");
  glGetPixelTexGenParameterfvSGIS = cast(pfglGetPixelTexGenParameterfvSGIS)getProc("glGetPixelTexGenParameterfvSGIS");

  glPixelTexGenSGIX = cast(pfglPixelTexGenSGIX)getProc("glPixelTexGenSGIX");

  glTexImage4DSGIS = cast(pfglTexImage4DSGIS)getProc("glTexImage4DSGIS");
  glTexSubImage4DSGIS = cast(pfglTexSubImage4DSGIS)getProc("glTexSubImage4DSGIS");

  glAreTexturesResidentEXT = cast(pfglAreTexturesResidentEXT)getProc("glAreTexturesResidentEXT");
  glBindTextureEXT = cast(pfglBindTextureEXT)getProc("glBindTextureEXT");
  glDeleteTexturesEXT = cast(pfglDeleteTexturesEXT)getProc("glDeleteTexturesEXT");
  glGenTexturesEXT = cast(pfglGenTexturesEXT)getProc("glGenTexturesEXT");
  glIsTextureEXT = cast(pfglIsTextureEXT)getProc("glIsTextureEXT");
  glPrioritizeTexturesEXT = cast(pfglPrioritizeTexturesEXT)getProc("glPrioritizeTexturesEXT");

  glDetailTexFuncSGIS = cast(pfglDetailTexFuncSGIS)getProc("glDetailTexFuncSGIS");
  glGetDetailTexFuncSGIS = cast(pfglGetDetailTexFuncSGIS)getProc("glGetDetailTexFuncSGIS");

  glSharpenTexFuncSGIS = cast(pfglSharpenTexFuncSGIS)getProc("glSharpenTexFuncSGIS");
  glGetSharpenTexFuncSGIS = cast(pfglGetSharpenTexFuncSGIS)getProc("glGetSharpenTexFuncSGIS");

  glSampleMaskSGIS = cast(pfglSampleMaskSGIS)getProc("glSampleMaskSGIS");
  glSamplePatternSGIS = cast(pfglSamplePatternSGIS)getProc("glSamplePatternSGIS");

  glArrayElementEXT = cast(pfglArrayElementEXT)getProc("glArrayElementEXT");
  glColorPointerEXT = cast(pfglColorPointerEXT)getProc("glColorPointerEXT");
  glDrawArraysEXT = cast(pfglDrawArraysEXT)getProc("glDrawArraysEXT");
  glEdgeFlagPointerEXT = cast(pfglEdgeFlagPointerEXT)getProc("glEdgeFlagPointerEXT");
  glGetPointervEXT = cast(pfglGetPointervEXT)getProc("glGetPointervEXT");
  glIndexPointerEXT = cast(pfglIndexPointerEXT)getProc("glIndexPointerEXT");
  glNormalPointerEXT = cast(pfglNormalPointerEXT)getProc("glNormalPointerEXT");
  glTexCoordPointerEXT = cast(pfglTexCoordPointerEXT)getProc("glTexCoordPointerEXT");
  glVertexPointerEXT = cast(pfglVertexPointerEXT)getProc("glVertexPointerEXT");

  glBlendEquationEXT = cast(pfglBlendEquationEXT)getProc("glBlendEquationEXT");

  glSpriteParameterfSGIX = cast(pfglSpriteParameterfSGIX)getProc("glSpriteParameterfSGIX");
  glSpriteParameterfvSGIX = cast(pfglSpriteParameterfvSGIX)getProc("glSpriteParameterfvSGIX");
  glSpriteParameteriSGIX = cast(pfglSpriteParameteriSGIX)getProc("glSpriteParameteriSGIX");
  glSpriteParameterivSGIX = cast(pfglSpriteParameterivSGIX)getProc("glSpriteParameterivSGIX");

  glPointParameterfEXT = cast(pfglPointParameterfEXT)getProc("glPointParameterfEXT");
  glPointParameterfvEXT = cast(pfglPointParameterfvEXT)getProc("glPointParameterfvEXT");

  glPointParameterfSGIS = cast(pfglPointParameterfSGIS)getProc("glPointParameterfSGIS");
  glPointParameterfvSGIS = cast(pfglPointParameterfvSGIS)getProc("glPointParameterfvSGIS");

  glGetInstrumentsSGIX = cast(pfglGetInstrumentsSGIX)getProc("glGetInstrumentsSGIX");
  glInstrumentsBufferSGIX = cast(pfglInstrumentsBufferSGIX)getProc("glInstrumentsBufferSGIX");
  glPollInstrumentsSGIX = cast(pfglPollInstrumentsSGIX)getProc("glPollInstrumentsSGIX");
  glReadInstrumentsSGIX = cast(pfglReadInstrumentsSGIX)getProc("glReadInstrumentsSGIX");
  glStartInstrumentsSGIX = cast(pfglStartInstrumentsSGIX)getProc("glStartInstrumentsSGIX");
  glStopInstrumentsSGIX = cast(pfglStopInstrumentsSGIX)getProc("glStopInstrumentsSGIX");

  glFrameZoomSGIX = cast(pfglFrameZoomSGIX)getProc("glFrameZoomSGIX");

  glTagSampleBufferSGIX = cast(pfglTagSampleBufferSGIX)getProc("glTagSampleBufferSGIX");

  glDeformationMap3dSGIX = cast(pfglDeformationMap3dSGIX)getProc("glDeformationMap3dSGIX");
  glDeformationMap3fSGIX = cast(pfglDeformationMap3fSGIX)getProc("glDeformationMap3fSGIX");
  glDeformSGIX = cast(pfglDeformSGIX)getProc("glDeformSGIX");
  glLoadIdentityDeformationMapSGIX = cast(pfglLoadIdentityDeformationMapSGIX)getProc("glLoadIdentityDeformationMapSGIX");

  glReferencePlaneSGIX = cast(pfglReferencePlaneSGIX)getProc("glReferencePlaneSGIX");

  glFlushRasterSGIX = cast(pfglFlushRasterSGIX)getProc("glFlushRasterSGIX");

  glFogFuncSGIS = cast(pfglFogFuncSGIS)getProc("glFogFuncSGIS");
  glGetFogFuncSGIS = cast(pfglGetFogFuncSGIS)getProc("glGetFogFuncSGIS");

  glImageTransformParameteriHP = cast(pfglImageTransformParameteriHP)getProc("glImageTransformParameteriHP");
  glImageTransformParameterfHP = cast(pfglImageTransformParameterfHP)getProc("glImageTransformParameterfHP");
  glImageTransformParameterivHP = cast(pfglImageTransformParameterivHP)getProc("glImageTransformParameterivHP");
  glImageTransformParameterfvHP = cast(pfglImageTransformParameterfvHP)getProc("glImageTransformParameterfvHP");
  glGetImageTransformParameterivHP = cast(pfglGetImageTransformParameterivHP)getProc("glGetImageTransformParameterivHP");
  glGetImageTransformParameterfvHP = cast(pfglGetImageTransformParameterfvHP)getProc("glGetImageTransformParameterfvHP");

  glColorSubTableEXT = cast(pfglColorSubTableEXT)getProc("glColorSubTableEXT");
  glCopyColorSubTableEXT = cast(pfglCopyColorSubTableEXT)getProc("glCopyColorSubTableEXT");

  glHintPGI = cast(pfglHintPGI)getProc("glHintPGI");

  glColorTableEXT = cast(pfglColorTableEXT)getProc("glColorTableEXT");
  glGetColorTableEXT = cast(pfglGetColorTableEXT)getProc("glGetColorTableEXT");
  glGetColorTableParameterivEXT = cast(pfglGetColorTableParameterivEXT)getProc("glGetColorTableParameterivEXT");
  glGetColorTableParameterfvEXT = cast(pfglGetColorTableParameterfvEXT)getProc("glGetColorTableParameterfvEXT");

  glGetListParameterfvSGIX = cast(pfglGetListParameterfvSGIX)getProc("glGetListParameterfvSGIX");
  glGetListParameterivSGIX = cast(pfglGetListParameterivSGIX)getProc("glGetListParameterivSGIX");
  glListParameterfSGIX = cast(pfglListParameterfSGIX)getProc("glListParameterfSGIX");
  glListParameterfvSGIX = cast(pfglListParameterfvSGIX)getProc("glListParameterfvSGIX");
  glListParameteriSGIX = cast(pfglListParameteriSGIX)getProc("glListParameteriSGIX");
  glListParameterivSGIX = cast(pfglListParameterivSGIX)getProc("glListParameterivSGIX");

  glIndexMaterialEXT = cast(pfglIndexMaterialEXT)getProc("glIndexMaterialEXT");

  glIndexFuncEXT = cast(pfglIndexFuncEXT)getProc("glIndexFuncEXT");

  glLockArraysEXT = cast(pfglLockArraysEXT)getProc("glLockArraysEXT");
  glUnlockArraysEXT = cast(pfglUnlockArraysEXT)getProc("glUnlockArraysEXT");

  glCullParameterdvEXT = cast(pfglCullParameterdvEXT)getProc("glCullParameterdvEXT");
  glCullParameterfvEXT = cast(pfglCullParameterfvEXT)getProc("glCullParameterfvEXT");

  glFragmentColorMaterialSGIX = cast(pfglFragmentColorMaterialSGIX)getProc("glFragmentColorMaterialSGIX");
  glFragmentLightfSGIX = cast(pfglFragmentLightfSGIX)getProc("glFragmentLightfSGIX");
  glFragmentLightfvSGIX = cast(pfglFragmentLightfvSGIX)getProc("glFragmentLightfvSGIX");
  glFragmentLightiSGIX = cast(pfglFragmentLightiSGIX)getProc("glFragmentLightiSGIX");
  glFragmentLightivSGIX = cast(pfglFragmentLightivSGIX)getProc("glFragmentLightivSGIX");
  glFragmentLightModelfSGIX = cast(pfglFragmentLightModelfSGIX)getProc("glFragmentLightModelfSGIX");
  glFragmentLightModelfvSGIX = cast(pfglFragmentLightModelfvSGIX)getProc("glFragmentLightModelfvSGIX");
  glFragmentLightModeliSGIX = cast(pfglFragmentLightModeliSGIX)getProc("glFragmentLightModeliSGIX");
  glFragmentLightModelivSGIX = cast(pfglFragmentLightModelivSGIX)getProc("glFragmentLightModelivSGIX");
  glFragmentMaterialfSGIX = cast(pfglFragmentMaterialfSGIX)getProc("glFragmentMaterialfSGIX");
  glFragmentMaterialfvSGIX = cast(pfglFragmentMaterialfvSGIX)getProc("glFragmentMaterialfvSGIX");
  glFragmentMaterialiSGIX = cast(pfglFragmentMaterialiSGIX)getProc("glFragmentMaterialiSGIX");
  glFragmentMaterialivSGIX = cast(pfglFragmentMaterialivSGIX)getProc("glFragmentMaterialivSGIX");
  glGetFragmentLightfvSGIX = cast(pfglGetFragmentLightfvSGIX)getProc("glGetFragmentLightfvSGIX");
  glGetFragmentLightivSGIX = cast(pfglGetFragmentLightivSGIX)getProc("glGetFragmentLightivSGIX");
  glGetFragmentMaterialfvSGIX = cast(pfglGetFragmentMaterialfvSGIX)getProc("glGetFragmentMaterialfvSGIX");
  glGetFragmentMaterialivSGIX = cast(pfglGetFragmentMaterialivSGIX)getProc("glGetFragmentMaterialivSGIX");
  glLightEnviSGIX = cast(pfglLightEnviSGIX)getProc("glLightEnviSGIX");

  glDrawRangeElementsEXT = cast(pfglDrawRangeElementsEXT)getProc("glDrawRangeElementsEXT");

  glApplyTextureEXT = cast(pfglApplyTextureEXT)getProc("glApplyTextureEXT");
  glTextureLightEXT = cast(pfglTextureLightEXT)getProc("glTextureLightEXT");
  glTextureMaterialEXT = cast(pfglTextureMaterialEXT)getProc("glTextureMaterialEXT");

  glAsyncMarkerSGIX = cast(pfglAsyncMarkerSGIX)getProc("glAsyncMarkerSGIX");
  glFinishAsyncSGIX = cast(pfglFinishAsyncSGIX)getProc("glFinishAsyncSGIX");
  glPollAsyncSGIX = cast(pfglPollAsyncSGIX)getProc("glPollAsyncSGIX");
  glGenAsyncMarkersSGIX = cast(pfglGenAsyncMarkersSGIX)getProc("glGenAsyncMarkersSGIX");
  glDeleteAsyncMarkersSGIX = cast(pfglDeleteAsyncMarkersSGIX)getProc("glDeleteAsyncMarkersSGIX");
  glIsAsyncMarkerSGIX = cast(pfglIsAsyncMarkerSGIX)getProc("glIsAsyncMarkerSGIX");

  glVertexPointervINTEL = cast(pfglVertexPointervINTEL)getProc("glVertexPointervINTEL");
  glNormalPointervINTEL = cast(pfglNormalPointervINTEL)getProc("glNormalPointervINTEL");
  glColorPointervINTEL = cast(pfglColorPointervINTEL)getProc("glColorPointervINTEL");
  glTexCoordPointervINTEL = cast(pfglTexCoordPointervINTEL)getProc("glTexCoordPointervINTEL");

  glPixelTransformParameteriEXT = cast(pfglPixelTransformParameteriEXT)getProc("glPixelTransformParameteriEXT");
  glPixelTransformParameterfEXT = cast(pfglPixelTransformParameterfEXT)getProc("glPixelTransformParameterfEXT");
  glPixelTransformParameterivEXT = cast(pfglPixelTransformParameterivEXT)getProc("glPixelTransformParameterivEXT");
  glPixelTransformParameterfvEXT = cast(pfglPixelTransformParameterfvEXT)getProc("glPixelTransformParameterfvEXT");

  glSecondaryColor3bEXT = cast(pfglSecondaryColor3bEXT)getProc("glSecondaryColor3bEXT");
  glSecondaryColor3bvEXT = cast(pfglSecondaryColor3bvEXT)getProc("glSecondaryColor3bvEXT");
  glSecondaryColor3dEXT = cast(pfglSecondaryColor3dEXT)getProc("glSecondaryColor3dEXT");
  glSecondaryColor3dvEXT = cast(pfglSecondaryColor3dvEXT)getProc("glSecondaryColor3dvEXT");
  glSecondaryColor3fEXT = cast(pfglSecondaryColor3fEXT)getProc("glSecondaryColor3fEXT");
  glSecondaryColor3fvEXT = cast(pfglSecondaryColor3fvEXT)getProc("glSecondaryColor3fvEXT");
  glSecondaryColor3iEXT = cast(pfglSecondaryColor3iEXT)getProc("glSecondaryColor3iEXT");
  glSecondaryColor3ivEXT = cast(pfglSecondaryColor3ivEXT)getProc("glSecondaryColor3ivEXT");
  glSecondaryColor3sEXT = cast(pfglSecondaryColor3sEXT)getProc("glSecondaryColor3sEXT");
  glSecondaryColor3svEXT = cast(pfglSecondaryColor3svEXT)getProc("glSecondaryColor3svEXT");
  glSecondaryColor3ubEXT = cast(pfglSecondaryColor3ubEXT)getProc("glSecondaryColor3ubEXT");
  glSecondaryColor3ubvEXT = cast(pfglSecondaryColor3ubvEXT)getProc("glSecondaryColor3ubvEXT");
  glSecondaryColor3uiEXT = cast(pfglSecondaryColor3uiEXT)getProc("glSecondaryColor3uiEXT");
  glSecondaryColor3uivEXT = cast(pfglSecondaryColor3uivEXT)getProc("glSecondaryColor3uivEXT");
  glSecondaryColor3usEXT = cast(pfglSecondaryColor3usEXT)getProc("glSecondaryColor3usEXT");
  glSecondaryColor3usvEXT = cast(pfglSecondaryColor3usvEXT)getProc("glSecondaryColor3usvEXT");
  glSecondaryColorPointerEXT = cast(pfglSecondaryColorPointerEXT)getProc("glSecondaryColorPointerEXT");

  glTextureNormalEXT = cast(pfglTextureNormalEXT)getProc("glTextureNormalEXT");

  glMultiDrawArraysEXT = cast(pfglMultiDrawArraysEXT)getProc("glMultiDrawArraysEXT");
  glMultiDrawElementsEXT = cast(pfglMultiDrawElementsEXT)getProc("glMultiDrawElementsEXT");

  glFogCoordfEXT = cast(pfglFogCoordfEXT)getProc("glFogCoordfEXT");
  glFogCoordfvEXT = cast(pfglFogCoordfvEXT)getProc("glFogCoordfvEXT");
  glFogCoorddEXT = cast(pfglFogCoorddEXT)getProc("glFogCoorddEXT");
  glFogCoorddvEXT = cast(pfglFogCoorddvEXT)getProc("glFogCoorddvEXT");
  glFogCoordPointerEXT = cast(pfglFogCoordPointerEXT)getProc("glFogCoordPointerEXT");

  glTangent3bEXT = cast(pfglTangent3bEXT)getProc("glTangent3bEXT");
  glTangent3bvEXT = cast(pfglTangent3bvEXT)getProc("glTangent3bvEXT");
  glTangent3dEXT = cast(pfglTangent3dEXT)getProc("glTangent3dEXT");
  glTangent3dvEXT = cast(pfglTangent3dvEXT)getProc("glTangent3dvEXT");
  glTangent3fEXT = cast(pfglTangent3fEXT)getProc("glTangent3fEXT");
  glTangent3fvEXT = cast(pfglTangent3fvEXT)getProc("glTangent3fvEXT");
  glTangent3iEXT = cast(pfglTangent3iEXT)getProc("glTangent3iEXT");
  glTangent3ivEXT = cast(pfglTangent3ivEXT)getProc("glTangent3ivEXT");
  glTangent3sEXT = cast(pfglTangent3sEXT)getProc("glTangent3sEXT");
  glTangent3svEXT = cast(pfglTangent3svEXT)getProc("glTangent3svEXT");
  glBinormal3bEXT = cast(pfglBinormal3bEXT)getProc("glBinormal3bEXT");
  glBinormal3bvEXT = cast(pfglBinormal3bvEXT)getProc("glBinormal3bvEXT");
  glBinormal3dEXT = cast(pfglBinormal3dEXT)getProc("glBinormal3dEXT");
  glBinormal3dvEXT = cast(pfglBinormal3dvEXT)getProc("glBinormal3dvEXT");
  glBinormal3fEXT = cast(pfglBinormal3fEXT)getProc("glBinormal3fEXT");
  glBinormal3fvEXT = cast(pfglBinormal3fvEXT)getProc("glBinormal3fvEXT");
  glBinormal3iEXT = cast(pfglBinormal3iEXT)getProc("glBinormal3iEXT");
  glBinormal3ivEXT = cast(pfglBinormal3ivEXT)getProc("glBinormal3ivEXT");
  glBinormal3sEXT = cast(pfglBinormal3sEXT)getProc("glBinormal3sEXT");
  glBinormal3svEXT = cast(pfglBinormal3svEXT)getProc("glBinormal3svEXT");
  glTangentPointerEXT = cast(pfglTangentPointerEXT)getProc("glTangentPointerEXT");
  glBinormalPointerEXT = cast(pfglBinormalPointerEXT)getProc("glBinormalPointerEXT");

  glFinishTextureSUNX = cast(pfglFinishTextureSUNX)getProc("glFinishTextureSUNX");

  glGlobalAlphaFactorbSUN = cast(pfglGlobalAlphaFactorbSUN)getProc("glGlobalAlphaFactorbSUN");
  glGlobalAlphaFactorsSUN = cast(pfglGlobalAlphaFactorsSUN)getProc("glGlobalAlphaFactorsSUN");
  glGlobalAlphaFactoriSUN = cast(pfglGlobalAlphaFactoriSUN)getProc("glGlobalAlphaFactoriSUN");
  glGlobalAlphaFactorfSUN = cast(pfglGlobalAlphaFactorfSUN)getProc("glGlobalAlphaFactorfSUN");
  glGlobalAlphaFactordSUN = cast(pfglGlobalAlphaFactordSUN)getProc("glGlobalAlphaFactordSUN");
  glGlobalAlphaFactorubSUN = cast(pfglGlobalAlphaFactorubSUN)getProc("glGlobalAlphaFactorubSUN");
  glGlobalAlphaFactorusSUN = cast(pfglGlobalAlphaFactorusSUN)getProc("glGlobalAlphaFactorusSUN");
  glGlobalAlphaFactoruiSUN = cast(pfglGlobalAlphaFactoruiSUN)getProc("glGlobalAlphaFactoruiSUN");

  glReplacementCodeuiSUN = cast(pfglReplacementCodeuiSUN)getProc("glReplacementCodeuiSUN");
  glReplacementCodeusSUN = cast(pfglReplacementCodeusSUN)getProc("glReplacementCodeusSUN");
  glReplacementCodeubSUN = cast(pfglReplacementCodeubSUN)getProc("glReplacementCodeubSUN");
  glReplacementCodeuivSUN = cast(pfglReplacementCodeuivSUN)getProc("glReplacementCodeuivSUN");
  glReplacementCodeusvSUN = cast(pfglReplacementCodeusvSUN)getProc("glReplacementCodeusvSUN");
  glReplacementCodeubvSUN = cast(pfglReplacementCodeubvSUN)getProc("glReplacementCodeubvSUN");
  glReplacementCodePointerSUN = cast(pfglReplacementCodePointerSUN)getProc("glReplacementCodePointerSUN");

  glColor4ubVertex2fSUN = cast(pfglColor4ubVertex2fSUN)getProc("glColor4ubVertex2fSUN");
  glColor4ubVertex2fvSUN = cast(pfglColor4ubVertex2fvSUN)getProc("glColor4ubVertex2fvSUN");
  glColor4ubVertex3fSUN = cast(pfglColor4ubVertex3fSUN)getProc("glColor4ubVertex3fSUN");
  glColor4ubVertex3fvSUN = cast(pfglColor4ubVertex3fvSUN)getProc("glColor4ubVertex3fvSUN");
  glColor3fVertex3fSUN = cast(pfglColor3fVertex3fSUN)getProc("glColor3fVertex3fSUN");
  glColor3fVertex3fvSUN = cast(pfglColor3fVertex3fvSUN)getProc("glColor3fVertex3fvSUN");
  glNormal3fVertex3fSUN = cast(pfglNormal3fVertex3fSUN)getProc("glNormal3fVertex3fSUN");
  glNormal3fVertex3fvSUN = cast(pfglNormal3fVertex3fvSUN)getProc("glNormal3fVertex3fvSUN");
  glColor4fNormal3fVertex3fSUN = cast(pfglColor4fNormal3fVertex3fSUN)getProc("glColor4fNormal3fVertex3fSUN");
  glColor4fNormal3fVertex3fvSUN = cast(pfglColor4fNormal3fVertex3fvSUN)getProc("glColor4fNormal3fVertex3fvSUN");
  glTexCoord2fVertex3fSUN = cast(pfglTexCoord2fVertex3fSUN)getProc("glTexCoord2fVertex3fSUN");
  glTexCoord2fVertex3fvSUN = cast(pfglTexCoord2fVertex3fvSUN)getProc("glTexCoord2fVertex3fvSUN");
  glTexCoord4fVertex4fSUN = cast(pfglTexCoord4fVertex4fSUN)getProc("glTexCoord4fVertex4fSUN");
  glTexCoord4fVertex4fvSUN = cast(pfglTexCoord4fVertex4fvSUN)getProc("glTexCoord4fVertex4fvSUN");
  glTexCoord2fColor4ubVertex3fSUN = cast(pfglTexCoord2fColor4ubVertex3fSUN)getProc("glTexCoord2fColor4ubVertex3fSUN");
  glTexCoord2fColor4ubVertex3fvSUN = cast(pfglTexCoord2fColor4ubVertex3fvSUN)getProc("glTexCoord2fColor4ubVertex3fvSUN");
  glTexCoord2fColor3fVertex3fSUN = cast(pfglTexCoord2fColor3fVertex3fSUN)getProc("glTexCoord2fColor3fVertex3fSUN");
  glTexCoord2fColor3fVertex3fvSUN = cast(pfglTexCoord2fColor3fVertex3fvSUN)getProc("glTexCoord2fColor3fVertex3fvSUN");
  glTexCoord2fNormal3fVertex3fSUN = cast(pfglTexCoord2fNormal3fVertex3fSUN)getProc("glTexCoord2fNormal3fVertex3fSUN");
  glTexCoord2fNormal3fVertex3fvSUN = cast(pfglTexCoord2fNormal3fVertex3fvSUN)getProc("glTexCoord2fNormal3fVertex3fvSUN");
  glTexCoord2fColor4fNormal3fVertex3fSUN = cast(pfglTexCoord2fColor4fNormal3fVertex3fSUN)getProc("glTexCoord2fColor4fNormal3fVertex3fSUN");
  glTexCoord2fColor4fNormal3fVertex3fvSUN = cast(pfglTexCoord2fColor4fNormal3fVertex3fvSUN)getProc("glTexCoord2fColor4fNormal3fVertex3fvSUN");
  glTexCoord4fColor4fNormal3fVertex4fSUN = cast(pfglTexCoord4fColor4fNormal3fVertex4fSUN)getProc("glTexCoord4fColor4fNormal3fVertex4fSUN");
  glTexCoord4fColor4fNormal3fVertex4fvSUN = cast(pfglTexCoord4fColor4fNormal3fVertex4fvSUN)getProc("glTexCoord4fColor4fNormal3fVertex4fvSUN");
  glReplacementCodeuiVertex3fSUN = cast(pfglReplacementCodeuiVertex3fSUN)getProc("glReplacementCodeuiVertex3fSUN");
  glReplacementCodeuiVertex3fvSUN = cast(pfglReplacementCodeuiVertex3fvSUN)getProc("glReplacementCodeuiVertex3fvSUN");
  glReplacementCodeuiColor4ubVertex3fSUN = cast(pfglReplacementCodeuiColor4ubVertex3fSUN)getProc("glReplacementCodeuiColor4ubVertex3fSUN");
  glReplacementCodeuiColor4ubVertex3fvSUN = cast(pfglReplacementCodeuiColor4ubVertex3fvSUN)getProc("glReplacementCodeuiColor4ubVertex3fvSUN");
  glReplacementCodeuiColor3fVertex3fSUN = cast(pfglReplacementCodeuiColor3fVertex3fSUN)getProc("glReplacementCodeuiColor3fVertex3fSUN");
  glReplacementCodeuiColor3fVertex3fvSUN = cast(pfglReplacementCodeuiColor3fVertex3fvSUN)getProc("glReplacementCodeuiColor3fVertex3fvSUN");
  glReplacementCodeuiNormal3fVertex3fSUN = cast(pfglReplacementCodeuiNormal3fVertex3fSUN)getProc("glReplacementCodeuiNormal3fVertex3fSUN");
  glReplacementCodeuiNormal3fVertex3fvSUN = cast(pfglReplacementCodeuiNormal3fVertex3fvSUN)getProc("glReplacementCodeuiNormal3fVertex3fvSUN");
  glReplacementCodeuiColor4fNormal3fVertex3fSUN = cast(pfglReplacementCodeuiColor4fNormal3fVertex3fSUN)getProc("glReplacementCodeuiColor4fNormal3fVertex3fSUN");
  glReplacementCodeuiColor4fNormal3fVertex3fvSUN = cast(pfglReplacementCodeuiColor4fNormal3fVertex3fvSUN)getProc("glReplacementCodeuiColor4fNormal3fVertex3fvSUN");
  glReplacementCodeuiTexCoord2fVertex3fSUN = cast(pfglReplacementCodeuiTexCoord2fVertex3fSUN)getProc("glReplacementCodeuiTexCoord2fVertex3fSUN");
  glReplacementCodeuiTexCoord2fVertex3fvSUN = cast(pfglReplacementCodeuiTexCoord2fVertex3fvSUN)getProc("glReplacementCodeuiTexCoord2fVertex3fvSUN");
  glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN = cast(pfglReplacementCodeuiTexCoord2fNormal3fVertex3fSUN)getProc("glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN");
  glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN = cast(pfglReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN)getProc("glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN");
  glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN = cast(pfglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN)getProc("glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN");
  glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN = cast(pfglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN)getProc("glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN");

  glBlendFuncSeparateEXT = cast(pfglBlendFuncSeparateEXT)getProc("glBlendFuncSeparateEXT");

  glBlendFuncSeparateINGR = cast(pfglBlendFuncSeparateINGR)getProc("glBlendFuncSeparateINGR");

  glVertexWeightfEXT = cast(pfglVertexWeightfEXT)getProc("glVertexWeightfEXT");
  glVertexWeightfvEXT = cast(pfglVertexWeightfvEXT)getProc("glVertexWeightfvEXT");
  glVertexWeightPointerEXT = cast(pfglVertexWeightPointerEXT)getProc("glVertexWeightPointerEXT");

  glFlushVertexArrayRangeNV = cast(pfglFlushVertexArrayRangeNV)getProc("glFlushVertexArrayRangeNV");
  glVertexArrayRangeNV = cast(pfglVertexArrayRangeNV)getProc("glVertexArrayRangeNV");

  glCombinerParameterfvNV = cast(pfglCombinerParameterfvNV)getProc("glCombinerParameterfvNV");
  glCombinerParameterfNV = cast(pfglCombinerParameterfNV)getProc("glCombinerParameterfNV");
  glCombinerParameterivNV = cast(pfglCombinerParameterivNV)getProc("glCombinerParameterivNV");
  glCombinerParameteriNV = cast(pfglCombinerParameteriNV)getProc("glCombinerParameteriNV");
  glCombinerInputNV = cast(pfglCombinerInputNV)getProc("glCombinerInputNV");
  glCombinerOutputNV = cast(pfglCombinerOutputNV)getProc("glCombinerOutputNV");
  glFinalCombinerInputNV = cast(pfglFinalCombinerInputNV)getProc("glFinalCombinerInputNV");
  glGetCombinerInputParameterfvNV = cast(pfglGetCombinerInputParameterfvNV)getProc("glGetCombinerInputParameterfvNV");
  glGetCombinerInputParameterivNV = cast(pfglGetCombinerInputParameterivNV)getProc("glGetCombinerInputParameterivNV");
  glGetCombinerOutputParameterfvNV = cast(pfglGetCombinerOutputParameterfvNV)getProc("glGetCombinerOutputParameterfvNV");
  glGetCombinerOutputParameterivNV = cast(pfglGetCombinerOutputParameterivNV)getProc("glGetCombinerOutputParameterivNV");
  glGetFinalCombinerInputParameterfvNV = cast(pfglGetFinalCombinerInputParameterfvNV)getProc("glGetFinalCombinerInputParameterfvNV");
  glGetFinalCombinerInputParameterivNV = cast(pfglGetFinalCombinerInputParameterivNV)getProc("glGetFinalCombinerInputParameterivNV");

  glResizeBuffersMESA = cast(pfglResizeBuffersMESA)getProc("glResizeBuffersMESA");

  glWindowPos2dMESA = cast(pfglWindowPos2dMESA)getProc("glWindowPos2dMESA");
  glWindowPos2dvMESA = cast(pfglWindowPos2dvMESA)getProc("glWindowPos2dvMESA");
  glWindowPos2fMESA = cast(pfglWindowPos2fMESA)getProc("glWindowPos2fMESA");
  glWindowPos2fvMESA = cast(pfglWindowPos2fvMESA)getProc("glWindowPos2fvMESA");
  glWindowPos2iMESA = cast(pfglWindowPos2iMESA)getProc("glWindowPos2iMESA");
  glWindowPos2ivMESA = cast(pfglWindowPos2ivMESA)getProc("glWindowPos2ivMESA");
  glWindowPos2sMESA = cast(pfglWindowPos2sMESA)getProc("glWindowPos2sMESA");
  glWindowPos2svMESA = cast(pfglWindowPos2svMESA)getProc("glWindowPos2svMESA");
  glWindowPos3dMESA = cast(pfglWindowPos3dMESA)getProc("glWindowPos3dMESA");
  glWindowPos3dvMESA = cast(pfglWindowPos3dvMESA)getProc("glWindowPos3dvMESA");
  glWindowPos3fMESA = cast(pfglWindowPos3fMESA)getProc("glWindowPos3fMESA");
  glWindowPos3fvMESA = cast(pfglWindowPos3fvMESA)getProc("glWindowPos3fvMESA");
  glWindowPos3iMESA = cast(pfglWindowPos3iMESA)getProc("glWindowPos3iMESA");
  glWindowPos3ivMESA = cast(pfglWindowPos3ivMESA)getProc("glWindowPos3ivMESA");
  glWindowPos3sMESA = cast(pfglWindowPos3sMESA)getProc("glWindowPos3sMESA");
  glWindowPos3svMESA = cast(pfglWindowPos3svMESA)getProc("glWindowPos3svMESA");
  glWindowPos4dMESA = cast(pfglWindowPos4dMESA)getProc("glWindowPos4dMESA");
  glWindowPos4dvMESA = cast(pfglWindowPos4dvMESA)getProc("glWindowPos4dvMESA");
  glWindowPos4fMESA = cast(pfglWindowPos4fMESA)getProc("glWindowPos4fMESA");
  glWindowPos4fvMESA = cast(pfglWindowPos4fvMESA)getProc("glWindowPos4fvMESA");
  glWindowPos4iMESA = cast(pfglWindowPos4iMESA)getProc("glWindowPos4iMESA");
  glWindowPos4ivMESA = cast(pfglWindowPos4ivMESA)getProc("glWindowPos4ivMESA");
  glWindowPos4sMESA = cast(pfglWindowPos4sMESA)getProc("glWindowPos4sMESA");
  glWindowPos4svMESA = cast(pfglWindowPos4svMESA)getProc("glWindowPos4svMESA");

  glMultiModeDrawArraysIBM = cast(pfglMultiModeDrawArraysIBM)getProc("glMultiModeDrawArraysIBM");
  glMultiModeDrawElementsIBM = cast(pfglMultiModeDrawElementsIBM)getProc("glMultiModeDrawElementsIBM");

  glColorPointerListIBM = cast(pfglColorPointerListIBM)getProc("glColorPointerListIBM");
  glSecondaryColorPointerListIBM = cast(pfglSecondaryColorPointerListIBM)getProc("glSecondaryColorPointerListIBM");
  glEdgeFlagPointerListIBM = cast(pfglEdgeFlagPointerListIBM)getProc("glEdgeFlagPointerListIBM");
  glFogCoordPointerListIBM = cast(pfglFogCoordPointerListIBM)getProc("glFogCoordPointerListIBM");
  glIndexPointerListIBM = cast(pfglIndexPointerListIBM)getProc("glIndexPointerListIBM");
  glNormalPointerListIBM = cast(pfglNormalPointerListIBM)getProc("glNormalPointerListIBM");
  glTexCoordPointerListIBM = cast(pfglTexCoordPointerListIBM)getProc("glTexCoordPointerListIBM");
  glVertexPointerListIBM = cast(pfglVertexPointerListIBM)getProc("glVertexPointerListIBM");

  glTbufferMask3DFX = cast(pfglTbufferMask3DFX)getProc("glTbufferMask3DFX");

  glSampleMaskEXT = cast(pfglSampleMaskEXT)getProc("glSampleMaskEXT");
  glSamplePatternEXT = cast(pfglSamplePatternEXT)getProc("glSamplePatternEXT");

  glTextureColorMaskSGIS = cast(pfglTextureColorMaskSGIS)getProc("glTextureColorMaskSGIS");

  glIglooInterfaceSGIX = cast(pfglIglooInterfaceSGIX)getProc("glIglooInterfaceSGIX");

  glDeleteFencesNV = cast(pfglDeleteFencesNV)getProc("glDeleteFencesNV");
  glGenFencesNV = cast(pfglGenFencesNV)getProc("glGenFencesNV");
  glIsFenceNV = cast(pfglIsFenceNV)getProc("glIsFenceNV");
  glTestFenceNV = cast(pfglTestFenceNV)getProc("glTestFenceNV");
  glGetFenceivNV = cast(pfglGetFenceivNV)getProc("glGetFenceivNV");
  glFinishFenceNV = cast(pfglFinishFenceNV)getProc("glFinishFenceNV");
  glSetFenceNV = cast(pfglSetFenceNV)getProc("glSetFenceNV");

  glMapControlPointsNV = cast(pfglMapControlPointsNV)getProc("glMapControlPointsNV");
  glMapParameterivNV = cast(pfglMapParameterivNV)getProc("glMapParameterivNV");
  glMapParameterfvNV = cast(pfglMapParameterfvNV)getProc("glMapParameterfvNV");
  glGetMapControlPointsNV = cast(pfglGetMapControlPointsNV)getProc("glGetMapControlPointsNV");
  glGetMapParameterivNV = cast(pfglGetMapParameterivNV)getProc("glGetMapParameterivNV");
  glGetMapParameterfvNV = cast(pfglGetMapParameterfvNV)getProc("glGetMapParameterfvNV");
  glGetMapAttribParameterivNV = cast(pfglGetMapAttribParameterivNV)getProc("glGetMapAttribParameterivNV");
  glGetMapAttribParameterfvNV = cast(pfglGetMapAttribParameterfvNV)getProc("glGetMapAttribParameterfvNV");
  glEvalMapsNV = cast(pfglEvalMapsNV)getProc("glEvalMapsNV");

  glCombinerStageParameterfvNV = cast(pfglCombinerStageParameterfvNV)getProc("glCombinerStageParameterfvNV");
  glGetCombinerStageParameterfvNV = cast(pfglGetCombinerStageParameterfvNV)getProc("glGetCombinerStageParameterfvNV");

  glAreProgramsResidentNV = cast(pfglAreProgramsResidentNV)getProc("glAreProgramsResidentNV");
  glBindProgramNV = cast(pfglBindProgramNV)getProc("glBindProgramNV");
  glDeleteProgramsNV = cast(pfglDeleteProgramsNV)getProc("glDeleteProgramsNV");
  glExecuteProgramNV = cast(pfglExecuteProgramNV)getProc("glExecuteProgramNV");
  glGenProgramsNV = cast(pfglGenProgramsNV)getProc("glGenProgramsNV");
  glGetProgramParameterdvNV = cast(pfglGetProgramParameterdvNV)getProc("glGetProgramParameterdvNV");
  glGetProgramParameterfvNV = cast(pfglGetProgramParameterfvNV)getProc("glGetProgramParameterfvNV");
  glGetProgramivNV = cast(pfglGetProgramivNV)getProc("glGetProgramivNV");
  glGetProgramStringNV = cast(pfglGetProgramStringNV)getProc("glGetProgramStringNV");
  glGetTrackMatrixivNV = cast(pfglGetTrackMatrixivNV)getProc("glGetTrackMatrixivNV");
  glGetVertexAttribdvNV = cast(pfglGetVertexAttribdvNV)getProc("glGetVertexAttribdvNV");
  glGetVertexAttribfvNV = cast(pfglGetVertexAttribfvNV)getProc("glGetVertexAttribfvNV");
  glGetVertexAttribivNV = cast(pfglGetVertexAttribivNV)getProc("glGetVertexAttribivNV");
  glGetVertexAttribPointervNV = cast(pfglGetVertexAttribPointervNV)getProc("glGetVertexAttribPointervNV");
  glIsProgramNV = cast(pfglIsProgramNV)getProc("glIsProgramNV");
  glLoadProgramNV = cast(pfglLoadProgramNV)getProc("glLoadProgramNV");
  glProgramParameter4dNV = cast(pfglProgramParameter4dNV)getProc("glProgramParameter4dNV");
  glProgramParameter4dvNV = cast(pfglProgramParameter4dvNV)getProc("glProgramParameter4dvNV");
  glProgramParameter4fNV = cast(pfglProgramParameter4fNV)getProc("glProgramParameter4fNV");
  glProgramParameter4fvNV = cast(pfglProgramParameter4fvNV)getProc("glProgramParameter4fvNV");
  glProgramParameters4dvNV = cast(pfglProgramParameters4dvNV)getProc("glProgramParameters4dvNV");
  glProgramParameters4fvNV = cast(pfglProgramParameters4fvNV)getProc("glProgramParameters4fvNV");
  glRequestResidentProgramsNV = cast(pfglRequestResidentProgramsNV)getProc("glRequestResidentProgramsNV");
  glTrackMatrixNV = cast(pfglTrackMatrixNV)getProc("glTrackMatrixNV");
  glVertexAttribPointerNV = cast(pfglVertexAttribPointerNV)getProc("glVertexAttribPointerNV");
  glVertexAttrib1dNV = cast(pfglVertexAttrib1dNV)getProc("glVertexAttrib1dNV");
  glVertexAttrib1dvNV = cast(pfglVertexAttrib1dvNV)getProc("glVertexAttrib1dvNV");
  glVertexAttrib1fNV = cast(pfglVertexAttrib1fNV)getProc("glVertexAttrib1fNV");
  glVertexAttrib1fvNV = cast(pfglVertexAttrib1fvNV)getProc("glVertexAttrib1fvNV");
  glVertexAttrib1sNV = cast(pfglVertexAttrib1sNV)getProc("glVertexAttrib1sNV");
  glVertexAttrib1svNV = cast(pfglVertexAttrib1svNV)getProc("glVertexAttrib1svNV");
  glVertexAttrib2dNV = cast(pfglVertexAttrib2dNV)getProc("glVertexAttrib2dNV");
  glVertexAttrib2dvNV = cast(pfglVertexAttrib2dvNV)getProc("glVertexAttrib2dvNV");
  glVertexAttrib2fNV = cast(pfglVertexAttrib2fNV)getProc("glVertexAttrib2fNV");
  glVertexAttrib2fvNV = cast(pfglVertexAttrib2fvNV)getProc("glVertexAttrib2fvNV");
  glVertexAttrib2sNV = cast(pfglVertexAttrib2sNV)getProc("glVertexAttrib2sNV");
  glVertexAttrib2svNV = cast(pfglVertexAttrib2svNV)getProc("glVertexAttrib2svNV");
  glVertexAttrib3dNV = cast(pfglVertexAttrib3dNV)getProc("glVertexAttrib3dNV");
  glVertexAttrib3dvNV = cast(pfglVertexAttrib3dvNV)getProc("glVertexAttrib3dvNV");
  glVertexAttrib3fNV = cast(pfglVertexAttrib3fNV)getProc("glVertexAttrib3fNV");
  glVertexAttrib3fvNV = cast(pfglVertexAttrib3fvNV)getProc("glVertexAttrib3fvNV");
  glVertexAttrib3sNV = cast(pfglVertexAttrib3sNV)getProc("glVertexAttrib3sNV");
  glVertexAttrib3svNV = cast(pfglVertexAttrib3svNV)getProc("glVertexAttrib3svNV");
  glVertexAttrib4dNV = cast(pfglVertexAttrib4dNV)getProc("glVertexAttrib4dNV");
  glVertexAttrib4dvNV = cast(pfglVertexAttrib4dvNV)getProc("glVertexAttrib4dvNV");
  glVertexAttrib4fNV = cast(pfglVertexAttrib4fNV)getProc("glVertexAttrib4fNV");
  glVertexAttrib4fvNV = cast(pfglVertexAttrib4fvNV)getProc("glVertexAttrib4fvNV");
  glVertexAttrib4sNV = cast(pfglVertexAttrib4sNV)getProc("glVertexAttrib4sNV");
  glVertexAttrib4svNV = cast(pfglVertexAttrib4svNV)getProc("glVertexAttrib4svNV");
  glVertexAttrib4ubNV = cast(pfglVertexAttrib4ubNV)getProc("glVertexAttrib4ubNV");
  glVertexAttrib4ubvNV = cast(pfglVertexAttrib4ubvNV)getProc("glVertexAttrib4ubvNV");
  glVertexAttribs1dvNV = cast(pfglVertexAttribs1dvNV)getProc("glVertexAttribs1dvNV");
  glVertexAttribs1fvNV = cast(pfglVertexAttribs1fvNV)getProc("glVertexAttribs1fvNV");
  glVertexAttribs1svNV = cast(pfglVertexAttribs1svNV)getProc("glVertexAttribs1svNV");
  glVertexAttribs2dvNV = cast(pfglVertexAttribs2dvNV)getProc("glVertexAttribs2dvNV");
  glVertexAttribs2fvNV = cast(pfglVertexAttribs2fvNV)getProc("glVertexAttribs2fvNV");
  glVertexAttribs2svNV = cast(pfglVertexAttribs2svNV)getProc("glVertexAttribs2svNV");
  glVertexAttribs3dvNV = cast(pfglVertexAttribs3dvNV)getProc("glVertexAttribs3dvNV");
  glVertexAttribs3fvNV = cast(pfglVertexAttribs3fvNV)getProc("glVertexAttribs3fvNV");
  glVertexAttribs3svNV = cast(pfglVertexAttribs3svNV)getProc("glVertexAttribs3svNV");
  glVertexAttribs4dvNV = cast(pfglVertexAttribs4dvNV)getProc("glVertexAttribs4dvNV");
  glVertexAttribs4fvNV = cast(pfglVertexAttribs4fvNV)getProc("glVertexAttribs4fvNV");
  glVertexAttribs4svNV = cast(pfglVertexAttribs4svNV)getProc("glVertexAttribs4svNV");
  glVertexAttribs4ubvNV = cast(pfglVertexAttribs4ubvNV)getProc("glVertexAttribs4ubvNV");

  glTexBumpParameterivATI = cast(pfglTexBumpParameterivATI)getProc("glTexBumpParameterivATI");
  glTexBumpParameterfvATI = cast(pfglTexBumpParameterfvATI)getProc("glTexBumpParameterfvATI");
  glGetTexBumpParameterivATI = cast(pfglGetTexBumpParameterivATI)getProc("glGetTexBumpParameterivATI");
  glGetTexBumpParameterfvATI = cast(pfglGetTexBumpParameterfvATI)getProc("glGetTexBumpParameterfvATI");

  glGenFragmentShadersATI = cast(pfglGenFragmentShadersATI)getProc("glGenFragmentShadersATI");
  glBindFragmentShaderATI = cast(pfglBindFragmentShaderATI)getProc("glBindFragmentShaderATI");
  glDeleteFragmentShaderATI = cast(pfglDeleteFragmentShaderATI)getProc("glDeleteFragmentShaderATI");
  glBeginFragmentShaderATI = cast(pfglBeginFragmentShaderATI)getProc("glBeginFragmentShaderATI");
  glEndFragmentShaderATI = cast(pfglEndFragmentShaderATI)getProc("glEndFragmentShaderATI");
  glPassTexCoordATI = cast(pfglPassTexCoordATI)getProc("glPassTexCoordATI");
  glSampleMapATI = cast(pfglSampleMapATI)getProc("glSampleMapATI");
  glColorFragmentOp1ATI = cast(pfglColorFragmentOp1ATI)getProc("glColorFragmentOp1ATI");
  glColorFragmentOp2ATI = cast(pfglColorFragmentOp2ATI)getProc("glColorFragmentOp2ATI");
  glColorFragmentOp3ATI = cast(pfglColorFragmentOp3ATI)getProc("glColorFragmentOp3ATI");
  glAlphaFragmentOp1ATI = cast(pfglAlphaFragmentOp1ATI)getProc("glAlphaFragmentOp1ATI");
  glAlphaFragmentOp2ATI = cast(pfglAlphaFragmentOp2ATI)getProc("glAlphaFragmentOp2ATI");
  glAlphaFragmentOp3ATI = cast(pfglAlphaFragmentOp3ATI)getProc("glAlphaFragmentOp3ATI");
  glSetFragmentShaderConstantATI = cast(pfglSetFragmentShaderConstantATI)getProc("glSetFragmentShaderConstantATI");

  glPNTrianglesiATI = cast(pfglPNTrianglesiATI)getProc("glPNTrianglesiATI");
  glPNTrianglesfATI = cast(pfglPNTrianglesfATI)getProc("glPNTrianglesfATI");

  glNewObjectBufferATI = cast(pfglNewObjectBufferATI)getProc("glNewObjectBufferATI");
  glIsObjectBufferATI = cast(pfglIsObjectBufferATI)getProc("glIsObjectBufferATI");
  glUpdateObjectBufferATI = cast(pfglUpdateObjectBufferATI)getProc("glUpdateObjectBufferATI");
  glGetObjectBufferfvATI = cast(pfglGetObjectBufferfvATI)getProc("glGetObjectBufferfvATI");
  glGetObjectBufferivATI = cast(pfglGetObjectBufferivATI)getProc("glGetObjectBufferivATI");
  glFreeObjectBufferATI = cast(pfglFreeObjectBufferATI)getProc("glFreeObjectBufferATI");
  glArrayObjectATI = cast(pfglArrayObjectATI)getProc("glArrayObjectATI");
  glGetArrayObjectfvATI = cast(pfglGetArrayObjectfvATI)getProc("glGetArrayObjectfvATI");
  glGetArrayObjectivATI = cast(pfglGetArrayObjectivATI)getProc("glGetArrayObjectivATI");
  glVariantArrayObjectATI = cast(pfglVariantArrayObjectATI)getProc("glVariantArrayObjectATI");
  glGetVariantArrayObjectfvATI = cast(pfglGetVariantArrayObjectfvATI)getProc("glGetVariantArrayObjectfvATI");
  glGetVariantArrayObjectivATI = cast(pfglGetVariantArrayObjectivATI)getProc("glGetVariantArrayObjectivATI");

  glBeginVertexShaderEXT = cast(pfglBeginVertexShaderEXT)getProc("glBeginVertexShaderEXT");
  glEndVertexShaderEXT = cast(pfglEndVertexShaderEXT)getProc("glEndVertexShaderEXT");
  glBindVertexShaderEXT = cast(pfglBindVertexShaderEXT)getProc("glBindVertexShaderEXT");
  glGenVertexShadersEXT = cast(pfglGenVertexShadersEXT)getProc("glGenVertexShadersEXT");
  glDeleteVertexShaderEXT = cast(pfglDeleteVertexShaderEXT)getProc("glDeleteVertexShaderEXT");
  glShaderOp1EXT = cast(pfglShaderOp1EXT)getProc("glShaderOp1EXT");
  glShaderOp2EXT = cast(pfglShaderOp2EXT)getProc("glShaderOp2EXT");
  glShaderOp3EXT = cast(pfglShaderOp3EXT)getProc("glShaderOp3EXT");
  glSwizzleEXT = cast(pfglSwizzleEXT)getProc("glSwizzleEXT");
  glWriteMaskEXT = cast(pfglWriteMaskEXT)getProc("glWriteMaskEXT");
  glInsertComponentEXT = cast(pfglInsertComponentEXT)getProc("glInsertComponentEXT");
  glExtractComponentEXT = cast(pfglExtractComponentEXT)getProc("glExtractComponentEXT");
  glGenSymbolsEXT = cast(pfglGenSymbolsEXT)getProc("glGenSymbolsEXT");
  glSetInvariantEXT = cast(pfglSetInvariantEXT)getProc("glSetInvariantEXT");
  glSetLocalConstantEXT = cast(pfglSetLocalConstantEXT)getProc("glSetLocalConstantEXT");
  glVariantbvEXT = cast(pfglVariantbvEXT)getProc("glVariantbvEXT");
  glVariantsvEXT = cast(pfglVariantsvEXT)getProc("glVariantsvEXT");
  glVariantivEXT = cast(pfglVariantivEXT)getProc("glVariantivEXT");
  glVariantfvEXT = cast(pfglVariantfvEXT)getProc("glVariantfvEXT");
  glVariantdvEXT = cast(pfglVariantdvEXT)getProc("glVariantdvEXT");
  glVariantubvEXT = cast(pfglVariantubvEXT)getProc("glVariantubvEXT");
  glVariantusvEXT = cast(pfglVariantusvEXT)getProc("glVariantusvEXT");
  glVariantuivEXT = cast(pfglVariantuivEXT)getProc("glVariantuivEXT");
  glVariantPointerEXT = cast(pfglVariantPointerEXT)getProc("glVariantPointerEXT");
  glEnableVariantClientStateEXT = cast(pfglEnableVariantClientStateEXT)getProc("glEnableVariantClientStateEXT");
  glDisableVariantClientStateEXT = cast(pfglDisableVariantClientStateEXT)getProc("glDisableVariantClientStateEXT");
  glBindLightParameterEXT = cast(pfglBindLightParameterEXT)getProc("glBindLightParameterEXT");
  glBindMaterialParameterEXT = cast(pfglBindMaterialParameterEXT)getProc("glBindMaterialParameterEXT");
  glBindTexGenParameterEXT = cast(pfglBindTexGenParameterEXT)getProc("glBindTexGenParameterEXT");
  glBindTextureUnitParameterEXT = cast(pfglBindTextureUnitParameterEXT)getProc("glBindTextureUnitParameterEXT");
  glBindParameterEXT = cast(pfglBindParameterEXT)getProc("glBindParameterEXT");
  glIsVariantEnabledEXT = cast(pfglIsVariantEnabledEXT)getProc("glIsVariantEnabledEXT");
  glGetVariantBooleanvEXT = cast(pfglGetVariantBooleanvEXT)getProc("glGetVariantBooleanvEXT");
  glGetVariantIntegervEXT = cast(pfglGetVariantIntegervEXT)getProc("glGetVariantIntegervEXT");
  glGetVariantFloatvEXT = cast(pfglGetVariantFloatvEXT)getProc("glGetVariantFloatvEXT");
  glGetVariantPointervEXT = cast(pfglGetVariantPointervEXT)getProc("glGetVariantPointervEXT");
  glGetInvariantBooleanvEXT = cast(pfglGetInvariantBooleanvEXT)getProc("glGetInvariantBooleanvEXT");
  glGetInvariantIntegervEXT = cast(pfglGetInvariantIntegervEXT)getProc("glGetInvariantIntegervEXT");
  glGetInvariantFloatvEXT = cast(pfglGetInvariantFloatvEXT)getProc("glGetInvariantFloatvEXT");
  glGetLocalConstantBooleanvEXT = cast(pfglGetLocalConstantBooleanvEXT)getProc("glGetLocalConstantBooleanvEXT");
  glGetLocalConstantIntegervEXT = cast(pfglGetLocalConstantIntegervEXT)getProc("glGetLocalConstantIntegervEXT");
  glGetLocalConstantFloatvEXT = cast(pfglGetLocalConstantFloatvEXT)getProc("glGetLocalConstantFloatvEXT");

  glVertexStream1sATI = cast(pfglVertexStream1sATI)getProc("glVertexStream1sATI");
  glVertexStream1svATI = cast(pfglVertexStream1svATI)getProc("glVertexStream1svATI");
  glVertexStream1iATI = cast(pfglVertexStream1iATI)getProc("glVertexStream1iATI");
  glVertexStream1ivATI = cast(pfglVertexStream1ivATI)getProc("glVertexStream1ivATI");
  glVertexStream1fATI = cast(pfglVertexStream1fATI)getProc("glVertexStream1fATI");
  glVertexStream1fvATI = cast(pfglVertexStream1fvATI)getProc("glVertexStream1fvATI");
  glVertexStream1dATI = cast(pfglVertexStream1dATI)getProc("glVertexStream1dATI");
  glVertexStream1dvATI = cast(pfglVertexStream1dvATI)getProc("glVertexStream1dvATI");
  glVertexStream2sATI = cast(pfglVertexStream2sATI)getProc("glVertexStream2sATI");
  glVertexStream2svATI = cast(pfglVertexStream2svATI)getProc("glVertexStream2svATI");
  glVertexStream2iATI = cast(pfglVertexStream2iATI)getProc("glVertexStream2iATI");
  glVertexStream2ivATI = cast(pfglVertexStream2ivATI)getProc("glVertexStream2ivATI");
  glVertexStream2fATI = cast(pfglVertexStream2fATI)getProc("glVertexStream2fATI");
  glVertexStream2fvATI = cast(pfglVertexStream2fvATI)getProc("glVertexStream2fvATI");
  glVertexStream2dATI = cast(pfglVertexStream2dATI)getProc("glVertexStream2dATI");
  glVertexStream2dvATI = cast(pfglVertexStream2dvATI)getProc("glVertexStream2dvATI");
  glVertexStream3sATI = cast(pfglVertexStream3sATI)getProc("glVertexStream3sATI");
  glVertexStream3svATI = cast(pfglVertexStream3svATI)getProc("glVertexStream3svATI");
  glVertexStream3iATI = cast(pfglVertexStream3iATI)getProc("glVertexStream3iATI");
  glVertexStream3ivATI = cast(pfglVertexStream3ivATI)getProc("glVertexStream3ivATI");
  glVertexStream3fATI = cast(pfglVertexStream3fATI)getProc("glVertexStream3fATI");
  glVertexStream3fvATI = cast(pfglVertexStream3fvATI)getProc("glVertexStream3fvATI");
  glVertexStream3dATI = cast(pfglVertexStream3dATI)getProc("glVertexStream3dATI");
  glVertexStream3dvATI = cast(pfglVertexStream3dvATI)getProc("glVertexStream3dvATI");
  glVertexStream4sATI = cast(pfglVertexStream4sATI)getProc("glVertexStream4sATI");
  glVertexStream4svATI = cast(pfglVertexStream4svATI)getProc("glVertexStream4svATI");
  glVertexStream4iATI = cast(pfglVertexStream4iATI)getProc("glVertexStream4iATI");
  glVertexStream4ivATI = cast(pfglVertexStream4ivATI)getProc("glVertexStream4ivATI");
  glVertexStream4fATI = cast(pfglVertexStream4fATI)getProc("glVertexStream4fATI");
  glVertexStream4fvATI = cast(pfglVertexStream4fvATI)getProc("glVertexStream4fvATI");
  glVertexStream4dATI = cast(pfglVertexStream4dATI)getProc("glVertexStream4dATI");
  glVertexStream4dvATI = cast(pfglVertexStream4dvATI)getProc("glVertexStream4dvATI");
  glNormalStream3bATI = cast(pfglNormalStream3bATI)getProc("glNormalStream3bATI");
  glNormalStream3bvATI = cast(pfglNormalStream3bvATI)getProc("glNormalStream3bvATI");
  glNormalStream3sATI = cast(pfglNormalStream3sATI)getProc("glNormalStream3sATI");
  glNormalStream3svATI = cast(pfglNormalStream3svATI)getProc("glNormalStream3svATI");
  glNormalStream3iATI = cast(pfglNormalStream3iATI)getProc("glNormalStream3iATI");
  glNormalStream3ivATI = cast(pfglNormalStream3ivATI)getProc("glNormalStream3ivATI");
  glNormalStream3fATI = cast(pfglNormalStream3fATI)getProc("glNormalStream3fATI");
  glNormalStream3fvATI = cast(pfglNormalStream3fvATI)getProc("glNormalStream3fvATI");
  glNormalStream3dATI = cast(pfglNormalStream3dATI)getProc("glNormalStream3dATI");
  glNormalStream3dvATI = cast(pfglNormalStream3dvATI)getProc("glNormalStream3dvATI");
  glClientActiveVertexStreamATI = cast(pfglClientActiveVertexStreamATI)getProc("glClientActiveVertexStreamATI");
  glVertexBlendEnviATI = cast(pfglVertexBlendEnviATI)getProc("glVertexBlendEnviATI");
  glVertexBlendEnvfATI = cast(pfglVertexBlendEnvfATI)getProc("glVertexBlendEnvfATI");

  glElementPointerATI = cast(pfglElementPointerATI)getProc("glElementPointerATI");
  glDrawElementArrayATI = cast(pfglDrawElementArrayATI)getProc("glDrawElementArrayATI");
  glDrawRangeElementArrayATI = cast(pfglDrawRangeElementArrayATI)getProc("glDrawRangeElementArrayATI");

  glDrawMeshArraysSUN = cast(pfglDrawMeshArraysSUN)getProc("glDrawMeshArraysSUN");

  glGenOcclusionQueriesNV = cast(pfglGenOcclusionQueriesNV)getProc("glGenOcclusionQueriesNV");
  glDeleteOcclusionQueriesNV = cast(pfglDeleteOcclusionQueriesNV)getProc("glDeleteOcclusionQueriesNV");
  glIsOcclusionQueryNV = cast(pfglIsOcclusionQueryNV)getProc("glIsOcclusionQueryNV");
  glBeginOcclusionQueryNV = cast(pfglBeginOcclusionQueryNV)getProc("glBeginOcclusionQueryNV");
  glEndOcclusionQueryNV = cast(pfglEndOcclusionQueryNV)getProc("glEndOcclusionQueryNV");
  glGetOcclusionQueryivNV = cast(pfglGetOcclusionQueryivNV)getProc("glGetOcclusionQueryivNV");
  glGetOcclusionQueryuivNV = cast(pfglGetOcclusionQueryuivNV)getProc("glGetOcclusionQueryuivNV");

  glPointParameteriNV = cast(pfglPointParameteriNV)getProc("glPointParameteriNV");
  glPointParameterivNV = cast(pfglPointParameterivNV)getProc("glPointParameterivNV");

  glActiveStencilFaceEXT = cast(pfglActiveStencilFaceEXT)getProc("glActiveStencilFaceEXT");

  glElementPointerAPPLE = cast(pfglElementPointerAPPLE)getProc("glElementPointerAPPLE");
  glDrawElementArrayAPPLE = cast(pfglDrawElementArrayAPPLE)getProc("glDrawElementArrayAPPLE");
  glDrawRangeElementArrayAPPLE = cast(pfglDrawRangeElementArrayAPPLE)getProc("glDrawRangeElementArrayAPPLE");
  glMultiDrawElementArrayAPPLE = cast(pfglMultiDrawElementArrayAPPLE)getProc("glMultiDrawElementArrayAPPLE");
  glMultiDrawRangeElementArrayAPPLE = cast(pfglMultiDrawRangeElementArrayAPPLE)getProc("glMultiDrawRangeElementArrayAPPLE");

  glGenFencesAPPLE = cast(pfglGenFencesAPPLE)getProc("glGenFencesAPPLE");
  glDeleteFencesAPPLE = cast(pfglDeleteFencesAPPLE)getProc("glDeleteFencesAPPLE");
  glSetFenceAPPLE = cast(pfglSetFenceAPPLE)getProc("glSetFenceAPPLE");
  glIsFenceAPPLE = cast(pfglIsFenceAPPLE)getProc("glIsFenceAPPLE");
  glTestFenceAPPLE = cast(pfglTestFenceAPPLE)getProc("glTestFenceAPPLE");
  glFinishFenceAPPLE = cast(pfglFinishFenceAPPLE)getProc("glFinishFenceAPPLE");
  glTestObjectAPPLE = cast(pfglTestObjectAPPLE)getProc("glTestObjectAPPLE");
  glFinishObjectAPPLE = cast(pfglFinishObjectAPPLE)getProc("glFinishObjectAPPLE");

  glBindVertexArrayAPPLE = cast(pfglBindVertexArrayAPPLE)getProc("glBindVertexArrayAPPLE");
  glDeleteVertexArraysAPPLE = cast(pfglDeleteVertexArraysAPPLE)getProc("glDeleteVertexArraysAPPLE");
  glGenVertexArraysAPPLE = cast(pfglGenVertexArraysAPPLE)getProc("glGenVertexArraysAPPLE");
  glIsVertexArrayAPPLE = cast(pfglIsVertexArrayAPPLE)getProc("glIsVertexArrayAPPLE");

  glVertexArrayRangeAPPLE = cast(pfglVertexArrayRangeAPPLE)getProc("glVertexArrayRangeAPPLE");
  glFlushVertexArrayRangeAPPLE = cast(pfglFlushVertexArrayRangeAPPLE)getProc("glFlushVertexArrayRangeAPPLE");
  glVertexArrayParameteriAPPLE = cast(pfglVertexArrayParameteriAPPLE)getProc("glVertexArrayParameteriAPPLE");

  glDrawBuffersATI = cast(pfglDrawBuffersATI)getProc("glDrawBuffersATI");

  glProgramNamedParameter4fNV = cast(pfglProgramNamedParameter4fNV)getProc("glProgramNamedParameter4fNV");
  glProgramNamedParameter4dNV = cast(pfglProgramNamedParameter4dNV)getProc("glProgramNamedParameter4dNV");
  glProgramNamedParameter4fvNV = cast(pfglProgramNamedParameter4fvNV)getProc("glProgramNamedParameter4fvNV");
  glProgramNamedParameter4dvNV = cast(pfglProgramNamedParameter4dvNV)getProc("glProgramNamedParameter4dvNV");
  glGetProgramNamedParameterfvNV = cast(pfglGetProgramNamedParameterfvNV)getProc("glGetProgramNamedParameterfvNV");
  glGetProgramNamedParameterdvNV = cast(pfglGetProgramNamedParameterdvNV)getProc("glGetProgramNamedParameterdvNV");

  glVertex2hNV = cast(pfglVertex2hNV)getProc("glVertex2hNV");
  glVertex2hvNV = cast(pfglVertex2hvNV)getProc("glVertex2hvNV");
  glVertex3hNV = cast(pfglVertex3hNV)getProc("glVertex3hNV");
  glVertex3hvNV = cast(pfglVertex3hvNV)getProc("glVertex3hvNV");
  glVertex4hNV = cast(pfglVertex4hNV)getProc("glVertex4hNV");
  glVertex4hvNV = cast(pfglVertex4hvNV)getProc("glVertex4hvNV");
  glNormal3hNV = cast(pfglNormal3hNV)getProc("glNormal3hNV");
  glNormal3hvNV = cast(pfglNormal3hvNV)getProc("glNormal3hvNV");
  glColor3hNV = cast(pfglColor3hNV)getProc("glColor3hNV");
  glColor3hvNV = cast(pfglColor3hvNV)getProc("glColor3hvNV");
  glColor4hNV = cast(pfglColor4hNV)getProc("glColor4hNV");
  glColor4hvNV = cast(pfglColor4hvNV)getProc("glColor4hvNV");
  glTexCoord1hNV = cast(pfglTexCoord1hNV)getProc("glTexCoord1hNV");
  glTexCoord1hvNV = cast(pfglTexCoord1hvNV)getProc("glTexCoord1hvNV");
  glTexCoord2hNV = cast(pfglTexCoord2hNV)getProc("glTexCoord2hNV");
  glTexCoord2hvNV = cast(pfglTexCoord2hvNV)getProc("glTexCoord2hvNV");
  glTexCoord3hNV = cast(pfglTexCoord3hNV)getProc("glTexCoord3hNV");
  glTexCoord3hvNV = cast(pfglTexCoord3hvNV)getProc("glTexCoord3hvNV");
  glTexCoord4hNV = cast(pfglTexCoord4hNV)getProc("glTexCoord4hNV");
  glTexCoord4hvNV = cast(pfglTexCoord4hvNV)getProc("glTexCoord4hvNV");
  glMultiTexCoord1hNV = cast(pfglMultiTexCoord1hNV)getProc("glMultiTexCoord1hNV");
  glMultiTexCoord1hvNV = cast(pfglMultiTexCoord1hvNV)getProc("glMultiTexCoord1hvNV");
  glMultiTexCoord2hNV = cast(pfglMultiTexCoord2hNV)getProc("glMultiTexCoord2hNV");
  glMultiTexCoord2hvNV = cast(pfglMultiTexCoord2hvNV)getProc("glMultiTexCoord2hvNV");
  glMultiTexCoord3hNV = cast(pfglMultiTexCoord3hNV)getProc("glMultiTexCoord3hNV");
  glMultiTexCoord3hvNV = cast(pfglMultiTexCoord3hvNV)getProc("glMultiTexCoord3hvNV");
  glMultiTexCoord4hNV = cast(pfglMultiTexCoord4hNV)getProc("glMultiTexCoord4hNV");
  glMultiTexCoord4hvNV = cast(pfglMultiTexCoord4hvNV)getProc("glMultiTexCoord4hvNV");
  glFogCoordhNV = cast(pfglFogCoordhNV)getProc("glFogCoordhNV");
  glFogCoordhvNV = cast(pfglFogCoordhvNV)getProc("glFogCoordhvNV");
  glSecondaryColor3hNV = cast(pfglSecondaryColor3hNV)getProc("glSecondaryColor3hNV");
  glSecondaryColor3hvNV = cast(pfglSecondaryColor3hvNV)getProc("glSecondaryColor3hvNV");
  glVertexWeighthNV = cast(pfglVertexWeighthNV)getProc("glVertexWeighthNV");
  glVertexWeighthvNV = cast(pfglVertexWeighthvNV)getProc("glVertexWeighthvNV");
  glVertexAttrib2hNV = cast(pfglVertexAttrib2hNV)getProc("glVertexAttrib2hNV");
  glVertexAttrib2hvNV = cast(pfglVertexAttrib2hvNV)getProc("glVertexAttrib2hvNV");
  glVertexAttrib1hNV = cast(pfglVertexAttrib1hNV)getProc("glVertexAttrib1hNV");
  glVertexAttrib1hvNV = cast(pfglVertexAttrib1hvNV)getProc("glVertexAttrib1hvNV");
  glVertexAttrib3hNV = cast(pfglVertexAttrib3hNV)getProc("glVertexAttrib3hNV");
  glVertexAttrib3hvNV = cast(pfglVertexAttrib3hvNV)getProc("glVertexAttrib3hvNV");
  glVertexAttrib4hNV = cast(pfglVertexAttrib4hNV)getProc("glVertexAttrib4hNV");
  glVertexAttrib4hvNV = cast(pfglVertexAttrib4hvNV)getProc("glVertexAttrib4hvNV");
  glVertexAttribs1hvNV = cast(pfglVertexAttribs1hvNV)getProc("glVertexAttribs1hvNV");
  glVertexAttribs2hvNV = cast(pfglVertexAttribs2hvNV)getProc("glVertexAttribs2hvNV");
  glVertexAttribs3hvNV = cast(pfglVertexAttribs3hvNV)getProc("glVertexAttribs3hvNV");
  glVertexAttribs4hvNV = cast(pfglVertexAttribs4hvNV)getProc("glVertexAttribs4hvNV");

  glPixelDataRangeNV = cast(pfglPixelDataRangeNV)getProc("glPixelDataRangeNV");
  glFlushPixelDataRangeNV = cast(pfglFlushPixelDataRangeNV)getProc("glFlushPixelDataRangeNV");

  glPrimitiveRestartNV = cast(pfglPrimitiveRestartNV)getProc("glPrimitiveRestartNV");
  glPrimitiveRestartIndexNV = cast(pfglPrimitiveRestartIndexNV)getProc("glPrimitiveRestartIndexNV");

  glMapObjectBufferATI = cast(pfglMapObjectBufferATI)getProc("glMapObjectBufferATI");
  glUnmapObjectBufferATI = cast(pfglUnmapObjectBufferATI)getProc("glUnmapObjectBufferATI");

  glStencilOpSeparateATI = cast(pfglStencilOpSeparateATI)getProc("glStencilOpSeparateATI");
  glStencilFuncSeparateATI = cast(pfglStencilFuncSeparateATI)getProc("glStencilFuncSeparateATI");

  glVertexAttribArrayObjectATI = cast(pfglVertexAttribArrayObjectATI)getProc("glVertexAttribArrayObjectATI");
  glGetVertexAttribArrayObjectfvATI = cast(pfglGetVertexAttribArrayObjectfvATI)getProc("glGetVertexAttribArrayObjectfvATI");
  glGetVertexAttribArrayObjectivATI = cast(pfglGetVertexAttribArrayObjectivATI)getProc("glGetVertexAttribArrayObjectivATI");

  glDepthBoundsEXT = cast(pfglDepthBoundsEXT)getProc("glDepthBoundsEXT");

  glBlendEquationSeparateEXT = cast(pfglBlendEquationSeparateEXT)getProc("glBlendEquationSeparateEXT");

  glIsRenderbufferEXT = cast(pfglIsRenderbufferEXT)getProc("glIsRenderbufferEXT");
  glBindRenderbufferEXT = cast(pfglBindRenderbufferEXT)getProc("glBindRenderbufferEXT");
  glDeleteRenderbuffersEXT = cast(pfglDeleteRenderbuffersEXT)getProc("glDeleteRenderbuffersEXT");
  glGenRenderbuffersEXT = cast(pfglGenRenderbuffersEXT)getProc("glGenRenderbuffersEXT");
  glRenderbufferStorageEXT = cast(pfglRenderbufferStorageEXT)getProc("glRenderbufferStorageEXT");
  glGetRenderbufferParameterivEXT = cast(pfglGetRenderbufferParameterivEXT)getProc("glGetRenderbufferParameterivEXT");
  glIsFramebufferEXT = cast(pfglIsFramebufferEXT)getProc("glIsFramebufferEXT");
  glBindFramebufferEXT = cast(pfglBindFramebufferEXT)getProc("glBindFramebufferEXT");
  glDeleteFramebuffersEXT = cast(pfglDeleteFramebuffersEXT)getProc("glDeleteFramebuffersEXT");
  glGenFramebuffersEXT = cast(pfglGenFramebuffersEXT)getProc("glGenFramebuffersEXT");
  glCheckFramebufferStatusEXT = cast(pfglCheckFramebufferStatusEXT)getProc("glCheckFramebufferStatusEXT");
  glFramebufferTexture1DEXT = cast(pfglFramebufferTexture1DEXT)getProc("glFramebufferTexture1DEXT");
  glFramebufferTexture2DEXT = cast(pfglFramebufferTexture2DEXT)getProc("glFramebufferTexture2DEXT");
  glFramebufferTexture3DEXT = cast(pfglFramebufferTexture3DEXT)getProc("glFramebufferTexture3DEXT");
  glFramebufferRenderbufferEXT = cast(pfglFramebufferRenderbufferEXT)getProc("glFramebufferRenderbufferEXT");
  glGetFramebufferAttachmentParameterivEXT = cast(pfglGetFramebufferAttachmentParameterivEXT)getProc("glGetFramebufferAttachmentParameterivEXT");
  glGenerateMipmapEXT = cast(pfglGenerateMipmapEXT)getProc("glGenerateMipmapEXT");

  glStringMarkerGREMEDY = cast(pfglStringMarkerGREMEDY)getProc("glStringMarkerGREMEDY");

  glStencilClearTagEXT = cast(pfglStencilClearTagEXT)getProc("glStencilClearTagEXT");

  glBlitFramebufferEXT = cast(pfglBlitFramebufferEXT)getProc("glBlitFramebufferEXT");

  glRenderbufferStorageMultisampleEXT = cast(pfglRenderbufferStorageMultisampleEXT)getProc("glRenderbufferStorageMultisampleEXT");



  glGetQueryObjecti64vEXT = cast(pfglGetQueryObjecti64vEXT)getProc("glGetQueryObjecti64vEXT");
  glGetQueryObjectui64vEXT = cast(pfglGetQueryObjectui64vEXT)getProc("GetQueryObjectui64vEXT");

  glProgramEnvParameters4fvEXT = cast(pfglProgramEnvParameters4fvEXT)getProc("glProgramEnvParameters4fvEXT");
  glProgramLocalParameters4fvEXT = cast(pfglProgramLocalParameters4fvEXT)getProc("glProgramLocalParameters4fvEXT");

  glBufferParameteriAPPLE = cast(pfglBufferParameteriAPPLE)getProc("glBufferParameteriAPPLE");
  glFlushMappedBufferRangeAPPLE = cast(pfglFlushMappedBufferRangeAPPLE)getProc("glFlushMappedBufferRangeAPPLE");
}

static ~this () {
  ExeModule_Release(glextdrv);
}

version (Windows) {
  extern (Windows):
} else {
  extern (C):
}
/*
 * ARB Extensions
 */
// 1 - GL_ARB_multitexture
typedef GLvoid function(GLenum) pfglActiveTextureARB;
typedef GLvoid function(GLenum) pfglClientActiveTextureARB;
typedef GLvoid function(GLenum, GLdouble) pfglMultiTexCoord1dARB;
typedef GLvoid function(GLenum, GLdouble*) pfglMultiTexCoord1dvARB;
typedef GLvoid function(GLenum, GLfloat) pfglMultiTexCoord1fARB;
typedef GLvoid function(GLenum, GLfloat*) pfglMultiTexCoord1fvARB;
typedef GLvoid function(GLenum, GLint) pfglMultiTexCoord1iARB;
typedef GLvoid function(GLenum, GLint*) pfglMultiTexCoord1ivARB;
typedef GLvoid function(GLenum, GLshort) pfglMultiTexCoord1sARB;
typedef GLvoid function(GLenum, GLshort*) pfglMultiTexCoord1svARB;
typedef GLvoid function(GLenum, GLdouble, GLdouble) pfglMultiTexCoord2dARB;
typedef GLvoid function(GLenum, GLdouble*) pfglMultiTexCoord2dvARB;
typedef GLvoid function(GLenum, GLfloat, GLfloat) pfglMultiTexCoord2fARB;
typedef GLvoid function(GLenum, GLfloat*) pfglMultiTexCoord2fvARB;
typedef GLvoid function(GLenum, GLint, GLint) pfglMultiTexCoord2iARB;
typedef GLvoid function(GLenum, GLint*) pfglMultiTexCoord2ivARB;
typedef GLvoid function(GLenum, GLshort, GLshort) pfglMultiTexCoord2sARB;
typedef GLvoid function(GLenum, GLshort*) pfglMultiTexCoord2svARB;
typedef GLvoid function(GLenum, GLdouble, GLdouble, GLdouble) pfglMultiTexCoord3dARB;
typedef GLvoid function(GLenum, GLdouble*) pfglMultiTexCoord3dvARB;
typedef GLvoid function(GLenum, GLfloat, GLfloat, GLfloat) pfglMultiTexCoord3fARB;
typedef GLvoid function(GLenum, GLfloat*) pfglMultiTexCoord3fvARB;
typedef GLvoid function(GLenum, GLint, GLint, GLint) pfglMultiTexCoord3iARB;
typedef GLvoid function(GLenum, GLint*) pfglMultiTexCoord3ivARB;
typedef GLvoid function(GLenum, GLshort, GLshort, GLshort) pfglMultiTexCoord3sARB;
typedef GLvoid function(GLenum, GLshort*) pfglMultiTexCoord3svARB;
typedef GLvoid function(GLenum, GLdouble, GLdouble, GLdouble, GLdouble) pfglMultiTexCoord4dARB;
typedef GLvoid function(GLenum, GLdouble*) pfglMultiTexCoord4dvARB;
typedef GLvoid function(GLenum, GLfloat, GLfloat, GLfloat, GLfloat) pfglMultiTexCoord4fARB;
typedef GLvoid function(GLenum, GLfloat*) pfglMultiTexCoord4fvARB;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLint) pfglMultiTexCoord4iARB;
typedef GLvoid function(GLenum, GLint*) pfglMultiTexCoord4ivARB;
typedef GLvoid function(GLenum, GLshort, GLshort, GLshort, GLshort) pfglMultiTexCoord4sARB;
typedef GLvoid function(GLenum, GLshort*) pfglMultiTexCoord4svARB;

pfglActiveTextureARB      glActiveTextureARB;
pfglClientActiveTextureARB    glClientActiveTextureARB;
pfglMultiTexCoord1dARB      glMultiTexCoord1dARB;
pfglMultiTexCoord1dvARB     glMultiTexCoord1dvARB;
pfglMultiTexCoord1fARB      glMultiTexCoord1fARB;
pfglMultiTexCoord1fvARB     glMultiTexCoord1fvARB;
pfglMultiTexCoord1iARB      glMultiTexCoord1iARB;
pfglMultiTexCoord1ivARB     glMultiTexCoord1ivARB;
pfglMultiTexCoord1sARB      glMultiTexCoord1sARB;
pfglMultiTexCoord1svARB     glMultiTexCoord1svARB;
pfglMultiTexCoord2dARB      glMultiTexCoord2dARB;
pfglMultiTexCoord2dvARB     glMultiTexCoord2dvARB;
pfglMultiTexCoord2fARB      glMultiTexCoord2fARB;
pfglMultiTexCoord2fvARB     glMultiTexCoord2fvARB;
pfglMultiTexCoord2iARB      glMultiTexCoord2iARB;
pfglMultiTexCoord2ivARB     glMultiTexCoord2ivARB;
pfglMultiTexCoord2sARB      glMultiTexCoord2sARB;
pfglMultiTexCoord2svARB     glMultiTexCoord2svARB;
pfglMultiTexCoord3dARB      glMultiTexCoord3dARB;
pfglMultiTexCoord3dvARB     glMultiTexCoord3dvARB;
pfglMultiTexCoord3fARB      glMultiTexCoord3fARB;
pfglMultiTexCoord3fvARB     glMultiTexCoord3fvARB;
pfglMultiTexCoord3iARB      glMultiTexCoord3iARB;
pfglMultiTexCoord3ivARB     glMultiTexCoord3ivARB;
pfglMultiTexCoord3sARB      glMultiTexCoord3sARB;
pfglMultiTexCoord3svARB     glMultiTexCoord3svARB;
pfglMultiTexCoord4dARB      glMultiTexCoord4dARB;
pfglMultiTexCoord4dvARB     glMultiTexCoord4dvARB;
pfglMultiTexCoord4fARB      glMultiTexCoord4fARB;
pfglMultiTexCoord4fvARB     glMultiTexCoord4fvARB;
pfglMultiTexCoord4iARB      glMultiTexCoord4iARB;
pfglMultiTexCoord4ivARB     glMultiTexCoord4ivARB;
pfglMultiTexCoord4sARB      glMultiTexCoord4sARB;
pfglMultiTexCoord4svARB     glMultiTexCoord4svARB;

// 3 - GL_ARB_transpose_matrix
typedef GLvoid function(GLfloat*) pfglLoadTransposeMatrixfARB;
typedef GLvoid function(GLdouble*) pfglLoadTransposeMatrixdARB;
typedef GLvoid function(GLfloat*) pfglMultTransposeMatrixfARB;
typedef GLvoid function(GLdouble*) pfglMultTransposeMatrixdARB;

pfglLoadTransposeMatrixfARB   glLoadTransposeMatrixfARB;
pfglLoadTransposeMatrixdARB   glLoadTransposeMatrixdARB;
pfglMultTransposeMatrixfARB   glMultTransposeMatrixfARB;
pfglMultTransposeMatrixdARB   glMultTransposeMatrixdARB;

// 5 - GL_ARB_multisample
typedef GLvoid function(GLclampf, GLboolean) pfglSampleCoverageARB;

pfglSampleCoverageARB     glSampleCoverageARB;

// 12 - GL_ARB_texture_compression
typedef GLvoid function(GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLint, GLsizei, GLvoid*) pfglCompressedTexImage3DARB;
typedef GLvoid function(GLenum, GLint, GLenum, GLsizei, GLsizei, GLint, GLsizei, GLvoid*) pfglCompressedTexImage2DARB;
typedef GLvoid function(GLenum, GLint, GLenum, GLsizei, GLint, GLsizei, GLvoid*) pfglCompressedTexImage1DARB;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLsizei, GLvoid*) pfglCompressedTexSubImage3DARB;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLsizei, GLvoid*) pfglCompressedTexSubImage2DARB;
typedef GLvoid function(GLenum, GLint, GLint, GLsizei, GLenum, GLsizei, GLvoid*) pfglCompressedTexSubImage1DARB;
typedef GLvoid function(GLenum, GLint, GLvoid*) pfglGetCompressedTexImageARB;

pfglCompressedTexImage3DARB   glCompressedTexImage3DARB;
pfglCompressedTexImage2DARB   glCompressedTexImage2DARB;
pfglCompressedTexImage1DARB   glCompressedTexImage1DARB;
pfglCompressedTexSubImage3DARB    glCompressedTexSubImage3DARB;
pfglCompressedTexSubImage2DARB    glCompressedTexSubImage2DARB;
pfglCompressedTexSubImage1DARB    glCompressedTexSubImage1DARB;
pfglGetCompressedTexImageARB    glGetCompressedTexImageARB;

// 14 - GL_ARB_point_parameters
typedef GLvoid function(GLenum, GLfloat) pfglPointParameterfARB;
typedef GLvoid function(GLenum, GLfloat*) pfglPointParameterfvARB;

pfglPointParameterfARB      glPointParameterfARB;
pfglPointParameterfvARB     glPointParameterfvARB;

// 15 - GL_ARB_vertex_blend
typedef GLvoid function(GLint, GLbyte*) pfglWeightbvARB;
typedef GLvoid function(GLint, GLshort*) pfglWeightsvARB;
typedef GLvoid function(GLint, GLint*) pfglWeightivARB;
typedef GLvoid function(GLint, GLfloat*) pfglWeightfvARB;
typedef GLvoid function(GLint, GLdouble*) pfglWeightdvARB;
typedef GLvoid function(GLint, GLubyte*) pfglWeightubvARB;
typedef GLvoid function(GLint, GLushort*) pfglWeightusvARB;
typedef GLvoid function(GLint, GLuint*) pfglWeightuivARB;
typedef GLvoid function(GLint, GLenum, GLsizei, GLvoid*) pfglWeightPointerARB;
typedef GLvoid function(GLint) pfglVertexBlendARB;

pfglWeightbvARB       glWeightbvARB;
pfglWeightsvARB       glWeightsvARB;
pfglWeightivARB       glWeightivARB;
pfglWeightfvARB       glWeightfvARB;
pfglWeightdvARB       glWeightdvARB;
pfglWeightubvARB      glWeightubvARB;
pfglWeightusvARB      glWeightusvARB;
pfglWeightuivARB      glWeightuivARB;
pfglWeightPointerARB      glWeightPointerARB;
pfglVertexBlendARB      glVertexBlendARB;

// 16 - GL_ARB_matrix_palette
typedef GLvoid function(GLint) pfglCurrentPaletteMatrixARB;
typedef GLvoid function(GLint, GLubyte*) pfglMatrixIndexubvARB;
typedef GLvoid function(GLint, GLushort*) pfglMatrixIndexusvARB;
typedef GLvoid function(GLint, GLuint*) pfglMatrixIndexuivARB;
typedef GLvoid function(GLint, GLenum, GLsizei, GLvoid*) pfglMatrixIndexPointerARB;

pfglCurrentPaletteMatrixARB   glCurrentPaletteMatrixARB;
pfglMatrixIndexubvARB     glMatrixIndexubvARB;
pfglMatrixIndexusvARB     glMatrixIndexusvARB;
pfglMatrixIndexuivARB     glMatrixIndexuivARB;
pfglMatrixIndexPointerARB   glMatrixIndexPointerARB;

// 25 - GL_ARB_window_pos
typedef GLvoid function(GLdouble, GLdouble) pfglWindowPos2dARB;
typedef GLvoid function(GLdouble*) pfglWindowPos2dvARB;
typedef GLvoid function(GLfloat, GLfloat) pfglWindowPos2fARB;
typedef GLvoid function(GLfloat*) pfglWindowPos2fvARB;
typedef GLvoid function(GLint, GLint) pfglWindowPos2iARB;
typedef GLvoid function(GLint*) pfglWindowPos2ivARB;
typedef GLvoid function(GLshort, GLshort) pfglWindowPos2sARB;
typedef GLvoid function(GLshort*) pfglWindowPos2svARB;
typedef GLvoid function(GLdouble, GLdouble, GLdouble) pfglWindowPos3dARB;
typedef GLvoid function(GLdouble*) pfglWindowPos3dvARB;
typedef GLvoid function(GLfloat, GLfloat, GLfloat) pfglWindowPos3fARB;
typedef GLvoid function(GLfloat*) pfglWindowPos3fvARB;
typedef GLvoid function(GLint, GLint, GLint) pfglWindowPos3iARB;
typedef GLvoid function(GLint*) pfglWindowPos3ivARB;
typedef GLvoid function(GLshort, GLshort, GLshort) pfglWindowPos3sARB;
typedef GLvoid function(GLshort*) pfglWindowPos3svARB;

pfglWindowPos2dARB      glWindowPos2dARB;
pfglWindowPos2dvARB     glWindowPos2dvARB;
pfglWindowPos2fARB      glWindowPos2fARB;
pfglWindowPos2fvARB     glWindowPos2fvARB;
pfglWindowPos2iARB      glWindowPos2iARB;
pfglWindowPos2ivARB     glWindowPos2ivARB;
pfglWindowPos2sARB      glWindowPos2sARB;
pfglWindowPos2svARB     glWindowPos2svARB;
pfglWindowPos3dARB      glWindowPos3dARB;
pfglWindowPos3dvARB     glWindowPos3dvARB;
pfglWindowPos3fARB      glWindowPos3fARB;
pfglWindowPos3fvARB     glWindowPos3fvARB;
pfglWindowPos3iARB      glWindowPos3iARB;
pfglWindowPos3ivARB     glWindowPos3ivARB;
pfglWindowPos3sARB      glWindowPos3sARB;
pfglWindowPos3svARB     glWindowPos3svARB;

// 26 - GL_ARB_vertex_program
typedef GLvoid function(GLuint, GLdouble) pfglVertexAttrib1dARB;
typedef GLvoid function(GLuint, GLdouble*) pfglVertexAttrib1dvARB;
typedef GLvoid function(GLuint, GLfloat) pfglVertexAttrib1fARB;
typedef GLvoid function(GLuint, GLfloat*) pfglVertexAttrib1fvARB;
typedef GLvoid function(GLuint, GLshort) pfglVertexAttrib1sARB;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib1svARB;
typedef GLvoid function(GLuint, GLdouble, GLdouble) pfglVertexAttrib2dARB;
typedef GLvoid function(GLuint, GLdouble*) pfglVertexAttrib2dvARB;
typedef GLvoid function(GLuint, GLfloat, GLfloat) pfglVertexAttrib2fARB;
typedef GLvoid function(GLuint, GLfloat*) pfglVertexAttrib2fvARB;
typedef GLvoid function(GLuint, GLshort, GLshort) pfglVertexAttrib2sARB;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib2svARB;
typedef GLvoid function(GLuint, GLdouble, GLdouble, GLdouble) pfglVertexAttrib3dARB;
typedef GLvoid function(GLuint, GLdouble*) pfglVertexAttrib3dvARB;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat) pfglVertexAttrib3fARB;
typedef GLvoid function(GLuint, GLfloat*) pfglVertexAttrib3fvARB;
typedef GLvoid function(GLuint, GLshort, GLshort, GLshort) pfglVertexAttrib3sARB;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib3svARB;
typedef GLvoid function(GLuint, GLbyte*) pfglVertexAttrib4NbvARB;
typedef GLvoid function(GLuint, GLint*) pfglVertexAttrib4NivARB;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib4NsvARB;
typedef GLvoid function(GLuint, GLubyte, GLubyte, GLubyte, GLubyte) pfglVertexAttrib4NubARB;
typedef GLvoid function(GLuint, GLubyte*) pfglVertexAttrib4NubvARB;
typedef GLvoid function(GLuint, GLuint*) pfglVertexAttrib4NuivARB;
typedef GLvoid function(GLuint, GLushort*) pfglVertexAttrib4NusvARB;
typedef GLvoid function(GLuint, GLbyte*) pfglVertexAttrib4bvARB;
typedef GLvoid function(GLuint, GLdouble, GLdouble, GLdouble, GLdouble) pfglVertexAttrib4dARB;
typedef GLvoid function(GLuint, GLdouble*) pfglVertexAttrib4dvARB;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat) pfglVertexAttrib4fARB;
typedef GLvoid function(GLuint, GLfloat*) pfglVertexAttrib4fvARB;
typedef GLvoid function(GLuint, GLint*) pfglVertexAttrib4ivARB;
typedef GLvoid function(GLuint, GLshort, GLshort, GLshort, GLshort) pfglVertexAttrib4sARB;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib4svARB;
typedef GLvoid function(GLuint, GLubyte*) pfglVertexAttrib4ubvARB;
typedef GLvoid function(GLuint, GLuint*) pfglVertexAttrib4uivARB;
typedef GLvoid function(GLuint, GLushort*) pfglVertexAttrib4usvARB;
typedef GLvoid function(GLuint, GLint, GLenum, GLboolean, GLsizei, GLvoid*) pfglVertexAttribPointerARB;
typedef GLvoid function(GLuint) pfglEnableVertexAttribArrayARB;
typedef GLvoid function(GLuint) pfglDisableVertexAttribArrayARB;
typedef GLvoid function(GLenum, GLenum, GLsizei, GLvoid*) pfglProgramStringARB;
typedef GLvoid function(GLenum, GLuint) pfglBindProgramARB;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteProgramsARB;
typedef GLvoid function(GLsizei, GLuint*) pfglGenProgramsARB;
typedef GLvoid function(GLenum, GLuint, GLdouble, GLdouble, GLdouble, GLdouble) pfglProgramEnvParameter4dARB;
typedef GLvoid function(GLenum, GLuint, GLdouble*) pfglProgramEnvParameter4dvARB;
typedef GLvoid function(GLenum, GLuint, GLfloat, GLfloat, GLfloat, GLfloat) pfglProgramEnvParameter4fARB;
typedef GLvoid function(GLenum, GLuint, GLfloat*) pfglProgramEnvParameter4fvARB;
typedef GLvoid function(GLenum, GLuint, GLdouble, GLdouble, GLdouble, GLdouble) pfglProgramLocalParameter4dARB;
typedef GLvoid function(GLenum, GLuint, GLdouble*) pfglProgramLocalParameter4dvARB;
typedef GLvoid function(GLenum, GLuint, GLfloat, GLfloat, GLfloat, GLfloat) pfglProgramLocalParameter4fARB;
typedef GLvoid function(GLenum, GLuint, GLfloat*) pfglProgramLocalParameter4fvARB;
typedef GLvoid function(GLenum, GLuint, GLdouble*) pfglGetProgramEnvParameterdvARB;
typedef GLvoid function(GLenum, GLuint, GLfloat*) pfglGetProgramEnvParameterfvARB;
typedef GLvoid function(GLenum, GLuint, GLdouble*) pfglGetProgramLocalParameterdvARB;
typedef GLvoid function(GLenum, GLuint, GLfloat*) pfglGetProgramLocalParameterfvARB;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetProgramivARB;
typedef GLvoid function(GLenum, GLenum, GLvoid*) pfglGetProgramStringARB;
typedef GLvoid function(GLuint, GLenum, GLdouble*) pfglGetVertexAttribdvARB;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetVertexAttribfvARB;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetVertexAttribivARB;
typedef GLvoid function(GLuint, GLenum, GLvoid**) pfglGetVertexAttribPointervARB;
typedef GLboolean function(GLuint) pfglIsProgramARB;

pfglVertexAttrib1dARB     glVertexAttrib1dARB;
pfglVertexAttrib1dvARB      glVertexAttrib1dvARB;
pfglVertexAttrib1fARB     glVertexAttrib1fARB;
pfglVertexAttrib1fvARB      glVertexAttrib1fvARB;
pfglVertexAttrib1sARB     glVertexAttrib1sARB;
pfglVertexAttrib1svARB      glVertexAttrib1svARB;
pfglVertexAttrib2dARB     glVertexAttrib2dARB;
pfglVertexAttrib2dvARB      glVertexAttrib2dvARB;
pfglVertexAttrib2fARB     glVertexAttrib2fARB;
pfglVertexAttrib2fvARB      glVertexAttrib2fvARB;
pfglVertexAttrib2sARB     glVertexAttrib2sARB;
pfglVertexAttrib2svARB      glVertexAttrib2svARB;
pfglVertexAttrib3dARB     glVertexAttrib3dARB;
pfglVertexAttrib3dvARB      glVertexAttrib3dvARB;
pfglVertexAttrib3fARB     glVertexAttrib3fARB;
pfglVertexAttrib3fvARB      glVertexAttrib3fvARB;
pfglVertexAttrib3sARB     glVertexAttrib3sARB;
pfglVertexAttrib3svARB      glVertexAttrib3svARB;
pfglVertexAttrib4NbvARB     glVertexAttrib4NbvARB;
pfglVertexAttrib4NivARB     glVertexAttrib4NivARB;
pfglVertexAttrib4NsvARB     glVertexAttrib4NsvARB;
pfglVertexAttrib4NubARB     glVertexAttrib4NubARB;
pfglVertexAttrib4NubvARB    glVertexAttrib4NubvARB;
pfglVertexAttrib4NuivARB    glVertexAttrib4NuivARB;
pfglVertexAttrib4NusvARB    glVertexAttrib4NusvARB;
pfglVertexAttrib4bvARB      glVertexAttrib4bvARB;
pfglVertexAttrib4dARB     glVertexAttrib4dARB;
pfglVertexAttrib4dvARB      glVertexAttrib4dvARB;
pfglVertexAttrib4fARB     glVertexAttrib4fARB;
pfglVertexAttrib4fvARB      glVertexAttrib4fvARB;
pfglVertexAttrib4ivARB      glVertexAttrib4ivARB;
pfglVertexAttrib4sARB     glVertexAttrib4sARB;
pfglVertexAttrib4svARB      glVertexAttrib4svARB;
pfglVertexAttrib4ubvARB     glVertexAttrib4ubvARB;
pfglVertexAttrib4uivARB     glVertexAttrib4uivARB;
pfglVertexAttrib4usvARB     glVertexAttrib4usvARB;
pfglVertexAttribPointerARB    glVertexAttribPointerARB;
pfglEnableVertexAttribArrayARB    glEnableVertexAttribArrayARB;
pfglDisableVertexAttribArrayARB   glDisableVertexAttribArrayARB;
pfglProgramStringARB      glProgramStringARB;
pfglBindProgramARB      glBindProgramARB;
pfglDeleteProgramsARB     glDeleteProgramsARB;
pfglGenProgramsARB      glGenProgramsARB;
pfglProgramEnvParameter4dARB    glProgramEnvParameter4dARB;
pfglProgramEnvParameter4dvARB   glProgramEnvParameter4dvARB;
pfglProgramEnvParameter4fARB    glProgramEnvParameter4fARB;
pfglProgramEnvParameter4fvARB   glProgramEnvParameter4fvARB;
pfglProgramLocalParameter4dARB    glProgramLocalParameter4dARB;
pfglProgramLocalParameter4dvARB   glProgramLocalParameter4dvARB;
pfglProgramLocalParameter4fARB    glProgramLocalParameter4fARB;
pfglProgramLocalParameter4fvARB   glProgramLocalParameter4fvARB;
pfglGetProgramEnvParameterdvARB   glGetProgramEnvParameterdvARB;
pfglGetProgramEnvParameterfvARB   glGetProgramEnvParameterfvARB;
pfglGetProgramLocalParameterdvARB glGetProgramLocalParameterdvARB;
pfglGetProgramLocalParameterfvARB glGetProgramLocalParameterfvARB;
pfglGetProgramivARB     glGetProgramivARB;
pfglGetProgramStringARB     glGetProgramStringARB;
pfglGetVertexAttribdvARB    glGetVertexAttribdvARB;
pfglGetVertexAttribfvARB    glGetVertexAttribfvARB;
pfglGetVertexAttribivARB    glGetVertexAttribivARB;
pfglGetVertexAttribPointervARB    glGetVertexAttribPointervARB;
pfglIsProgramARB      glIsProgramARB;

// 28 - GL_ARB_vertex_buffer_object
typedef GLvoid function(GLenum, GLuint) pfglBindBufferARB;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteBuffersARB;
typedef GLvoid function(GLsizei, GLuint*) pfglGenBuffersARB;
typedef GLboolean function(GLuint) pfglIsBufferARB;
typedef GLvoid function(GLenum, GLsizeiptrARB, GLvoid*, GLenum) pfglBufferDataARB;
typedef GLvoid function(GLenum, GLintptrARB, GLsizeiptrARB, GLvoid*) pfglBufferSubDataARB;
typedef GLvoid function(GLenum, GLintptrARB, GLsizeiptrARB, GLvoid*) pfglGetBufferSubDataARB;
typedef GLvoid* function(GLenum, GLenum) pfglMapBufferARB;
typedef GLboolean function(GLenum) pfglUnmapBufferARB;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetBufferParameterivARB;
typedef GLvoid function(GLenum, GLenum, GLvoid**) pfglGetBufferPointervARB;

pfglBindBufferARB     glBindBufferARB;
pfglDeleteBuffersARB      glDeleteBuffersARB;
pfglGenBuffersARB     glGenBuffersARB;
pfglIsBufferARB       glIsBufferARB;
pfglBufferDataARB     glBufferDataARB;
pfglBufferSubDataARB      glBufferSubDataARB;
pfglGetBufferSubDataARB     glGetBufferSubDataARB;
pfglMapBufferARB      glMapBufferARB;
pfglUnmapBufferARB      glUnmapBufferARB;
pfglGetBufferParameterivARB   glGetBufferParameterivARB;
pfglGetBufferPointervARB    glGetBufferPointervARB;

// 29 - GL_ARB_occlusion_query
typedef GLvoid function(GLsizei, GLuint*) pfglGenQueriesARB;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteQueriesARB;
typedef GLboolean function(GLuint) pfglIsQueryARB;
typedef GLvoid function(GLenum, GLuint) pfglBeginQueryARB;
typedef GLvoid function(GLenum) pfglEndQueryARB;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetQueryivARB;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetQueryObjectivARB;
typedef GLvoid function(GLuint, GLenum, GLuint*) pfglGetQueryObjectuivARB;

pfglGenQueriesARB     glGenQueriesARB;
pfglDeleteQueriesARB      glDeleteQueriesARB;
pfglIsQueryARB        glIsQueryARB;
pfglBeginQueryARB     glBeginQueryARB;
pfglEndQueryARB       glEndQueryARB;
pfglGetQueryivARB     glGetQueryivARB;
pfglGetQueryObjectivARB     glGetQueryObjectivARB;
pfglGetQueryObjectuivARB    glGetQueryObjectuivARB;

// 30 - GL_ARB_shader_objects
typedef GLvoid function(GLhandleARB) pfglDeleteObjectARB;
typedef GLhandleARB function(GLenum) pfglGetHandleARB;
typedef GLvoid function(GLhandleARB, GLhandleARB) pfglDetachObjectARB;
typedef GLhandleARB function(GLenum) pfglCreateShaderObjectARB;
typedef GLvoid function(GLhandleARB, GLsizei, GLcharARB**, GLint*) pfglShaderSourceARB;
typedef GLvoid function(GLhandleARB) pfglCompileShaderARB;
typedef GLhandleARB function() pfglCreateProgramObjectARB;
typedef GLvoid function(GLhandleARB, GLhandleARB) pfglAttachObjectARB;
typedef GLvoid function(GLhandleARB) pfglLinkProgramARB;
typedef GLvoid function(GLhandleARB) pfglUseProgramObjectARB;
typedef GLvoid function(GLhandleARB) pfglValidateProgramARB;
typedef GLvoid function(GLint, GLfloat) pfglUniform1fARB;
typedef GLvoid function(GLint, GLfloat, GLfloat) pfglUniform2fARB;
typedef GLvoid function(GLint, GLfloat, GLfloat, GLfloat) pfglUniform3fARB;
typedef GLvoid function(GLint, GLfloat, GLfloat, GLfloat, GLfloat) pfglUniform4fARB;
typedef GLvoid function(GLint, GLint) pfglUniform1iARB;
typedef GLvoid function(GLint, GLint, GLint) pfglUniform2iARB;
typedef GLvoid function(GLint, GLint, GLint, GLint) pfglUniform3iARB;
typedef GLvoid function(GLint, GLint, GLint, GLint, GLint) pfglUniform4iARB;
typedef GLvoid function(GLint, GLsizei, GLfloat*) pfglUniform1fvARB;
typedef GLvoid function(GLint, GLsizei, GLfloat*) pfglUniform2fvARB;
typedef GLvoid function(GLint, GLsizei, GLfloat*) pfglUniform3fvARB;
typedef GLvoid function(GLint, GLsizei, GLfloat*) pfglUniform4fvARB;
typedef GLvoid function(GLint, GLsizei, GLint*) pfglUniform1ivARB;
typedef GLvoid function(GLint, GLsizei, GLint*) pfglUniform2ivARB;
typedef GLvoid function(GLint, GLsizei, GLint*) pfglUniform3ivARB;
typedef GLvoid function(GLint, GLsizei, GLint*) pfglUniform4ivARB;
typedef GLvoid function(GLint, GLsizei, GLboolean, GLfloat*) pfglUniformMatrix2fvARB;
typedef GLvoid function(GLint, GLsizei, GLboolean, GLfloat*) pfglUniformMatrix3fvARB;
typedef GLvoid function(GLint, GLsizei, GLboolean, GLfloat*) pfglUniformMatrix4fvARB;
typedef GLvoid function(GLhandleARB, GLenum, GLfloat*) pfglGetObjectParameterfvARB;
typedef GLvoid function(GLhandleARB, GLenum, GLint*) pfglGetObjectParameterivARB;
typedef GLvoid function(GLhandleARB, GLsizei, GLsizei*, GLcharARB*) pfglGetInfoLogARB;
typedef GLvoid function(GLhandleARB, GLsizei, GLsizei*, GLhandleARB*) pfglGetAttachedObjectsARB;
typedef GLint function(GLhandleARB, GLcharARB*) pfglGetUniformLocationARB;
typedef GLvoid function(GLhandleARB, GLuint, GLsizei, GLsizei*, GLint*, GLenum*, GLcharARB*) pfglGetActiveUniformARB;
typedef GLvoid function(GLhandleARB, GLint, GLfloat*) pfglGetUniformfvARB;
typedef GLvoid function(GLhandleARB, GLint, GLint*) pfglGetUniformivARB;
typedef GLvoid function(GLhandleARB, GLsizei, GLsizei*, GLcharARB*) pfglGetShaderSourceARB;

pfglDeleteObjectARB     glDeleteObjectARB;
pfglGetHandleARB      glGetHandleARB;
pfglDetachObjectARB     glDetachObjectARB;
pfglCreateShaderObjectARB   glCreateShaderObjectARB;
pfglShaderSourceARB     glShaderSourceARB;
pfglCompileShaderARB      glCompileShaderARB;
pfglCreateProgramObjectARB    glCreateProgramObjectARB;
pfglAttachObjectARB     glAttachObjectARB;
pfglLinkProgramARB      glLinkProgramARB;
pfglUseProgramObjectARB     glUseProgramObjectARB;
pfglValidateProgramARB      glValidateProgramARB;
pfglUniform1fARB      glUniform1fARB;
pfglUniform2fARB      glUniform2fARB;
pfglUniform3fARB      glUniform3fARB;
pfglUniform4fARB      glUniform4fARB;
pfglUniform1iARB      glUniform1iARB;
pfglUniform2iARB      glUniform2iARB;
pfglUniform3iARB      glUniform3iARB;
pfglUniform4iARB      glUniform4iARB;
pfglUniform1fvARB     glUniform1fvARB;
pfglUniform2fvARB     glUniform2fvARB;
pfglUniform3fvARB     glUniform3fvARB;
pfglUniform4fvARB     glUniform4fvARB;
pfglUniform1ivARB     glUniform1ivARB;
pfglUniform2ivARB     glUniform2ivARB;
pfglUniform3ivARB     glUniform3ivARB;
pfglUniform4ivARB     glUniform4ivARB;
pfglUniformMatrix2fvARB     glUniformMatrix2fvARB;
pfglUniformMatrix3fvARB     glUniformMatrix3fvARB;
pfglUniformMatrix4fvARB     glUniformMatrix4fvARB;
pfglGetObjectParameterfvARB   glGetObjectParameterfvARB;
pfglGetObjectParameterivARB   glGetObjectParameterivARB;
pfglGetInfoLogARB     glGetInfoLogARB;
pfglGetAttachedObjectsARB   glGetAttachedObjectsARB;
pfglGetUniformLocationARB   glGetUniformLocationARB;
pfglGetActiveUniformARB     glGetActiveUniformARB;
pfglGetUniformfvARB     glGetUniformfvARB;
pfglGetUniformivARB     glGetUniformivARB;
pfglGetShaderSourceARB      glGetShaderSourceARB;

// 31 - GL_ARB_vertex_shader
typedef GLvoid function(GLhandleARB, GLuint, GLcharARB*) pfglBindAttribLocationARB;
typedef GLvoid function(GLhandleARB, GLuint, GLsizei, GLsizei*, GLint*, GLenum*, GLcharARB*) pfglGetActiveAttribARB;
typedef GLint function(GLhandleARB, GLcharARB*) pfglGetAttribLocationARB;

pfglBindAttribLocationARB   glBindAttribLocationARB;
pfglGetActiveAttribARB      glGetActiveAttribARB;
pfglGetAttribLocationARB    glGetAttribLocationARB;

// 37 - GL_ARB_draw_buffers
typedef GLvoid function(GLsizei, GLenum*) pfglDrawBuffersARB;

pfglDrawBuffersARB      glDrawBuffersARB;

// 39 - GL_ARB_color_buffer_float
typedef GLvoid function(GLenum, GLenum) pfglClampColorARB;

pfglClampColorARB     glClampColorARB;

/*
 * Non-ARB Extensions
 */
// 2 - GL_EXT_blend_color
typedef GLvoid function(GLclampf, GLclampf, GLclampf, GLclampf) pfglBlendColorEXT;

pfglBlendColorEXT     glBlendColorEXT;

// 3 - GL_EXT_polygon_offset
typedef GLvoid function(GLfloat, GLfloat) pfglPolygonOffsetEXT;

pfglPolygonOffsetEXT      glPolygonOffsetEXT;

// 6 - GL_EXT_texture3D
typedef GLvoid function(GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, GLvoid*) pfglTexImage3DEXT;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLenum, GLenum, GLvoid*) pfglTexSubImage3DEXT;

pfglTexImage3DEXT     glTexImage3DEXT;
pfglTexSubImage3DEXT      glTexSubImage3DEXT;

// 7 - GL_SGIS_texture_filter4
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetTexFilterFuncSGIS;
typedef GLvoid function(GLenum, GLenum, GLsizei, GLfloat*) pfglTexFilterFuncSGIS;

pfglGetTexFilterFuncSGIS    glGetTexFilterFuncSGIS;
pfglTexFilterFuncSGIS     glTexFilterFuncSGIS;

// 9 - GL_EXT_subtexture
typedef GLvoid function(GLenum, GLint, GLint, GLsizei, GLenum, GLenum, GLvoid*) pfglTexSubImage1DEXT;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLsizei, GLsizei, GLenum, GLenum, GLvoid*) pfglTexSubImage2DEXT;

pfglTexSubImage1DEXT      glTexSubImage1DEXT;
pfglTexSubImage2DEXT      glTexSubImage2DEXT;

// 10 - GL_EXT_copy_texture
typedef GLvoid function(GLenum, GLint, GLenum, GLint, GLint, GLsizei, GLint) pfglCopyTexImage1DEXT;
typedef GLvoid function(GLenum, GLint, GLenum, GLint, GLint, GLsizei, GLsizei, GLint) pfglCopyTexImage2DEXT;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLint, GLsizei) pfglCopyTexSubImage1DEXT;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei) pfglCopyTexSubImage2DEXT;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei) pfglCopyTexSubImage3DEXT;

pfglCopyTexImage1DEXT     glCopyTexImage1DEXT;
pfglCopyTexImage2DEXT     glCopyTexImage2DEXT;
pfglCopyTexSubImage1DEXT    glCopyTexSubImage1DEXT;
pfglCopyTexSubImage2DEXT    glCopyTexSubImage2DEXT;
pfglCopyTexSubImage3DEXT    glCopyTexSubImage3DEXT;

// 11 - GL_EXT_histogram
typedef GLvoid function(GLenum, GLboolean, GLenum, GLenum, GLvoid*) pfglGetHistogramEXT;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetHistogramParameterfvEXT;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetHistogramParameterivEXT;
typedef GLvoid function(GLenum, GLboolean, GLenum, GLenum, GLvoid*) pfglGetMinmaxEXT;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetMinmaxParameterfvEXT;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetMinmaxParameterivEXT;
typedef GLvoid function(GLenum, GLsizei, GLenum, GLboolean) pfglHistogramEXT;
typedef GLvoid function(GLenum, GLenum, GLboolean) pfglMinmaxEXT;
typedef GLvoid function(GLenum) pfglResetHistogramEXT;
typedef GLvoid function(GLenum) pfglResetMinmaxEXT;

pfglGetHistogramEXT     glGetHistogramEXT;
pfglGetHistogramParameterfvEXT    glGetHistogramParameterfvEXT;
pfglGetHistogramParameterivEXT    glGetHistogramParameterivEXT;
pfglGetMinmaxEXT      glGetMinmaxEXT;
pfglGetMinmaxParameterfvEXT   glGetMinmaxParameterfvEXT;
pfglGetMinmaxParameterivEXT   glGetMinmaxParameterivEXT;
pfglHistogramEXT      glHistogramEXT;
pfglMinmaxEXT       glMinmaxEXT;
pfglResetHistogramEXT     glResetHistogramEXT;
pfglResetMinmaxEXT      glResetMinmaxEXT;

// 12 - GL_EXT_convolution
typedef GLvoid function(GLenum, GLenum, GLsizei, GLenum, GLenum, GLvoid*) pfglConvolutionFilter1DEXT;
typedef GLvoid function(GLenum, GLenum, GLsizei, GLsizei, GLenum, GLenum, GLvoid*) pfglConvolutionFilter2DEXT;
typedef GLvoid function(GLenum, GLenum, GLfloat) pfglConvolutionParameterfEXT;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglConvolutionParameterfvEXT;
typedef GLvoid function(GLenum, GLenum, GLint) pfglConvolutionParameteriEXT;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglConvolutionParameterivEXT;
typedef GLvoid function(GLenum, GLenum, GLint, GLint, GLsizei) pfglCopyConvolutionFilter1DEXT;
typedef GLvoid function(GLenum, GLenum, GLint, GLint, GLsizei, GLsizei) pfglCopyConvolutionFilter2DEXT;
typedef GLvoid function(GLenum, GLenum, GLenum, GLvoid*) pfglGetConvolutionFilterEXT;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetConvolutionParameterfvEXT;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetConvolutionParameterivEXT;
typedef GLvoid function(GLenum, GLenum, GLenum, GLvoid*, GLvoid*, GLvoid*) pfglGetSeparableFilterEXT;
typedef GLvoid function(GLenum, GLenum, GLsizei, GLsizei, GLenum, GLenum, GLvoid*, GLvoid*) pfglSeparableFilter2DEXT;

pfglConvolutionFilter1DEXT    glConvolutionFilter1DEXT;
pfglConvolutionFilter2DEXT    glConvolutionFilter2DEXT;
pfglConvolutionParameterfEXT    glConvolutionParameterfEXT;
pfglConvolutionParameterfvEXT   glConvolutionParameterfvEXT;
pfglConvolutionParameteriEXT    glConvolutionParameteriEXT;
pfglConvolutionParameterivEXT   glConvolutionParameterivEXT;
pfglCopyConvolutionFilter1DEXT    glCopyConvolutionFilter1DEXT;
pfglCopyConvolutionFilter2DEXT    glCopyConvolutionFilter2DEXT;
pfglGetConvolutionFilterEXT   glGetConvolutionFilterEXT;
pfglGetConvolutionParameterfvEXT  glGetConvolutionParameterfvEXT;
pfglGetConvolutionParameterivEXT  glGetConvolutionParameterivEXT;
pfglGetSeparableFilterEXT   glGetSeparableFilterEXT;
pfglSeparableFilter2DEXT    glSeparableFilter2DEXT;

// 14 - GL_SGI_color_table
typedef GLvoid function(GLenum, GLenum, GLsizei, GLenum, GLenum, GLvoid*) pfglColorTableSGI;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglColorTableParameterfvSGI;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglColorTableParameterivSGI;
typedef GLvoid function(GLenum, GLenum, GLint, GLint, GLsizei) pfglCopyColorTableSGI;
typedef GLvoid function(GLenum, GLenum, GLenum, GLvoid*) pfglGetColorTableSGI;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetColorTableParameterfvSGI;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetColorTableParameterivSGI;

pfglColorTableSGI     glColorTableSGI;
pfglColorTableParameterfvSGI    glColorTableParameterfvSGI;
pfglColorTableParameterivSGI    glColorTableParameterivSGI;
pfglCopyColorTableSGI     glCopyColorTableSGI;
pfglGetColorTableSGI      glGetColorTableSGI;
pfglGetColorTableParameterfvSGI   glGetColorTableParameterfvSGI;
pfglGetColorTableParameterivSGI   glGetColorTableParameterivSGI;

// 15 - GL_SGIS_pixel_texture
typedef GLvoid function(GLenum, GLint) pfglPixelTexGenParameteriSGIS;
typedef GLvoid function(GLenum, GLint*) pfglPixelTexGenParameterivSGIS;
typedef GLvoid function(GLenum, GLfloat) pfglPixelTexGenParameterfSGIS;
typedef GLvoid function(GLenum, GLfloat*) pfglPixelTexGenParameterfvSGIS;
typedef GLvoid function(GLenum, GLint*) pfglGetPixelTexGenParameterivSGIS;
typedef GLvoid function(GLenum, GLfloat*) pfglGetPixelTexGenParameterfvSGIS;

pfglPixelTexGenParameteriSGIS   glPixelTexGenParameteriSGIS;
pfglPixelTexGenParameterivSGIS    glPixelTexGenParameterivSGIS;
pfglPixelTexGenParameterfSGIS   glPixelTexGenParameterfSGIS;
pfglPixelTexGenParameterfvSGIS    glPixelTexGenParameterfvSGIS;
pfglGetPixelTexGenParameterivSGIS glGetPixelTexGenParameterivSGIS;
pfglGetPixelTexGenParameterfvSGIS glGetPixelTexGenParameterfvSGIS;

// 15a - GL_SGIX_pixel_texture
typedef GLvoid function(GLenum) pfglPixelTexGenSGIX;

pfglPixelTexGenSGIX     glPixelTexGenSGIX;

// 16 - GL_SGIS_texture4D
typedef GLvoid function(GLenum, GLint, GLenum, GLsizei, GLsizei, GLsizei, GLsizei, GLint, GLenum, GLenum, GLvoid*) pfglTexImage4DSGIS;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLint, GLint, GLsizei, GLsizei, GLsizei, GLsizei, GLenum, GLenum, GLvoid*) pfglTexSubImage4DSGIS;

pfglTexImage4DSGIS      glTexImage4DSGIS;
pfglTexSubImage4DSGIS     glTexSubImage4DSGIS;

// 20 - GL_EXT_texture_object
typedef GLboolean function(GLsizei, GLuint*, GLboolean*) pfglAreTexturesResidentEXT;
typedef GLvoid function(GLenum, GLuint) pfglBindTextureEXT;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteTexturesEXT;
typedef GLvoid function(GLsizei, GLuint*) pfglGenTexturesEXT;
typedef GLboolean function(GLuint) pfglIsTextureEXT;
typedef GLvoid function(GLsizei, GLuint*, GLclampf*) pfglPrioritizeTexturesEXT;

pfglAreTexturesResidentEXT    glAreTexturesResidentEXT;
pfglBindTextureEXT      glBindTextureEXT;
pfglDeleteTexturesEXT     glDeleteTexturesEXT;
pfglGenTexturesEXT      glGenTexturesEXT;
pfglIsTextureEXT      glIsTextureEXT;
pfglPrioritizeTexturesEXT   glPrioritizeTexturesEXT;

// 21 - GL_SGIS_detail_texture
typedef GLvoid function(GLenum, GLsizei, GLfloat*) pfglDetailTexFuncSGIS;
typedef GLvoid function(GLenum, GLfloat*) pfglGetDetailTexFuncSGIS;

pfglDetailTexFuncSGIS     glDetailTexFuncSGIS;
pfglGetDetailTexFuncSGIS    glGetDetailTexFuncSGIS;

// 22 - GL_SGIS_sharpen_texture
typedef GLvoid function(GLenum, GLsizei, GLfloat*) pfglSharpenTexFuncSGIS;
typedef GLvoid function(GLenum, GLfloat*) pfglGetSharpenTexFuncSGIS;

pfglSharpenTexFuncSGIS      glSharpenTexFuncSGIS;
pfglGetSharpenTexFuncSGIS   glGetSharpenTexFuncSGIS;

// 25 - GL_SGIS_multisample
typedef GLvoid function(GLclampf, GLboolean) pfglSampleMaskSGIS;
typedef GLvoid function(GLenum) pfglSamplePatternSGIS;

pfglSampleMaskSGIS      glSampleMaskSGIS;
pfglSamplePatternSGIS     glSamplePatternSGIS;

// 30 - GL_EXT_vertex_array
typedef GLvoid function(GLint) pfglArrayElementEXT;
typedef GLvoid function(GLint, GLenum, GLsizei, GLsizei, GLvoid*) pfglColorPointerEXT;
typedef GLvoid function(GLenum, GLint, GLsizei) pfglDrawArraysEXT;
typedef GLvoid function(GLsizei, GLsizei, GLboolean*) pfglEdgeFlagPointerEXT;
typedef GLvoid function(GLenum, GLvoid**) pfglGetPointervEXT;
typedef GLvoid function(GLenum, GLsizei, GLsizei, GLvoid*) pfglIndexPointerEXT;
typedef GLvoid function(GLenum, GLsizei, GLsizei, GLvoid*) pfglNormalPointerEXT;
typedef GLvoid function(GLint, GLenum, GLsizei, GLsizei, GLvoid*) pfglTexCoordPointerEXT;
typedef GLvoid function(GLint, GLenum, GLsizei, GLsizei, GLvoid*) pfglVertexPointerEXT;

pfglArrayElementEXT     glArrayElementEXT;
pfglColorPointerEXT     glColorPointerEXT;
pfglDrawArraysEXT     glDrawArraysEXT;
pfglEdgeFlagPointerEXT      glEdgeFlagPointerEXT;
pfglGetPointervEXT      glGetPointervEXT;
pfglIndexPointerEXT     glIndexPointerEXT;
pfglNormalPointerEXT      glNormalPointerEXT;
pfglTexCoordPointerEXT      glTexCoordPointerEXT;
pfglVertexPointerEXT      glVertexPointerEXT;

// 37 - GL_EXT_blend_minmax
typedef GLvoid function(GLenum) pfglBlendEquationEXT;

pfglBlendEquationEXT      glBlendEquationEXT;

// 52 - GL_SGIX_sprite
typedef GLvoid function(GLenum, GLfloat) pfglSpriteParameterfSGIX;
typedef GLvoid function(GLenum, GLfloat*) pfglSpriteParameterfvSGIX;
typedef GLvoid function(GLenum, GLint) pfglSpriteParameteriSGIX;
typedef GLvoid function(GLenum, GLint*) pfglSpriteParameterivSGIX;

pfglSpriteParameterfSGIX    glSpriteParameterfSGIX;
pfglSpriteParameterfvSGIX   glSpriteParameterfvSGIX;
pfglSpriteParameteriSGIX    glSpriteParameteriSGIX;
pfglSpriteParameterivSGIX   glSpriteParameterivSGIX;

// 54 - GL_EXT_point_parameters
typedef GLvoid function(GLenum, GLfloat) pfglPointParameterfEXT;
typedef GLvoid function(GLenum, GLfloat*) pfglPointParameterfvEXT;

pfglPointParameterfEXT      glPointParameterfEXT;
pfglPointParameterfvEXT     glPointParameterfvEXT;

// ? - GL_SGIS_point_parameters
typedef GLvoid function(GLenum, GLfloat) pfglPointParameterfSGIS;
typedef GLvoid function(GLenum, GLfloat*) pfglPointParameterfvSGIS;

pfglPointParameterfSGIS     glPointParameterfSGIS;
pfglPointParameterfvSGIS    glPointParameterfvSGIS;

// 55 - GL_SGIX_instruments
typedef GLint function() pfglGetInstrumentsSGIX;
typedef GLvoid function(GLsizei, GLint*) pfglInstrumentsBufferSGIX;
typedef GLint function(GLint*) pfglPollInstrumentsSGIX;
typedef GLvoid function(GLint) pfglReadInstrumentsSGIX;
typedef GLvoid function() pfglStartInstrumentsSGIX;
typedef GLvoid function(GLint) pfglStopInstrumentsSGIX;

pfglGetInstrumentsSGIX      glGetInstrumentsSGIX;
pfglInstrumentsBufferSGIX   glInstrumentsBufferSGIX;
pfglPollInstrumentsSGIX     glPollInstrumentsSGIX;
pfglReadInstrumentsSGIX     glReadInstrumentsSGIX;
pfglStartInstrumentsSGIX    glStartInstrumentsSGIX;
pfglStopInstrumentsSGIX     glStopInstrumentsSGIX;

// 57 - GL_SGIX_framezoom
typedef GLvoid function(GLint) pfglFrameZoomSGIX;

pfglFrameZoomSGIX     glFrameZoomSGIX;

// 58 - GL_SGIX_tag_sample_buffer
typedef GLvoid function() pfglTagSampleBufferSGIX;

pfglTagSampleBufferSGIX     glTagSampleBufferSGIX;

// ? - GL_SGIX_polynomial_ffd
typedef GLvoid function(GLenum, GLdouble, GLdouble, GLint, GLint, GLdouble, GLdouble, GLint, GLint, GLdouble, GLdouble, GLint, GLint, GLdouble*) pfglDeformationMap3dSGIX;
typedef GLvoid function(GLenum, GLfloat, GLfloat, GLint, GLint, GLfloat, GLfloat, GLint, GLint, GLfloat, GLfloat, GLint, GLint, GLfloat*) pfglDeformationMap3fSGIX;
typedef GLvoid function(GLbitfield) pfglDeformSGIX;
typedef GLvoid function(GLbitfield) pfglLoadIdentityDeformationMapSGIX;

pfglDeformationMap3dSGIX    glDeformationMap3dSGIX;
pfglDeformationMap3fSGIX    glDeformationMap3fSGIX;
pfglDeformSGIX        glDeformSGIX;
pfglLoadIdentityDeformationMapSGIX  glLoadIdentityDeformationMapSGIX;

// 60 - GL_SGIX_reference_plane
typedef GLvoid function(GLdouble*) pfglReferencePlaneSGIX;

pfglReferencePlaneSGIX      glReferencePlaneSGIX;

// 61 - GL_SGIX_flush_raster
typedef GLvoid function() pfglFlushRasterSGIX;

pfglFlushRasterSGIX     glFlushRasterSGIX;

// 64 - GL_SGIS_fog_function
typedef GLvoid function(GLsizei, GLfloat*) pfglFogFuncSGIS;
typedef GLvoid function(GLfloat*) pfglGetFogFuncSGIS;

pfglFogFuncSGIS       glFogFuncSGIS;
pfglGetFogFuncSGIS      glGetFogFuncSGIS;

// 66 - GL_HP_image_transform
typedef GLvoid function(GLenum, GLenum, GLint) pfglImageTransformParameteriHP;
typedef GLvoid function(GLenum, GLenum, GLfloat) pfglImageTransformParameterfHP;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglImageTransformParameterivHP;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglImageTransformParameterfvHP;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetImageTransformParameterivHP;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetImageTransformParameterfvHP;

pfglImageTransformParameteriHP    glImageTransformParameteriHP;
pfglImageTransformParameterfHP    glImageTransformParameterfHP;
pfglImageTransformParameterivHP   glImageTransformParameterivHP;
pfglImageTransformParameterfvHP   glImageTransformParameterfvHP;
pfglGetImageTransformParameterivHP  glGetImageTransformParameterivHP;
pfglGetImageTransformParameterfvHP  glGetImageTransformParameterfvHP;

// 74 - GL_EXT_color_subtable
typedef GLvoid function(GLenum, GLsizei, GLsizei, GLenum, GLenum, GLvoid*) pfglColorSubTableEXT;
typedef GLvoid function(GLenum, GLsizei, GLint, GLint, GLsizei) pfglCopyColorSubTableEXT;

pfglColorSubTableEXT      glColorSubTableEXT;
pfglCopyColorSubTableEXT    glCopyColorSubTableEXT;

// 77 - GL_PGI_misc_hints
typedef GLvoid function(GLenum, GLint) pfglHintPGI;

pfglHintPGI       glHintPGI;

// 78 - GL_EXT_paletted_texture
typedef GLvoid function(GLenum, GLenum, GLsizei, GLenum, GLenum, GLvoid*) pfglColorTableEXT;
typedef GLvoid function(GLenum, GLenum, GLenum, GLvoid*) pfglGetColorTableEXT;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetColorTableParameterivEXT;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetColorTableParameterfvEXT;

pfglColorTableEXT     glColorTableEXT;
pfglGetColorTableEXT      glGetColorTableEXT;
pfglGetColorTableParameterivEXT   glGetColorTableParameterivEXT;
pfglGetColorTableParameterfvEXT   glGetColorTableParameterfvEXT;

// 80 - GL_SGIX_list_priority
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetListParameterfvSGIX;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetListParameterivSGIX;
typedef GLvoid function(GLuint, GLenum, GLfloat) pfglListParameterfSGIX;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglListParameterfvSGIX;
typedef GLvoid function(GLuint, GLenum, GLint) pfglListParameteriSGIX;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglListParameterivSGIX;

pfglGetListParameterfvSGIX    glGetListParameterfvSGIX;
pfglGetListParameterivSGIX    glGetListParameterivSGIX;
pfglListParameterfSGIX      glListParameterfSGIX;
pfglListParameterfvSGIX     glListParameterfvSGIX;
pfglListParameteriSGIX      glListParameteriSGIX;
pfglListParameterivSGIX     glListParameterivSGIX;

// 94 - GL_EXT_index_material
typedef GLvoid function(GLenum, GLenum) pfglIndexMaterialEXT;

pfglIndexMaterialEXT      glIndexMaterialEXT;

// 95 - GL_EXT_index_func
typedef GLvoid function(GLenum, GLclampf) pfglIndexFuncEXT;

pfglIndexFuncEXT      glIndexFuncEXT;

// 97 - GL_EXT_compiled_vertex_array
typedef GLvoid function(GLint, GLsizei) pfglLockArraysEXT;
typedef GLvoid function() pfglUnlockArraysEXT;

pfglLockArraysEXT     glLockArraysEXT;
pfglUnlockArraysEXT     glUnlockArraysEXT;

// 98 - GL_EXT_cull_vertex
typedef GLvoid function(GLenum, GLdouble*) pfglCullParameterdvEXT;
typedef GLvoid function(GLenum, GLfloat*) pfglCullParameterfvEXT;

pfglCullParameterdvEXT      glCullParameterdvEXT;
pfglCullParameterfvEXT      glCullParameterfvEXT;

// 102 - GL_SGIX_fragment_lighting
typedef GLvoid function(GLenum, GLenum) pfglFragmentColorMaterialSGIX;
typedef GLvoid function(GLenum, GLenum, GLfloat) pfglFragmentLightfSGIX;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglFragmentLightfvSGIX;
typedef GLvoid function(GLenum, GLenum, GLint) pfglFragmentLightiSGIX;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglFragmentLightivSGIX;
typedef GLvoid function(GLenum, GLfloat) pfglFragmentLightModelfSGIX;
typedef GLvoid function(GLenum, GLfloat*) pfglFragmentLightModelfvSGIX;
typedef GLvoid function(GLenum, GLint) pfglFragmentLightModeliSGIX;
typedef GLvoid function(GLenum, GLint*) pfglFragmentLightModelivSGIX;
typedef GLvoid function(GLenum, GLenum, GLfloat) pfglFragmentMaterialfSGIX;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglFragmentMaterialfvSGIX;
typedef GLvoid function(GLenum, GLenum, GLint) pfglFragmentMaterialiSGIX;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglFragmentMaterialivSGIX;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetFragmentLightfvSGIX;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetFragmentLightivSGIX;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetFragmentMaterialfvSGIX;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetFragmentMaterialivSGIX;
typedef GLvoid function(GLenum, GLint) pfglLightEnviSGIX;

pfglFragmentColorMaterialSGIX   glFragmentColorMaterialSGIX;
pfglFragmentLightfSGIX      glFragmentLightfSGIX;
pfglFragmentLightfvSGIX     glFragmentLightfvSGIX;
pfglFragmentLightiSGIX      glFragmentLightiSGIX;
pfglFragmentLightivSGIX     glFragmentLightivSGIX;
pfglFragmentLightModelfSGIX   glFragmentLightModelfSGIX;
pfglFragmentLightModelfvSGIX    glFragmentLightModelfvSGIX;
pfglFragmentLightModeliSGIX   glFragmentLightModeliSGIX;
pfglFragmentLightModelivSGIX    glFragmentLightModelivSGIX;
pfglFragmentMaterialfSGIX   glFragmentMaterialfSGIX;
pfglFragmentMaterialfvSGIX    glFragmentMaterialfvSGIX;
pfglFragmentMaterialiSGIX   glFragmentMaterialiSGIX;
pfglFragmentMaterialivSGIX    glFragmentMaterialivSGIX;
pfglGetFragmentLightfvSGIX    glGetFragmentLightfvSGIX;
pfglGetFragmentLightivSGIX    glGetFragmentLightivSGIX;
pfglGetFragmentMaterialfvSGIX   glGetFragmentMaterialfvSGIX;
pfglGetFragmentMaterialivSGIX   glGetFragmentMaterialivSGIX;
pfglLightEnviSGIX     glLightEnviSGIX;

// 112 - GL_EXT_draw_range_elements
typedef GLvoid function(GLenum, GLuint, GLuint, GLsizei, GLenum, GLvoid*) pfglDrawRangeElementsEXT;

pfglDrawRangeElementsEXT    glDrawRangeElementsEXT;

// 117 - GL_EXT_light_texture
typedef GLvoid function(GLenum) pfglApplyTextureEXT;
typedef GLvoid function(GLenum) pfglTextureLightEXT;
typedef GLvoid function(GLenum, GLenum) pfglTextureMaterialEXT;

pfglApplyTextureEXT     glApplyTextureEXT;
pfglTextureLightEXT     glTextureLightEXT;
pfglTextureMaterialEXT      glTextureMaterialEXT;

// 132 - GL_SGIX_async
typedef GLvoid function(GLuint) pfglAsyncMarkerSGIX;
typedef GLint function(GLuint*) pfglFinishAsyncSGIX;
typedef GLint function(GLuint*) pfglPollAsyncSGIX;
typedef GLuint function(GLsizei) pfglGenAsyncMarkersSGIX;
typedef GLvoid function(GLuint, GLsizei) pfglDeleteAsyncMarkersSGIX;
typedef GLboolean function(GLuint) pfglIsAsyncMarkerSGIX;

pfglAsyncMarkerSGIX     glAsyncMarkerSGIX;
pfglFinishAsyncSGIX     glFinishAsyncSGIX;
pfglPollAsyncSGIX     glPollAsyncSGIX;
pfglGenAsyncMarkersSGIX     glGenAsyncMarkersSGIX;
pfglDeleteAsyncMarkersSGIX    glDeleteAsyncMarkersSGIX;
pfglIsAsyncMarkerSGIX     glIsAsyncMarkerSGIX;

// 136 - GL_INTEL_parallel_arrays
typedef GLvoid function(GLint, GLenum, GLvoid**) pfglVertexPointervINTEL;
typedef GLvoid function(GLenum, GLvoid**) pfglNormalPointervINTEL;
typedef GLvoid function(GLint, GLenum, GLvoid**) pfglColorPointervINTEL;
typedef GLvoid function(GLint, GLenum, GLvoid**) pfglTexCoordPointervINTEL;

pfglVertexPointervINTEL     glVertexPointervINTEL;
pfglNormalPointervINTEL     glNormalPointervINTEL;
pfglColorPointervINTEL      glColorPointervINTEL;
pfglTexCoordPointervINTEL   glTexCoordPointervINTEL;

// 138 - GL_EXT_pixel_transform
typedef GLvoid function(GLenum, GLenum, GLint) pfglPixelTransformParameteriEXT;
typedef GLvoid function(GLenum, GLenum, GLfloat) pfglPixelTransformParameterfEXT;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglPixelTransformParameterivEXT;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglPixelTransformParameterfvEXT;

pfglPixelTransformParameteriEXT   glPixelTransformParameteriEXT;
pfglPixelTransformParameterfEXT   glPixelTransformParameterfEXT;
pfglPixelTransformParameterivEXT  glPixelTransformParameterivEXT;
pfglPixelTransformParameterfvEXT  glPixelTransformParameterfvEXT;

// 145 - GL_EXT_secondary_color
typedef GLvoid function(GLbyte, GLbyte, GLbyte) pfglSecondaryColor3bEXT;
typedef GLvoid function(GLbyte*) pfglSecondaryColor3bvEXT;
typedef GLvoid function(GLdouble, GLdouble, GLdouble) pfglSecondaryColor3dEXT;
typedef GLvoid function(GLdouble*) pfglSecondaryColor3dvEXT;
typedef GLvoid function(GLfloat, GLfloat, GLfloat) pfglSecondaryColor3fEXT;
typedef GLvoid function(GLfloat*) pfglSecondaryColor3fvEXT;
typedef GLvoid function(GLint, GLint, GLint) pfglSecondaryColor3iEXT;
typedef GLvoid function(GLint*) pfglSecondaryColor3ivEXT;
typedef GLvoid function(GLshort, GLshort, GLshort) pfglSecondaryColor3sEXT;
typedef GLvoid function(GLshort*) pfglSecondaryColor3svEXT;
typedef GLvoid function(GLubyte, GLubyte, GLubyte) pfglSecondaryColor3ubEXT;
typedef GLvoid function(GLubyte*) pfglSecondaryColor3ubvEXT;
typedef GLvoid function(GLuint, GLuint, GLuint) pfglSecondaryColor3uiEXT;
typedef GLvoid function(GLuint*) pfglSecondaryColor3uivEXT;
typedef GLvoid function(GLushort, GLushort, GLushort) pfglSecondaryColor3usEXT;
typedef GLvoid function(GLushort*) pfglSecondaryColor3usvEXT;
typedef GLvoid function(GLint, GLenum, GLsizei, GLvoid*) pfglSecondaryColorPointerEXT;

pfglSecondaryColor3bEXT     glSecondaryColor3bEXT;
pfglSecondaryColor3bvEXT    glSecondaryColor3bvEXT;
pfglSecondaryColor3dEXT     glSecondaryColor3dEXT;
pfglSecondaryColor3dvEXT    glSecondaryColor3dvEXT;
pfglSecondaryColor3fEXT     glSecondaryColor3fEXT;
pfglSecondaryColor3fvEXT    glSecondaryColor3fvEXT;
pfglSecondaryColor3iEXT     glSecondaryColor3iEXT;
pfglSecondaryColor3ivEXT    glSecondaryColor3ivEXT;
pfglSecondaryColor3sEXT     glSecondaryColor3sEXT;
pfglSecondaryColor3svEXT    glSecondaryColor3svEXT;
pfglSecondaryColor3ubEXT    glSecondaryColor3ubEXT;
pfglSecondaryColor3ubvEXT   glSecondaryColor3ubvEXT;
pfglSecondaryColor3uiEXT    glSecondaryColor3uiEXT;
pfglSecondaryColor3uivEXT   glSecondaryColor3uivEXT;
pfglSecondaryColor3usEXT    glSecondaryColor3usEXT;
pfglSecondaryColor3usvEXT   glSecondaryColor3usvEXT;
pfglSecondaryColorPointerEXT    glSecondaryColorPointerEXT;

// 147 - GL_EXT_texture_perturb_normal
typedef GLvoid function(GLenum) pfglTextureNormalEXT;

pfglTextureNormalEXT      glTextureNormalEXT;

// 148 - GL_EXT_multi_draw_arrays
typedef GLvoid function(GLenum, GLint*, GLsizei*, GLsizei) pfglMultiDrawArraysEXT;
typedef GLvoid function(GLenum, GLsizei*, GLenum, GLvoid**, GLsizei) pfglMultiDrawElementsEXT;

pfglMultiDrawArraysEXT      glMultiDrawArraysEXT;
pfglMultiDrawElementsEXT    glMultiDrawElementsEXT;

// 149 - GL_EXT_fog_coord
typedef GLvoid function(GLfloat) pfglFogCoordfEXT;
typedef GLvoid function(GLfloat*) pfglFogCoordfvEXT;
typedef GLvoid function(GLdouble) pfglFogCoorddEXT;
typedef GLvoid function(GLdouble*) pfglFogCoorddvEXT;
typedef GLvoid function(GLenum, GLsizei, GLvoid*) pfglFogCoordPointerEXT;

pfglFogCoordfEXT      glFogCoordfEXT;
pfglFogCoordfvEXT     glFogCoordfvEXT;
pfglFogCoorddEXT      glFogCoorddEXT;
pfglFogCoorddvEXT     glFogCoorddvEXT;
pfglFogCoordPointerEXT      glFogCoordPointerEXT;

// 156 - GL_EXT_coordinate_frame
typedef GLvoid function(GLbyte, GLbyte, GLbyte) pfglTangent3bEXT;
typedef GLvoid function(GLbyte*) pfglTangent3bvEXT;
typedef GLvoid function(GLdouble, GLdouble, GLdouble) pfglTangent3dEXT;
typedef GLvoid function(GLdouble*) pfglTangent3dvEXT;
typedef GLvoid function(GLfloat, GLfloat, GLfloat) pfglTangent3fEXT;
typedef GLvoid function(GLfloat*) pfglTangent3fvEXT;
typedef GLvoid function(GLint, GLint, GLint) pfglTangent3iEXT;
typedef GLvoid function(GLint*) pfglTangent3ivEXT;
typedef GLvoid function(GLshort, GLshort, GLshort) pfglTangent3sEXT;
typedef GLvoid function(GLshort*) pfglTangent3svEXT;
typedef GLvoid function(GLbyte, GLbyte, GLbyte) pfglBinormal3bEXT;
typedef GLvoid function(GLbyte*) pfglBinormal3bvEXT;
typedef GLvoid function(GLdouble, GLdouble, GLdouble) pfglBinormal3dEXT;
typedef GLvoid function(GLdouble*) pfglBinormal3dvEXT;
typedef GLvoid function(GLfloat, GLfloat, GLfloat) pfglBinormal3fEXT;
typedef GLvoid function(GLfloat*) pfglBinormal3fvEXT;
typedef GLvoid function(GLint, GLint, GLint) pfglBinormal3iEXT;
typedef GLvoid function(GLint*) pfglBinormal3ivEXT;
typedef GLvoid function(GLshort, GLshort, GLshort) pfglBinormal3sEXT;
typedef GLvoid function(GLshort*) pfglBinormal3svEXT;
typedef GLvoid function(GLenum, GLsizei, GLvoid*) pfglTangentPointerEXT;
typedef GLvoid function(GLenum, GLsizei, GLvoid*) pfglBinormalPointerEXT;

pfglTangent3bEXT      glTangent3bEXT;
pfglTangent3bvEXT     glTangent3bvEXT;
pfglTangent3dEXT      glTangent3dEXT;
pfglTangent3dvEXT     glTangent3dvEXT;
pfglTangent3fEXT      glTangent3fEXT;
pfglTangent3fvEXT     glTangent3fvEXT;
pfglTangent3iEXT      glTangent3iEXT;
pfglTangent3ivEXT     glTangent3ivEXT;
pfglTangent3sEXT      glTangent3sEXT;
pfglTangent3svEXT     glTangent3svEXT;
pfglBinormal3bEXT     glBinormal3bEXT;
pfglBinormal3bvEXT      glBinormal3bvEXT;
pfglBinormal3dEXT     glBinormal3dEXT;
pfglBinormal3dvEXT      glBinormal3dvEXT;
pfglBinormal3fEXT     glBinormal3fEXT;
pfglBinormal3fvEXT      glBinormal3fvEXT;
pfglBinormal3iEXT     glBinormal3iEXT;
pfglBinormal3ivEXT      glBinormal3ivEXT;
pfglBinormal3sEXT     glBinormal3sEXT;
pfglBinormal3svEXT      glBinormal3svEXT;
pfglTangentPointerEXT     glTangentPointerEXT;
pfglBinormalPointerEXT      glBinormalPointerEXT;

// 163 - GL_SUNX_constant_data
typedef GLvoid function() pfglFinishTextureSUNX;

pfglFinishTextureSUNX     glFinishTextureSUNX;

// 164 - GL_SUN_global_alpha
typedef GLvoid function(GLbyte) pfglGlobalAlphaFactorbSUN;
typedef GLvoid function(GLshort) pfglGlobalAlphaFactorsSUN;
typedef GLvoid function(GLint) pfglGlobalAlphaFactoriSUN;
typedef GLvoid function(GLfloat) pfglGlobalAlphaFactorfSUN;
typedef GLvoid function(GLdouble) pfglGlobalAlphaFactordSUN;
typedef GLvoid function(GLubyte) pfglGlobalAlphaFactorubSUN;
typedef GLvoid function(GLushort) pfglGlobalAlphaFactorusSUN;
typedef GLvoid function(GLuint) pfglGlobalAlphaFactoruiSUN;

pfglGlobalAlphaFactorbSUN   glGlobalAlphaFactorbSUN;
pfglGlobalAlphaFactorsSUN   glGlobalAlphaFactorsSUN;
pfglGlobalAlphaFactoriSUN   glGlobalAlphaFactoriSUN;
pfglGlobalAlphaFactorfSUN   glGlobalAlphaFactorfSUN;
pfglGlobalAlphaFactordSUN   glGlobalAlphaFactordSUN;
pfglGlobalAlphaFactorubSUN    glGlobalAlphaFactorubSUN;
pfglGlobalAlphaFactorusSUN    glGlobalAlphaFactorusSUN;
pfglGlobalAlphaFactoruiSUN    glGlobalAlphaFactoruiSUN;

// 165 - GL_SUN_triangle_list
typedef GLvoid function(GLuint) pfglReplacementCodeuiSUN;
typedef GLvoid function(GLushort) pfglReplacementCodeusSUN;
typedef GLvoid function(GLubyte) pfglReplacementCodeubSUN;
typedef GLvoid function(GLuint*) pfglReplacementCodeuivSUN;
typedef GLvoid function(GLushort*) pfglReplacementCodeusvSUN;
typedef GLvoid function(GLubyte*) pfglReplacementCodeubvSUN;
typedef GLvoid function(GLenum, GLsizei, GLvoid**) pfglReplacementCodePointerSUN;

pfglReplacementCodeuiSUN    glReplacementCodeuiSUN;
pfglReplacementCodeusSUN    glReplacementCodeusSUN;
pfglReplacementCodeubSUN    glReplacementCodeubSUN;
pfglReplacementCodeuivSUN   glReplacementCodeuivSUN;
pfglReplacementCodeusvSUN   glReplacementCodeusvSUN;
pfglReplacementCodeubvSUN   glReplacementCodeubvSUN;
pfglReplacementCodePointerSUN   glReplacementCodePointerSUN;

// 166 - GL_SUN_vertex
typedef GLvoid function(GLubyte, GLubyte, GLubyte, GLubyte, GLfloat, GLfloat) pfglColor4ubVertex2fSUN;
typedef GLvoid function(GLubyte*, GLfloat*) pfglColor4ubVertex2fvSUN;
typedef GLvoid function(GLubyte, GLubyte, GLubyte, GLubyte, GLfloat, GLfloat, GLfloat) pfglColor4ubVertex3fSUN;
typedef GLvoid function(GLubyte*, GLfloat*) pfglColor4ubVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglColor3fVertex3fSUN;
typedef GLvoid function(GLfloat*, GLfloat*) pfglColor3fVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglNormal3fVertex3fSUN;
typedef GLvoid function(GLfloat*, GLfloat*) pfglNormal3fVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglColor4fNormal3fVertex3fSUN;
typedef GLvoid function(GLfloat*, GLfloat*, GLfloat*) pfglColor4fNormal3fVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglTexCoord2fVertex3fSUN;
typedef GLvoid function(GLfloat*, GLfloat*) pfglTexCoord2fVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglTexCoord4fVertex4fSUN;
typedef GLvoid function(GLfloat*, GLfloat*) pfglTexCoord4fVertex4fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLubyte, GLubyte, GLubyte, GLubyte, GLfloat, GLfloat, GLfloat) pfglTexCoord2fColor4ubVertex3fSUN;
typedef GLvoid function(GLfloat*, GLubyte*, GLfloat*) pfglTexCoord2fColor4ubVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglTexCoord2fColor3fVertex3fSUN;
typedef GLvoid function(GLfloat*, GLfloat*, GLfloat*) pfglTexCoord2fColor3fVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglTexCoord2fNormal3fVertex3fSUN;
typedef GLvoid function(GLfloat*, GLfloat*, GLfloat*) pfglTexCoord2fNormal3fVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglTexCoord2fColor4fNormal3fVertex3fSUN;
typedef GLvoid function(GLfloat*, GLfloat*, GLfloat*, GLfloat*) pfglTexCoord2fColor4fNormal3fVertex3fvSUN;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglTexCoord4fColor4fNormal3fVertex4fSUN;
typedef GLvoid function(GLfloat*, GLfloat*, GLfloat*, GLfloat*) pfglTexCoord4fColor4fNormal3fVertex4fvSUN;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat) pfglReplacementCodeuiVertex3fSUN;
typedef GLvoid function(GLuint*, GLfloat*) pfglReplacementCodeuiVertex3fvSUN;
typedef GLvoid function(GLuint, GLubyte, GLubyte, GLubyte, GLubyte, GLfloat, GLfloat, GLfloat) pfglReplacementCodeuiColor4ubVertex3fSUN;
typedef GLvoid function(GLuint*, GLubyte*, GLfloat*) pfglReplacementCodeuiColor4ubVertex3fvSUN;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglReplacementCodeuiColor3fVertex3fSUN;
typedef GLvoid function(GLuint*, GLfloat*, GLfloat*) pfglReplacementCodeuiColor3fVertex3fvSUN;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglReplacementCodeuiNormal3fVertex3fSUN;
typedef GLvoid function(GLuint*, GLfloat*, GLfloat*) pfglReplacementCodeuiNormal3fVertex3fvSUN;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglReplacementCodeuiColor4fNormal3fVertex3fSUN;
typedef GLvoid function(GLuint*, GLfloat*, GLfloat*, GLfloat*) pfglReplacementCodeuiColor4fNormal3fVertex3fvSUN;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglReplacementCodeuiTexCoord2fVertex3fSUN;
typedef GLvoid function(GLuint*, GLfloat*, GLfloat*) pfglReplacementCodeuiTexCoord2fVertex3fvSUN;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglReplacementCodeuiTexCoord2fNormal3fVertex3fSUN;
typedef GLvoid function(GLuint*, GLfloat*, GLfloat*, GLfloat*) pfglReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat, GLfloat) pfglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN;
typedef GLvoid function(GLuint*, GLfloat*, GLfloat*, GLfloat*, GLfloat*) pfglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN;

pfglColor4ubVertex2fSUN     glColor4ubVertex2fSUN;
pfglColor4ubVertex2fvSUN    glColor4ubVertex2fvSUN;
pfglColor4ubVertex3fSUN     glColor4ubVertex3fSUN;
pfglColor4ubVertex3fvSUN    glColor4ubVertex3fvSUN;
pfglColor3fVertex3fSUN      glColor3fVertex3fSUN;
pfglColor3fVertex3fvSUN     glColor3fVertex3fvSUN;
pfglNormal3fVertex3fSUN     glNormal3fVertex3fSUN;
pfglNormal3fVertex3fvSUN    glNormal3fVertex3fvSUN;
pfglColor4fNormal3fVertex3fSUN    glColor4fNormal3fVertex3fSUN;
pfglColor4fNormal3fVertex3fvSUN   glColor4fNormal3fVertex3fvSUN;
pfglTexCoord2fVertex3fSUN   glTexCoord2fVertex3fSUN;
pfglTexCoord2fVertex3fvSUN    glTexCoord2fVertex3fvSUN;
pfglTexCoord4fVertex4fSUN   glTexCoord4fVertex4fSUN;
pfglTexCoord4fVertex4fvSUN    glTexCoord4fVertex4fvSUN;
pfglTexCoord2fColor4ubVertex3fSUN glTexCoord2fColor4ubVertex3fSUN;
pfglTexCoord2fColor4ubVertex3fvSUN  glTexCoord2fColor4ubVertex3fvSUN;
pfglTexCoord2fColor3fVertex3fSUN  glTexCoord2fColor3fVertex3fSUN;
pfglTexCoord2fColor3fVertex3fvSUN glTexCoord2fColor3fVertex3fvSUN;
pfglTexCoord2fNormal3fVertex3fSUN glTexCoord2fNormal3fVertex3fSUN;
pfglTexCoord2fNormal3fVertex3fvSUN  glTexCoord2fNormal3fVertex3fvSUN;
pfglTexCoord2fColor4fNormal3fVertex3fSUN glTexCoord2fColor4fNormal3fVertex3fSUN;
pfglTexCoord2fColor4fNormal3fVertex3fvSUN glTexCoord2fColor4fNormal3fVertex3fvSUN;
pfglTexCoord4fColor4fNormal3fVertex4fSUN glTexCoord4fColor4fNormal3fVertex4fSUN;
pfglTexCoord4fColor4fNormal3fVertex4fvSUN glTexCoord4fColor4fNormal3fVertex4fvSUN;
pfglReplacementCodeuiVertex3fSUN  glReplacementCodeuiVertex3fSUN;
pfglReplacementCodeuiVertex3fvSUN glReplacementCodeuiVertex3fvSUN;
pfglReplacementCodeuiColor4ubVertex3fSUN glReplacementCodeuiColor4ubVertex3fSUN;
pfglReplacementCodeuiColor4ubVertex3fvSUN glReplacementCodeuiColor4ubVertex3fvSUN;
pfglReplacementCodeuiColor3fVertex3fSUN glReplacementCodeuiColor3fVertex3fSUN;
pfglReplacementCodeuiColor3fVertex3fvSUN glReplacementCodeuiColor3fVertex3fvSUN;
pfglReplacementCodeuiNormal3fVertex3fSUN glReplacementCodeuiNormal3fVertex3fSUN;
pfglReplacementCodeuiNormal3fVertex3fvSUN glReplacementCodeuiNormal3fVertex3fvSUN;
pfglReplacementCodeuiColor4fNormal3fVertex3fSUN glReplacementCodeuiColor4fNormal3fVertex3fSUN;
pfglReplacementCodeuiColor4fNormal3fVertex3fvSUN glReplacementCodeuiColor4fNormal3fVertex3fvSUN;
pfglReplacementCodeuiTexCoord2fVertex3fSUN glReplacementCodeuiTexCoord2fVertex3fSUN;
pfglReplacementCodeuiTexCoord2fVertex3fvSUN glReplacementCodeuiTexCoord2fVertex3fvSUN;
pfglReplacementCodeuiTexCoord2fNormal3fVertex3fSUN glReplacementCodeuiTexCoord2fNormal3fVertex3fSUN;
pfglReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN glReplacementCodeuiTexCoord2fNormal3fVertex3fvSUN;
pfglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fSUN;
pfglReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN glReplacementCodeuiTexCoord2fColor4fNormal3fVertex3fvSUN;

// 173 - GL_EXT_blend_func_separate
typedef GLvoid function(GLenum, GLenum, GLenum, GLenum) pfglBlendFuncSeparateEXT;

pfglBlendFuncSeparateEXT    glBlendFuncSeparateEXT;

// ? - GL_INGR_blend_func_separate
typedef GLvoid function(GLenum, GLenum, GLenum, GLenum) pfglBlendFuncSeparateINGR;

pfglBlendFuncSeparateINGR   glBlendFuncSeparateINGR;

// 188 - GL_EXT_vertex_weighting
typedef GLvoid function(GLfloat) pfglVertexWeightfEXT;
typedef GLvoid function(GLfloat*) pfglVertexWeightfvEXT;
typedef GLvoid function(GLsizei, GLenum, GLsizei, GLvoid*) pfglVertexWeightPointerEXT;

pfglVertexWeightfEXT      glVertexWeightfEXT;
pfglVertexWeightfvEXT     glVertexWeightfvEXT;
pfglVertexWeightPointerEXT    glVertexWeightPointerEXT;

// 190 - GL_NV_vertex_array_range
typedef GLvoid function() pfglFlushVertexArrayRangeNV;
typedef GLvoid function(GLsizei, GLvoid*) pfglVertexArrayRangeNV;

pfglFlushVertexArrayRangeNV   glFlushVertexArrayRangeNV;
pfglVertexArrayRangeNV      glVertexArrayRangeNV;

// 191 - GL_NV_register_combiners
typedef GLvoid function(GLenum, GLfloat*) pfglCombinerParameterfvNV;
typedef GLvoid function(GLenum, GLfloat) pfglCombinerParameterfNV;
typedef GLvoid function(GLenum, GLint*) pfglCombinerParameterivNV;
typedef GLvoid function(GLenum, GLint) pfglCombinerParameteriNV;
typedef GLvoid function(GLenum, GLenum, GLenum, GLenum, GLenum, GLenum) pfglCombinerInputNV;
typedef GLvoid function(GLenum, GLenum, GLenum, GLenum, GLenum, GLenum, GLenum, GLboolean, GLboolean, GLboolean) pfglCombinerOutputNV;
typedef GLvoid function(GLenum, GLenum, GLenum, GLenum) pfglFinalCombinerInputNV;
typedef GLvoid function(GLenum, GLenum, GLenum, GLenum, GLfloat*) pfglGetCombinerInputParameterfvNV;
typedef GLvoid function(GLenum, GLenum, GLenum, GLenum, GLint*) pfglGetCombinerInputParameterivNV;
typedef GLvoid function(GLenum, GLenum, GLenum, GLfloat*) pfglGetCombinerOutputParameterfvNV;
typedef GLvoid function(GLenum, GLenum, GLenum, GLint*) pfglGetCombinerOutputParameterivNV;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetFinalCombinerInputParameterfvNV;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetFinalCombinerInputParameterivNV;

pfglCombinerParameterfvNV   glCombinerParameterfvNV;
pfglCombinerParameterfNV    glCombinerParameterfNV;
pfglCombinerParameterivNV   glCombinerParameterivNV;
pfglCombinerParameteriNV    glCombinerParameteriNV;
pfglCombinerInputNV     glCombinerInputNV;
pfglCombinerOutputNV      glCombinerOutputNV;
pfglFinalCombinerInputNV    glFinalCombinerInputNV;
pfglGetCombinerInputParameterfvNV glGetCombinerInputParameterfvNV;
pfglGetCombinerInputParameterivNV glGetCombinerInputParameterivNV;
pfglGetCombinerOutputParameterfvNV  glGetCombinerOutputParameterfvNV;
pfglGetCombinerOutputParameterivNV  glGetCombinerOutputParameterivNV;
pfglGetFinalCombinerInputParameterfvNV  glGetFinalCombinerInputParameterfvNV;
pfglGetFinalCombinerInputParameterivNV  glGetFinalCombinerInputParameterivNV;

// 196 - GL_MESA_resize_buffers
typedef GLvoid function() pfglResizeBuffersMESA;

pfglResizeBuffersMESA   glResizeBuffersMESA;

// 197 - GL_MESA_window_pos
typedef GLvoid function(GLdouble, GLdouble) pfglWindowPos2dMESA;
typedef GLvoid function(GLdouble*) pfglWindowPos2dvMESA;
typedef GLvoid function(GLfloat, GLfloat) pfglWindowPos2fMESA;
typedef GLvoid function(GLfloat*) pfglWindowPos2fvMESA;
typedef GLvoid function(GLint, GLint) pfglWindowPos2iMESA;
typedef GLvoid function(GLint*) pfglWindowPos2ivMESA;
typedef GLvoid function(GLshort, GLshort) pfglWindowPos2sMESA;
typedef GLvoid function(GLshort*) pfglWindowPos2svMESA;
typedef GLvoid function(GLdouble, GLdouble, GLdouble) pfglWindowPos3dMESA;
typedef GLvoid function(GLdouble*) pfglWindowPos3dvMESA;
typedef GLvoid function(GLfloat, GLfloat, GLfloat) pfglWindowPos3fMESA;
typedef GLvoid function(GLfloat*) pfglWindowPos3fvMESA;
typedef GLvoid function(GLint, GLint, GLint) pfglWindowPos3iMESA;
typedef GLvoid function(GLint*) pfglWindowPos3ivMESA;
typedef GLvoid function(GLshort, GLshort, GLshort) pfglWindowPos3sMESA;
typedef GLvoid function(GLshort*) pfglWindowPos3svMESA;
typedef GLvoid function(GLdouble, GLdouble, GLdouble, GLdouble) pfglWindowPos4dMESA;
typedef GLvoid function(GLdouble*) pfglWindowPos4dvMESA;
typedef GLvoid function(GLfloat, GLfloat, GLfloat, GLfloat) pfglWindowPos4fMESA;
typedef GLvoid function(GLfloat*) pfglWindowPos4fvMESA;
typedef GLvoid function(GLint, GLint, GLint, GLint) pfglWindowPos4iMESA;
typedef GLvoid function(GLint*) pfglWindowPos4ivMESA;
typedef GLvoid function(GLshort, GLshort, GLshort, GLshort) pfglWindowPos4sMESA;
typedef GLvoid function(GLshort*) pfglWindowPos4svMESA;

pfglWindowPos2dMESA     glWindowPos2dMESA;
pfglWindowPos2dvMESA      glWindowPos2dvMESA;
pfglWindowPos2fMESA     glWindowPos2fMESA;
pfglWindowPos2fvMESA      glWindowPos2fvMESA;
pfglWindowPos2iMESA     glWindowPos2iMESA;
pfglWindowPos2ivMESA      glWindowPos2ivMESA;
pfglWindowPos2sMESA     glWindowPos2sMESA;
pfglWindowPos2svMESA      glWindowPos2svMESA;
pfglWindowPos3dMESA     glWindowPos3dMESA;
pfglWindowPos3dvMESA      glWindowPos3dvMESA;
pfglWindowPos3fMESA     glWindowPos3fMESA;
pfglWindowPos3fvMESA      glWindowPos3fvMESA;
pfglWindowPos3iMESA     glWindowPos3iMESA;
pfglWindowPos3ivMESA      glWindowPos3ivMESA;
pfglWindowPos3sMESA     glWindowPos3sMESA;
pfglWindowPos3svMESA      glWindowPos3svMESA;
pfglWindowPos4dMESA     glWindowPos4dMESA;
pfglWindowPos4dvMESA      glWindowPos4dvMESA;
pfglWindowPos4fMESA     glWindowPos4fMESA;
pfglWindowPos4fvMESA      glWindowPos4fvMESA;
pfglWindowPos4iMESA     glWindowPos4iMESA;
pfglWindowPos4ivMESA      glWindowPos4ivMESA;
pfglWindowPos4sMESA     glWindowPos4sMESA;
pfglWindowPos4svMESA      glWindowPos4svMESA;

// 200 - GL_IBM_multimode_draw_arrays
typedef GLvoid function(GLenum*, GLint*, GLsizei*, GLsizei, GLint) pfglMultiModeDrawArraysIBM;
typedef GLvoid function(GLenum*, GLsizei*, GLenum, GLvoid**, GLsizei, GLint) pfglMultiModeDrawElementsIBM;

pfglMultiModeDrawArraysIBM    glMultiModeDrawArraysIBM;
pfglMultiModeDrawElementsIBM    glMultiModeDrawElementsIBM;

// 201 - GL_IBM_vertex_array_lists
typedef GLvoid function(GLint, GLenum, GLint, GLvoid**, GLint) pfglColorPointerListIBM;
typedef GLvoid function(GLint, GLenum, GLint, GLvoid**, GLint) pfglSecondaryColorPointerListIBM;
typedef GLvoid function(GLint, GLboolean**, GLint) pfglEdgeFlagPointerListIBM;
typedef GLvoid function(GLenum, GLint, GLvoid**, GLint) pfglFogCoordPointerListIBM;
typedef GLvoid function(GLenum, GLint, GLvoid**, GLint) pfglIndexPointerListIBM;
typedef GLvoid function(GLenum, GLint, GLvoid**, GLint) pfglNormalPointerListIBM;
typedef GLvoid function(GLint, GLenum, GLint, GLvoid**, GLint) pfglTexCoordPointerListIBM;
typedef GLvoid function(GLint, GLenum, GLint, GLvoid**, GLint) pfglVertexPointerListIBM;

pfglColorPointerListIBM     glColorPointerListIBM;
pfglSecondaryColorPointerListIBM  glSecondaryColorPointerListIBM;
pfglEdgeFlagPointerListIBM    glEdgeFlagPointerListIBM;
pfglFogCoordPointerListIBM    glFogCoordPointerListIBM;
pfglIndexPointerListIBM     glIndexPointerListIBM;
pfglNormalPointerListIBM    glNormalPointerListIBM;
pfglTexCoordPointerListIBM    glTexCoordPointerListIBM;
pfglVertexPointerListIBM    glVertexPointerListIBM;

// 208 - GL_3DFX_tbuffer
typedef GLvoid function(GLuint) pfglTbufferMask3DFX;

pfglTbufferMask3DFX     glTbufferMask3DFX;

// 209 - GL_EXT_multisample
typedef GLvoid function(GLclampf, GLboolean) pfglSampleMaskEXT;
typedef GLvoid function(GLenum) pfglSamplePatternEXT;

pfglSampleMaskEXT     glSampleMaskEXT;
pfglSamplePatternEXT      glSamplePatternEXT;

// 214 - GL_SGIS_texture_color_mask
typedef GLvoid function(GLboolean, GLboolean, GLboolean, GLboolean) pfglTextureColorMaskSGIS;

pfglTextureColorMaskSGIS    glTextureColorMaskSGIS;

// ? - GL_SGIX_igloo_interface
typedef GLvoid function(GLenum, GLvoid*) pfglIglooInterfaceSGIX;

pfglIglooInterfaceSGIX      glIglooInterfaceSGIX;

// 222 - GL_NV_fence
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteFencesNV;
typedef GLvoid function(GLsizei, GLuint*) pfglGenFencesNV;
typedef GLboolean function(GLuint) pfglIsFenceNV;
typedef GLboolean function(GLuint) pfglTestFenceNV;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetFenceivNV;
typedef GLvoid function(GLuint) pfglFinishFenceNV;
typedef GLvoid function(GLuint, GLenum) pfglSetFenceNV;

pfglDeleteFencesNV      glDeleteFencesNV;
pfglGenFencesNV       glGenFencesNV;
pfglIsFenceNV       glIsFenceNV;
pfglTestFenceNV       glTestFenceNV;
pfglGetFenceivNV      glGetFenceivNV;
pfglFinishFenceNV     glFinishFenceNV;
pfglSetFenceNV        glSetFenceNV;

// 225 - GL_NV_evaluators
typedef GLvoid function(GLenum, GLuint, GLenum, GLsizei, GLsizei, GLint, GLint, GLboolean, GLvoid*) pfglMapControlPointsNV;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglMapParameterivNV;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglMapParameterfvNV;
typedef GLvoid function(GLenum, GLuint, GLenum, GLsizei, GLsizei, GLboolean, GLvoid*) pfglGetMapControlPointsNV;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetMapParameterivNV;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetMapParameterfvNV;
typedef GLvoid function(GLenum, GLuint, GLenum, GLint*) pfglGetMapAttribParameterivNV;
typedef GLvoid function(GLenum, GLuint, GLenum, GLfloat*) pfglGetMapAttribParameterfvNV;
typedef GLvoid function(GLenum, GLenum) pfglEvalMapsNV;

pfglMapControlPointsNV      glMapControlPointsNV;
pfglMapParameterivNV      glMapParameterivNV;
pfglMapParameterfvNV      glMapParameterfvNV;
pfglGetMapControlPointsNV   glGetMapControlPointsNV;
pfglGetMapParameterivNV     glGetMapParameterivNV;
pfglGetMapParameterfvNV     glGetMapParameterfvNV;
pfglGetMapAttribParameterivNV   glGetMapAttribParameterivNV;
pfglGetMapAttribParameterfvNV   glGetMapAttribParameterfvNV;
pfglEvalMapsNV        glEvalMapsNV;

// 227 - GL_NV_register_combiners2
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglCombinerStageParameterfvNV;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetCombinerStageParameterfvNV;

pfglCombinerStageParameterfvNV    glCombinerStageParameterfvNV;
pfglGetCombinerStageParameterfvNV glGetCombinerStageParameterfvNV;

// 233 - GL_NV_vertex_program
typedef GLboolean function(GLsizei, GLuint*, GLboolean*) pfglAreProgramsResidentNV;
typedef GLvoid function(GLenum, GLuint) pfglBindProgramNV;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteProgramsNV;
typedef GLvoid function(GLenum, GLuint, GLfloat*) pfglExecuteProgramNV;
typedef GLvoid function(GLsizei, GLuint*) pfglGenProgramsNV;
typedef GLvoid function(GLenum, GLuint, GLenum, GLdouble*) pfglGetProgramParameterdvNV;
typedef GLvoid function(GLenum, GLuint, GLenum, GLfloat*) pfglGetProgramParameterfvNV;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetProgramivNV;
typedef GLvoid function(GLuint, GLenum, GLubyte*) pfglGetProgramStringNV;
typedef GLvoid function(GLenum, GLuint, GLenum, GLint*) pfglGetTrackMatrixivNV;
typedef GLvoid function(GLuint, GLenum, GLdouble*) pfglGetVertexAttribdvNV;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetVertexAttribfvNV;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetVertexAttribivNV;
typedef GLvoid function(GLuint, GLenum, GLvoid**) pfglGetVertexAttribPointervNV;
typedef GLboolean function(GLuint) pfglIsProgramNV;
typedef GLvoid function(GLenum, GLuint, GLsizei, GLubyte*) pfglLoadProgramNV;
typedef GLvoid function(GLenum, GLuint, GLdouble, GLdouble, GLdouble, GLdouble) pfglProgramParameter4dNV;
typedef GLvoid function(GLenum, GLuint, GLdouble*) pfglProgramParameter4dvNV;
typedef GLvoid function(GLenum, GLuint, GLfloat, GLfloat, GLfloat, GLfloat) pfglProgramParameter4fNV;
typedef GLvoid function(GLenum, GLuint, GLfloat*) pfglProgramParameter4fvNV;
typedef GLvoid function(GLenum, GLuint, GLuint, GLdouble*) pfglProgramParameters4dvNV;
typedef GLvoid function(GLenum, GLuint, GLuint, GLfloat*) pfglProgramParameters4fvNV;
typedef GLvoid function(GLsizei, GLuint*) pfglRequestResidentProgramsNV;
typedef GLvoid function(GLenum, GLuint, GLenum, GLenum) pfglTrackMatrixNV;
typedef GLvoid function(GLuint, GLint, GLenum, GLsizei, GLvoid*) pfglVertexAttribPointerNV;
typedef GLvoid function(GLuint, GLdouble) pfglVertexAttrib1dNV;
typedef GLvoid function(GLuint, GLdouble*) pfglVertexAttrib1dvNV;
typedef GLvoid function(GLuint, GLfloat) pfglVertexAttrib1fNV;
typedef GLvoid function(GLuint, GLfloat*) pfglVertexAttrib1fvNV;
typedef GLvoid function(GLuint, GLshort) pfglVertexAttrib1sNV;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib1svNV;
typedef GLvoid function(GLuint, GLdouble, GLdouble) pfglVertexAttrib2dNV;
typedef GLvoid function(GLuint, GLdouble*) pfglVertexAttrib2dvNV;
typedef GLvoid function(GLuint, GLfloat, GLfloat) pfglVertexAttrib2fNV;
typedef GLvoid function(GLuint, GLfloat*) pfglVertexAttrib2fvNV;
typedef GLvoid function(GLuint, GLshort, GLshort) pfglVertexAttrib2sNV;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib2svNV;
typedef GLvoid function(GLuint, GLdouble, GLdouble, GLdouble) pfglVertexAttrib3dNV;
typedef GLvoid function(GLuint, GLdouble*) pfglVertexAttrib3dvNV;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat) pfglVertexAttrib3fNV;
typedef GLvoid function(GLuint, GLfloat*) pfglVertexAttrib3fvNV;
typedef GLvoid function(GLuint, GLshort, GLshort, GLshort) pfglVertexAttrib3sNV;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib3svNV;
typedef GLvoid function(GLuint, GLdouble, GLdouble, GLdouble, GLdouble) pfglVertexAttrib4dNV;
typedef GLvoid function(GLuint, GLdouble*) pfglVertexAttrib4dvNV;
typedef GLvoid function(GLuint, GLfloat, GLfloat, GLfloat, GLfloat) pfglVertexAttrib4fNV;
typedef GLvoid function(GLuint, GLfloat*) pfglVertexAttrib4fvNV;
typedef GLvoid function(GLuint, GLshort, GLshort, GLshort, GLshort) pfglVertexAttrib4sNV;
typedef GLvoid function(GLuint, GLshort*) pfglVertexAttrib4svNV;
typedef GLvoid function(GLuint, GLubyte, GLubyte, GLubyte, GLubyte) pfglVertexAttrib4ubNV;
typedef GLvoid function(GLuint, GLubyte*) pfglVertexAttrib4ubvNV;
typedef GLvoid function(GLuint, GLsizei, GLdouble*) pfglVertexAttribs1dvNV;
typedef GLvoid function(GLuint, GLsizei, GLfloat*) pfglVertexAttribs1fvNV;
typedef GLvoid function(GLuint, GLsizei, GLshort*) pfglVertexAttribs1svNV;
typedef GLvoid function(GLuint, GLsizei, GLdouble*) pfglVertexAttribs2dvNV;
typedef GLvoid function(GLuint, GLsizei, GLfloat*) pfglVertexAttribs2fvNV;
typedef GLvoid function(GLuint, GLsizei, GLshort*) pfglVertexAttribs2svNV;
typedef GLvoid function(GLuint, GLsizei, GLdouble*) pfglVertexAttribs3dvNV;
typedef GLvoid function(GLuint, GLsizei, GLfloat*) pfglVertexAttribs3fvNV;
typedef GLvoid function(GLuint, GLsizei, GLshort*) pfglVertexAttribs3svNV;
typedef GLvoid function(GLuint, GLsizei, GLdouble*) pfglVertexAttribs4dvNV;
typedef GLvoid function(GLuint, GLsizei, GLfloat*) pfglVertexAttribs4fvNV;
typedef GLvoid function(GLuint, GLsizei, GLshort*) pfglVertexAttribs4svNV;
typedef GLvoid function(GLuint, GLsizei, GLubyte*) pfglVertexAttribs4ubvNV;

pfglAreProgramsResidentNV   glAreProgramsResidentNV;
pfglBindProgramNV     glBindProgramNV;
pfglDeleteProgramsNV      glDeleteProgramsNV;
pfglExecuteProgramNV      glExecuteProgramNV;
pfglGenProgramsNV     glGenProgramsNV;
pfglGetProgramParameterdvNV   glGetProgramParameterdvNV;
pfglGetProgramParameterfvNV   glGetProgramParameterfvNV;
pfglGetProgramivNV      glGetProgramivNV;
pfglGetProgramStringNV      glGetProgramStringNV;
pfglGetTrackMatrixivNV      glGetTrackMatrixivNV;
pfglGetVertexAttribdvNV     glGetVertexAttribdvNV;
pfglGetVertexAttribfvNV     glGetVertexAttribfvNV;
pfglGetVertexAttribivNV     glGetVertexAttribivNV;
pfglGetVertexAttribPointervNV   glGetVertexAttribPointervNV;
pfglIsProgramNV       glIsProgramNV;
pfglLoadProgramNV     glLoadProgramNV;
pfglProgramParameter4dNV    glProgramParameter4dNV;
pfglProgramParameter4dvNV   glProgramParameter4dvNV;
pfglProgramParameter4fNV    glProgramParameter4fNV;
pfglProgramParameter4fvNV   glProgramParameter4fvNV;
pfglProgramParameters4dvNV    glProgramParameters4dvNV;
pfglProgramParameters4fvNV    glProgramParameters4fvNV;
pfglRequestResidentProgramsNV   glRequestResidentProgramsNV;
pfglTrackMatrixNV     glTrackMatrixNV;
pfglVertexAttribPointerNV   glVertexAttribPointerNV;
pfglVertexAttrib1dNV      glVertexAttrib1dNV;
pfglVertexAttrib1dvNV     glVertexAttrib1dvNV;
pfglVertexAttrib1fNV      glVertexAttrib1fNV;
pfglVertexAttrib1fvNV     glVertexAttrib1fvNV;
pfglVertexAttrib1sNV      glVertexAttrib1sNV;
pfglVertexAttrib1svNV     glVertexAttrib1svNV;
pfglVertexAttrib2dNV      glVertexAttrib2dNV;
pfglVertexAttrib2dvNV     glVertexAttrib2dvNV;
pfglVertexAttrib2fNV      glVertexAttrib2fNV;
pfglVertexAttrib2fvNV     glVertexAttrib2fvNV;
pfglVertexAttrib2sNV      glVertexAttrib2sNV;
pfglVertexAttrib2svNV     glVertexAttrib2svNV;
pfglVertexAttrib3dNV      glVertexAttrib3dNV;
pfglVertexAttrib3dvNV     glVertexAttrib3dvNV;
pfglVertexAttrib3fNV      glVertexAttrib3fNV;
pfglVertexAttrib3fvNV     glVertexAttrib3fvNV;
pfglVertexAttrib3sNV      glVertexAttrib3sNV;
pfglVertexAttrib3svNV     glVertexAttrib3svNV;
pfglVertexAttrib4dNV      glVertexAttrib4dNV;
pfglVertexAttrib4dvNV     glVertexAttrib4dvNV;
pfglVertexAttrib4fNV      glVertexAttrib4fNV;
pfglVertexAttrib4fvNV     glVertexAttrib4fvNV;
pfglVertexAttrib4sNV      glVertexAttrib4sNV;
pfglVertexAttrib4svNV     glVertexAttrib4svNV;
pfglVertexAttrib4ubNV     glVertexAttrib4ubNV;
pfglVertexAttrib4ubvNV      glVertexAttrib4ubvNV;
pfglVertexAttribs1dvNV      glVertexAttribs1dvNV;
pfglVertexAttribs1fvNV      glVertexAttribs1fvNV;
pfglVertexAttribs1svNV      glVertexAttribs1svNV;
pfglVertexAttribs2dvNV      glVertexAttribs2dvNV;
pfglVertexAttribs2fvNV      glVertexAttribs2fvNV;
pfglVertexAttribs2svNV      glVertexAttribs2svNV;
pfglVertexAttribs3dvNV      glVertexAttribs3dvNV;
pfglVertexAttribs3fvNV      glVertexAttribs3fvNV;
pfglVertexAttribs3svNV      glVertexAttribs3svNV;
pfglVertexAttribs4dvNV      glVertexAttribs4dvNV;
pfglVertexAttribs4fvNV      glVertexAttribs4fvNV;
pfglVertexAttribs4svNV      glVertexAttribs4svNV;
pfglVertexAttribs4ubvNV     glVertexAttribs4ubvNV;

// 244 - GL_ATI_envmap_bumpmap
typedef GLvoid function(GLenum, GLint*) pfglTexBumpParameterivATI;
typedef GLvoid function(GLenum, GLfloat*) pfglTexBumpParameterfvATI;
typedef GLvoid function(GLenum, GLint*) pfglGetTexBumpParameterivATI;
typedef GLvoid function(GLenum, GLfloat*) pfglGetTexBumpParameterfvATI;

pfglTexBumpParameterivATI   glTexBumpParameterivATI;
pfglTexBumpParameterfvATI   glTexBumpParameterfvATI;
pfglGetTexBumpParameterivATI    glGetTexBumpParameterivATI;
pfglGetTexBumpParameterfvATI    glGetTexBumpParameterfvATI;

// 245 - GL_ATI_fragment_shader
typedef GLuint function(GLuint) pfglGenFragmentShadersATI;
typedef GLvoid function(GLuint) pfglBindFragmentShaderATI;
typedef GLvoid function(GLuint) pfglDeleteFragmentShaderATI;
typedef GLvoid function() pfglBeginFragmentShaderATI;
typedef GLvoid function() pfglEndFragmentShaderATI;
typedef GLvoid function(GLuint, GLuint, GLenum) pfglPassTexCoordATI;
typedef GLvoid function(GLuint, GLuint, GLenum) pfglSampleMapATI;
typedef GLvoid function(GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint) pfglColorFragmentOp1ATI;
typedef GLvoid function(GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint) pfglColorFragmentOp2ATI;
typedef GLvoid function(GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint) pfglColorFragmentOp3ATI;
typedef GLvoid function(GLenum, GLuint, GLuint, GLuint, GLuint, GLuint) pfglAlphaFragmentOp1ATI;
typedef GLvoid function(GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint) pfglAlphaFragmentOp2ATI;
typedef GLvoid function(GLenum, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint, GLuint) pfglAlphaFragmentOp3ATI;
typedef GLvoid function(GLuint, GLfloat*) pfglSetFragmentShaderConstantATI;

pfglGenFragmentShadersATI   glGenFragmentShadersATI;
pfglBindFragmentShaderATI   glBindFragmentShaderATI;
pfglDeleteFragmentShaderATI   glDeleteFragmentShaderATI;
pfglBeginFragmentShaderATI    glBeginFragmentShaderATI;
pfglEndFragmentShaderATI    glEndFragmentShaderATI;
pfglPassTexCoordATI     glPassTexCoordATI;
pfglSampleMapATI      glSampleMapATI;
pfglColorFragmentOp1ATI     glColorFragmentOp1ATI;
pfglColorFragmentOp2ATI     glColorFragmentOp2ATI;
pfglColorFragmentOp3ATI     glColorFragmentOp3ATI;
pfglAlphaFragmentOp1ATI     glAlphaFragmentOp1ATI;
pfglAlphaFragmentOp2ATI     glAlphaFragmentOp2ATI;
pfglAlphaFragmentOp3ATI     glAlphaFragmentOp3ATI;
pfglSetFragmentShaderConstantATI  glSetFragmentShaderConstantATI;

// 246 - GL_ATI_pn_triangles
typedef GLvoid function(GLenum, GLint) pfglPNTrianglesiATI;
typedef GLvoid function(GLenum, GLfloat) pfglPNTrianglesfATI;

pfglPNTrianglesiATI     glPNTrianglesiATI;
pfglPNTrianglesfATI     glPNTrianglesfATI;

// 247 - GL_ATI_vertex_array_object
typedef GLuint function(GLsizei, GLvoid*, GLenum) pfglNewObjectBufferATI;
typedef GLboolean function(GLuint) pfglIsObjectBufferATI;
typedef GLvoid function(GLuint, GLuint, GLsizei, GLvoid*, GLenum) pfglUpdateObjectBufferATI;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetObjectBufferfvATI;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetObjectBufferivATI;
typedef GLvoid function(GLuint) pfglFreeObjectBufferATI;
typedef GLvoid function(GLenum, GLint, GLenum, GLsizei, GLuint, GLuint) pfglArrayObjectATI;
typedef GLvoid function(GLenum, GLenum, GLfloat*) pfglGetArrayObjectfvATI;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetArrayObjectivATI;
typedef GLvoid function(GLuint, GLenum, GLsizei, GLuint, GLuint) pfglVariantArrayObjectATI;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetVariantArrayObjectfvATI;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetVariantArrayObjectivATI;

pfglNewObjectBufferATI      glNewObjectBufferATI;
pfglIsObjectBufferATI     glIsObjectBufferATI;
pfglUpdateObjectBufferATI   glUpdateObjectBufferATI;
pfglGetObjectBufferfvATI    glGetObjectBufferfvATI;
pfglGetObjectBufferivATI    glGetObjectBufferivATI;
pfglFreeObjectBufferATI     glFreeObjectBufferATI;
pfglArrayObjectATI      glArrayObjectATI;
pfglGetArrayObjectfvATI     glGetArrayObjectfvATI;
pfglGetArrayObjectivATI     glGetArrayObjectivATI;
pfglVariantArrayObjectATI   glVariantArrayObjectATI;
pfglGetVariantArrayObjectfvATI    glGetVariantArrayObjectfvATI;
pfglGetVariantArrayObjectivATI    glGetVariantArrayObjectivATI;

// 248 - GL_EXT_vertex_shader
typedef GLvoid function() pfglBeginVertexShaderEXT;
typedef GLvoid function() pfglEndVertexShaderEXT;
typedef GLvoid function(GLuint) pfglBindVertexShaderEXT;
typedef GLuint function(GLuint) pfglGenVertexShadersEXT;
typedef GLvoid function(GLuint) pfglDeleteVertexShaderEXT;
typedef GLvoid function(GLenum, GLuint, GLuint) pfglShaderOp1EXT;
typedef GLvoid function(GLenum, GLuint, GLuint, GLuint) pfglShaderOp2EXT;
typedef GLvoid function(GLenum, GLuint, GLuint, GLuint, GLuint) pfglShaderOp3EXT;
typedef GLvoid function(GLuint, GLuint, GLenum, GLenum, GLenum, GLenum) pfglSwizzleEXT;
typedef GLvoid function(GLuint, GLuint, GLenum, GLenum, GLenum, GLenum) pfglWriteMaskEXT;
typedef GLvoid function(GLuint, GLuint, GLuint) pfglInsertComponentEXT;
typedef GLvoid function(GLuint, GLuint, GLuint) pfglExtractComponentEXT;
typedef GLuint function(GLenum, GLenum, GLenum, GLuint) pfglGenSymbolsEXT;
typedef GLvoid function(GLuint, GLenum, GLvoid*) pfglSetInvariantEXT;
typedef GLvoid function(GLuint, GLenum, GLvoid*) pfglSetLocalConstantEXT;
typedef GLvoid function(GLuint, GLbyte*) pfglVariantbvEXT;
typedef GLvoid function(GLuint, GLshort*) pfglVariantsvEXT;
typedef GLvoid function(GLuint, GLint*) pfglVariantivEXT;
typedef GLvoid function(GLuint, GLfloat*) pfglVariantfvEXT;
typedef GLvoid function(GLuint, GLdouble*) pfglVariantdvEXT;
typedef GLvoid function(GLuint, GLubyte*) pfglVariantubvEXT;
typedef GLvoid function(GLuint, GLushort*) pfglVariantusvEXT;
typedef GLvoid function(GLuint, GLuint*) pfglVariantuivEXT;
typedef GLvoid function(GLuint, GLenum, GLuint, GLvoid*) pfglVariantPointerEXT;
typedef GLvoid function(GLuint) pfglEnableVariantClientStateEXT;
typedef GLvoid function(GLuint) pfglDisableVariantClientStateEXT;
typedef GLuint function(GLenum, GLenum) pfglBindLightParameterEXT;
typedef GLuint function(GLenum, GLenum) pfglBindMaterialParameterEXT;
typedef GLuint function(GLenum, GLenum, GLenum) pfglBindTexGenParameterEXT;
typedef GLuint function(GLenum, GLenum) pfglBindTextureUnitParameterEXT;
typedef GLuint function(GLenum) pfglBindParameterEXT;
typedef GLboolean function(GLuint, GLenum) pfglIsVariantEnabledEXT;
typedef GLvoid function(GLuint, GLenum, GLboolean*) pfglGetVariantBooleanvEXT;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetVariantIntegervEXT;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetVariantFloatvEXT;
typedef GLvoid function(GLuint, GLenum, GLvoid**) pfglGetVariantPointervEXT;
typedef GLvoid function(GLuint, GLenum, GLboolean*) pfglGetInvariantBooleanvEXT;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetInvariantIntegervEXT;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetInvariantFloatvEXT;
typedef GLvoid function(GLuint, GLenum, GLboolean*) pfglGetLocalConstantBooleanvEXT;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetLocalConstantIntegervEXT;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetLocalConstantFloatvEXT;

pfglBeginVertexShaderEXT    glBeginVertexShaderEXT;
pfglEndVertexShaderEXT      glEndVertexShaderEXT;
pfglBindVertexShaderEXT     glBindVertexShaderEXT;
pfglGenVertexShadersEXT     glGenVertexShadersEXT;
pfglDeleteVertexShaderEXT   glDeleteVertexShaderEXT;
pfglShaderOp1EXT      glShaderOp1EXT;
pfglShaderOp2EXT      glShaderOp2EXT;
pfglShaderOp3EXT      glShaderOp3EXT;
pfglSwizzleEXT        glSwizzleEXT;
pfglWriteMaskEXT      glWriteMaskEXT;
pfglInsertComponentEXT      glInsertComponentEXT;
pfglExtractComponentEXT     glExtractComponentEXT;
pfglGenSymbolsEXT     glGenSymbolsEXT;
pfglSetInvariantEXT     glSetInvariantEXT;
pfglSetLocalConstantEXT     glSetLocalConstantEXT;
pfglVariantbvEXT      glVariantbvEXT;
pfglVariantsvEXT      glVariantsvEXT;
pfglVariantivEXT      glVariantivEXT;
pfglVariantfvEXT      glVariantfvEXT;
pfglVariantdvEXT      glVariantdvEXT;
pfglVariantubvEXT     glVariantubvEXT;
pfglVariantusvEXT     glVariantusvEXT;
pfglVariantuivEXT     glVariantuivEXT;
pfglVariantPointerEXT     glVariantPointerEXT;
pfglEnableVariantClientStateEXT   glEnableVariantClientStateEXT;
pfglDisableVariantClientStateEXT  glDisableVariantClientStateEXT;
pfglBindLightParameterEXT   glBindLightParameterEXT;
pfglBindMaterialParameterEXT    glBindMaterialParameterEXT;
pfglBindTexGenParameterEXT    glBindTexGenParameterEXT;
pfglBindTextureUnitParameterEXT   glBindTextureUnitParameterEXT;
pfglBindParameterEXT      glBindParameterEXT;
pfglIsVariantEnabledEXT     glIsVariantEnabledEXT;
pfglGetVariantBooleanvEXT   glGetVariantBooleanvEXT;
pfglGetVariantIntegervEXT   glGetVariantIntegervEXT;
pfglGetVariantFloatvEXT     glGetVariantFloatvEXT;
pfglGetVariantPointervEXT   glGetVariantPointervEXT;
pfglGetInvariantBooleanvEXT   glGetInvariantBooleanvEXT;
pfglGetInvariantIntegervEXT   glGetInvariantIntegervEXT;
pfglGetInvariantFloatvEXT   glGetInvariantFloatvEXT;
pfglGetLocalConstantBooleanvEXT   glGetLocalConstantBooleanvEXT;
pfglGetLocalConstantIntegervEXT   glGetLocalConstantIntegervEXT;
pfglGetLocalConstantFloatvEXT   glGetLocalConstantFloatvEXT;

// 249 - GL_ATI_vertex_streams
typedef GLvoid function(GLenum, GLshort) pfglVertexStream1sATI;
typedef GLvoid function(GLenum, GLshort*) pfglVertexStream1svATI;
typedef GLvoid function(GLenum, GLint) pfglVertexStream1iATI;
typedef GLvoid function(GLenum, GLint*) pfglVertexStream1ivATI;
typedef GLvoid function(GLenum, GLfloat) pfglVertexStream1fATI;
typedef GLvoid function(GLenum, GLfloat*) pfglVertexStream1fvATI;
typedef GLvoid function(GLenum, GLdouble) pfglVertexStream1dATI;
typedef GLvoid function(GLenum, GLdouble*) pfglVertexStream1dvATI;
typedef GLvoid function(GLenum, GLshort, GLshort) pfglVertexStream2sATI;
typedef GLvoid function(GLenum, GLshort*) pfglVertexStream2svATI;
typedef GLvoid function(GLenum, GLint, GLint) pfglVertexStream2iATI;
typedef GLvoid function(GLenum, GLint*) pfglVertexStream2ivATI;
typedef GLvoid function(GLenum, GLfloat, GLfloat) pfglVertexStream2fATI;
typedef GLvoid function(GLenum, GLfloat*) pfglVertexStream2fvATI;
typedef GLvoid function(GLenum, GLdouble, GLdouble) pfglVertexStream2dATI;
typedef GLvoid function(GLenum, GLdouble*) pfglVertexStream2dvATI;
typedef GLvoid function(GLenum, GLshort, GLshort, GLshort) pfglVertexStream3sATI;
typedef GLvoid function(GLenum, GLshort*) pfglVertexStream3svATI;
typedef GLvoid function(GLenum, GLint, GLint, GLint) pfglVertexStream3iATI;
typedef GLvoid function(GLenum, GLint*) pfglVertexStream3ivATI;
typedef GLvoid function(GLenum, GLfloat, GLfloat, GLfloat) pfglVertexStream3fATI;
typedef GLvoid function(GLenum, GLfloat*) pfglVertexStream3fvATI;
typedef GLvoid function(GLenum, GLdouble, GLdouble, GLdouble) pfglVertexStream3dATI;
typedef GLvoid function(GLenum, GLdouble*) pfglVertexStream3dvATI;
typedef GLvoid function(GLenum, GLshort, GLshort, GLshort, GLshort) pfglVertexStream4sATI;
typedef GLvoid function(GLenum, GLshort*) pfglVertexStream4svATI;
typedef GLvoid function(GLenum, GLint, GLint, GLint, GLint) pfglVertexStream4iATI;
typedef GLvoid function(GLenum, GLint*) pfglVertexStream4ivATI;
typedef GLvoid function(GLenum, GLfloat, GLfloat, GLfloat, GLfloat) pfglVertexStream4fATI;
typedef GLvoid function(GLenum, GLfloat*) pfglVertexStream4fvATI;
typedef GLvoid function(GLenum, GLdouble, GLdouble, GLdouble, GLdouble) pfglVertexStream4dATI;
typedef GLvoid function(GLenum, GLdouble*) pfglVertexStream4dvATI;
typedef GLvoid function(GLenum, GLbyte, GLbyte, GLbyte) pfglNormalStream3bATI;
typedef GLvoid function(GLenum, GLbyte*) pfglNormalStream3bvATI;
typedef GLvoid function(GLenum, GLshort, GLshort, GLshort) pfglNormalStream3sATI;
typedef GLvoid function(GLenum, GLshort*) pfglNormalStream3svATI;
typedef GLvoid function(GLenum, GLint, GLint, GLint) pfglNormalStream3iATI;
typedef GLvoid function(GLenum, GLint*) pfglNormalStream3ivATI;
typedef GLvoid function(GLenum, GLfloat, GLfloat, GLfloat) pfglNormalStream3fATI;
typedef GLvoid function(GLenum, GLfloat*) pfglNormalStream3fvATI;
typedef GLvoid function(GLenum, GLdouble, GLdouble, GLdouble) pfglNormalStream3dATI;
typedef GLvoid function(GLenum, GLdouble*) pfglNormalStream3dvATI;
typedef GLvoid function(GLenum) pfglClientActiveVertexStreamATI;
typedef GLvoid function(GLenum, GLint) pfglVertexBlendEnviATI;
typedef GLvoid function(GLenum, GLfloat) pfglVertexBlendEnvfATI;

pfglVertexStream1sATI     glVertexStream1sATI;
pfglVertexStream1svATI      glVertexStream1svATI;
pfglVertexStream1iATI     glVertexStream1iATI;
pfglVertexStream1ivATI      glVertexStream1ivATI;
pfglVertexStream1fATI     glVertexStream1fATI;
pfglVertexStream1fvATI      glVertexStream1fvATI;
pfglVertexStream1dATI     glVertexStream1dATI;
pfglVertexStream1dvATI      glVertexStream1dvATI;
pfglVertexStream2sATI     glVertexStream2sATI;
pfglVertexStream2svATI      glVertexStream2svATI;
pfglVertexStream2iATI     glVertexStream2iATI;
pfglVertexStream2ivATI      glVertexStream2ivATI;
pfglVertexStream2fATI     glVertexStream2fATI;
pfglVertexStream2fvATI      glVertexStream2fvATI;
pfglVertexStream2dATI     glVertexStream2dATI;
pfglVertexStream2dvATI      glVertexStream2dvATI;
pfglVertexStream3sATI     glVertexStream3sATI;
pfglVertexStream3svATI      glVertexStream3svATI;
pfglVertexStream3iATI     glVertexStream3iATI;
pfglVertexStream3ivATI      glVertexStream3ivATI;
pfglVertexStream3fATI     glVertexStream3fATI;
pfglVertexStream3fvATI      glVertexStream3fvATI;
pfglVertexStream3dATI     glVertexStream3dATI;
pfglVertexStream3dvATI      glVertexStream3dvATI;
pfglVertexStream4sATI     glVertexStream4sATI;
pfglVertexStream4svATI      glVertexStream4svATI;
pfglVertexStream4iATI     glVertexStream4iATI;
pfglVertexStream4ivATI      glVertexStream4ivATI;
pfglVertexStream4fATI     glVertexStream4fATI;
pfglVertexStream4fvATI      glVertexStream4fvATI;
pfglVertexStream4dATI     glVertexStream4dATI;
pfglVertexStream4dvATI      glVertexStream4dvATI;
pfglNormalStream3bATI     glNormalStream3bATI;
pfglNormalStream3bvATI      glNormalStream3bvATI;
pfglNormalStream3sATI     glNormalStream3sATI;
pfglNormalStream3svATI      glNormalStream3svATI;
pfglNormalStream3iATI     glNormalStream3iATI;
pfglNormalStream3ivATI      glNormalStream3ivATI;
pfglNormalStream3fATI     glNormalStream3fATI;
pfglNormalStream3fvATI      glNormalStream3fvATI;
pfglNormalStream3dATI     glNormalStream3dATI;
pfglNormalStream3dvATI      glNormalStream3dvATI;
pfglClientActiveVertexStreamATI   glClientActiveVertexStreamATI;
pfglVertexBlendEnviATI      glVertexBlendEnviATI;
pfglVertexBlendEnvfATI      glVertexBlendEnvfATI;

// 256 - GL_ATI_element_array
typedef GLvoid function(GLenum, GLvoid*) pfglElementPointerATI;
typedef GLvoid function(GLenum, GLsizei) pfglDrawElementArrayATI;
typedef GLvoid function(GLenum, GLuint, GLuint, GLsizei) pfglDrawRangeElementArrayATI;

pfglElementPointerATI     glElementPointerATI;
pfglDrawElementArrayATI     glDrawElementArrayATI;
pfglDrawRangeElementArrayATI    glDrawRangeElementArrayATI;

// 257 - GL_SUN_mesh_array
typedef GLvoid function(GLenum, GLint, GLsizei, GLsizei) pfglDrawMeshArraysSUN;

pfglDrawMeshArraysSUN     glDrawMeshArraysSUN;

// 261 - GL_NV_occlusion_query
typedef GLvoid function(GLsizei, GLuint*) pfglGenOcclusionQueriesNV;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteOcclusionQueriesNV;
typedef GLboolean function(GLuint) pfglIsOcclusionQueryNV;
typedef GLvoid function(GLuint) pfglBeginOcclusionQueryNV;
typedef GLvoid function() pfglEndOcclusionQueryNV;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetOcclusionQueryivNV;
typedef GLvoid function(GLuint, GLenum, GLuint*) pfglGetOcclusionQueryuivNV;

pfglGenOcclusionQueriesNV   glGenOcclusionQueriesNV;
pfglDeleteOcclusionQueriesNV    glDeleteOcclusionQueriesNV;
pfglIsOcclusionQueryNV      glIsOcclusionQueryNV;
pfglBeginOcclusionQueryNV   glBeginOcclusionQueryNV;
pfglEndOcclusionQueryNV     glEndOcclusionQueryNV;
pfglGetOcclusionQueryivNV   glGetOcclusionQueryivNV;
pfglGetOcclusionQueryuivNV    glGetOcclusionQueryuivNV;

// 262 - GL_NV_point_sprite
typedef GLvoid function(GLenum, GLint) pfglPointParameteriNV;
typedef GLvoid function(GLenum, GLint*) pfglPointParameterivNV;

pfglPointParameteriNV     glPointParameteriNV;
pfglPointParameterivNV      glPointParameterivNV;

// 268 - GL_EXT_stencil_two_side
typedef GLvoid function(GLenum) pfglActiveStencilFaceEXT;

pfglActiveStencilFaceEXT    glActiveStencilFaceEXT;

// 271 - GL_APPLE_element_array
typedef GLvoid function(GLenum, GLvoid*) pfglElementPointerAPPLE;
typedef GLvoid function(GLenum, GLint, GLsizei) pfglDrawElementArrayAPPLE;
typedef GLvoid function(GLenum, GLuint, GLuint, GLint, GLsizei) pfglDrawRangeElementArrayAPPLE;
typedef GLvoid function(GLenum, GLint*, GLsizei*, GLsizei) pfglMultiDrawElementArrayAPPLE;
typedef GLvoid function(GLenum, GLuint, GLuint, GLint*, GLsizei*, GLsizei) pfglMultiDrawRangeElementArrayAPPLE;

pfglElementPointerAPPLE     glElementPointerAPPLE;
pfglDrawElementArrayAPPLE   glDrawElementArrayAPPLE;
pfglDrawRangeElementArrayAPPLE    glDrawRangeElementArrayAPPLE;
pfglMultiDrawElementArrayAPPLE    glMultiDrawElementArrayAPPLE;
pfglMultiDrawRangeElementArrayAPPLE glMultiDrawRangeElementArrayAPPLE;

// 272 - GL_APPLE_fence
typedef GLvoid function(GLsizei, GLuint*) pfglGenFencesAPPLE;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteFencesAPPLE;
typedef GLvoid function(GLuint) pfglSetFenceAPPLE;
typedef GLboolean function(GLuint) pfglIsFenceAPPLE;
typedef GLboolean function(GLuint) pfglTestFenceAPPLE;
typedef GLvoid function(GLuint) pfglFinishFenceAPPLE;
typedef GLboolean function(GLenum, GLuint) pfglTestObjectAPPLE;
typedef GLvoid function(GLenum, GLint) pfglFinishObjectAPPLE;

pfglGenFencesAPPLE      glGenFencesAPPLE;
pfglDeleteFencesAPPLE     glDeleteFencesAPPLE;
pfglSetFenceAPPLE     glSetFenceAPPLE;
pfglIsFenceAPPLE      glIsFenceAPPLE;
pfglTestFenceAPPLE      glTestFenceAPPLE;
pfglFinishFenceAPPLE      glFinishFenceAPPLE;
pfglTestObjectAPPLE     glTestObjectAPPLE;
pfglFinishObjectAPPLE     glFinishObjectAPPLE;

// 273 - GL_APPLE_vertex_array_object
typedef GLvoid function(GLuint) pfglBindVertexArrayAPPLE;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteVertexArraysAPPLE;
typedef GLvoid function(GLsizei, GLuint*) pfglGenVertexArraysAPPLE;
typedef GLboolean function(GLuint) pfglIsVertexArrayAPPLE;

pfglBindVertexArrayAPPLE    glBindVertexArrayAPPLE;
pfglDeleteVertexArraysAPPLE   glDeleteVertexArraysAPPLE;
pfglGenVertexArraysAPPLE    glGenVertexArraysAPPLE;
pfglIsVertexArrayAPPLE      glIsVertexArrayAPPLE;

// 274 - GL_APPLE_vertex_array_range
typedef GLvoid function(GLsizei, GLvoid*) pfglVertexArrayRangeAPPLE;
typedef GLvoid function(GLsizei, GLvoid*) pfglFlushVertexArrayRangeAPPLE;
typedef GLvoid function(GLenum, GLint) pfglVertexArrayParameteriAPPLE;

pfglVertexArrayRangeAPPLE   glVertexArrayRangeAPPLE;
pfglFlushVertexArrayRangeAPPLE    glFlushVertexArrayRangeAPPLE;
pfglVertexArrayParameteriAPPLE    glVertexArrayParameteriAPPLE;

// 277 - GL_ATI_draw_buffers
typedef GLvoid function(GLsizei, GLenum*) pfglDrawBuffersATI;

pfglDrawBuffersATI      glDrawBuffersATI;

// 282 - GL_NV_fragment_program
typedef GLvoid function(GLuint, GLsizei, GLubyte*, GLfloat, GLfloat, GLfloat, GLfloat) pfglProgramNamedParameter4fNV;
typedef GLvoid function(GLuint, GLsizei, GLubyte*, GLdouble, GLdouble, GLdouble, GLdouble) pfglProgramNamedParameter4dNV;
typedef GLvoid function(GLuint, GLsizei, GLubyte*, GLfloat*) pfglProgramNamedParameter4fvNV;
typedef GLvoid function(GLuint, GLsizei, GLubyte*, GLdouble*) pfglProgramNamedParameter4dvNV;
typedef GLvoid function(GLuint, GLsizei, GLubyte*, GLfloat*) pfglGetProgramNamedParameterfvNV;
typedef GLvoid function(GLuint, GLsizei, GLubyte*, GLdouble*) pfglGetProgramNamedParameterdvNV;

pfglProgramNamedParameter4fNV   glProgramNamedParameter4fNV;
pfglProgramNamedParameter4dNV   glProgramNamedParameter4dNV;
pfglProgramNamedParameter4fvNV    glProgramNamedParameter4fvNV;
pfglProgramNamedParameter4dvNV    glProgramNamedParameter4dvNV;
pfglGetProgramNamedParameterfvNV  glGetProgramNamedParameterfvNV;
pfglGetProgramNamedParameterdvNV  glGetProgramNamedParameterdvNV;

// 283 - GL_NV_half_float
typedef GLvoid function(GLhalfNV, GLhalfNV) pfglVertex2hNV;
typedef GLvoid function(GLhalfNV*) pfglVertex2hvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV, GLhalfNV) pfglVertex3hNV;
typedef GLvoid function(GLhalfNV*) pfglVertex3hvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV, GLhalfNV, GLhalfNV) pfglVertex4hNV;
typedef GLvoid function(GLhalfNV*) pfglVertex4hvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV, GLhalfNV) pfglNormal3hNV;
typedef GLvoid function(GLhalfNV*) pfglNormal3hvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV, GLhalfNV) pfglColor3hNV;
typedef GLvoid function(GLhalfNV*) pfglColor3hvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV, GLhalfNV, GLhalfNV) pfglColor4hNV;
typedef GLvoid function(GLhalfNV*) pfglColor4hvNV;
typedef GLvoid function(GLhalfNV) pfglTexCoord1hNV;
typedef GLvoid function(GLhalfNV*) pfglTexCoord1hvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV) pfglTexCoord2hNV;
typedef GLvoid function(GLhalfNV*) pfglTexCoord2hvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV, GLhalfNV) pfglTexCoord3hNV;
typedef GLvoid function(GLhalfNV*) pfglTexCoord3hvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV, GLhalfNV, GLhalfNV) pfglTexCoord4hNV;
typedef GLvoid function(GLhalfNV*) pfglTexCoord4hvNV;
typedef GLvoid function(GLenum, GLhalfNV) pfglMultiTexCoord1hNV;
typedef GLvoid function(GLenum, GLhalfNV*) pfglMultiTexCoord1hvNV;
typedef GLvoid function(GLenum, GLhalfNV, GLhalfNV) pfglMultiTexCoord2hNV;
typedef GLvoid function(GLenum, GLhalfNV*) pfglMultiTexCoord2hvNV;
typedef GLvoid function(GLenum, GLhalfNV, GLhalfNV, GLhalfNV) pfglMultiTexCoord3hNV;
typedef GLvoid function(GLenum, GLhalfNV*) pfglMultiTexCoord3hvNV;
typedef GLvoid function(GLenum, GLhalfNV, GLhalfNV, GLhalfNV, GLhalfNV) pfglMultiTexCoord4hNV;
typedef GLvoid function(GLenum, GLhalfNV*) pfglMultiTexCoord4hvNV;
typedef GLvoid function(GLhalfNV) pfglFogCoordhNV;
typedef GLvoid function(GLhalfNV*) pfglFogCoordhvNV;
typedef GLvoid function(GLhalfNV, GLhalfNV, GLhalfNV) pfglSecondaryColor3hNV;
typedef GLvoid function(GLhalfNV*) pfglSecondaryColor3hvNV;
typedef GLvoid function(GLhalfNV) pfglVertexWeighthNV;
typedef GLvoid function(GLhalfNV*) pfglVertexWeighthvNV;
typedef GLvoid function(GLuint, GLhalfNV) pfglVertexAttrib1hNV;
typedef GLvoid function(GLuint, GLhalfNV*) pfglVertexAttrib1hvNV;
typedef GLvoid function(GLuint, GLhalfNV, GLhalfNV) pfglVertexAttrib2hNV;
typedef GLvoid function(GLuint, GLhalfNV*) pfglVertexAttrib2hvNV;
typedef GLvoid function(GLuint, GLhalfNV, GLhalfNV, GLhalfNV) pfglVertexAttrib3hNV;
typedef GLvoid function(GLuint, GLhalfNV*) pfglVertexAttrib3hvNV;
typedef GLvoid function(GLuint, GLhalfNV, GLhalfNV, GLhalfNV, GLhalfNV) pfglVertexAttrib4hNV;
typedef GLvoid function(GLuint, GLhalfNV*) pfglVertexAttrib4hvNV;
typedef GLvoid function(GLuint, GLsizei, GLhalfNV*) pfglVertexAttribs1hvNV;
typedef GLvoid function(GLuint, GLsizei, GLhalfNV*) pfglVertexAttribs2hvNV;
typedef GLvoid function(GLuint, GLsizei, GLhalfNV*) pfglVertexAttribs3hvNV;
typedef GLvoid function(GLuint, GLsizei, GLhalfNV*) pfglVertexAttribs4hvNV;

pfglVertex2hNV        glVertex2hNV;
pfglVertex2hvNV       glVertex2hvNV;
pfglVertex3hNV        glVertex3hNV;
pfglVertex3hvNV       glVertex3hvNV;
pfglVertex4hNV        glVertex4hNV;
pfglVertex4hvNV       glVertex4hvNV;
pfglNormal3hNV        glNormal3hNV;
pfglNormal3hvNV       glNormal3hvNV;
pfglColor3hNV       glColor3hNV;
pfglColor3hvNV        glColor3hvNV;
pfglColor4hNV       glColor4hNV;
pfglColor4hvNV        glColor4hvNV;
pfglTexCoord1hNV      glTexCoord1hNV;
pfglTexCoord1hvNV     glTexCoord1hvNV;
pfglTexCoord2hNV      glTexCoord2hNV;
pfglTexCoord2hvNV     glTexCoord2hvNV;
pfglTexCoord3hNV      glTexCoord3hNV;
pfglTexCoord3hvNV     glTexCoord3hvNV;
pfglTexCoord4hNV      glTexCoord4hNV;
pfglTexCoord4hvNV     glTexCoord4hvNV;
pfglMultiTexCoord1hNV     glMultiTexCoord1hNV;
pfglMultiTexCoord1hvNV      glMultiTexCoord1hvNV;
pfglMultiTexCoord2hNV     glMultiTexCoord2hNV;
pfglMultiTexCoord2hvNV      glMultiTexCoord2hvNV;
pfglMultiTexCoord3hNV     glMultiTexCoord3hNV;
pfglMultiTexCoord3hvNV      glMultiTexCoord3hvNV;
pfglMultiTexCoord4hNV     glMultiTexCoord4hNV;
pfglMultiTexCoord4hvNV      glMultiTexCoord4hvNV;
pfglFogCoordhNV       glFogCoordhNV;
pfglFogCoordhvNV      glFogCoordhvNV;
pfglSecondaryColor3hNV      glSecondaryColor3hNV;
pfglSecondaryColor3hvNV     glSecondaryColor3hvNV;
pfglVertexWeighthNV     glVertexWeighthNV;
pfglVertexWeighthvNV      glVertexWeighthvNV;
pfglVertexAttrib2hNV      glVertexAttrib2hNV;
pfglVertexAttrib2hvNV     glVertexAttrib2hvNV;
pfglVertexAttrib1hNV      glVertexAttrib1hNV;
pfglVertexAttrib1hvNV     glVertexAttrib1hvNV;
pfglVertexAttrib3hNV      glVertexAttrib3hNV;
pfglVertexAttrib3hvNV     glVertexAttrib3hvNV;
pfglVertexAttrib4hNV      glVertexAttrib4hNV;
pfglVertexAttrib4hvNV     glVertexAttrib4hvNV;
pfglVertexAttribs1hvNV      glVertexAttribs1hvNV;
pfglVertexAttribs2hvNV      glVertexAttribs2hvNV;
pfglVertexAttribs3hvNV      glVertexAttribs3hvNV;
pfglVertexAttribs4hvNV      glVertexAttribs4hvNV;

// 184 - GL_NV_pixel_data_range
typedef GLvoid function(GLenum, GLsizei, GLvoid*) pfglPixelDataRangeNV;
typedef GLvoid function(GLenum) pfglFlushPixelDataRangeNV;

pfglPixelDataRangeNV      glPixelDataRangeNV;
pfglFlushPixelDataRangeNV   glFlushPixelDataRangeNV;

// 285 - GL_NV_primitive_restart
typedef GLvoid function() pfglPrimitiveRestartNV;
typedef GLvoid function(GLuint) pfglPrimitiveRestartIndexNV;

pfglPrimitiveRestartNV      glPrimitiveRestartNV;
pfglPrimitiveRestartIndexNV   glPrimitiveRestartIndexNV;

// 288 - GL_ATI_map_object_buffer
typedef GLvoid* function(GLuint) pfglMapObjectBufferATI;
typedef GLvoid function(GLuint) pfglUnmapObjectBufferATI;

pfglMapObjectBufferATI      glMapObjectBufferATI;
pfglUnmapObjectBufferATI    glUnmapObjectBufferATI;

// 289 - GL_ATI_separate_stencil
typedef GLvoid function(GLenum, GLenum, GLenum, GLenum) pfglStencilOpSeparateATI;
typedef GLvoid function(GLenum, GLenum, GLint, GLuint) pfglStencilFuncSeparateATI;

pfglStencilOpSeparateATI    glStencilOpSeparateATI;
pfglStencilFuncSeparateATI    glStencilFuncSeparateATI;

// 290 - GL_ATI_vertex_attrib_array_object
typedef GLvoid function(GLuint, GLint, GLenum, GLboolean, GLsizei, GLuint, GLuint) pfglVertexAttribArrayObjectATI;
typedef GLvoid function(GLuint, GLenum, GLfloat*) pfglGetVertexAttribArrayObjectfvATI;
typedef GLvoid function(GLuint, GLenum, GLint*) pfglGetVertexAttribArrayObjectivATI;

pfglVertexAttribArrayObjectATI    glVertexAttribArrayObjectATI;
pfglGetVertexAttribArrayObjectfvATI glGetVertexAttribArrayObjectfvATI;
pfglGetVertexAttribArrayObjectivATI glGetVertexAttribArrayObjectivATI;

// 297 - GL_EXT_depth_bounds_test
typedef GLvoid function(GLclampd, GLclampd) pfglDepthBoundsEXT;

pfglDepthBoundsEXT      glDepthBoundsEXT;

// 299 - GL_EXT_blend_equation_separate
typedef GLvoid function(GLenum, GLenum) pfglBlendEquationSeparateEXT;

pfglBlendEquationSeparateEXT    glBlendEquationSeparateEXT;

// 310 - GL_EXT_framebuffer_object
typedef GLboolean function(GLuint) pfglIsRenderbufferEXT;
typedef GLvoid function(GLenum, GLuint) pfglBindRenderbufferEXT;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteRenderbuffersEXT;
typedef GLvoid function(GLsizei, GLuint*) pfglGenRenderbuffersEXT;
typedef GLvoid function(GLenum, GLenum, GLsizei, GLsizei) pfglRenderbufferStorageEXT;
typedef GLvoid function(GLenum, GLenum, GLint*) pfglGetRenderbufferParameterivEXT;
typedef GLboolean function(GLuint) pfglIsFramebufferEXT;
typedef GLvoid function(GLenum, GLuint) pfglBindFramebufferEXT;
typedef GLvoid function(GLsizei, GLuint*) pfglDeleteFramebuffersEXT;
typedef GLvoid function(GLsizei, GLuint*) pfglGenFramebuffersEXT;
typedef GLenum function(GLenum) pfglCheckFramebufferStatusEXT;
typedef GLvoid function(GLenum, GLenum, GLenum, GLuint, GLint) pfglFramebufferTexture1DEXT;
typedef GLvoid function(GLenum, GLenum, GLenum, GLuint, GLint) pfglFramebufferTexture2DEXT;
typedef GLvoid function(GLenum, GLenum, GLenum, GLuint, GLint, GLint) pfglFramebufferTexture3DEXT;
typedef GLvoid function(GLenum, GLenum, GLenum, GLuint) pfglFramebufferRenderbufferEXT;
typedef GLvoid function(GLenum, GLenum, GLenum, GLint*) pfglGetFramebufferAttachmentParameterivEXT;
typedef GLvoid function(GLenum) pfglGenerateMipmapEXT;

pfglIsRenderbufferEXT     glIsRenderbufferEXT;
pfglBindRenderbufferEXT     glBindRenderbufferEXT;
pfglDeleteRenderbuffersEXT    glDeleteRenderbuffersEXT;
pfglGenRenderbuffersEXT     glGenRenderbuffersEXT;
pfglRenderbufferStorageEXT    glRenderbufferStorageEXT;
pfglGetRenderbufferParameterivEXT glGetRenderbufferParameterivEXT;
pfglIsFramebufferEXT      glIsFramebufferEXT;
pfglBindFramebufferEXT      glBindFramebufferEXT;
pfglDeleteFramebuffersEXT   glDeleteFramebuffersEXT;
pfglGenFramebuffersEXT      glGenFramebuffersEXT;
pfglCheckFramebufferStatusEXT   glCheckFramebufferStatusEXT;
pfglFramebufferTexture1DEXT   glFramebufferTexture1DEXT;
pfglFramebufferTexture2DEXT   glFramebufferTexture2DEXT;
pfglFramebufferTexture3DEXT   glFramebufferTexture3DEXT;
pfglFramebufferRenderbufferEXT    glFramebufferRenderbufferEXT;
pfglGetFramebufferAttachmentParameterivEXT glGetFramebufferAttachmentParameterivEXT;
pfglGenerateMipmapEXT     glGenerateMipmapEXT;

// 311 - GL_GREMEDY_string_marker
typedef GLvoid function(GLsizei, GLvoid*) pfglStringMarkerGREMEDY;

pfglStringMarkerGREMEDY     glStringMarkerGREMEDY;

// 314 - GL_EXT_stencil_clear_tag
typedef GLvoid function(GLsizei, GLuint) pfglStencilClearTagEXT;

pfglStencilClearTagEXT      glStencilClearTagEXT;

// 316 - GL_EXT_framebuffer_blit
typedef GLvoid function(GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLint, GLbitfield, GLenum) pfglBlitFramebufferEXT;

pfglBlitFramebufferEXT      glBlitFramebufferEXT;

// 317 - GL_EXT_framebuffer_multisample
typedef GLvoid function(GLenum, GLsizei, GLenum, GLsizei, GLsizei) pfglRenderbufferStorageMultisampleEXT;

pfglRenderbufferStorageMultisampleEXT glRenderbufferStorageMultisampleEXT;

// 319 - GL_EXT_timer_query
typedef GLvoid function(GLuint id, GLenum pname, long* params) pfglGetQueryObjecti64vEXT;
typedef GLvoid function(GLuint id, GLenum pname, ulong* params) pfglGetQueryObjectui64vEXT;

pfglGetQueryObjecti64vEXT   glGetQueryObjecti64vEXT;
pfglGetQueryObjectui64vEXT    glGetQueryObjectui64vEXT;

// 320 - GL_EXT_gpu_program_parameters
typedef GLvoid function(GLenum target, GLuint index, GLsizei count, GLfloat* params) pfglProgramEnvParameters4fvEXT;
typedef GLvoid function(GLenum target, GLuint index, GLsizei count, GLfloat* params) pfglProgramLocalParameters4fvEXT;

pfglProgramEnvParameters4fvEXT    glProgramEnvParameters4fvEXT;
pfglProgramLocalParameters4fvEXT  glProgramLocalParameters4fvEXT;

// 321 - GL_APPLE_flush_buffer_range
typedef GLvoid function(GLenum target, GLenum pname, GLint param) pfglBufferParameteriAPPLE;
typedef GLvoid function(GLenum target, GLintptr offset, GLsizeiptr size) pfglFlushMappedBufferRangeAPPLE;

pfglBufferParameteriAPPLE   glBufferParameteriAPPLE;
pfglFlushMappedBufferRangeAPPLE   glFlushMappedBufferRangeAPPLE;
