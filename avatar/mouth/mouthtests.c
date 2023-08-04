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
    void *ud;
    struct vec4 region;
    btprnt_region *bpreg;
} image_data;

#define US_MAXTHREADS 8

typedef struct thread_userdata thread_userdata;

typedef struct {
    image_data *data;
    int off;
    void (*draw)(float *, struct vec2, thread_userdata *);
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
    int nthreads;
    int xstart, ystart;
    int xend, yend;
    struct vec4 *reg;
    thread_userdata thud;
    btprnt_region *bpreg;

    td = arg;
    data = td->data;

    reg = &data->region;

    bpreg = data->bpreg;

    ystart = td->off + reg->y;
    xstart = reg->x;
    xend = reg->z + reg->x;
    yend = reg->w + reg->y;

    /* This is hard-coded for now */
    nthreads = US_MAXTHREADS;

    thud.th = td;
    thud.data = data;
    for (y = ystart; y < yend; y+=nthreads) {
        for (x = xstart; x < xend; x++) {
            float c;
            int bit;

            c = 1.0;
            td->draw(&c, svec2(x - reg->x, y - reg->y), &thud);

            /* flipped because in btprnt 1 is black, 0 white */
            bit = c < 0.5 ? 1 : 0;
            btprnt_region_draw(bpreg, x, y, bit);
        }
    }

    return NULL;
}

void draw_with_stride(void (*drawfunc)(float *, struct vec2, thread_userdata *),
                      void *ud,
                      btprnt_region *bpreg)
{
    thread_data td[US_MAXTHREADS];
    pthread_t thread[US_MAXTHREADS];
    int t;
    image_data data;

    data.ud = ud;
    /* data.region = svec4(bpreg->x, bpreg->y, bpreg->w, bpreg->h); */
    /* I don't think btprnt offsets are needed, that's only for btprnt canvas */
    data.region = svec4(0, 0, bpreg->w, bpreg->h);
    data.bpreg = bpreg;

    for (t = 0; t < US_MAXTHREADS; t++) {
        td[t].data = &data;
        td[t].off = t;
        td[t].draw = drawfunc;
        sdfvm_init(&td[t].vm);
        pthread_create(&thread[t], NULL, draw_thread, &td[t]);
    }

    for (t = 0; t < US_MAXTHREADS; t++) {
        pthread_join(thread[t], NULL);
    }
}

void draw(void (*drawfunc)(float *, struct vec2, thread_userdata *),
          void *ud,
          btprnt_region *reg)
{
    draw_with_stride(drawfunc, ud, reg);
}

struct vec3 rgb2color(int r, int g, int b)
{
    float scale = 1.0 / 255;
    return svec3(r * scale, g * scale, b * scale);
}

static void d_fill(float *fragColor,
                   struct vec2 fragCoord,
                   thread_userdata *thud)
{
    image_data *id;
    float *col;
    id = thud->data;

    col = id->ud;
    *fragColor = *col;
}

static void fill(btprnt_region *reg, float clr)
{
    draw(d_fill, &clr, reg);
}

typedef struct {
    struct vec2 points[4];
    float circleness;
    float roundedge;
    float circrad;
} mouthshape;

static void mouth1_program(sdfvm *vm,
                           struct vec2 p,
                           mouthshape *m,
                           float *fragColor)
{
    struct vec2 *points;
    int i;
    float col;

    points = m->points;
    sdfvm_push_vec2(vm, p);

    for (i = 0; i < 4; i++) {
        sdfvm_push_vec2(vm, points[i]);
    }

    sdfvm_poly4(vm);
    sdfvm_push_scalar(vm, m->roundedge);
    sdfvm_roundness(vm);

    sdfvm_push_vec2(vm, p);
    sdfvm_push_scalar(vm, m->circrad);
    sdfvm_circle(vm);
    sdfvm_push_scalar(vm, m->circleness);
    sdfvm_lerp(vm);

    sdfvm_gtz(vm);

    sdfvm_push_scalar(vm, *fragColor);
    sdfvm_push_scalar(vm, 0.0);
    sdfvm_lerp(vm);

    sdfvm_pop_scalar(vm, &col);

    *fragColor = col;
}

static void d_mouth1(float *fragColor,
                     struct vec2 st,
                     thread_userdata *thud)
{
    struct vec2 p;
    image_data *id;
    struct vec2 res;
    sdfvm *vm;
    mouthshape *m;

    id = thud->data;
    vm = &thud->th->vm;

    m = id->ud;

    res = svec2(id->region.z, id->region.w);
    sdfvm_push_vec2(vm, svec2(st.x, st.y));
    sdfvm_push_vec2(vm, res);
    sdfvm_normalize(vm);
    sdfvm_pop_vec2(vm, &p);
    p.y = p.y*-1;

    mouth1_program(vm, p, m, fragColor);
}

