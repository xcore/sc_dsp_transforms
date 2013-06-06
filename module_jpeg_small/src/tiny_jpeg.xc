#include <flashlib.h>
#include "flash_loader.h"
#include "tiny_jpeg.h"
#include "lcd_sdram_manager.h"
#include <stdlib.h>
#include <stdio.h>
#define ERROR_CHECK

int Decode(chanend server, unsigned image_no);
extern void init_idct (void);
extern void idct(short a []);
#define PAGE_SIZE 256
unsigned char buf [PAGE_SIZE];
#define HUF_TBL_SIZE 256


unsigned sector_address;
unsigned cur_page_offset;

/*
 * getByte returns a byte from the jpeg. It must be used sequentially, i.e.
 * offset must increase with each call. It will fetch the next page from
 * flash when needed, hence wont work in reverse.
 */
#pragma unsafe arrays
inline unsigned char getByte(unsigned offset){
  if(offset>>8 != cur_page_offset){
    fl_readPage(sector_address  + (offset>>8) * PAGE_SIZE, buf);
    cur_page_offset = offset>>8;
  }
  return buf[offset&0xff];
}

#pragma unsafe arrays
unsigned short getShort(unsigned offset){
  if(offset>>8 == cur_page_offset){
    char bottom = buf[offset&0xff];
    if((offset+1)>>8 == cur_page_offset){
      return (bottom<<8) | buf[(offset+1)&0xff];
    } else {
      fl_readPage(sector_address  + (offset>>8) * PAGE_SIZE, buf);
      cur_page_offset++;
      return (bottom<<8) | buf[0];
    }
   } else {
     fl_readPage(sector_address  + (offset>>8) * PAGE_SIZE, buf);
     cur_page_offset = offset>>8;
     return ( buf[offset&0xff]<<8) | buf[(offset+1)&0xff];
   }
}

#pragma unsafe arrays
void load_jpeg_from_flash(chanend server, unsigned image_no, unsigned sectnum){
  sector_address = fl_getSectorAddress(sectnum);
  fl_readPage(sector_address, buf);
  Decode(server, image_no);
}

#pragma unsafe arrays
static inline unsigned DecodeDQT(unsigned offset, unsigned char qtab[4][64]) {
  unsigned length = getShort(offset);
  offset += 2;
  while (length >= 65) {
    unsigned char i = getByte(offset);
    for (unsigned index = 0; index < 64; ++index) {
      qtab[i][index] = buf[index + 1 + offset];
    }
    offset += 65;
    length -= 65;
  }
  return offset;
}

#pragma unsafe arrays
static inline unsigned DecodeHuffBaselineDCT( unsigned offset, stComps &components) {
  unsigned length = getShort(offset);
#ifdef ERROR_CHECK
  unsigned precision = getByte(offset + 2);
#endif
  unsigned height = getShort(offset + 3);
  unsigned width = getShort(offset + 5);
  unsigned num_components = getByte(offset + 7);
  components.height = height;
  components.width = width;
#ifdef ERROR_CHECK
  if (precision != 8){
    //fail
  }
  if (num_components !=3) {
    //fail
  }
#endif
  for(unsigned i = offset + 8; i< offset + 8 + 3*num_components; i+=3){
    unsigned id =  getByte(i);
    components.sampling_factors[id-1] = getByte(i+1);
    components.qt_table[id-1] = getByte(i+2);
  }
  return offset + length;
}

