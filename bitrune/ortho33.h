#ifndef ORTHO33_H
#define ORTHO33_H
typedef struct ortho33 ortho33;

void ortho33_init(ortho33 *orth);

void ortho33_init(ortho33 *orth);
void ortho33_add_triplet(ortho33 *orth, const char *xyz, int val);
int ortho33_step(ortho33 *orth, int c);
void ortho33_free(ortho33 *orth);
size_t ortho33_sizeof(void);

int ortho33_steps(ortho33 *orth);
int ortho33_curval(ortho33 *orth);
int* ortho33_triplet(ortho33 *orth);
int ortho33_nitems(ortho33 *orth);
int ortho33_command(ortho33 *orth);
void ortho33_process_input(ortho33 *orth, int c);

int ortho33_is_command(int cmd);
int ortho33_get_command(int cmd);
int ortho33_is_value(int cmd);

void ortho33_enter_navmode(ortho33 *orth);
int ortho33_is_navmode(ortho33 *orth);
#endif
