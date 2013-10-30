// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

    // Forward DCT for JPEG - gets a patch of 8x8 (ints) and a quantisation table (8x8 ints).
    // Makes liberal use of CP and DP. To be optimised further.
    // Based on reference algorithm.

    // TODO: remove SHR prior to MACCU
    // TODO: rounding after phase 1 and phase 2.
    // TODO: remove abuse of stackpointer for loop iteration - there must be a better way.


    .globl   doDCT.nstackwords
    .linkset doDCT.nstackwords, 0

    .globl doDCT

    .align 4
doDCT:
    out   res[r0], r1
    in    r0, res[r0]
    retsp 0


    .globl   endDCT.nstackwords
    .linkset endDCT.nstackwords, 0

    .globl endDCT

    .align 4
endDCT:
    outct res[r0], 5
    chkct res[r0], 5
    retsp 0

#define FIX_0_298631336  (  2446)	/* FIX(0.298631336) */
#define FIX_0_390180644  (  3196)	/* FIX(0.390180644) */
#define FIX_0_541196100  (  4433)	/* FIX(0.541196100) */
#define FIX_0_765366865  (  6270)	/* FIX(0.765366865) */
#define FIX_0_899976223  (  7373)	/* FIX(0.899976223) */
#define FIX_1_175875602  (  9633)	/* FIX(1.175875602) */
#define FIX_1_501321110  (  12299)	/* FIX(1.501321110) */
#define FIX_1_847759065  (  15137)	/* FIX(1.847759065) */
#define FIX_1_961570560  (  16069)	/* FIX(1.961570560) */
#define FIX_2_053119869  (  16819)	/* FIX(2.053119869) */
#define FIX_2_562915447  (  20995)	/* FIX(2.562915447) */
#define FIX_3_072711026  (  25172)	/* FIX(3.072711026) */

#define N 14

    .globl   forwardDCT.nstackwords
    .linkset forwardDCT.nstackwords, N

    .globl forwardDCT

    .align 4
forwardDCT:
    entsp N
    stw r4, sp[0]
    stw r5, sp[1]
    stw r6, sp[2]
    stw r7, sp[3]
    stw r8, sp[4]
    stw r9, sp[5]
    stw r10, sp[6]
    stw r11, sp[7]
    stw dp, sp[8]
    stw cp, sp[9]
    stw r0, sp[10]
    stw r1, sp[11]

blockLoop:
    ldw cp, sp[11]
    testct r1, res[r0]
    bt r1, noMoreBlocks
    in r1, res[r0]
    set dp, r1
    stw r1, sp[12]
    ldc r11, 0                         // Just misalign nextRow - improves performance.

nextRow:
    ldw r0, dp[0]
    ldw r11, dp[7]
    sub r7, r0, r11
    add r0, r0, r11

    ldw r1, dp[1]
    ldw r11, dp[6]
    sub r6, r1, r11
    add r1, r1, r11

    ldw r2, dp[2]
    ldw r11, dp[5]
    sub r5, r2, r11
    add r2, r2, r11

    ldw r3, dp[3]
    ldw r11, dp[4]
    sub r4, r3, r11
    add r3, r3, r11

    add r10, r0, r3
    sub  r9, r0, r3
    add r11, r1, r2           // r0 & r3 dead
    sub  r8, r1, r2           // r1 & r2 dead

    add r0, r10, r11
    ldc r1, 1024               // Bias term - take 128 offset in all pixels out.
    sub r0, r0, r1
    shl r0, r0, 2
    stw r0, dp[0]

    sub r0, r10, r11
    shl r0, r0, 2
    stw r0, dp[4]            // r10, r11 dead.

    ldc r2, 11

    add r0, r8, r9
    ldc r1,  FIX_0_541196100
    mul r0, r0, r1
    ldc r1,  FIX_0_765366865
    mul r9, r1, r9
    add r9, r9, r0
    ashr r9, r9, r2
    stw r9, dp[2]
    ldc r1,  FIX_1_847759065
    mul r8, r1, r8
    sub r8, r0, r8
    ashr r8, r8, r2
    stw r8, dp[6]            // r8, r9 dead

    add r1, r4, r7
    add r2, r5, r6
    add r3, r4, r6
    add r0, r5, r7
    add r11, r3, r0
    ldc r10, FIX_1_175875602
    mul r11, r11, r10

    ldc r10, FIX_0_298631336
    mul r4, r4, r10
    ldc r10, FIX_2_053119869
    mul r5, r5, r10
    ldc r10, FIX_3_072711026
    mul r6, r6, r10
    ldc r10, FIX_1_501321110
    mul r7, r7, r10

    ldc r10, FIX_0_899976223
    mul r1, r1, r10
    ldc r10, FIX_2_562915447
    mul r2, r2, r10
    ldc r10, FIX_1_961570560
    mul r3, r3, r10
    ldc r10, FIX_0_390180644
    mul r0, r0, r10

    sub r3, r11, r3
    sub r0, r11, r0

    ldc r10, 11

    sub r4, r4, r1
    add r4, r4, r3
    ashr r4, r4, r10
    stw r4, dp[7]

    sub r5, r5, r2
    add r5, r5, r0
    ashr r5, r5, r10
    stw r5, dp[5]

    sub r6, r6, r2
    add r6, r6, r3
    ashr r6, r6, r10
    stw r6, dp[3]

    sub r7, r7, r1
    add r7, r7, r0
    ashr r7, r7, r10
    stw r7, dp[1]

    ldaw dp, dp[8]

    ldaw r11, cp[1]
    set  cp, r11
    ldw  r10, cp[7*8]
    bt   r10, nextRow

    extdp 64


