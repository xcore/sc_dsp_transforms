// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*! \file */

/** This function performs zero or more DCT operations, and quantises the
 * result. Each block address is sent to the DCT process over the channel,
 * and when done the address is sent out over the channel. It is streaming
 * so that a block can always be waiting in the channel. This function
 * should be running inside a thread, and is interfaced to through the
 * streaming channel.
 *
 * The quant array should have been preprocessed using the quantDCT function.
 *
 * The functions doDCT and endDCT can be used to interact with the forwardDCT
 * function; if full parallelism is required, then a block address should
 * be sent over the channel, and subsequently a block address should be
 * input for every block address that is output. Some form of double
 * buffering is required to make sure that forwardDCT() "owns" the buffer
 * that it operates on.
 *
 * This function does not return until it receives an 'END' control token
 * over its channel.
 *
 * \param blocks            The channel end to stream addresses of blocks over
 *
 * \param preprocessedQuant array of quantisation values.
 *
 * \sa quantDCT
 * \sa doDCT
 * \sa endDCT
 */
extern void forwardDCT(streaming chanend blocks, int preprocessedQuant[65]);

/** This is an Interface function to synchronously perform a DCT operation
 * on a single datablock.
 *
 * \param blocks    The channelend that connects to the forwardDCT function.
 *
 * \param dataBlock an 8x8 array of integers on which to perform a
 *                  quantised DCT.
 *
 * \sa forwardDCT
 */
extern int doDCT(streaming chanend blocks, int dataBlock[64]);

/** This interface function terminates the forwardDCT function.
 *
 * \param blocks The channelend that connects to the forwardDCT function.
 *
 * \sa forwardDCT
 */
extern void endDCT(streaming chanend blocks);

/** This function preprocesses the quantisation table for use by forwardDCT.
 * Note that the preprocessed table is one word longer than the input table.
 *
 * \param quantisationTable table with divider values for the quantisation process
 *
 * \param preprocessedQuant table to be passed to forwardDCT
 *
 * \sa forwardDCT
 */
extern void quantDCT(int preprocessedQuant[65], const unsigned char quantisationTable[64]);
