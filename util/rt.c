#include "lua/lua.h"
#include "lua/lauxlib.h"
#include "lua/lualib.h"
int mno_rtserver_loader(int argc,
                        char *argv[],
                        void (*loadfun)(lua_State*),
                        void (*cleanfun)(lua_State*));
void mno_lua_load(lua_State *L);
void mno_lua_clean(lua_State *L);
int luaopen_bitrune(lua_State *L);

static void load(lua_State *L)
{
    mno_lua_load(L);
    luaL_requiref(L, "bitrune", luaopen_bitrune, 1);
}

static void clean(lua_State *L)
{
    mno_lua_clean(L);
}

int main(int argc, char *argv[])
{
    return mno_rtserver_loader(argc, argv, load, clean);
}

