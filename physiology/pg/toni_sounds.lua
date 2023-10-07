core = require("util/core")
lilt = core.lilt
lilts = core.lilts

zz = "zz"
lilts {
    {"tubularnew", 15, 2},
    {"regset", "zz", 4},
    {"regmrk", 4},
}
lil( [[
genvals [tabnew 1] "0.1 0.1 0.1 0.1 0.1 0.3 0.1 0.9"
regset zz 3

tabnew [tubularsz [regget 4] ]
regset zz 6

tractdrm [regget 6] [regget 3]
tubulardiams [regget 4] [regget 6]
]])
lil("regget 4")
lilts {
    {"metro", "[rline 1 20 2]"},
    {"hold"},
    {"regset", zz, 0},

    {"regget", 0},
    {"env", zz, 0.001, 0.001, 0.001},
    {"scale", zz, 500, 1000},
    {"param", 0.2},
    {"sine", zz, zz},
    -- {"sine", "[rline 500 3000 1]", "[param 1]"},
    -- {"mul", zz, zz},
    {"regget", 0},
    {"env", zz, 0.001, 0.01, 0.001},
    {"mul", zz, zz},
}
lil("tubular zz zz")


lilt {"wavout", zz, "tmp/test.wav"}

lil("computes 10")
