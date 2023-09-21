#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include "engine.h"

#define BITRUNE_MAXROWS 30
#define BITRUNE_MAXSYMS 40

uint32_t base64_triple(const unsigned char *data);
uint32_t base64_encode_segment(const unsigned char *data, int input_length);

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

static void b64write(unsigned char *data, int len, FILE *fp)
{
    uint32_t out;
    unsigned char bytes[4];

    out = base64_encode_segment((const unsigned char *)data, len);
    bytes[0] = (out >> 24) & 0xFF;
    bytes[1] = (out >> 16) & 0xFF;
    bytes[2] = (out >> 8) & 0xFF;
    bytes[3] = out & 0xFF;

    fwrite(bytes, 1, 4, fp);
}


static void append_byte(unsigned char *data,
                        int *plen,
                        int *prowpos,
                        unsigned char c,
                        FILE *fp)
{
    int len;
    int rowpos;

    len = *plen;
    rowpos = *prowpos;

    data[len] = c;
    len++;

    if (len >= 3) {
        b64write(data, len, fp);
        rowpos += 4;
        if (rowpos >= 40) {
            rowpos = 0;
            fputc('\n', fp);
        }
        len = 0;
    }

    *plen = len;
    *prowpos = rowpos;
}

static uint16_t writesymbols(bitrune_engine *br, FILE *fp, int dowrite)
{
    int r;
    unsigned char zero;
    unsigned char msgpack_uint8;
    uint16_t nitems;
    unsigned char data[3];
    int len;
    int rowpos;

    len = 0;
    zero = 0;
    nitems = 0;
    msgpack_uint8 = 0xcc;
    rowpos = 4; /* first 4 bytes are msgpack header */

    for (r = 0; r < BITRUNE_MAXROWS; r++) {
        bitrune_row *row;
        row = &br->rows[r];
        if (row->length > 0) {
            if (dowrite) {
                int s;
                for (s = 0; s < row->length; s++) {
                    append_byte(data, &len, &rowpos, msgpack_uint8, fp);
                    append_byte(data, &len, &rowpos, row->symbols[s], fp);
                }
            }
            nitems += row->length;
            if(dowrite) {
                append_byte(data, &len, &rowpos, msgpack_uint8, fp);
                append_byte(data, &len, &rowpos, zero, fp);
            }
            nitems++;
        }
    }

    if (dowrite && len > 0) {
        b64write(data, len, fp);
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
    b64write(msgpack_array16, 3, fp);
    writesymbols(br, fp, 1);
    fclose(fp);
}

static void read_block(int *ppos,
                       int *pnbytes,
                       unsigned char *sextet,
                       int *pspos,
                       unsigned char *buf,
                       unsigned char *b64buf,
                       FILE *fp)
{
    int n, s, b64bytes;
    int pos, nbytes;
    int spos;

    pos = *ppos;
    nbytes = *pnbytes;
    spos = *pspos;
    /* in the rare case there are skipped bytes */
    pos = pos - nbytes;
    b64bytes = fread(b64buf, 1, 128, fp);
    s = 0;
    nbytes = 0;

    for (n = 0; n < b64bytes; n++) {
        /* TODO: check for valid b64 chars instead */
        if (b64buf[n] != '\n') {
            sextet[spos] = b64buf[n];
            spos++;
        }

        if (spos == 4) {
            spos = 0;
            uint32_t triple;
            triple = base64_triple(sextet);
            buf[s] = (triple >> 16) & 0xFF;
            buf[s + 1] = (triple >> 8) & 0xFF;
            buf[s + 2] = (triple) & 0xFF;
            s += 3;
            nbytes += 3;
        }
    }

    *ppos = pos;
    *pnbytes = nbytes;
    *pspos = spos;
}

void bitrune_load(bitrune_engine *br, const char *filename)
{
    FILE *fp;
    unsigned char *buf;
    unsigned char *b64buf;
    int nbytes;
    int pos;
    int row;
    int sym;
    int mode;
    int spos;
    unsigned char sextet[4];

    fp = fopen(filename, "rb");
    buf = calloc(1, 128);
    b64buf = calloc(1, 128);

    if (fp == NULL) return;

    pos = 0;
    row = 0;
    sym = 0;
    mode = 0;
    spos = 0;
    nbytes = 0;

    read_block(&pos, &nbytes, sextet, &spos, buf, b64buf, fp);

    while (nbytes > 0) {
        unsigned char c;
        if (pos > nbytes) {
            read_block(&pos, &nbytes, sextet, &spos, buf, b64buf, fp);
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
    free(b64buf);
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
        msg[spos] = map[(s >> 4) & 0xf];
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
