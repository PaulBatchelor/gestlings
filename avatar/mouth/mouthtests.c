#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

#include "btprnt/btprnt.h"

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif
#include "mathc/mathc.h"

#include "sdf2d/sdf.h"

#define SDF2D_SDFVM_PRIV
#include "sdf2d/sdfvm.h"

typedef struct {
    struct vec2 iResolution;
    void *ud;
    struct vec4 *region;
    btprnt_region *bpreg;
} image_data;

struct canvas {
    struct vec3 *buf;
    struct vec2 res;
    btprnt_region *reg;
};

typedef struct {
    sdfvm vm;
} user_params;

#define US_MAXTHREADS 8

typedef struct thread_userdata thread_userdata;

typedef struct {
    struct vec3 *buf;
    image_data *data;
    int off;
    void (*draw)(struct vec3 *, struct vec2, thread_userdata *);
    int stride;
    sdfvm vm;
} thread_data;

struct thread_userdata {
    thread_data *th;
    image_data *data;
};

void *draw_thread(void *arg)
{
    thread_data *td;
    image_data *data;
    int x, y;
    int w, h;
    int stride;
    struct vec3 *buf;
    int nthreads;
    int xstart, ystart;
    int xend, yend;
    int maxpos;
    struct vec4 *reg;
    thread_userdata thud;
    btprnt_region *bpreg;

    td = arg;
    data = td->data;
    buf = td->buf;

    w = data->iResolution.x;
    h = data->iResolution.y;
    stride = td->stride;
    reg = data->region;

    bpreg = data->bpreg;

    ystart = td->off + reg->y;
    xstart = reg->x;
    xend = reg->z + reg->x;
    yend = reg->w + reg->y;

    /* This is hard-coded for now */
    nthreads = US_MAXTHREADS;

    maxpos = w * h;

    thud.th = td;
    thud.data = data;
    for (y = ystart; y < yend; y+=nthreads) {
        for (x = xstart; x < xend; x++) {
            int pos;
            struct vec3 *c;
            int bit;
            pos = y*stride + x;

            if (pos > maxpos || pos < 0) continue;
            c = &buf[pos];
            td->draw(c, svec2(x - reg->x, y - reg->y), &thud);

            /* flipped because in btprnt 1 is black, 0 white */
            bit = c->x < 0.5 ? 1 : 0;
            btprnt_region_draw(bpreg, x, y, bit);
        }
    }

    return NULL;
}

void draw_with_stride(struct vec3 *buf,
                      struct vec2 res,
                      struct vec4 region,
                      void (*drawfunc)(struct vec3 *, struct vec2, thread_userdata *),
                      void *ud,
                      int stride,
                      btprnt_region *bpreg)
{
    thread_data td[US_MAXTHREADS];
    pthread_t thread[US_MAXTHREADS];
    int t;
    image_data data;

    data.iResolution = res;
    data.ud = ud;
    data.region = &region;
    data.bpreg = bpreg;

    for (t = 0; t < US_MAXTHREADS; t++) {
        td[t].buf = buf;
        td[t].data = &data;
        td[t].off = t;
        td[t].draw = drawfunc;
        td[t].stride = stride;
        sdfvm_init(&td[t].vm);
        pthread_create(&thread[t], NULL, draw_thread, &td[t]);
    }

    for (t = 0; t < US_MAXTHREADS; t++) {
        pthread_join(thread[t], NULL);
    }
}

void draw(struct vec3 *buf,
          struct vec2 res,
          struct vec4 region,
          void (*drawfunc)(struct vec3 *, struct vec2, thread_userdata *),
          void *ud,
          btprnt_region *reg)
{
    draw_with_stride(buf, res, region, drawfunc, ud, res.x, reg);
}

struct vec3 rgb2color(int r, int g, int b)
{
    float scale = 1.0 / 255;
    return svec3(r * scale, g * scale, b * scale);
}

static int mkcolor(float x)
{
    return floor(x * 255);
}

static void d_fill(struct vec3 *fragColor,
                   struct vec2 fragCoord,
                   thread_userdata *thud)
{
    image_data *id;
    struct vec3 *col;
    id = thud->data;

    col = id->ud;
    *fragColor = *col;
}

static void fill(struct canvas *ctx, struct vec3 clr)
{
    draw(ctx->buf, ctx->res,
         svec4(0, 0, ctx->res.x, ctx->res.y),
         d_fill, &clr, ctx->reg);
}