#pragma unsafe arrays
static inline unsigned DecodeHuffmanTableDef(unsigned offset, unsigned huffTableSize[4],
    huffEntry huffTable[4][HUF_TBL_SIZE]) {

  unsigned length = getShort(offset);
  unsigned endOfSection = offset + length;
  offset += 2;
  while (offset < endOfSection) {
    //the total number of codes must be less than 256
    int hufcounter = 0;
    int codelengthcounter = 1;
    unsigned tblID = getByte(offset);
    unsigned ht_number = tblID&0xf;
    unsigned ac_dc = (tblID>>4)&0x1;
    unsigned tblIndex = ac_dc | (ht_number<<1);
    unsigned symbol_index = 16;
    unsigned entry = 0;
    offset += 1;
    huffTableSize[tblIndex] = length - symbol_index;

    for (unsigned i = 0; i < 16; i++) {
      unsigned length = i + 1;
      unsigned count = getByte(offset + i);
      for (unsigned j = 0; j < count; j++) {
        unsigned symbol = getByte(offset + symbol_index);
        while (1) {
          if (length == codelengthcounter) {
            huffTable[tblIndex][entry].length = length;
            huffTable[tblIndex][entry].code = hufcounter;
            huffTable[tblIndex][entry].symbol = symbol;
            entry++;
            hufcounter++;
            break;
          } else {
            hufcounter = (hufcounter << 1 );
            codelengthcounter++;
          }
        }
        symbol_index++;
      }
    }
    offset += symbol_index;
  }
  return endOfSection;
}

unsigned g_streamOffset;
unsigned g_bitOffset;
unsigned g_stream_buffer;


void initStream(unsigned offset) {
  unsigned char t;
  g_streamOffset = offset;
  g_bitOffset = 0;

  t = getByte(g_streamOffset);
  g_stream_buffer = t<<24;
  g_streamOffset = g_streamOffset + 1 + (t == 0xff);

  t = getByte(g_streamOffset);
  g_stream_buffer |= t<<16;
  g_streamOffset = g_streamOffset + 1 + (t == 0xff);

  t = getByte(g_streamOffset);
  g_stream_buffer |= t<<8;
  g_streamOffset = g_streamOffset + 1 + (t == 0xff);

  t = getByte(g_streamOffset);
  g_stream_buffer |= t;
  g_streamOffset = g_streamOffset + 1 + (t == 0xff);
}

static inline unsigned short getStream() {
  return (unsigned short)(g_stream_buffer>>(16-g_bitOffset));
}

static inline void advanceStream(char bits_matched) {
  unsigned short t;
  g_bitOffset += bits_matched;
  if(g_bitOffset<16) return;
  while (g_bitOffset > 8) {
    g_bitOffset -= 8;
    g_stream_buffer <<= 8;
    t = getByte(g_streamOffset);
    g_stream_buffer |= t;
    g_streamOffset = g_streamOffset + 1 + (t == 0xff);
  }
}

#pragma unsafe arrays
static inline unsigned char matchCode(unsigned short next16bits, const huffEntry huffTable[HUF_TBL_SIZE], char &symbol) {
  unsigned i = 0;
  while (i < HUF_TBL_SIZE) {
    unsigned short mask = next16bits >> (16 - huffTable[i].length);
    if (mask == huffTable[i].code) {
      symbol = huffTable[i].symbol;
      return huffTable[i].length;
    }
    i++;
  }
  return 0;
}


#pragma unsafe arrays
static void DecodeChannel(short channel[64],
    const huffEntry huffTable[4][HUF_TBL_SIZE], unsigned dc_table, unsigned ac_table, short &prevDC,
    const unsigned char qt[64]) {
  unsigned char symbol;
  unsigned i;
  unsigned short next16bits = getStream();
  unsigned num_matched;

  i = 0;

  num_matched = matchCode(next16bits, huffTable[dc_table], symbol);

  advanceStream(num_matched);
  next16bits = getStream();

  for(unsigned j=0;j<64;j++){
    channel[j] = 0;
  }

  if (symbol != 0) {
    unsigned topbits = (symbol >> 4);
    unsigned bottombits = symbol & 0xf;
    short additional = next16bits >> (16 - bottombits);
    short dc;
    if (additional >> (bottombits - 1)) {
      dc = additional;
    } else {
      dc = additional - (1 << (bottombits)) + 1;
    }
    advanceStream(bottombits);
    next16bits = getStream();
    topbits+=i;
    for(;i<topbits;i++){
      channel[dezigzag[i]] = 0;
    }
    channel[dezigzag[i]] = (dc + prevDC) * qt[i];
    prevDC = dc+ prevDC;
  } else {
    channel[dezigzag[i]] = (0 + prevDC)* qt[i];
    prevDC = 0+ prevDC;
  }

  i++;
  num_matched = matchCode(next16bits, huffTable[ac_table], symbol);

  while (symbol) {
    advanceStream(num_matched);
    next16bits = getStream();
    {
    unsigned topbits = (symbol >> 4)&0xf;
    unsigned bottombits = symbol & 0xf;
    short additional = next16bits >> (16 - bottombits);
    short dc;
    if (additional >> (bottombits - 1)) {
      dc = additional;
    } else {
      dc = additional - (1 << (bottombits)) + 1;
    }
    advanceStream(bottombits);
    next16bits = getStream();
    i+=topbits;
    channel[dezigzag[i]] = dc * qt[i];
    }
    i++;
    num_matched = matchCode(next16bits, huffTable[ac_table], symbol);
  }

  advanceStream(num_matched);
}


