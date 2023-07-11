#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "engine.h"

#define BITRUNE_MAXROWS 30
#define BITRUNE_MAXSYMS 40

struct bitrune_row {
    uint8_t symbols[BITRUNE_MAXSYMS];
    int length;
};

struct bitrune_engine {
    bitrune_row rows[BITRUNE_MAXROWS];
    int currow;
    int cursym;
    char msgbuf[512];
};

int bitrune_curpos(bitrune_engine *br)
{
    bitrune_row *row;
    row = &br->rows[br->currow];

    /* what happens when a cursor jumps to a small row */
    if ((br->cursym - row->length) >= 1)
        return row->length;

    return br->cursym;
}

void bitrune_init(bitrune_engine *br)
{
    int r;
    br->currow = 0;
    br->cursym = 0;

    for (r = 0; r < BITRUNE_MAXROWS; r++) {
        int s;
        bitrune_row *row;
        row = &br->rows[r];
        for (s = 0; s < BITRUNE_MAXSYMS; s++) {
            row->symbols[s] = 0;
            row->length = 0;
        }
    }
}

void bitrune_move_left(bitrune_engine *br)
{
    if (br->cursym > 0) br->cursym--;
}

void bitrune_move_right(bitrune_engine *br)
{
    bitrune_row *row;

    br->cursym = bitrune_curpos(br);
    row = &br->rows[br->currow];

    if (br->cursym < row->length) br->cursym++;
}

void bitrune_move_up(bitrune_engine *br)
{
    if (br->currow > 0) br->currow--;
}

void bitrune_move_down(bitrune_engine *br)
{
    bitrune_row *row;

    row = &br->rows[br->currow];
    if (row->length == 0) return;
    if (br->currow < (BITRUNE_MAXROWS - 1)) br->currow++;
}

void bitrune_place(bitrune_engine *br, int c)
{
    bitrune_row *row;
    int curpos;

    row = &br->rows[br->currow];

    curpos = bitrune_curpos(br);
    if (row->length == BITRUNE_MAXSYMS) return;

    if (curpos < row->length) {
        int n;

        for (n = row->length; n > curpos; n--) {
            row->symbols[n] = row->symbols[n - 1];
        }
    }

    row->symbols[curpos] = c;
    row->length++;
}

void bitrune_insert(bitrune_engine *br, int c)
{
    bitrune_place(br, c);
    bitrune_move_right(br);
}

void bitrune_remove(bitrune_engine *br)
{
    bitrune_row *row;
    int curpos;

    row = &br->rows[br->currow];

    curpos = bitrune_curpos(br);

    if (row->length == 0) return;

    if (curpos < row->length) {
        int n;
        for (n = curpos + 1; n < row->length; n++) {
            row->symbols[n - 1] = row->symbols[n];
        }
    }

    row->length--;
}

static void print_row(bitrune_row *row)
{
    int i;

    for(i = 0; i < row->length; i++) {
        if (i > 0) printf(" ");
        printf("%x", row->symbols[i]);
    }

    printf("\n");
}

void bitrune_eval_block(bitrune_engine *br)
{
    int r;

    for (r = 0; r < BITRUNE_MAXROWS; r++) {
        bitrune_row *row;

        row = &br->rows[r];

        if (row->length > 0) print_row(row);
    }
}

size_t bitrune_engine_sizeof(void)
{
    return sizeof(bitrune_engine);
}

bitrune_row* bitrune_get_row(bitrune_engine *br, int rowpos)
{
    return &br->rows[rowpos];
}

unsigned char * bitrune_row_data(bitrune_row *row)
{
    return row->symbols;
}

int bitrune_row_length(bitrune_row *row)
{
    return row->length;
}

void bitrune_set_curpos(bitrune_engine *br, int curpos)
{
    br->cursym = curpos;
}

int bitrune_currow(bitrune_engine *br)
{
    return br->currow;
}

static uint16_t writesymbols(bitrune_engine *br, FILE *fp, int dowrite)
{
    int r;
    unsigned char zero;
    unsigned char msgpack_uint8;
    uint16_t nitems;
    zero = 0;
    nitems = 0;
    msgpack_uint8 = 0xcc;

    for (r = 0; r < BITRUNE_MAXROWS; r++) {
        bitrune_row *row;
        row = &br->rows[r];
        if (row->length > 0) {
            if (dowrite) {
                int s;
                for (s = 0; s < row->length; s++) {
                    fputc(msgpack_uint8, fp);
                    fputc(row->symbols[s], fp);
                }
            }
            nitems += row->length;
            if(dowrite) {
                fputc(msgpack_uint8, fp);
                fputc(zero, fp);
            }
            nitems++;
        }
    }

    return nitems;
}

void bitrune_save(bitrune_engine *br, const char *filename)
{
    FILE *fp;
    uint16_t nitems;
    unsigned char msgpack_array16[3];
    fp = fopen(filename, "wb");

    nitems = writesymbols(br, fp, 0);
    msgpack_array16[0] = 0xdc;
    msgpack_array16[1] = (nitems >> 8) & 0xff;
    msgpack_array16[2] = nitems & 0xff;
    fwrite(msgpack_array16, 1, 3, fp);
    writesymbols(br, fp, 1);
    fclose(fp);
}

void bitrune_load(bitrune_engine *br, const char *filename)
{
    FILE *fp;
    unsigned char *buf;
    int nbytes;
    int pos;
    int row;
    int sym;
    int mode;

    fp = fopen(filename, "rb");
    buf = calloc(1, 128);

    if (fp == NULL) return;

    nbytes = fread(buf, 1, 128, fp);
    pos = 0;
    row = 0;
    sym = 0;
    mode = 0;

    while (nbytes > 0) {
        unsigned char c;
        if (pos > nbytes) {
            /* in the rare case there are skipped bytes */
            pos = pos - nbytes;
            nbytes = fread(buf, 1, 128, fp);
            continue;
        }

        if (mode == 0) {
            /* msgpack array16 header, skip */
            /* TODO: what happens when this goes out of bounds */
            pos += 3;
            mode = 1;
        } else if (mode == 1) {
            /* msgpack integer header, skip */
            pos ++;
            mode = 2;
        } else {
            c = buf[pos];
            pos++;

            if (c == 0) {
                row++;
                sym = 0;
                br->rows[row].length = 0;
            } else {
                br->rows[row].symbols[sym] = c;
                br->rows[row].length++;
                sym++;
            }
            mode = 1;
        }
    }

    free(buf);
    fclose(fp);
}

void bitrune_eval_line(bitrune_engine *br)
{
    bitrune_row *row;
    unsigned char *syms;
    int nsyms;
    int n;
    int spos;
    char *msg;
    const char *map = "0123456789abcdef";

    row = &br->rows[br->currow];
    syms = row->symbols;
    nsyms = row->length;

    msg = br->msgbuf;
    spos = 0;
    for (n = 0; n < nsyms; n++) {
        unsigned char s;
        if (n != 0) {
            msg[spos] = ' ';
            spos++;
        }

        s = syms[n];
        msg[spos] = map[(s >> 8) & 0xf];
        spos++;
        msg[spos] = map[s & 0xf];
        spos++;
    }
    msg[spos] = 0;
}

const char *bitrune_message(bitrune_engine *br)
{
    return br->msgbuf;
}
