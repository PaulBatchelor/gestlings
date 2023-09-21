#include <stdlib.h>
/* #include <monome.h> */
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <stdint.h>
#include <sys/time.h>
#include <sys/ioctl.h>
#include <stdio.h>
#include <termios.h>
#include "btprnt/btprnt.h"
#include "sndkit/lil/lil.h"
#define MNOLTH_UF2_PRIV
#include "uf2.h"
#include "ortho33.h"
#include "engine.h"
#include "bitrune.h"

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

typedef struct bitrune_display {
    struct uf2_font uf2;
    btprnt *bp;
    int please_draw;
    int please_update;

    int scroll_jump;
    int symbol_jump;

    int is_running;
    uint8_t quadL[8];
    uint8_t quadR[8];

    btprnt_region main;
    btprnt_region window;

    int update;
    int cursorchange;
    int show_vscroll;
    int saved;
    int show_triplets;

    ortho33 *ortho;

    int length; /* in pixels */

    struct termios oldt;
    struct termios newt;

    int eval;
    char filename[128];
} bitrune_display;

struct bitrune {
    bitrune_engine *engine;
    bitrune_display display;
};

static void display_cleanup(bitrune_display *bd)
{
    btprnt_del(&bd->bp);
    ortho33_free(bd->ortho);
    free(bd->ortho);
}


void bitrune_del(bitrune **brp)
{
    bitrune *br;

    br = *brp;

    display_cleanup(&br->display);
    free(br->engine);
    free(br);
}

static void add_keyshapes(bitrune_display *bd, const char *keyshapesfile);
static void display_init(bitrune_display *bd, const char *fontfile, const char *keyshapesfile)
{
    int y;

    bd->please_draw = 0;
    bd->please_update = 0;
    bd->scroll_jump = -1;
    bd->symbol_jump = -1;
    bd->is_running = 1;
    bd->cursorchange = 0;
    bd->update = 0;
    bd->saved = 0;
    bd->ortho = malloc(ortho33_sizeof());
    ortho33_init(bd->ortho);
    bd->show_triplets = 1;
    bd->show_vscroll = 0;
    bd->bp = btprnt_new(128, 8);
    btprnt_region_init(btprnt_canvas_get(bd->bp), &bd->main, 0, 0, 128, 8);
    btprnt_region_init(btprnt_canvas_get(bd->bp), &bd->window, 0, 0, 16, 8);

    for (y = 0; y < 8; y++) {
        bd->quadL[y] = 0;
        bd->quadR[y] = 0;
    }
    bd->update = 1;
    bd->length = 0;

    uf2_load(&bd->uf2, fontfile);

    add_keyshapes(bd, keyshapesfile);

    bd->eval = 0;
}

bitrune * bitrune_new(const char *font, const char *shapes, const char *outfile)
{
    bitrune *br;
    br = malloc(sizeof(bitrune));

    br->engine = malloc(bitrune_engine_sizeof());
    bitrune_init(br->engine);
    strcpy(br->display.filename, outfile);
    bitrune_load(br->engine, br->display.filename);
    display_init(&br->display, font, shapes);

    return br;
}

static void set_led(int x, int y, int s, uint8_t *quadL, uint8_t *quadR)
{
    uint8_t *q;

    if (x >= 8) {
        q = quadR;
        x -= 8;
    } else {
        q = quadL;
    }

    if (s) {
        q[y] |= 1 << x;
    } else {
        q[y] &= ~(1 << x);
    }
}

void bitrune_monome_press(bitrune *br, int x, int y)
{
    bitrune_display *bd;

    bd = &br->display;
    if (y == 7) {
        bd->scroll_jump = x;
    }

    if (y == 0) {
        bd->symbol_jump = x;
    }

    bd->please_draw = 1;
}

#if 0
void handle_press(const monome_event_t *e, void *data) {
    unsigned int x, y;
    bitrune *br;

    br = data;
    x = e->grid.x;
    y = e->grid.y;
    bitrune_monome_press(br, x, y);
}

static void redraw(monome_t *m, uint8_t *quadL, uint8_t *quadR)
{
    monome_led_map(m, 0, 0, quadL);
    monome_led_map(m, 255, 0, quadR);
}
static void please_close(int sig)
{
    /*
    is_running = 0;
    */
}
#endif

