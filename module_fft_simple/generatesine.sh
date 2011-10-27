awk '
BEGIN {
  for(j = 2; j <= 2048; j = j * 2) {
    printf("int sine_%d[%d] = {\n ", 4*j, j+1);
    for(i = 0; i < j; i++) {
      printf(" %10d,", sin(i*3.1415926535/2/j) * 1024*1024*1024*2);
      if (i % 4 == 3) printf("\n ");
    }
    printf(" %10d,", 1 * 1024*1024*1024*2-1);
    printf("\n};\n\n");
  }
}
'
