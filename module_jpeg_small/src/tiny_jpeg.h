void load_jpeg_from_flash(chanend server, unsigned image_no, unsigned sector);

enum JpegMarkers {
    // Start of Frame markers, non-differential, Huffman coding
    HuffBaselineDCT = 0xFFC0,
    HuffExtSequentialDCT = 0xFFC1,
    HuffProgressiveDCT = 0xFFC2,
    HuffLosslessSeq = 0xFFC3,

    // Start of Frame markers, differential, Huffman coding
    HuffDiffSequentialDCT = 0xFFC5,
    HuffDiffProgressiveDCT = 0xFFC6,
    HuffDiffLosslessSeq = 0xFFC7,

    // Start of Frame markers, non-differential, arithmetic coding
    ArthBaselineDCT = 0xFFC8,
    ArthExtSequentialDCT = 0xFFC9,
    ArthProgressiveDCT = 0xFFCA,
    ArthLosslessSeq = 0xFFCB,

    // Start of Frame markers, differential, arithmetic coding
    ArthDiffSequentialDCT = 0xFFCD,
    ArthDiffProgressiveDCT = 0xFFCE,
    ArthDiffLosslessSeq = 0xFFCF,

    // Huffman table spec
    HuffmanTableDef = 0xFFC4,

    // Arithmetic table spec
    ArithmeticTableDef = 0xFFCC,

    // Restart Interval termination
    RestartIntervalStart = 0xFFD0,
    RestartIntervalEnd = 0xFFD7,

    // Other markers
    StartOfImage = 0xFFD8,
    EndOfImage = 0xFFD9,
    StartOfScan = 0xFFDA,
    QuantTableDef = 0xFFDB,
    NumberOfLinesDef = 0xFFDC,
    RestartIntervalDef = 0xFFDD,
    HierarchProgressionDef = 0xFFDE,
    ExpandRefComponents = 0xFFDF,

    // App segments
    App0 = 0xFFE0,
    App1 = 0xFFE1,
    App2 = 0xFFE2,
    App3 = 0xFFE3,
    App4 = 0xFFE4,
    App5 = 0xFFE5,
    App6 = 0xFFE6,
    App7 = 0xFFE7,
    App8 = 0xFFE8,
    App9 = 0xFFE9,
    App10 = 0xFFEA,
    App11 = 0xFFEB,
    App12 = 0xFFEC,
    App13 = 0xFFED,
    App14 = 0xFFEE,
    App15 = 0xFFEF,

    // Jpeg Extensions
    JpegExt0 = 0xFFF0,
    JpegExt1 = 0xFFF1,
    JpegExt2 = 0xFFF2,
    JpegExt3 = 0xFFF3,
    JpegExt4 = 0xFFF4,
    JpegExt5 = 0xFFF5,
    JpegExt6 = 0xFFF6,
    JpegExt7 = 0xFFF7,
    JpegExt8 = 0xFFF8,
    JpegExt9 = 0xFFF9,
    JpegExtA = 0xFFFA,
    JpegExtB = 0xFFFB,
    JpegExtC = 0xFFFC,
    JpegExtD = 0xFFFD,

    // Comments
    Comment = 0xFFFE,

    // Reserved
    ArithTemp = 0xFF01,
    ReservedStart = 0xFF02,
    ReservedEnd = 0xFFBF
};
#define MAX_COMPONENT_COUNT 5

enum {
  Y=0, Cb=1, Cr=2
};

struct stBlock {
  int value;
  int length; // in bits.
  unsigned short int code; // 2 byte code
};

typedef struct huffEntry {
  unsigned char length;
  unsigned short code;
  unsigned char symbol;
} huffEntry;

static unsigned char dezigzag[64] = {
        0,   1,  8, 16,  9,  2,  3, 10,
        17, 24, 32, 25, 18, 11,  4,  5,
        12, 19, 26, 33, 40, 48, 41, 34,
        27, 20, 13,  6,  7, 14, 21, 28,
        35, 42, 49, 56, 57, 50, 43, 36,
        29, 22, 15, 23, 30, 37, 44, 51,
        58, 59, 52, 45, 38, 31, 39, 46,
        53, 60, 61, 54, 47, 55, 62, 63
       };

typedef struct stComps{
  unsigned char count;
  unsigned height;
  unsigned width;
  unsigned char ac_table[MAX_COMPONENT_COUNT];
  unsigned char dc_table[MAX_COMPONENT_COUNT];
  unsigned char qt_table[MAX_COMPONENT_COUNT];
  unsigned char sampling_factors[MAX_COMPONENT_COUNT];
  short Y[4][64];
  short Cb[64];
  short Cr[64];
} stComps;
