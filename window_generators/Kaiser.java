class Kaiser {
    static double Att = 90;

    static double Ino(double x) {
        int d = 0;
        double ds = 1, s = 1;
        do {
            d += 2;
            ds *= x*x/(d*d);
            s += ds;
        } while (ds > s * 1e-6);
        return s;
    }

    static double sqr(double x) { return x * x; }

    static double kaiser(int n, int N) {
        double alpha;
        if (Att < 21) {
            alpha = 0;
        } else if (Att > 50) {
            alpha = 0.1102 * (Att -8.7);
        } else {
            alpha = 0.5842 * Math.pow((Att-21), 0.4) + 0.07886*(Att-21);
        }
        double Inoalpha = Ino(alpha);
        double root = Math.sqrt(1-sqr(2*n/((double)N-1)-1));
        double ret = Ino(alpha * root)/Inoalpha;
        return ret;
    }

    public static void main(String a[]) {
        for(int N = 32; N < 1025; N *= 2) {
          for(Att = 40; Att < 141; Att += 10) {
            System.out.println("int kaiser_half_" + ((int)Att) + "_" + N + "[" + (N/2) + "] = {");
            for(int i = 0; i < N/2; i++) {
                double d = kaiser(i, N);
                long di = (long) Math.floor(d * 0x80000000L);
                System.out.println("    " + di + ", // " + d);
            }
            System.out.println("};\n");
          }
        }
    }
}
