#ifndef ENGINE_H
#define ENGINE_H
typedef struct bitrune_row bitrune_row;
typedef struct bitrune_engine bitrune_engine;
int bitrune_curpos(bitrune_engine *br);
void bitrune_init(bitrune_engine *br);
void bitrune_move_left(bitrune_engine *br);
void bitrune_move_right(bitrune_engine *br);
void bitrune_move_up(bitrune_engine *br);
void bitrune_move_down(bitrune_engine *br);
void bitrune_place(bitrune_engine *br, int c);
void bitrune_insert(bitrune_engine *br, int c);
void bitrune_remove(bitrune_engine *br);
void bitrune_eval_line(bitrune_engine *br);
void bitrune_eval_block(bitrune_engine *br);
size_t bitrune_engine_sizeof(void);
bitrune_row* bitrune_get_row(bitrune_engine *br, int rowpos);
unsigned char * bitrune_row_data(bitrune_row *row);
int bitrune_row_length(bitrune_row *row);
void bitrune_set_curpos(bitrune_engine *br, int curpos);
int bitrune_currow(bitrune_engine *br);
void bitrune_save(bitrune_engine *br, const char *filename);
void bitrune_load(bitrune_engine *br, const char *filename);
void bitrune_eval_line(bitrune_engine *br);
const char *bitrune_message(bitrune_engine *br);
#endif
