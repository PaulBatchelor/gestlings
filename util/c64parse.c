#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <mnolth/lodepng/lodepng.h>

static void indent(int nspaces)
{
    int n;
    for (n = 0; n < nspaces*4; n++) printf(" ");
}

static void print_char(unsigned char *buf,
                       int w, int h, char c,
                       int xoff, int yoff)
{
    int x, y;
    int charwidth;

    charwidth = 8;
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
    printf("width = %d,\n", charwidth);
    indent(1);
    if (c == '"') {
        printf("name=\"\\\"\",\n");
    } else if (c == '\\') {
        printf("name=\"\\\\\",\n");
    } else {
        printf("name=\"%c\",\n", c);
    }
    indent(1);
    printf("bits = {\n");
    for (y = 0; y < charwidth; y++) {
        indent(2);
        printf("\"");
        for (x = 0; x < charwidth; x++) {
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
    int charwidth;

    charwidth = 8;

    c = ' ';
    indent(0);
    printf("symbols[0x%x] = {\n", c);
    indent(1);
    printf("id = 0x%x,\n", c);
    indent(1);
    printf("width = %d,\n", charwidth);
    indent(1);
    printf("name = \"space\",\n");
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
    int charwidth;
    const char *pngfile;
    size_t *charset_rows;
    char **charrows;
    const char *charset_file;
    FILE *fp;
    size_t charset_file_size;
    size_t n;
    size_t last;
    char *charset;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s charset.png charset.txt\n", argv[0]);
        return 1;
    }

    pngfile = argv[1];
    charset_file = argv[2];

    rc = lodepng_decode24_file(&buf, &w, &h, pngfile);

    if (rc) {
        fprintf(stderr, "Could not load PNG file '%s'\n", pngfile);
        return 1;
    }

    fp = fopen(charset_file, "r");

    if (fp == NULL) {
        fprintf(stderr, "Could not open file '%s'\n", charset_file);
        return 1;
    }

    fseek(fp, 0L, SEEK_END);
    charset_file_size = ftell(fp);
    fseek(fp, 0L, SEEK_SET);
    charset = malloc(charset_file_size + 1);
    fread(charset, 1, charset_file_size, fp);
    charset[charset_file_size] = 0;

    printf("symbols = {}\n");

    maxrows = 0;
    for (n = 0; n < charset_file_size; n++) {
        if (charset[n] == '\n') {
            maxrows++;
        }
    }

    if (charset[charset_file_size - 1] != '\n') {
        /* some text editors don't include a line break on
         * the last line */
        maxrows++;
    }


    charset_rows = malloc(sizeof(size_t) * maxrows);
    last = 0;
    maxrows = 0;

    for (n = 0; n < charset_file_size; n++) {
        if (charset[n] == '\n') {
            charset_rows[maxrows] = last;
            last = n + 1;
            maxrows++;
        }
    }

    if (charset[charset_file_size - 1] != '\n') {
        /* some text editors don't include a line break on
         * the last line */
        maxrows++;
        charset_rows[maxrows] = last;
    }


    maxcols = 32;
    charwidth = 8;
    charpos = 0;
    rowpos = 0;

    for (yoff = 0; yoff < h; yoff+= charwidth) {
        int len;
        const char *row;
        if (rowpos >= maxrows) break;
        row = &charset[charset_rows[rowpos]];
        charpos = 0;

        if (rowpos == (maxrows - 1)) {
            len = charset_file_size - charset_rows[rowpos];
        } else {
            len = charset_rows[rowpos + 1] - charset_rows[rowpos];
        }
        for (xoff = 0; xoff < w; xoff+= charwidth) {
            if (charpos >= maxcols || charpos >= len) continue;
            c = row[charpos];
            if (c != '\n') {
                print_char(buf, w, h, c, xoff, yoff);
            }
            charpos++;
        }

        rowpos++;
    }

    print_space();

    printf("return symbols\n");
    free(buf);
    free(charset);
    free(charset_rows);
    return 0;
}