static int xpos_from_cursor(struct uf2_font *fnt, int cursor, unsigned char *bytes)
{
    int i;
    int xpos;
    xpos = 0;
    for (i = 0; i < cursor; i++) {
        xpos += fnt->widths[bytes[i]];
    }
    return xpos;
}

int draw_symbols(btprnt_region *reg,
                 struct uf2_font *fnt,
                 bitrune_engine *br)
{
    int length;
    bitrune_row *row;
    int curpos;
    int nsyms;
    unsigned char *bytes;

    curpos = bitrune_curpos(br);
    row = bitrune_get_row(br, bitrune_currow(br));
    bytes = bitrune_row_data(row);
    nsyms = bitrune_row_length(row);

    length = btprnt_uf2_draw_bytes(reg, fnt, 0, 1, bytes, curpos, 1);
    /* draw cursor */
    btprnt_region_draw(reg, length, 0, 1);
    length += btprnt_uf2_draw_bytes(reg, fnt, length, 1, &bytes[curpos], nsyms - curpos, 1);

    return length;
}

static void process_valid_char(bitrune_display *bd, bitrune_engine *br, int c)
{
    btprnt_region *window;
    int cmd;
    ortho33 *ortho;

    window = &bd->window;
    ortho = bd->ortho;
    if (c == 'a') {
        window->x++;
        bd->update = 1;
        if (window->x > (127 - 16)) window->x = 127 - 16;
        return;
    } else if (c == 'b') {
        window->x--;
        bd->update = 1;
        if (window->x < 0) window->x = 0;
        return;
    }

    ortho33_process_input(ortho, c);
    bd->update = 1;

    cmd = ortho33_command(ortho);
    if (ortho33_is_command(cmd)) {
        switch (ortho33_get_command(cmd)) {
            case 3:
                ortho33_enter_navmode(ortho);
                break;
            case 7:
                bd->is_running = 0;
                break;
            case 6:
                bd->show_triplets ^= 1;
                break;
            case 9:
                bitrune_remove(br);
                bd->update = 1;
                bd->cursorchange = 1;
                break;
            case 2:
                bitrune_save(br, bd->filename);
                bd->saved = 1;
                break;
            case 5:
                bitrune_eval_line(br);
                bd->eval = 1;
                break;
            default:
                break;
        }
    } else if (ortho33_is_value(cmd)) {
        switch (cmd & 0xf) {
            case 1: /* right */
                bitrune_move_right(br);
                bd->update = 1;
                bd->cursorchange = 1;
                break;
            case 2: /* left */
                bitrune_move_left(br);
                bd->update = 1;
                bd->cursorchange = 1;
                break;
            case 3: /* up */
                bitrune_move_up(br);
                bd->update = 1;
                bd->cursorchange = 1;
                bd->show_vscroll = 1;
                break;
            case 4: /* down */
                bitrune_move_down(br);
                bd->update = 1;
                bd->cursorchange = 1;
                bd->show_vscroll = 1;
                break;
            case 5: /* northeast */
                bitrune_remove(br);
                bd->update = 1;
                bd->cursorchange = 1;
                break;
            case 8: /* center */
                bitrune_eval_line(br);
                bd->update = 1;
                bd->cursorchange = 1;
                bd->eval = 1;
                break;
            default: {
                int curval;
                curval = ortho33_curval(ortho);
                if (curval > 0) {
                    printf("curval: %d\n", curval);
                    bitrune_insert(br, curval);
                }
                bd->update = 1;
                bd->cursorchange = 1;
            }
            break;
        }
    }
}

void bitrune_process_input(bitrune *br, int c)
{
    if (c >= 0) {
        int valid_chars =
            (c >= '1' && c <= '9') ||
            (c == 'a' || c == 'b');

        if (!valid_chars) return;
        process_valid_char(&br->display, br->engine, c);
    }
}

