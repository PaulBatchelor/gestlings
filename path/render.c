#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include "btprnt/btprnt.h"
#define MNOLTH_UF2_PRIV
#include "mnolth/uf2.h"
#define WIDTH 320
#define HEIGHT 200
#define MARGIN 20

/*
#define WIDTH 160
#define HEIGHT 100
#define MARGIN 10
*/

#define LINEHEIGHT 12
int main(int argc, char *argv[])
{
    btprnt *bp;
    btprnt_region r;
    struct uf2_font *fnt;
    unsigned char buf[128];
    int i, n;
    int nbytes;
    int start;
    int linepos;

    bp = btprnt_new(WIDTH, HEIGHT);
    fnt = malloc(uf2_size());
    /* uf2_load(fnt, "chicago12.uf2"); */
    uf2_load(fnt, "test.uf2");
    btprnt_region_init(btprnt_canvas_get(bp),
                       &r, MARGIN, MARGIN,
                       WIDTH - MARGIN*2, HEIGHT - MARGIN*2);

    nbytes = fread(buf, 1, 256, stdin);
    start = 0;
    linepos = 0;
    for (n = 0; n < nbytes; n++) {
        if (buf[n] == 0x00) {
            btprnt_uf2_draw_bytes(&r,
                                  fnt,
                                  0, linepos*LINEHEIGHT,
                                  &buf[start],
                                  n - start);
            start = n + 1;
            linepos++;
        }
    }
    btprnt_pbm(bp, NULL);
    btprnt_del(&bp);
    return 0;
}
