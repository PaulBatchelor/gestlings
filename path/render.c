#include <stdlib.h>
#include <stdint.h>
#include "btprnt/btprnt.h"
#define MNOLTH_UF2_PRIV
#include "mnolth/uf2.h"

int main(int argc, char *argv[])
{
    btprnt *bp;
    btprnt_region r;
    struct uf2_font *fnt;
    unsigned char buf[32];
    int i;

    bp = btprnt_new(320, 200);
    fnt = malloc(uf2_size());
    /* uf2_load(fnt, "chicago12.uf2"); */
    uf2_load(fnt, "test.uf2");
    btprnt_region_init(btprnt_canvas_get(bp),
                       &r, 20, 20,
                       320 - 40, 200 - 40);

    for(i = 0; i < 16; i++) {
        buf[i + 1] = i + 1;
    }

    buf[0] = 0x11;
    buf[17] = 0x12;

    btprnt_uf2_draw_bytes(&r, fnt, 0, 0, buf, 18);
    btprnt_pbm(bp, "out.pbm");
    btprnt_del(&bp);
    return 0;
}
