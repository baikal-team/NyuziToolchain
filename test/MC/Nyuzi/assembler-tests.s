# This file auto-generated by make_tests.py. Do not edit.
# RUN: llvm-mc -arch=nyuzi -show-encoding %s | FileCheck %s
or s1, s2, s3                    # CHECK: 0x22,0x80,0x01,0xc0
or v5, v6, s7                    # CHECK: 0xa6,0x80,0x03,0xc4
or_mask v9, s12, v10, s11        # CHECK: 0x2a,0xb1,0x05,0xc8
or v13, v14, v15                 # CHECK: 0xae,0x81,0x07,0xd0
or_mask v17, s20, v18, v19       # CHECK: 0x32,0xd2,0x09,0xd4
or s21, s22, -56                 # CHECK: 0xb6,0x22,0xff,0x00
or v24, v25, 82                  # CHECK: 0x19,0x4b,0x01,0x20
or_mask v27, s1, v0, 96          # CHECK: 0x60,0x07,0x30,0x60
and s2, s3, s4                   # CHECK: 0x43,0x00,0x12,0xc0
and v6, v7, s8                   # CHECK: 0xc7,0x00,0x14,0xc4
and_mask v10, s13, v11, s12      # CHECK: 0x4b,0x35,0x16,0xc8
and v14, v15, v16                # CHECK: 0xcf,0x01,0x18,0xd0
and_mask v18, s21, v19, v20      # CHECK: 0x53,0x56,0x1a,0xd4
and s22, s23, 54                 # CHECK: 0xd7,0xda,0x00,0x01
and v25, v26, 127                # CHECK: 0x3a,0xff,0x01,0x21
and_mask v0, s2, v1, 26          # CHECK: 0x01,0x08,0x0d,0x61
xor s3, s4, s5                   # CHECK: 0x64,0x80,0x32,0xc0
xor v7, v8, s9                   # CHECK: 0xe8,0x80,0x34,0xc4
xor_mask v11, s14, v12, s13      # CHECK: 0x6c,0xb9,0x36,0xc8
xor v15, v16, v17                # CHECK: 0xf0,0x81,0x38,0xd0
xor_mask v19, s22, v20, v21      # CHECK: 0x74,0xda,0x3a,0xd4
xor s23, s24, -53                # CHECK: 0xf8,0x2e,0xff,0x03
xor v26, v27, -56                # CHECK: 0x5b,0x23,0xff,0x23
xor_mask v1, s3, v2, 19          # CHECK: 0x22,0x8c,0x09,0x63
add_i s4, s5, s6                 # CHECK: 0x85,0x00,0x53,0xc0
add_i v8, v9, s10                # CHECK: 0x09,0x01,0x55,0xc4
add_i_mask v12, s15, v13, s14    # CHECK: 0x8d,0x3d,0x57,0xc8
add_i v16, v17, v18              # CHECK: 0x11,0x02,0x59,0xd0
add_i_mask v20, s23, v21, v22    # CHECK: 0x95,0x5e,0x5b,0xd4
add_i s24, s25, -119             # CHECK: 0x19,0x27,0xfe,0x05
add_i v27, v0, -89               # CHECK: 0x60,0x9f,0xfe,0x25
add_i_mask v2, s4, v3, 94        # CHECK: 0x43,0x10,0x2f,0x65
sub_i s5, s6, s7                 # CHECK: 0xa6,0x80,0x63,0xc0
sub_i v9, v10, s11               # CHECK: 0x2a,0x81,0x65,0xc4
sub_i_mask v13, s16, v14, s15    # CHECK: 0xae,0xc1,0x67,0xc8
sub_i v17, v18, v19              # CHECK: 0x32,0x82,0x69,0xd0
sub_i_mask v21, s24, v22, v23    # CHECK: 0xb6,0xe2,0x6b,0xd4
sub_i s25, s26, 88               # CHECK: 0x3a,0x63,0x01,0x06
sub_i v0, v1, -76                # CHECK: 0x01,0xd0,0xfe,0x26
sub_i_mask v3, s5, v4, 115       # CHECK: 0x64,0x94,0x39,0x66
mull_i s6, s7, s8                # CHECK: 0xc7,0x00,0x74,0xc0
mull_i v10, v11, s12             # CHECK: 0x4b,0x01,0x76,0xc4
mull_i_mask v14, s17, v15, s16   # CHECK: 0xcf,0x45,0x78,0xc8
mull_i v18, v19, v20             # CHECK: 0x53,0x02,0x7a,0xd0
mull_i_mask v22, s25, v23, v24   # CHECK: 0xd7,0x66,0x7c,0xd4
mull_i s26, s27, -9              # CHECK: 0x5b,0xdf,0xff,0x07
mull_i v1, v2, 26                # CHECK: 0x22,0x68,0x00,0x27
mull_i_mask v4, s6, v5, 111      # CHECK: 0x85,0x98,0x37,0x67
mulh_u s7, s8, s9                # CHECK: 0xe8,0x80,0x84,0xc0
mulh_u v11, v12, s13             # CHECK: 0x6c,0x81,0x86,0xc4
mulh_u_mask v15, s18, v16, s17   # CHECK: 0xf0,0xc9,0x88,0xc8
mulh_u v19, v20, v21             # CHECK: 0x74,0x82,0x8a,0xd0
mulh_u_mask v23, s26, v24, v25   # CHECK: 0xf8,0xea,0x8c,0xd4
mulh_u s27, s0, -73              # CHECK: 0x60,0xdf,0xfe,0x08
mulh_u v2, v3, -59               # CHECK: 0x43,0x14,0xff,0x28
mulh_u_mask v5, s7, v6, 116      # CHECK: 0xa6,0x1c,0x3a,0x68
ashr s8, s9, s10                 # CHECK: 0x09,0x01,0x95,0xc0
ashr v12, v13, s14               # CHECK: 0x8d,0x01,0x97,0xc4
ashr_mask v16, s19, v17, s18     # CHECK: 0x11,0x4e,0x99,0xc8
ashr v20, v21, v22               # CHECK: 0x95,0x02,0x9b,0xd0
ashr_mask v24, s27, v25, v26     # CHECK: 0x19,0x6f,0x9d,0xd4
ashr s0, s1, 63                  # CHECK: 0x01,0xfc,0x00,0x09
ashr v3, v4, 21                  # CHECK: 0x64,0x54,0x00,0x29
ashr_mask v6, s8, v7, -20        # CHECK: 0xc7,0x20,0xf6,0x69
shr s9, s10, s11                 # CHECK: 0x2a,0x81,0xa5,0xc0
shr v13, v14, s15                # CHECK: 0xae,0x81,0xa7,0xc4
shr_mask v17, s20, v18, s19      # CHECK: 0x32,0xd2,0xa9,0xc8
shr v21, v22, v23                # CHECK: 0xb6,0x82,0xab,0xd0
shr_mask v25, s0, v26, v27       # CHECK: 0x3a,0x83,0xad,0xd4
shr s1, s2, 4                    # CHECK: 0x22,0x10,0x00,0x0a
shr v4, v5, -75                  # CHECK: 0x85,0xd4,0xfe,0x2a
shr_mask v7, s9, v8, 85          # CHECK: 0xe8,0xa4,0x2a,0x6a
shl s10, s11, s12                # CHECK: 0x4b,0x01,0xb6,0xc0
shl v14, v15, s16                # CHECK: 0xcf,0x01,0xb8,0xc4
shl_mask v18, s21, v19, s20      # CHECK: 0x53,0x56,0xba,0xc8
shl v22, v23, v24                # CHECK: 0xd7,0x02,0xbc,0xd0
shl_mask v26, s1, v27, v0        # CHECK: 0x5b,0x07,0xb0,0xd4
shl s2, s3, -27                  # CHECK: 0x43,0x94,0xff,0x0b
shl v5, v6, -75                  # CHECK: 0xa6,0xd4,0xfe,0x2b
shl_mask v8, s10, v9, 58         # CHECK: 0x09,0x29,0x1d,0x6b
add_f s11, s12, s13              # CHECK: 0x6c,0x81,0x06,0xc2
add_f v15, v16, s17              # CHECK: 0xf0,0x81,0x08,0xc6
add_f_mask v19, s22, v20, s21    # CHECK: 0x74,0xda,0x0a,0xca
add_f v23, v24, v25              # CHECK: 0xf8,0x82,0x0c,0xd2
add_f_mask v27, s2, v0, v1       # CHECK: 0x60,0x8b,0x00,0xd6
sub_f s3, s4, s5                 # CHECK: 0x64,0x80,0x12,0xc2
sub_f v7, v8, s9                 # CHECK: 0xe8,0x80,0x14,0xc6
sub_f_mask v11, s14, v12, s13    # CHECK: 0x6c,0xb9,0x16,0xca
sub_f v15, v16, v17              # CHECK: 0xf0,0x81,0x18,0xd2
sub_f_mask v19, s22, v20, v21    # CHECK: 0x74,0xda,0x1a,0xd6
mul_f s23, s24, s25              # CHECK: 0xf8,0x82,0x2c,0xc2
mul_f v27, v0, s1                # CHECK: 0x60,0x83,0x20,0xc6
mul_f_mask v3, s6, v4, s5        # CHECK: 0x64,0x98,0x22,0xca
mul_f v7, v8, v9                 # CHECK: 0xe8,0x80,0x24,0xd2
mul_f_mask v11, s14, v12, v13    # CHECK: 0x6c,0xb9,0x26,0xd6
mulh_i s15, s16, s17             # CHECK: 0xf0,0x81,0xf8,0xc1
mulh_i v19, v20, s21             # CHECK: 0x74,0x82,0xfa,0xc5
mulh_i_mask v23, s26, v24, s25   # CHECK: 0xf8,0xea,0xfc,0xc9
mulh_i v27, v0, v1               # CHECK: 0x60,0x83,0xf0,0xd1
mulh_i_mask v3, s6, v4, v5       # CHECK: 0x64,0x98,0xf2,0xd5
mulh_i s7, s8, -41               # CHECK: 0xe8,0x5c,0xff,0x1f
mulh_i v10, v11, 49              # CHECK: 0x4b,0xc5,0x00,0x3f
mulh_i_mask v13, s15, v14, 54    # CHECK: 0xae,0x3d,0x1b,0x7f
movehi s2, 371769                # CHECK: 0x59,0x84,0xb5,0x4f
clz s1, s2                       # CHECK: 0x20,0x00,0xc1,0xc0
clz v1, s2                       # CHECK: 0x20,0x00,0xc1,0xc4
clz_mask v1, s3, s2              # CHECK: 0x20,0x0c,0xc1,0xc8
clz v1, v2                       # CHECK: 0x20,0x00,0xc1,0xd0
clz_mask v1, s3, v2              # CHECK: 0x20,0x0c,0xc1,0xd4
ctz s4, s5                       # CHECK: 0x80,0x80,0xe2,0xc0
ctz v4, s5                       # CHECK: 0x80,0x80,0xe2,0xc4
ctz_mask v4, s6, s5              # CHECK: 0x80,0x98,0xe2,0xc8
ctz v4, v5                       # CHECK: 0x80,0x80,0xe2,0xd0
ctz_mask v4, s6, v5              # CHECK: 0x80,0x98,0xe2,0xd4
move s7, s8                      # CHECK: 0xe0,0x00,0xf4,0xc0
move v7, s8                      # CHECK: 0xe0,0x00,0xf4,0xc4
move_mask v7, s9, s8             # CHECK: 0xe0,0x24,0xf4,0xc8
move v7, v8                      # CHECK: 0xe0,0x00,0xf4,0xd0
move_mask v7, s9, v8             # CHECK: 0xe0,0x24,0xf4,0xd4
reciprocal s10, s11              # CHECK: 0x40,0x81,0xc5,0xc1
reciprocal v10, s11              # CHECK: 0x40,0x81,0xc5,0xc5
reciprocal_mask v10, s12, s11    # CHECK: 0x40,0xb1,0xc5,0xc9
reciprocal v10, v11              # CHECK: 0x40,0x81,0xc5,0xd1
reciprocal_mask v10, s12, v11    # CHECK: 0x40,0xb1,0xc5,0xd5
ftoi s13, s14                    # CHECK: 0xa0,0x01,0xb7,0xc1
ftoi v13, s14                    # CHECK: 0xa0,0x01,0xb7,0xc5
ftoi_mask v13, s15, s14          # CHECK: 0xa0,0x3d,0xb7,0xc9
ftoi v13, v14                    # CHECK: 0xa0,0x01,0xb7,0xd1
ftoi_mask v13, s15, v14          # CHECK: 0xa0,0x3d,0xb7,0xd5
sext_8 s16, s17                  # CHECK: 0x00,0x82,0xd8,0xc1
sext_8 v16, s17                  # CHECK: 0x00,0x82,0xd8,0xc5
sext_8_mask v16, s18, s17        # CHECK: 0x00,0xca,0xd8,0xc9
sext_8 v16, v17                  # CHECK: 0x00,0x82,0xd8,0xd1
sext_8_mask v16, s18, v17        # CHECK: 0x00,0xca,0xd8,0xd5
sext_16 s19, s20                 # CHECK: 0x60,0x02,0xea,0xc1
sext_16 v19, s20                 # CHECK: 0x60,0x02,0xea,0xc5
sext_16_mask v19, s21, s20       # CHECK: 0x60,0x56,0xea,0xc9
sext_16 v19, v20                 # CHECK: 0x60,0x02,0xea,0xd1
sext_16_mask v19, s21, v20       # CHECK: 0x60,0x56,0xea,0xd5
itof s22, s23                    # CHECK: 0xc0,0x82,0xab,0xc2
itof v22, s23                    # CHECK: 0xc0,0x82,0xab,0xc6
itof_mask v22, s24, s23          # CHECK: 0xc0,0xe2,0xab,0xca
itof v22, v23                    # CHECK: 0xc0,0x82,0xab,0xd2
itof_mask v22, s24, v23          # CHECK: 0xc0,0xe2,0xab,0xd6
move s2, 72                      # CHECK: 0x40,0x20,0x01,0x0f
move v3, 72                      # CHECK: 0x60,0x20,0x01,0x2f
shuffle v1, v2, v3               # CHECK: 0x22,0x80,0xd1,0xd0
shuffle_mask v1, s4, v2, v3      # CHECK: 0x22,0x90,0xd1,0xd4
getlane s4, v5, s6               # CHECK: 0x85,0x00,0xa3,0xc5
getlane s4, v5, 7                # CHECK: 0x85,0x1c,0x00,0x3a
nop                              # CHECK: 0x00,0x00,0x00,0x00
cmpeq_i s1, s2, s3               # CHECK: 0x22,0x80,0x01,0xc1
cmpeq_i s1, v2, s3               # CHECK: 0x22,0x80,0x01,0xc5
cmpeq_i s1, v2, v3               # CHECK: 0x22,0x80,0x01,0xd1
cmpeq_i s1, s2, 56               # CHECK: 0x22,0xe0,0x00,0x10
cmpeq_i s1, v2, 56               # CHECK: 0x22,0xe0,0x00,0x30
cmpne_i s4, s5, s6               # CHECK: 0x85,0x00,0x13,0xc1
cmpne_i s4, v5, s6               # CHECK: 0x85,0x00,0x13,0xc5
cmpne_i s4, v5, v6               # CHECK: 0x85,0x00,0x13,0xd1
cmpne_i s4, s5, 20               # CHECK: 0x85,0x50,0x00,0x11
cmpne_i s4, v5, 20               # CHECK: 0x85,0x50,0x00,0x31
cmpgt_i s7, s8, s9               # CHECK: 0xe8,0x80,0x24,0xc1
cmpgt_i s7, v8, s9               # CHECK: 0xe8,0x80,0x24,0xc5
cmpgt_i s7, v8, v9               # CHECK: 0xe8,0x80,0x24,0xd1
cmpgt_i s7, s8, 237              # CHECK: 0xe8,0xb4,0x03,0x12
cmpgt_i s7, v8, 237              # CHECK: 0xe8,0xb4,0x03,0x32
cmpge_i s10, s11, s12            # CHECK: 0x4b,0x01,0x36,0xc1
cmpge_i s10, v11, s12            # CHECK: 0x4b,0x01,0x36,0xc5
cmpge_i s10, v11, v12            # CHECK: 0x4b,0x01,0x36,0xd1
cmpge_i s10, s11, 109            # CHECK: 0x4b,0xb5,0x01,0x13
cmpge_i s10, v11, 109            # CHECK: 0x4b,0xb5,0x01,0x33
cmplt_i s13, s14, s15            # CHECK: 0xae,0x81,0x47,0xc1
cmplt_i s13, v14, s15            # CHECK: 0xae,0x81,0x47,0xc5
cmplt_i s13, v14, v15            # CHECK: 0xae,0x81,0x47,0xd1
cmplt_i s13, s14, 137            # CHECK: 0xae,0x25,0x02,0x14
cmplt_i s13, v14, 137            # CHECK: 0xae,0x25,0x02,0x34
cmple_i s16, s17, s18            # CHECK: 0x11,0x02,0x59,0xc1
cmple_i s16, v17, s18            # CHECK: 0x11,0x02,0x59,0xc5
cmple_i s16, v17, v18            # CHECK: 0x11,0x02,0x59,0xd1
cmple_i s16, s17, 247            # CHECK: 0x11,0xde,0x03,0x15
cmple_i s16, v17, 247            # CHECK: 0x11,0xde,0x03,0x35
cmpgt_u s19, s20, s21            # CHECK: 0x74,0x82,0x6a,0xc1
cmpgt_u s19, v20, s21            # CHECK: 0x74,0x82,0x6a,0xc5
cmpgt_u s19, v20, v21            # CHECK: 0x74,0x82,0x6a,0xd1
cmpgt_u s19, s20, 101            # CHECK: 0x74,0x96,0x01,0x16
cmpgt_u s19, v20, 101            # CHECK: 0x74,0x96,0x01,0x36
cmpge_u s22, s23, s24            # CHECK: 0xd7,0x02,0x7c,0xc1
cmpge_u s22, v23, s24            # CHECK: 0xd7,0x02,0x7c,0xc5
cmpge_u s22, v23, v24            # CHECK: 0xd7,0x02,0x7c,0xd1
cmpge_u s22, s23, 152            # CHECK: 0xd7,0x62,0x02,0x17
cmpge_u s22, v23, 152            # CHECK: 0xd7,0x62,0x02,0x37
cmplt_u s25, s26, s27            # CHECK: 0x3a,0x83,0x8d,0xc1
cmplt_u s25, v26, s27            # CHECK: 0x3a,0x83,0x8d,0xc5
cmplt_u s25, v26, v27            # CHECK: 0x3a,0x83,0x8d,0xd1
cmplt_u s25, s26, 97             # CHECK: 0x3a,0x87,0x01,0x18
cmplt_u s25, v26, 97             # CHECK: 0x3a,0x87,0x01,0x38
cmple_u s0, s1, s2               # CHECK: 0x01,0x00,0x91,0xc1
cmple_u s0, v1, s2               # CHECK: 0x01,0x00,0x91,0xc5
cmple_u s0, v1, v2               # CHECK: 0x01,0x00,0x91,0xd1
cmple_u s0, s1, 33               # CHECK: 0x01,0x84,0x00,0x19
cmple_u s0, v1, 33               # CHECK: 0x01,0x84,0x00,0x39
cmpgt_f s3, s4, s5               # CHECK: 0x64,0x80,0xc2,0xc2
cmpgt_f s3, v4, s5               # CHECK: 0x64,0x80,0xc2,0xc6
cmpgt_f s3, v4, v5               # CHECK: 0x64,0x80,0xc2,0xd2
cmpge_f s6, s7, s8               # CHECK: 0xc7,0x00,0xd4,0xc2
cmpge_f s6, v7, s8               # CHECK: 0xc7,0x00,0xd4,0xc6
cmpge_f s6, v7, v8               # CHECK: 0xc7,0x00,0xd4,0xd2
cmplt_f s9, s10, s11             # CHECK: 0x2a,0x81,0xe5,0xc2
cmplt_f s9, v10, s11             # CHECK: 0x2a,0x81,0xe5,0xc6
cmplt_f s9, v10, v11             # CHECK: 0x2a,0x81,0xe5,0xd2
cmple_f s12, s13, s14            # CHECK: 0x8d,0x01,0xf7,0xc2
cmple_f s12, v13, s14            # CHECK: 0x8d,0x01,0xf7,0xc6
cmple_f s12, v13, v14            # CHECK: 0x8d,0x01,0xf7,0xd2
load_u8 s1, (s2)                 # CHECK: 0x22,0x00,0x00,0xa0
load_u8 s1, 3(s2)                # CHECK: 0x22,0x0c,0x00,0xa0
load_s8 s4, (s5)                 # CHECK: 0x85,0x00,0x00,0xa2
load_s8 s4, 6(s5)                # CHECK: 0x85,0x18,0x00,0xa2
load_u16 s7, (s8)                # CHECK: 0xe8,0x00,0x00,0xa4
load_u16 s7, 9(s8)               # CHECK: 0xe8,0x24,0x00,0xa4
load_s16 s10, (s11)              # CHECK: 0x4b,0x01,0x00,0xa6
load_s16 s10, 12(s11)            # CHECK: 0x4b,0x31,0x00,0xa6
load_32 s13, (s14)               # CHECK: 0xae,0x01,0x00,0xa8
load_32 s13, 15(s14)             # CHECK: 0xae,0x3d,0x00,0xa8
load_sync s16, (s17)             # CHECK: 0x11,0x02,0x00,0xaa
load_sync s16, 18(s17)           # CHECK: 0x11,0x4a,0x00,0xaa
store_8 s19, (s20)               # CHECK: 0x74,0x02,0x00,0x82
store_8 s19, 21(s20)             # CHECK: 0x74,0x56,0x00,0x82
store_16 s22, (s23)              # CHECK: 0xd7,0x02,0x00,0x86
store_16 s22, 24(s23)            # CHECK: 0xd7,0x62,0x00,0x86
store_32 s25, (s26)              # CHECK: 0x3a,0x03,0x00,0x88
store_32 s25, 27(s26)            # CHECK: 0x3a,0x6f,0x00,0x88
store_sync s0, (s1)              # CHECK: 0x01,0x00,0x00,0x8a
store_sync s0, 2(s1)             # CHECK: 0x01,0x08,0x00,0x8a
load_v v1, 424(s2)               # CHECK: 0x22,0xa0,0x06,0xae
load_v_mask v1, s3, 424(s2)      # CHECK: 0x22,0x0c,0xd4,0xb0
load_v v1, (s2)                  # CHECK: 0x22,0x00,0x00,0xae
load_v_mask v1, s3, (s2)         # CHECK: 0x22,0x0c,0x00,0xb0
store_v v1, 424(s2)              # CHECK: 0x22,0xa0,0x06,0x8e
store_v_mask v1, s3, 424(s2)     # CHECK: 0x22,0x0c,0xd4,0x90
store_v v1, (s2)                 # CHECK: 0x22,0x00,0x00,0x8e
store_v_mask v1, s3, (s2)        # CHECK: 0x22,0x0c,0x00,0x90
load_gath v4, 312(v5)            # CHECK: 0x85,0xe0,0x04,0xba
load_gath_mask v4, s6, 312(v5)   # CHECK: 0x85,0x18,0x9c,0xbc
load_gath v4, (v5)               # CHECK: 0x85,0x00,0x00,0xba
load_gath_mask v4, s6, (v5)      # CHECK: 0x85,0x18,0x00,0xbc
store_scat v4, 312(v5)           # CHECK: 0x85,0xe0,0x04,0x9a
store_scat_mask v4, s6, 312(v5)  # CHECK: 0x85,0x18,0x9c,0x9c
store_scat v4, (v5)              # CHECK: 0x85,0x00,0x00,0x9a
store_scat_mask v4, s6, (v5)     # CHECK: 0x85,0x18,0x00,0x9c
getcr s7, 9                      # CHECK: 0xe9,0x00,0x00,0xac
setcr s11, 13                    # CHECK: 0x6d,0x01,0x00,0x8c
dflush s7                        # CHECK: 0x07,0x00,0x00,0xe4
membar                           # CHECK: 0x00,0x00,0x00,0xe8
dinvalidate s9                   # CHECK: 0x09,0x00,0x00,0xe2
iinvalidate s11                  # CHECK: 0x0b,0x00,0x00,0xe6
tlbinval s12                     # CHECK: 0x0c,0x00,0x00,0xea
tlbinvalall                      # CHECK: 0x00,0x00,0x00,0xec
dtlbinsert s1, s2                # CHECK: 0x41,0x00,0x00,0xe0
itlbinsert s3, s4                # CHECK: 0x83,0x00,0x00,0xee
break                            # CHECK: 0x00,0x00,0xe0,0xc3
syscall                          # CHECK: 0x00,0x00,0xf0,0xc3