static void update_display(bitrune_display *bd, bitrune_engine *br)
{
    ortho33 *ortho;
    uint8_t *quadL, *quadR;
    int x, y;
    btprnt_region *main;
    btprnt_region *window;
    struct uf2_font *uf2;

    ortho = bd->ortho;
    quadL = bd->quadL;
    quadR = bd->quadR;
    uf2 = &bd->uf2;

    main = &bd->main;
    window = &bd->window;

    if (bd->scroll_jump >= 0) {
        window->x = (bd->scroll_jump / (float)16) * bd->length;
        /* in update branch, scroll_jump is cleared */
        /* update must be set for this to work */
        bd->update = 1;
    }

    if (bd->symbol_jump >= 0) {
        int n;
        int xpos;
        int target;
        int curpos;
        unsigned char *bytes;
        bitrune_row *row;
        int nsyms;

        curpos = -1;
        xpos = 0;
        target = window->x + bd->symbol_jump;

        row = bitrune_get_row(br, bitrune_currow(br));
        bytes = bitrune_row_data(row);
        nsyms = bitrune_row_length(row);
        for (n = 0; n < nsyms; n++) {
            xpos += uf2->widths[bytes[n]];

            if (xpos > target) {
                curpos = n;
                bd->symbol_jump = -1;
                xpos -= uf2->widths[bytes[n]];

                if (xpos < window->x) {
                    window->x = xpos;
                }
                break;
            }
        }

        if (bd->symbol_jump >= 0) {
            curpos = nsyms;
            bitrune_set_curpos(br, curpos);
            bd->symbol_jump = -1;
        }

        if (curpos >= 0) {
            bitrune_set_curpos(br, curpos);
        }

        bd->update = 1;
    }

    if (bd->update) {
        int progress;
        int curpos;
        unsigned char *bytes;
        bitrune_row *row;
        bd->update = 0;
        btprnt_fill(main, 0);

        bd->please_draw = 1;
        curpos = bitrune_curpos(br);
        row = bitrune_get_row(br, bitrune_currow(br));
        bytes = bitrune_row_data(row);
        /* nsyms = bitrune_row_length(row); */

        bd->length = draw_symbols(main, &bd->uf2, br);
        /* update xpos if cursor is offscreen */
        if (bd->cursorchange) {
            int xpos;
            bd->cursorchange = 0;
            xpos = xpos_from_cursor(uf2, curpos, bytes);

            if ((xpos < window->x) || (xpos > (window->x + 15))) {
                window->x = xpos;
                /* try to add some padding */
                window->x -= 8;

                if (window->x < 0) {
                    window->x = xpos;
                }
            }
        }

        for (y = 0; y < 8; y++) {
            for (x = 0; x < 16; x++) {
                int b;
                b = btprnt_region_read(window, x, y);
                set_led(x, y, b, quadL, quadR);
            }
        }

        /* clear zero jump here */
        if (bd->scroll_jump >= 0) {
            progress = bd->scroll_jump;
            bd->scroll_jump = -1;
        } else {
            progress = ((float)window->x / bd->length)*16;
        }
        if (progress > 15) progress = 15;
        set_led(progress, 7, 1, quadL, quadR);

        /* visualize the 3x3 ortho keypad */

        if (bd->show_triplets) {
            if (ortho33_is_navmode(ortho)) {
                set_led(14, 5, 1, quadL, quadR);
                set_led(14, 6, 1, quadL, quadR);
                set_led(15, 6, 1, quadL, quadR);
                set_led(13, 6, 1, quadL, quadR);
                set_led(14, 7, 1, quadL, quadR);
            } else {
                int i;
                int *triplet;

                triplet = ortho33_triplet(ortho);
                for (i = 0; i < 9; i++) {
                    int bx, by;
                    int t;
                    int s;

                    bx = (i % 3);
                    by = (i / 3);

                    s = 0;

                    for (t = 0; t < 3; t++) {
                        if (triplet[t] == (i + 1)) s = 1;
                    }
                    set_led(13 + bx, (2 - by) + 5, s, quadL, quadR);
                }
            }
        }
    }

    /* vertical scrolling: shows which line are we on */

    if (bd->show_vscroll) {
        int currow;
        currow = bitrune_currow(br);
        /* scroll is only 5 tall to avoid the triplet box */
#if 0
        for(y = 0; y < 5; y++) {
            /* TODO: handle more than 5 */
            if (y == currow) set_led(15, y, 1, quadL, quadR);
            else set_led(15, y, 0, quadL, quadR);
        }
#endif
        /* render position in binary in 5 bits */
        for(y = 0; y < 5; y++) {
            if (currow & (1 << y)) set_led(15, y, 1, quadL, quadR);
            else set_led(15, y, 0, quadL, quadR);
        }
        bd->show_vscroll = 0;
    }

    if (bd->saved) {
        char pat[] = {
            0x7, /* ### */
            0x5, /* #-# */
            0x7, /* ### */
        };

        bd->saved = 0;

        for (x = 0; x < 3; x++) {
            for (y = 0; y < 3; y++) {
                set_led(13 + x, 5 + y, pat[y] & (1 <<x), quadL, quadR);
            }
        }
    }
}

