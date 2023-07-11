msgpack=dofile(os.getenv("HOME") .. "/p/gestlings/util/MessagePack.lua")
shapes = {
    {"123", 1},
    {"654", 2},
    {"987", 3},
    {"324", 4},
    {"657", 5},
}

fp = io.open("shapes.bin", "w")
fp:write(msgpack.pack(shapes))
fp:close()