// End of ROW pass

    ldw cp, sp[11]

//    extsp 8

   // .align 4
nextColumn:
    ldw r0, dp[0*8]
    ldw r11, dp[7*8]
    sub r7, r0, r11
    add r0, r0, r11

    ldw r1, dp[1*8]
    ldw r11, dp[6*8]
    sub r6, r1, r11
    add r1, r1, r11

    ldw r2, dp[2*8]
    ldw r11, dp[5*8]
    sub r5, r2, r11
    add r2, r2, r11

    ldw r3, dp[3*8]
    ldw r11, dp[4*8]
    sub r4, r3, r11
    add r3, r3, r11

    add r10, r0, r3
    sub  r9, r0, r3
    add r11, r1, r2           // r0 & r3 dead
    sub  r8, r1, r2           // r1 & r2 dead

    add r0, r10, r11
    ashr r0, r0, 2
    ldw r1, cp[0*8]
    ldc r2, 0
    ldc r3, 0x80
    shl r3, r3, 24
    maccs r2, r3, r1, r0
    stw r2, dp[0*8]

    sub r0, r10, r11
    ashr r0, r0, 2
    ldw r1, cp[4*8]
    ldc r2, 0
    ldc r3, 0x80
    shl r3, r3, 24
    maccs r2, r3, r1, r0
    stw r2, dp[4*8]            // r10, r11 dead.

    ldc r10, 15

    add r0, r8, r9
    ldc r1,  FIX_0_541196100
    mul r0, r0, r1
    ldc r1,  FIX_0_765366865
    mul r9, r1, r9
    add r9, r9, r0
    ashr r9, r9, r10
    ldw r1, cp[2*8]
    ldc r2, 0
    ldc r3, 0x80
    shl r3, r3, 24
    maccs r2, r3, r9, r1
    stw r2, dp[2*8]
    ldc r1,  FIX_1_847759065
    mul r8, r1, r8
    sub r8, r0, r8
    ashr r8, r8, r10
    ldw r1, cp[6*8]
    ldc r2, 0
    ldc r3, 0x80
    shl r3, r3, 24
    maccs r2, r3, r8, r1
    stw r2, dp[6*8]            // r8, r9 dead

    add r1, r4, r7
    add r2, r5, r6
    add r3, r4, r6
    add r0, r5, r7
    add r11, r3, r0
    ldc r10, FIX_1_175875602
    mul r11, r11, r10

    ldc r10, FIX_0_298631336
    mul r4, r4, r10
    ldc r10, FIX_2_053119869
    mul r5, r5, r10
    ldc r10, FIX_3_072711026
    mul r6, r6, r10
    ldc r10, FIX_1_501321110
    mul r7, r7, r10

    ldc r10, FIX_0_899976223
    mul r1, r1, r10
    ldc r10, FIX_2_562915447
    mul r2, r2, r10
    ldc r10, FIX_1_961570560
    mul r3, r3, r10
    ldc r10, FIX_0_390180644
    mul r0, r0, r10

    sub r3, r11, r3
    sub r0, r11, r0

    ldc r10, 15

    sub r4, r4, r1
    add r4, r4, r3
    ashr r4, r4, r10
    ldw r8, cp[7*8]
    ldc r9, 0
    ldc r11, 0x80
    shl r11, r11, 24
    maccs r9, r11, r4, r8
    stw r9, dp[7*8]

    sub r5, r5, r2
    add r5, r5, r0
    ashr r5, r5, r10
    ldw r8, cp[5*8]
    ldc r9, 0
    ldc r11, 0x80
    shl r11, r11, 24
    maccs r9, r11, r5, r8
    stw r9, dp[5*8]

    sub r6, r6, r2
    add r6, r6, r3
    ashr r6, r6, r10
    ldw r8, cp[3*8]
    ldc r9, 0
    ldc r11, 0x80
    shl r11, r11, 24
    maccs r9, r11, r6, r8
    stw r9, dp[3*8]

    sub r7, r7, r1
    add r7, r7, r0
    ashr r7, r7, r10
    ldw r8, cp[1*8]
    ldc r9, 0
    ldc r11, 0x80
    shl r11, r11, 24
    maccs r9, r11, r7, r8
    stw r9, dp[1*8]

    ldaw dp, dp[1]
    ldaw r11, cp[1]
    set  cp, r11
    ldw  r11, cp[7*8]
    bt   r11, nextColumn

    ldw r0, sp[10]
    ldw r1, sp[12]
    out res[r0], r1

    bu blockLoop
noMoreBlocks:
    inct r1, res[r0]
    outct res[r0], r1

    ldw r4, sp[0]
    ldw r5, sp[1]
    ldw r6, sp[2]
    ldw r7, sp[3]
    ldw r8, sp[4]
    ldw r9, sp[5]
    ldw r10, sp[6]
    ldw r11, sp[7]
	ldw dp, sp[8]
	ldw cp, sp[9]

    retsp N