void bitrune_update_display(bitrune *br)
{
    update_display(&br->display, br->engine);
}

int bitrune_draw(bitrune *br, int state)
{
    if (state > 0) br->display.please_draw = state;
    return br->display.please_draw;
}

static void apply_terminal_settings(bitrune_display *bd)
{
    tcgetattr(STDIN_FILENO, &bd->oldt);
    bd->newt = bd->oldt;
    bd->newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &bd->newt);
}

static void reset_terminal_settings(bitrune_display *bd)
{
    tcsetattr(STDIN_FILENO, TCSANOW, &bd->oldt);
}

int bitrune_getchar(void)
{
    int c, n;

    c = -1;

    if (ioctl(0, FIONREAD, &n) == 0 && n > 0) {
        c = getchar();
    }

    return c;
}

static int readbyte(FILE *fp,
                    unsigned char *buf,
                    int *nbytes,
                    int *pos)
{
    int c;
    if (*nbytes <= 0) return -1;
    if (*pos >= *nbytes) {
        *pos = 0;
        *nbytes = fread(buf, 1, 128, fp);
    }
    c = buf[*pos];
    *pos = (*pos) + 1;
    return c;
}

static void add_keyshapes(bitrune_display *bd, const char *keyshapesfile)
{
    ortho33 *ortho;
    FILE *fp;
    unsigned char *buf;
    int nbytes;
    int pos;
    int c;
    int nshapes;
    int shp;

    buf = malloc(128);
    fp = fopen(keyshapesfile, "r");

    nbytes = fread(buf, 1, 128, fp);

    pos = 0;

    ortho = bd->ortho;

    c = buf[pos];

    pos++;

    nshapes = 0;
    if ((c >> 4) == 0x9) {
        nshapes = c & 0xf;
    } else if (c == 0xdc) {
        nshapes = (buf[pos] << 8) | buf[pos + 1];
        pos+=2;
    }

    printf("reading in %d shapes\n", nshapes);

    /* a very, VERY brittle msgpack parser for the keyshapes */
    for (shp = 0; shp < nshapes; shp++) {
        int byte;
        char shape[4];
        int id;

        byte = readbyte(fp, buf, &nbytes, &pos);
        if (byte < 0) break;

        /* read in 2-element array, string and number */

        if (byte != 0x92) {
            printf("expected 2-element array byte, got 0x%x\n", byte);
            break;
        }

        byte = readbyte(fp, buf, &nbytes, &pos);
        if (byte < 0) break;

        if (byte != 0xa3) {
            printf("expected fixstr of size 3\n");
        }

        /* read in fixstr of 3 */
        byte = readbyte(fp, buf, &nbytes, &pos);
        if (byte < 0) break;
        shape[0] = byte;
        byte = readbyte(fp, buf, &nbytes, &pos);
        if (byte < 0) break;
        shape[1] = byte;
        byte = readbyte(fp, buf, &nbytes, &pos);
        if (byte < 0) break;
        shape[2] = byte;
        shape[3] = 0;

        /* read id, fixnum or uint8 */
        byte = readbyte(fp, buf, &nbytes, &pos);
        if (byte < 0) break;

        if ((byte >> 7) == 0) {
            id = byte;
        } else if (byte == 0xcc) {
            byte = readbyte(fp, buf, &nbytes, &pos);
            if (byte < 0) break;
            id = byte;
        } else {
            printf("expected fixint or uint8\n");
            break;
        }
        ortho33_add_triplet(ortho, shape, id);
    }

    fclose(fp);
    free(buf);
}

int bitrune_is_running(bitrune *br)
{
    return br->display.is_running;
}

void bitrune_quads(bitrune *br, uint8_t **quadL, uint8_t **quadR)
{
    *quadL = br->display.quadL;
    *quadR = br->display.quadR;
}

void bitrune_terminal_setup(bitrune *br)
{
    apply_terminal_settings(&br->display);
}

void bitrune_terminal_reset(bitrune *br)
{
    reset_terminal_settings(&br->display);
}

int bitrune_message_available(bitrune *br)
{
    return br->display.eval;
}

