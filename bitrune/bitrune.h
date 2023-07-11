#ifndef BITRUNE_H
#define BITRUNE_H
typedef struct bitrune bitrune;
int bitrune_getchar(void);
bitrune * bitrune_new(const char *font, const char *shapes, const char *outfile);
void bitrune_del(bitrune **brp);
void bitrune_monome_press(bitrune *br, int x, int y);
void bitrune_process_input(bitrune *br, int c);
void bitrune_update_display(bitrune *br);
int bitrune_getchar(void);
int bitrune_is_running(bitrune *br);
void bitrune_quads(bitrune *br, uint8_t **quadL, uint8_t **quadR);
void bitrune_terminal_setup(bitrune *br);
void bitrune_terminal_reset(bitrune *br);
int bitrune_message_available(bitrune *br);
void bitrune_message_markasread(bitrune *br);
const char * bitrune_message_pop(bitrune *br);
#endif
