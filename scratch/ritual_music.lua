core = require("util/core")
gest = require("gest/gest")
pprint = require("util/pprint")
tal = require("tal/tal")
path = require("path/path")

lilts = core.lilts
zz = "zz"

lil("shapemorfnew lut shapes/tubesculpt_testshapes.b64")
lil("grab lut")
lut = pop()
lookup = shapemorf.generate_lookup(lut)

gm = gest.behavior.gliss_medium
gl = gest.behavior.gliss
lin = gest.behavior.linear

shapes = {
    "2b1d8a",
    "4e8a8e",
    "83ae8a",
    "172828",
    "54f27d",
    "8abe8d",
}

vt = path.vertex
test_path = {
    vt{shapes[1], {1, 1}, gm},
    vt{shapes[2], {1, 1}, gm},
    vt{shapes[1], {1, 1}, lin},
    vt{shapes[2], {1, 1}, gl},

    vt{shapes[3], {1, 1}, gm},
    vt{shapes[4], {1, 1}, gm},
    vt{shapes[3], {1, 1}, lin},
    vt{shapes[4], {1, 1}, gl},

    vt{shapes[5], {1, 1}, gm},
    vt{shapes[6], {1, 1}, gm},
    vt{shapes[5], {1, 1}, lin},
    vt{shapes[6], {1, 1}, gl}
}

words = {}
tal.begin(words)

tal.label(words, "vowshapes")
path.path(tal, words, test_path, lookup)
tal.jump(words, "vowshapes")

g = gest:new{tal = tal}
g:create()
g:compile(words)

lilts {
    {"metro", (153/(60 * 14))},
    {"tgate", zz, 0.005},
    {"smoother", zz, 0.001},
    {"dup"},
    {"modalres", zz, 800, 40},
    {"swap"},
    {"modalres", zz, 1800, 1400},
    {"add", zz, zz},
    {"mul", zz, "[dblin -10]"},
    {"limit", zz, -0.5, 0.5},
    {"dcblocker", zz},
    {"buthp", zz, 200},

    {"dup"},
    -- s m
    {"modalres", zz, 300, 50},
    -- m s
    {"swap"},
    -- m s s
    {"dup"},
    -- m s m
    {"modalres", zz, 880, 200},
    -- m m s
    {"swap"},
    -- m m m
    {"modalres", zz, 880+100, 500},
    {"add", zz, zz},
    {"add", zz, zz},

    {"dcblocker", zz},
    {"mul", zz, "[dblin -18]"},
    {"limit", zz, -0.9, 0.9},

    {"chaosnoise", 1.8, 300, 0.1},
    {"buthp", zz, 500},
    {"highshelf", zz, 8000, 4, 0.5},
    {"mul", zz, "[dblin -3]"},
    {"add", zz, zz},
}

lilts {
    {"tubularnew", 20.0, -1},
    {"regset", zz, 0},

    {
        -- gvm, lut, tubular, program , conductor
        "shapemorf",
        g:get(),
        "[grab lut]",
        "[regget 0]",
        "[" .. g:gmemsymstr("vowshapes") .. "]",
        "[phasor [scale [expmap [flipper [phasor 0.05 0]] 3] 1 10] 0]"
    },

    {"regget", 0},
    {"param", 33},
    {"jitseg", 0.3, -0.3, 0.5, 2, 1},
    {"add", zz, zz},
    {"mtof", zz},
    {"param", 0.3},
    {"param", 0.1},
    {"param", 0.0},
    {"glot", zz, zz, zz, zz},
    {"tubular", zz, zz, zz},
    {"butlp", zz, 8000},
    {"lowshelf", zz, 80, 4, 0.5},
    {"mul", zz, "[dblin -3]"},
}

lil("add zz zz")

lilts {
    {"dup"},
    {"phasor", 1/40, 0},
    {"flipper", zz},
    {"expmap", zz, 3},
    {"scale", zz, 1, 40},
    {"softclip", zz, zz},
    {"dup"},
    {"bigverb", zz, zz, 0.97, 10000},
    {"drop"},
    {"dcblocker", zz},
    {"mul", zz, "[dblin -10]"},
    {"add", zz, zz},
}



lilts {
    {"wavout", "zz", "test.wav"},
    {"computes", 80}
}
