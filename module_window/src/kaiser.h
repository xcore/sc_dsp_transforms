// Copyright (c) 2014, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/** Function that computes a Kaiser window over a set of input points.
 *
 * \param[out] output Array of N points in which the windowed data will be
 *                    stored.
 *
 * \param[in] data    Array of input points
 *
 * \param[in] offset  index of the first input point
 *
 * \param[in] N       Window size
 *
 * \param[in] kaiser  Array with kaiser values, This array should be N/2
 *                    elements long. They are provided by the name of 
 *                    kaiser_half_XXX_YYY below

 */
void window_kaiser(int output[], int data[], int offset, int N, const int hann[]);


/** Arrays of kaiser values. An array with the name kaiser_half_DB_N is a
 * value with a kaiser value with a gain of DB for N points. Values with a
 * higher gain have better side lobes but a worse main lobe.
 */
extern int kaiser_half_40_32[16];
extern int kaiser_half_50_32[16];
extern int kaiser_half_60_32[16];
extern int kaiser_half_70_32[16];
extern int kaiser_half_80_32[16];
extern int kaiser_half_90_32[16];
extern int kaiser_half_100_32[16];
extern int kaiser_half_110_32[16];
extern int kaiser_half_120_32[16];
extern int kaiser_half_130_32[16];
extern int kaiser_half_140_32[16];
extern int kaiser_half_40_64[32];
extern int kaiser_half_50_64[32];
extern int kaiser_half_60_64[32];
extern int kaiser_half_70_64[32];
extern int kaiser_half_80_64[32];
extern int kaiser_half_90_64[32];
extern int kaiser_half_100_64[32];
extern int kaiser_half_110_64[32];
extern int kaiser_half_120_64[32];
extern int kaiser_half_130_64[32];
extern int kaiser_half_140_64[32];
extern int kaiser_half_40_128[64];
extern int kaiser_half_50_128[64];
extern int kaiser_half_60_128[64];
extern int kaiser_half_70_128[64];
extern int kaiser_half_80_128[64];
extern int kaiser_half_90_128[64];
extern int kaiser_half_100_128[64];
extern int kaiser_half_110_128[64];
extern int kaiser_half_120_128[64];
extern int kaiser_half_130_128[64];
extern int kaiser_half_140_128[64];
extern int kaiser_half_40_256[128];
extern int kaiser_half_50_256[128];
extern int kaiser_half_60_256[128];
extern int kaiser_half_70_256[128];
extern int kaiser_half_80_256[128];
extern int kaiser_half_90_256[128];
extern int kaiser_half_100_256[128];
extern int kaiser_half_110_256[128];
extern int kaiser_half_120_256[128];
extern int kaiser_half_130_256[128];
extern int kaiser_half_140_256[128];
extern int kaiser_half_40_512[256];
extern int kaiser_half_50_512[256];
extern int kaiser_half_60_512[256];
extern int kaiser_half_70_512[256];
extern int kaiser_half_80_512[256];
extern int kaiser_half_90_512[256];
extern int kaiser_half_100_512[256];
extern int kaiser_half_110_512[256];
extern int kaiser_half_120_512[256];
extern int kaiser_half_130_512[256];
extern int kaiser_half_140_512[256];
extern int kaiser_half_40_1024[512];
extern int kaiser_half_50_1024[512];
extern int kaiser_half_60_1024[512];
extern int kaiser_half_70_1024[512];
extern int kaiser_half_80_1024[512];
extern int kaiser_half_90_1024[512];
extern int kaiser_half_100_1024[512];
extern int kaiser_half_110_1024[512];
extern int kaiser_half_120_1024[512];
extern int kaiser_half_130_1024[512];
extern int kaiser_half_140_1024[512];