/*
inline unsigned char Clip(const int x) {
    return (x < 0) ? 0 : ((x > 0xFF) ? 0xFF : (unsigned char) x);
}

inline unsigned short YCbCr_to_RGB565( short Y, short Cb, short Cr )
{
  register int y = Y << 8;
  register int cb = Cb - 128;
  register int cr = Cr - 128;
  int r = Clip((y            + 359 * cr + 128) >> 8);
  int g = Clip((y -  88 * cb - 183 * cr + 128) >> 8);
  int b = Clip((y + 454 * cb            + 128) >> 8);
  return (int)((r >> 3) & 0x1F) | ((int)((g >> 2) & 0x3F) << 5) | ((int)((b >> 3) & 0x1F) << 11);
}
*/


#define bits 5
#define const_a 1.402
#define const_b 0.34414
#define const_c 0.71414
#define const_d 1.722
#define const_A (int)(const_a*(1<<bits))
#define const_B (int)(const_c*(1<<bits))
#define const_C (int)(const_b*(1<<bits))
#define const_D (int)(const_d*(1<<bits))

inline unsigned short YCbCr_to_RGB565( short Y, short Cb, short Cr )
{
  register int y = Y << bits;
  register int cb = Cb - 128;
  register int cr = Cr - 128;
  int r = (y + const_A * cr + 128) >> (bits+3);
  int g = (y - const_B * cb - const_C * cr + 128) >> (bits+2);
  int b = (y + const_D * cb + 128) >>(bits+3);
  r = (r>>5)?((r<0)?0:0x1f):r;
  g = (g>>6)?((g<0)?0:0x3f):g;
  b = (b>>5)?((b<0)?0:0x1f):b;
  return r|(g<<5)|(b<<11);
}

