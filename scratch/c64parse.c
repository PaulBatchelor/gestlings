#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mnolth/lodepng/lodepng.h>

static void indent(int nspaces)
{
    int n;
    for (n = 0; n < nspaces*4; n++) printf(" ");
}

const char *c64chars[] = {
    "@abcdefghijklmnopqrstuvwxyz[ ]  ",
    " !\"#$%&`()*+,-./0123456789:;<=>?",
    "_ABCDEFGHIJKLMNOPQRSTUVWXYZ    "
};

static void print_char(unsigned char *buf,
                       int w, int h, char c,
                       int xoff, int yoff)
{
    int x, y;
    /* ignore weird characters for now, labeled ' ' */
    if (c == ' ') return;
    indent(0);
    printf("symbols[0x%x] = {\n", c);
    indent(1);


    if (c == ' ') {
        printf("id = ???,\n", c);
    } else {
        printf("id = 0x%x,\n", c);
    }

    indent(1);
    printf("width = 8,\n");
    indent(1);
    if (c == '"') {
        printf("name=\"\\%c\",\n", c);
    } else {
        printf("name=\"%c\",\n", c);
    }
    indent(1);
    printf("bits = {\n");
    for (y = 0; y < 8; y++) {
        indent(2);
        printf("\"");
        for (x = 0; x < 8; x++) {
            int pos;
            pos = (((yoff + y)*w) + (xoff + x))*3;

            if (buf[pos] == 0xFF) {
                printf("-");
            } else {
                printf("#");
            }
        }
        printf("\",");
        printf("\n");
    }
    indent(1);
    printf("}\n");
    indent(0);
    printf("}\n");
}

static void print_space(void)
{
    int x, y;
    char c;

    c = ' ';
    indent(0);
    printf("symbols[0x%x] = {\n", c);
    indent(1);
    printf("id = 0x%x,\n", c);
    indent(1);
    printf("width = 8,\n");
    indent(1);
    printf("name=\"space\",\n");
    indent(1);
    printf("bits = {},\n");
    indent(0);
    printf("}\n");
}

int main(int argc, char *argv[])
{
    unsigned char *buf;
    int w, h;
    int x, y;
    int rc;
    int xoff, yoff;
    char c;
    int charpos;
    int rowpos;
    int maxrows, maxcols;

    rc = lodepng_decode24_file(&buf, &w, &h, "fonts/antik_1.png");


    printf("symbols = {}\n");

    maxrows = 3;
    maxcols = 32;
    charpos = 0;
    rowpos = 0;
    for (yoff = 0; yoff < h; yoff+= 8) {
        int len;
        const char *row;
        if (rowpos >= maxrows) break;
        row = c64chars[rowpos];
        len = strlen(row);
        charpos = 0;
        for (xoff = 0; xoff < w; xoff+= 8) {
            if (charpos >= maxcols || charpos >= len) continue;
            c = row[charpos];
            print_char(buf, w, h, c, xoff, yoff);
            charpos++;
        }
        rowpos++;
    }

    print_space();

    printf("return symbols\n");
    free(buf);
    return 0;
}
