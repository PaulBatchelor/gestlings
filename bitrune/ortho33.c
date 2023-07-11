/* ortho33: a test input system for 3-shapes on a 3x3
 * ortho grid.
 * use a number pad to enter in ortho shapes
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ortho33.h"

/* TODO: revisit these flags */
#define COMMAND_FLAG 0x100
#define VALUE_FLAG 0x1000

struct btree9 {
    int val;
    struct btree9 *tree[9];
};

static void tree_init(struct btree9 *tree)
{
    int i;

    for (i = 0; i < 9; i++) {
        tree->tree[i] = NULL;
    }
    tree->val = 0;
}

struct ortho33 {
    struct btree9 tree;
    int steps;
    int nitems;
    int last;
    int cmdmode;
    int triplet[3];
    int curval;
    int command;
    int navmode;
};

int duplicates(int *t, int c, int n)
{
    int i;

    for (i = 0; i < n; i++) {
        if (t[i] == c) return 1;
    }

    return 0;
}

void sort_triplet(int *trip)
{
    int tmp;

    if (trip[0] > trip[1]) {
        tmp = trip[0];
        trip[0] = trip[1];
        trip[1] = tmp;
    }

    if (trip[0] > trip[2]) {
        tmp = trip[2];
        trip[2] = trip[0];
        trip[0] = tmp;
    }

    if (trip[1] > trip[2]) {
        tmp = trip[2];
        trip[2] = trip[1];
        trip[1] = tmp;
    }
}


void add_triplet(struct btree9 *tree, const char *xyz, int val)
{
    struct btree9 *tree_x;
    struct btree9 *tree_y;
    struct btree9 *tree_z;
    int triplet[3];
    int x, y, z;

    triplet[0] = xyz[0] - 0x30;
    triplet[1] = xyz[1] - 0x30;
    triplet[2] = xyz[2] - 0x30;
    sort_triplet(triplet);

    x = triplet[0];
    y = triplet[1];
    z = triplet[2];

    x--; y--; z--;
    if (x < 0 || x > 8) return;
    if (y < 0 || y > 8) return;
    if (z < 0 || z > 8) return;

    if (tree->tree[x] == NULL) {
        tree->tree[x] = malloc(sizeof(struct btree9));
        tree_init(tree->tree[x]);
    }

    tree_x = tree->tree[x];

    if (tree_x->tree[y] == NULL) {
        tree_x->tree[y] = malloc(sizeof(struct btree9));
        tree_init(tree_x->tree[y]);
    }

    tree_y = tree_x->tree[y];

    if (tree_y->tree[z] == NULL) {
        tree_y->tree[z] = malloc(sizeof(struct btree9));
        tree_init(tree_y->tree[z]);
    }

    tree_z = tree_y->tree[z];

    tree_z->val = val;
}

void ortho33_add_triplet(ortho33 *orth, const char *xyz, int val)
{
    add_triplet(&orth->tree, xyz, val);
}

void ortho33_init(ortho33 *orth)
{
    struct btree9 *tree;

    tree = &orth->tree;

    tree_init(tree);

    orth->steps = 0;
    orth->nitems = 0;
    orth->last = -1;
    orth->cmdmode = 0;
    orth->triplet[0] = orth->triplet[1] = orth->triplet[2] = -1;
    orth->curval = 0;
    orth->command = 0;
    orth->navmode = 0;
}

int lookup(struct btree9 *tree, int x, int y, int z)
{
    struct btree9 *tree_x;
    struct btree9 *tree_y;
    struct btree9 *tree_z;

    x--; y--; z--;
    if (x < 0 || x > 8) return 0;
    if (y < 0 || y > 8) return 0;
    if (z < 0 || z > 8) return 0;

    tree_x = tree->tree[x];

    if (tree_x == NULL) return 0;

    tree_y = tree_x->tree[y];

    if (tree_y == NULL) return 0;

    tree_z = tree_y->tree[z];

    if (tree_z == NULL) return 0;

    return tree_z->val;
}