#pragma unsafe arrays
void DecodeScan(unsigned offset,
    const unsigned huffTableSize[4], const huffEntry huffTable[4][HUF_TBL_SIZE],
    const unsigned char qt[4][64], stComps &components, chanend server, const unsigned image_no) {

  short prevDC = 0, prevDCCr = 0, prevDCCb = 0;
  unsigned mcu_count = components.height * components.width / 16 / 16;
  unsigned mcu = 0, x_coord = 0, y_coord = 0;
  short RGB[2][64*4];

  init_idct();
  initStream(offset);

  while (mcu < mcu_count) {

    unsigned ac_table_index = components.ac_table[Y];
    unsigned dc_table_index = components.dc_table[Y];
    unsigned qt_index = components.qt_table[Y];
    DecodeChannel(components.Y[0], huffTable, dc_table_index, ac_table_index, prevDC, qt[qt_index]);
    DecodeChannel(components.Y[1], huffTable, dc_table_index, ac_table_index, prevDC, qt[qt_index]);
    DecodeChannel(components.Y[2], huffTable, dc_table_index, ac_table_index, prevDC, qt[qt_index]);
    DecodeChannel(components.Y[3], huffTable, dc_table_index, ac_table_index, prevDC, qt[qt_index]);

    ac_table_index = components.ac_table[Cb];
    dc_table_index = components.dc_table[Cb];
    qt_index = components.qt_table[Cb];
    DecodeChannel(components.Cb, huffTable, dc_table_index, ac_table_index, prevDCCb, qt[qt_index]);

    ac_table_index = components.ac_table[Cr];
    dc_table_index = components.dc_table[Cr];
    qt_index = components.qt_table[Cr];
    DecodeChannel(components.Cr, huffTable, dc_table_index, ac_table_index, prevDCCr, qt[qt_index]);

    idct(components.Y[0]);
    idct(components.Y[1]);
    idct(components.Y[2]);
    idct(components.Y[3]);
    idct(components.Cb);
    idct(components.Cr);

    //now reconstruct the rgb
    for (unsigned i = 0; i < 64; i++) {

      short y = (1&(i>>2)) + 2*(i>=32);
      unsigned yy = 2*(i-(i&4)) &0x3f;
      unsigned r = 4*i-(2*(i&0x7));

      short Y0 = (components.Y[y][yy] - 128) & 0xff;
      short Y1 = (components.Y[y][yy+1] - 128) & 0xff;
      short Y2 = (components.Y[y][yy+8] - 128) & 0xff;
      short Y3 = (components.Y[y][yy+9] - 128) & 0xff;

      short Cb = (components.Cb[i] - 128) & 0xff;
      short Cr = (components.Cr[i] - 128) & 0xff;

      RGB[mcu&1][r] = YCbCr_to_RGB565(Y0, Cb, Cr);
      RGB[mcu&1][r+1] = YCbCr_to_RGB565(Y1, Cb, Cr);
      RGB[mcu&1][r+16] = YCbCr_to_RGB565(Y2, Cb, Cr);
      RGB[mcu&1][r+17] = YCbCr_to_RGB565(Y3, Cb, Cr);
    }

    image_write_16x16_nonblocking(server, y_coord, x_coord, image_no, RGB[mcu&1]);

    mcu++;

    x_coord += 16;
    if(x_coord == components.width){
      x_coord = 0;
      y_coord += 16;
    }

  }
}

int Decode(chanend server, unsigned image_no) {
  unsigned huffTableSize[4];
  huffEntry huffTable[4][HUF_TBL_SIZE];
  unsigned char qt[4][64];
  stComps components;
  unsigned offset = 2;

#ifdef ERROR_CHECK
  if (getShort(0) != 0xffd8){
    return -1;
  }
#endif

  while (offset < 1024) {
#ifdef ERROR_CHECK
    unsigned short marker = getShort(offset);
#else
    unsigned short marker = getByte(offset+1)|0xff00;
#endif
    offset += 2;

    switch (marker) {
    case QuantTableDef: {
      offset = DecodeDQT(offset, qt);
      break;
    }
    case HuffBaselineDCT: {
      offset = DecodeHuffBaselineDCT(offset, components);
      break;
    }
    case HuffmanTableDef: {
      offset = DecodeHuffmanTableDef(offset, huffTableSize, huffTable);
      break;
    }
    case RestartIntervalDef: {
      return -1;
    }
    case StartOfScan: {
      unsigned length =getShort(offset);
      unsigned num_components = getByte(offset+2);
      components.count = num_components;
      for(unsigned i=0;i<num_components;i++){
        unsigned char component_id = getByte(offset+3+2*i);
        unsigned tblInfo = getByte(offset+3+2*i+1);
        unsigned char ac_table = tblInfo&0xf;
        unsigned char dc_table = tblInfo>>4;
        components.ac_table[component_id-1] = 1 | (ac_table<<1) ;
        components.dc_table[component_id-1] = 0 | (dc_table<<1) ;
      }
      offset += length;
      DecodeScan(offset, huffTableSize, huffTable, qt, components, server, image_no);
      break;
    }
    default: {
      //skip unnessessary sections
      unsigned length = getShort(offset);
      offset += length;
      break;
    }
    }
  }
  return 0;
}