static void write_ppm(struct vec3 *buf,
                      struct vec2 res,
                      const char *filename)
{
    int x, y;
    FILE *fp;
    unsigned char *ibuf;

    fp = fopen(filename, "w");
    fprintf(fp, "P5\n%d %d\n%d\n", (int)res.x, (int)res.y, 255);

    ibuf = malloc(res.y * res.x * sizeof(unsigned char));
    for (y = 0; y < res.y; y++) {
        for (x = 0; x < res.x; x++) {
            int pos;
            pos = y * res.x + x;
            ibuf[pos] = mkcolor(buf[pos].x);
        }
    }

    fwrite(ibuf, res.y * res.x * sizeof(unsigned char), 1, fp);
    free(ibuf);
    fclose(fp);
}

void draw_gridlines(struct canvas *ctx)
{
    int x, y;
    int w, h;
    int size;

    w = ctx->res.x;
    h = ctx->res.y;

    size = w / 4;

    for (y = 0; y < h; y += size) {
        for (x = 0; x < w; x++) {
            int pos;
            pos = y*w + x;
            ctx->buf[pos] = svec3_zero();
        }
    }

    for (x = 0; x < w; x += size) {
        for (y = 0; y < h; y++) {
            int pos;
            pos = y*w + x;
            ctx->buf[pos] = svec3_zero();
        }
    }

}

static void draw_color(sdfvm *vm,
                       struct vec2 p,
                       struct vec3 *fragColor)
{
    struct vec2 points[4];
    int i;
    struct vec3 col;

    points[0] = svec2(-0.5, 0.5);
    points[1] = svec2(-0.1, -0.5);
    points[2] = svec2(0.1, -0.5);
    points[3] = svec2(0.5, 0.5);

    sdfvm_push_vec2(vm, p);
    for (i = 0; i < 4; i++) {
        sdfvm_push_vec2(vm, points[i]);
    }
    sdfvm_poly4(vm);
    sdfvm_push_scalar(vm, 0.1);
    sdfvm_roundness(vm);

    sdfvm_push_vec2(vm, p);
    sdfvm_push_scalar(vm, 0.7);
    sdfvm_circle(vm);
    sdfvm_push_scalar(vm, 0.1);
    sdfvm_lerp(vm);

    sdfvm_push_scalar(vm, -1.0);
    sdfvm_mul(vm);

    sdfvm_gtz(vm);

    sdfvm_push_vec3(vm, *fragColor);
    sdfvm_push_vec3(vm, svec3_zero());
    sdfvm_lerp3(vm);

    sdfvm_pop_vec3(vm, &col);

    *fragColor = col;
}

static void d_polygon(struct vec3 *fragColor,
                      struct vec2 st,
                      thread_userdata *thud)
{
    struct vec2 p;
    image_data *id;
    struct vec2 res;
    sdfvm *vm;

    id = thud->data;
    vm = &thud->th->vm;

    res = svec2(id->region->z, id->region->w);
    sdfvm_push_vec2(vm, svec2(st.x, st.y));
    sdfvm_push_vec2(vm, res);
    sdfvm_normalize(vm);
    sdfvm_pop_vec2(vm, &p);
    p.y = p.y*-1;

    draw_color(vm, p, fragColor);
}

void polygon(struct canvas *ctx,
           float x, float y,
           float w, float h,
           user_params *p)
{
    draw(ctx->buf, ctx->res, svec4(x, y, w, h), d_polygon, p, ctx->reg);
}

int main(int argc, char *argv[])
{
    struct vec3 *buf;
    int width, height;
    struct vec2 res;
    struct canvas ctx;
    int sz;
    int clrpos;
    user_params params;
    btprnt *bp;
    btprnt_region reg;

    bp = btprnt_new(512, 512);

    width = 512;
    height = 512;
    clrpos = 0;

    btprnt_region_init(btprnt_canvas_get(bp),
                       &reg, 0, 0,
                       512, 512);
    sz = width / 1;

    res = svec2(width, height);

    buf = malloc(width * height * sizeof(struct vec3));

    ctx.res = res;
    ctx.buf = buf;
    ctx.reg = &reg;

    sdfvm_init(&params.vm);

    fill(&ctx, svec3(1., 1.0, 1.0));
    polygon(&ctx, 0, 0, sz, sz, &params);
    clrpos = (clrpos + 1) % 5;

    write_ppm(buf, res, "mouthtests.pgm");

    btprnt_pbm(bp, "out.pbm");

    free(buf);
    btprnt_del(&bp);
    return 0;
}