void bitrune_message_markasread(bitrune *br)
{
    br->display.eval = 0;
}

const char * bitrune_message_pop(bitrune *br)
{
    const char *msg;
    if (!bitrune_message_available(br)) return NULL;
    msg = bitrune_message(br->engine);
    bitrune_message_markasread(br);
    return msg;
}


static int newbitrune(lua_State *L)
{
    const char *font;
    const char *keyshapes;
    const char *outfile;
    bitrune *br;

    font = lua_tostring(L, 1);
    keyshapes = lua_tostring(L, 2);
    outfile = lua_tostring(L, 3);


    br = bitrune_new(font, keyshapes, outfile);

    lua_pushlightuserdata(L, br);
    return 1;
}

static int delbitrune(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);

    bitrune_del(&br);
    return 0;
}

static int terminal_setup(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);
    bitrune_terminal_setup(br);
    return 0;
}

static int terminal_reset(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);
    bitrune_terminal_reset(br);
    return 0;
}

static int running(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);

    lua_pushboolean(L, bitrune_is_running(br));

    return 1;
}

static int monome_press(lua_State *L)
{
    bitrune *br;
    int x, y;

    br = lua_touserdata(L, 1);
    x = lua_tointeger(L, 2);
    y = lua_tointeger(L, 3);

    bitrune_monome_press(br, x, y);

    return 0;
}

#define BUFFER_MAX 64
static int br_getchar(lua_State *L)
{
    int i;

    lua_createtable(L, 1, 0);
    for (i = 0; i < BUFFER_MAX; i++) {
        int c;
        c = bitrune_getchar();
        if (c == -1) break;
        lua_pushinteger(L, i + 1);
        lua_pushinteger(L, c);
        lua_settable(L, -3);
    }
    return 1;
}

static int br_process_input(lua_State *L)
{
    bitrune *br;
    int c;

    br = lua_touserdata(L, 1);
    c = lua_tointeger(L, 2);

    bitrune_process_input(br, c);

    return 0;
}

static int l_message_available(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);

    lua_pushboolean(L, bitrune_message_available(br));

    return 1;
}

static int l_message_pop(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);

    lua_pushstring(L, bitrune_message_pop(br));

    return 1;
}

static int l_update_display(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);

    bitrune_update_display(br);

    return 0;
}

static int l_please_draw(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);

    lua_pushboolean(L, bitrune_draw(br, -1));

    return 1;
}

static int l_draw(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);

    bitrune_draw(br, 0);

    return 0;
}

static int l_quads(lua_State *L)
{
    bitrune *br;
    int row;
    uint8_t *quadL, *quadR;

    br = lua_touserdata(L, 1);

    bitrune_quads(br, &quadL, &quadR);

    lua_createtable(L, 8, 0);
    for (row = 0; row < 8; row++) {
        lua_pushinteger(L, row + 1);
        lua_pushinteger(L, quadL[row]);
        lua_settable(L, -3);
    }

    lua_createtable(L, 8, 0);
    for (row = 0; row < 8; row++) {
        lua_pushinteger(L, row + 1);
        lua_pushinteger(L, quadR[row]);
        lua_settable(L, -3);
    }

    return 2;
}

static int l_linepos(lua_State *L)
{
    bitrune *br;
    int row;

    br = lua_touserdata(L, 1);
    row = bitrune_currow(br->engine);
    lua_pushinteger(L, row);
    return 1;
}

static int l_start(lua_State *L)
{
    bitrune *br;

    br = lua_touserdata(L, 1);
    br->display.is_running = 1;
    return 0;
}

static const luaL_Reg bitrune_lib[] = {
    {"new", newbitrune},
    {"del", delbitrune},
    {"terminal_setup", terminal_setup},
    {"terminal_reset", terminal_reset},
    {"running", running},
    {"monome_press", monome_press},
    {"getchar", br_getchar},
    {"process_input", br_process_input},
    {"message_available", l_message_available},
    {"message_pop", l_message_pop},
    {"update_display", l_update_display},
    {"quads", l_quads},
    {"please_draw", l_please_draw},
    {"draw", l_draw},
    {"linepos", l_linepos},
    {"start", l_start},
    {NULL, NULL}
};

int luaopen_bitrune(lua_State *L)
{
    luaL_newlib(L, bitrune_lib);
    return 1;
}
