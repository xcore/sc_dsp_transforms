/**
 * Performs zero or more DCT operations, and quantises the result. Each block
 * address is sent to the DCT process over the channel, and when done the address is
 * sent out over the channel. It is streaming so that a block can always be waiting
 * in the channel.
 *
 * The quant array should have been preprocessed using the quantDCT function.
 *
 * The functions doDCT and endDCT can be used to interact with the fdctintS function.
 *
 * \param blocks The channel end to stream addresses of blocks over
 * \param preprocessedQuant array of quantisation values.
 * \sa quantDCT
 * \sa doDCT
 * \sa endDCT
 */
extern void fdctintS(streaming chanend blocks, int preprocessedQuant[65]);

/**
 * Interface function to synchronously perform a DCT operation on a single datablock.
 * \param blocks The channelend that connects to the fdctintS function.
 * \param dataBlock an 8x8 array of integers on which to performa  quantised DCT.
 * \sa fdctintS
 */
extern int doDCT(streaming chanend blocks, int dataBlock[64]);

/**
 * Interface function to terminate the fdctintS function.
 * \param blocks The channelend that connects to the fdctintS function.
 * \sa fdctintS
 */
extern void endDCT(streaming chanend blocks);

/**
 * Preprocesses the quantisation table for use by fdctintS.
 * \param quantisationTable table with divider values for the quantisation process
 * \param preprocessedQuant table to be passed to fdctintS
 * \sa fdctintS
 */
extern void quantDCT(int preprocessedQuant[65], const unsigned char quantisationTable[64]);