void mouth1(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.1;
    m.roundedge = 0.1;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.5, 0.5);
    points[1] = svec2(-0.1, -0.5);
    points[2] = svec2(0.1, -0.5);
    points[3] = svec2(0.5, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth2(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.1;
    m.roundedge = 0.1;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.1, 0.5);
    points[1] = svec2(-0.5, -0.5);
    points[2] = svec2(0.5, -0.5);
    points[3] = svec2(0.1, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth1b(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.8;
    m.roundedge = 0.1;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.5, 0.5);
    points[1] = svec2(-0.1, -0.5);
    points[2] = svec2(0.1, -0.5);
    points[3] = svec2(0.5, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth2b(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.8;
    m.roundedge = 0.1;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.1, 0.5);
    points[1] = svec2(-0.5, -0.5);
    points[2] = svec2(0.5, -0.5);
    points[3] = svec2(0.1, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth3(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.0;
    m.roundedge = 0.08;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.5, 0.02);
    points[1] = svec2(-0.5, -0.02);
    points[2] = svec2(0.5, -0.02);
    points[3] = svec2(0.5, 0.02);

    draw(d_mouth1, &m, reg);
}

void mouth3b(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.1;
    m.roundedge = 0.08;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.5, 0.02);
    points[1] = svec2(-0.5, -0.02);
    points[2] = svec2(0.5, -0.02);
    points[3] = svec2(0.5, 0.02);

    draw(d_mouth1, &m, reg);
}

void mouth4(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.0;
    m.roundedge = 0.08;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.2, 0.6);
    points[1] = svec2(-0.02, -0.6);
    points[2] = svec2(0.02, -0.6);
    points[3] = svec2(0.2, 0.6);

    draw(d_mouth1, &m, reg);
}

void mouth4b(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.3;
    m.roundedge = 0.08;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.2, 0.6);
    points[1] = svec2(-0.02, -0.6);
    points[2] = svec2(0.02, -0.6);
    points[3] = svec2(0.2, 0.6);

    draw(d_mouth1, &m, reg);
}

void mouth5(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.9;
    m.roundedge = 0.08;
    m.circrad = 0.3;
    points = m.points;
    points[0] = svec2(-0.5, 0.5);
    points[1] = svec2(-0.1, -0.5);
    points[2] = svec2(0.1, -0.5);
    points[3] = svec2(0.5, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth1c(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.0;
    m.roundedge = 0.0;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.5, 0.5);
    points[1] = svec2(-0.1, -0.5);
    points[2] = svec2(0.1, -0.5);
    points[3] = svec2(0.5, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth2c(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.0;
    m.roundedge = 0.0;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.1, 0.5);
    points[1] = svec2(-0.5, -0.5);
    points[2] = svec2(0.5, -0.5);
    points[3] = svec2(0.1, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth6(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.3;
    m.roundedge = 0.01;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.7, 0.7);
    points[1] = svec2(-0.4, -0.4);
    points[2] = svec2(0.4, -0.5);
    points[3] = svec2(0.5, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth7(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;
    float shearx;

    shearx = 0.2;
    m.circleness = 0.1;
    m.roundedge = 0.05;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.3 + shearx, 0.5);
    points[1] = svec2(-0.3 - shearx, -0.5);
    points[2] = svec2(0.3 - shearx, -0.5);
    points[3] = svec2(0.3 + shearx, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth7b(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;
    float shearx;

    shearx = 0.5;
    m.circleness = 0.0;
    m.roundedge = 0.1;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.3 - shearx, 0.5);
    points[1] = svec2(-0.3 + shearx, -0.5);
    points[2] = svec2(0.3 + shearx, -0.5);
    points[3] = svec2(0.3 - shearx, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth2d(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.1;
    m.roundedge = 0.1;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.1, 0.5);
    points[1] = svec2(-0.8, 0.3);
    points[2] = svec2(0.8, 0.3);
    points[3] = svec2(0.1, 0.5);

    draw(d_mouth1, &m, reg);
}

void mouth1d(btprnt_region *reg)
{
    mouthshape m;
    struct vec2 *points;

    m.circleness = 0.1;
    m.roundedge = 0.1;
    m.circrad = 0.7;
    points = m.points;
    points[0] = svec2(-0.8, 0.5);
    points[1] = svec2(-0.1, 0.3);
    points[2] = svec2(0.1, 0.3);
    points[3] = svec2(0.8, 0.5);

    draw(d_mouth1, &m, reg);
}

int main(int argc, char *argv[])
{
    btprnt *bp;
    btprnt_region rmain;
    btprnt_region reg;
    int i;

    bp = btprnt_new(512, 512);

    btprnt_region_init(btprnt_canvas_get(bp),
                       &rmain, 0, 0,
                       512, 512);

    fill(&rmain, 1.0);
    btprnt_layout_grid(&rmain, 4, 4, 0, 0, &reg);
    mouth1(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 1, 0, &reg);
    mouth2(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 2, 0, &reg);
    mouth1b(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 3, 0, &reg);
    mouth2b(&reg);

    btprnt_layout_grid(&rmain, 4, 4, 0, 1, &reg);
    mouth3(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 1, 1, &reg);
    mouth3b(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 2, 1, &reg);
    mouth4(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 3, 1, &reg);
    mouth4b(&reg);

    btprnt_layout_grid(&rmain, 4, 4, 0, 2, &reg);
    mouth5(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 1, 2, &reg);
    mouth1c(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 2, 2, &reg);
    mouth2c(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 3, 2, &reg);
    mouth6(&reg);

    btprnt_layout_grid(&rmain, 4, 4, 0, 3, &reg);
    mouth7(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 1, 3, &reg);
    mouth7b(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 2, 3, &reg);
    mouth2d(&reg);
    btprnt_layout_grid(&rmain, 4, 4, 3, 3, &reg);
    mouth1d(&reg);

    for (i = 0; i < 4; i++) {
        btprnt_draw_hline(&rmain, 0, (i + 1)*128, 512, 1);
        btprnt_draw_vline(&rmain, (i + 1)*128, 0, 512, 1);
    }

    btprnt_pbm(bp, "out.pbm");

    btprnt_del(&bp);
    return 0;
}