void ortho33_free(ortho33 *orth)
{
    int x, y, z;
    struct btree9 *tree;

    tree = &orth->tree;
    for (x = 0; x < 9; x++) {
        struct btree9 *tree_x;
        tree_x = tree->tree[x];
        if (tree_x != NULL) {
            for (y = 0; y < 9; y++) {
                struct btree9 *tree_y;
                tree_y = tree_x->tree[y];

                if (tree_y != NULL) {
                    for (z = 0; z < 9; z++) {
                        struct btree9 *tree_z;
                        tree_z = tree_y->tree[z];
                        if (tree_z != NULL) free(tree_z);
                    }
                    free(tree_y);
                }
            }
            free(tree_x);
        }
    }
}

static void process_input(int c, ortho33 *orth)
{
    int *triplet;

    triplet = orth->triplet;
    orth->command = 0;
    /* handle encoder */
    if (c == 'a' || c == 'b') {
        if (c == 'a') {
            orth->steps++;
        } else {
            orth->steps--;
        }

        if (orth->steps < 0) orth->steps = 0;

        if (orth->steps > 40) orth->steps = 40;

        return;
    }

    if (orth->navmode) {
        c -= 0x30;

        switch(c) {
            case 6: /* left */
                orth->command = VALUE_FLAG | 1;
                break;
            case 4: /* right */
                orth->command = VALUE_FLAG | 2;
                break;
            case 8: /* up */
                orth->command = VALUE_FLAG | 3;
                break;
            case 2: /* down */
                orth->command = VALUE_FLAG | 4;
                break;
            case 1: /* escape */
                orth->command = 0;
                orth->navmode = 0;
                break;
            case 9: /* northeast */
                orth->command = VALUE_FLAG | 5;
                break;
            case 3: /* southeast */
                orth->command = VALUE_FLAG | 6;
                break;
            case 7: /* northwest */
                orth->command = VALUE_FLAG | 7;
                break;
            case 5: /* center */
                orth->command = VALUE_FLAG | 8;
                break;
            default:
                break;
        }

        return;
    }

    {
        /* convert char to number */
        c -= 0x30;

        if (orth->nitems >= 3) {
            orth->nitems = 0;
            orth->last = -1;
            triplet[0] = triplet[1] = triplet[2] = -1;
        }


        /* nitems state here is a bit wonky, depending
         * on the edge case it will have either rolled
         * back to 0 or will just be about to in this
         * part of the code.
         */
        if ((orth->nitems == 0 || orth->nitems >= 3) && c == 1) {
            if (orth->cmdmode) orth->cmdmode = 0;
            else {
                orth->cmdmode = 1;
            }
            return;
        }
    }

    {
        if (orth->cmdmode) {
            orth->cmdmode = 0;
            orth->command = c | COMMAND_FLAG;
            return;
        }
    }

    {
        if (!duplicates(triplet, c, orth->nitems) && orth->last != c) {
            triplet[orth->nitems] = c;
            orth->nitems++;
            orth->last = c;

            if (orth->nitems >= 3) {
                sort_triplet(triplet);
                orth->curval = lookup(&orth->tree, triplet[0], triplet[1], triplet[2]);
                orth->command = VALUE_FLAG;
            }
        } else {
            orth->nitems = 0;
            triplet[0] = triplet[1] = triplet[2] = -1;
            orth->last = c;
        }
    }
}

void ortho33_process_input(ortho33 *orth, int c)
{
    process_input(c, orth);
}

size_t ortho33_sizeof(void)
{
    return sizeof(ortho33);
}

int ortho33_steps(ortho33 *orth)
{
    return orth->steps;
}

int ortho33_curval(ortho33 *orth)
{
    return orth->curval;
}

int* ortho33_triplet(ortho33 *orth)
{
    return orth->triplet;
}

int ortho33_nitems(ortho33 *orth)
{
    return orth->nitems;
}

int ortho33_command(ortho33 *orth)
{
    return orth->command;
}

int ortho33_is_command(int cmd)
{
    return cmd & COMMAND_FLAG;
}

int ortho33_get_command(int cmd)
{
    return cmd & ~COMMAND_FLAG;
}

int ortho33_is_value(int cmd)
{
    return cmd & VALUE_FLAG;
}

void ortho33_enter_navmode(ortho33 *orth)
{
    orth->navmode = 1;
}

int ortho33_is_navmode(ortho33 *orth)
{
    return orth->navmode;
}
