core = require("util/core")
sig = require("sig/sig")
lilts = core.lilts
lilt = core.lilt
pprint = require("util/pprint")
gest = require("gest/gest")
path = require("path/path")
tal = require("tal/tal")

function setup()
    lil("shapemorfnew lut shapes/junior.b64")
    lil("grab lut")
    lut = pop()
    lookup = shapemorf.generate_lookup(lut)
    -- for k,v in pairs(lookup) do print(k) end

    A='b275f8'
    B='51f271'
    C='9c6c5d'
    D='5d71be'
    E='ab8d71'

    local vtx = path.vertex
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear

    local p_shapes = {}

    table.insert(p_shapes, vtx{A, {1, 1}, lin})
    table.insert(p_shapes, vtx{B, {1, 1}, gl})
    table.insert(p_shapes, vtx{A, {1, 1}, lin})
    table.insert(p_shapes, vtx{C, {1, 1}, gm})
    table.insert(p_shapes, vtx{A, {1, 1}, lin})
    table.insert(p_shapes, vtx{D, {1, 1}, gm})
    table.insert(p_shapes, vtx{A, {1, 1}, lin})
    table.insert(p_shapes, vtx{E, {1, 1}, gm})

    local words = {}
    tal.begin(words)

    tal.label(words, "shapes")
    path.path(tal, words, p_shapes, lookup)
    tal.jump(words, "shapes")
    return words
end

function patch(words)
    lil("blkset 49")
    local G = gest:new()
    G:create()
    G:compile(words)
    lilts {
        {"phasor", 1, 0},
    }

    local cnd = sig:new()
    cnd:hold()

    lilts {
        {"tubularnew", 8, 4},
        {"regset", "zz", 4},
        {"regmrk", 4},
    }

    lilts {
        {"shapemorf",
            G:get(),
            "[grab lut]",
            "[regget 4]",
            "[" .. G:gmemsymstr("shapes") .. "]",
            "[" .. table.concat(cnd:getstr(), " ") .. "]"
        },
    }

    lilt {"regget", 4}
    lilts {
        {"param", 60},
        -- {"sine", 7, 0.1},
        -- {"add", "zz", "zz"},
        {"mtof", "zz"},
        {"param", 0.2},
        {"param", 0.15},
        {"param", 0.1},
        -- {"param", tract_effort[vid]},
        -- {"param", breathiness[vid][1]},
        -- {"param", breathiness[vid][2]},
        {"glot", "zz", "zz", "zz", "zz"}
        -- {"blsaw", "zz"},
    }

    -- lilt {"mul", "zz", 0}

    lilts {
        {"noise"},
        {"butlp", "zz", 1000},
        {"buthp", "zz", 1000},
        {"highshelf", "zz", 3000, 5, 0.5},
        {"mul", "zz", 0.5},

    }

    lilts {
        {"crossfade", "zz", "zz", 0.0}
    }

    lilts {
        -- whisper-y
        {"noise"},
        {"butlp", "zz", 500},
        {"peakeq", "zz", 300, 300, 2.5},
        {"buthp", "zz", 200},
        {"mul", "zz", 0.5},
    }

    lilts {
        {"crossfade", "zz", "zz", 0.0}
    }

    lilts {
        {"tubular", "zz", "zz"},
        {"butlp", "zz", 4000},
        {"buthp", "zz", 100},
        {"regclr", 4},
    }

    -- gesture(sigrunes, gst, gate_label, local_cnd)
    -- lil("gestvmlast " .. gst:get())
    -- voice_data.gate_gesture = pop()

    -- lilts {
    --     {"envar", "zz", 0.05, 0.2},
    --     {"mul", "zz", "zz"}
    -- }


    lilts {
        {"mul", "zz", "[dblin " .. -3 .."]"},
    }

    lil("dcblocker zz")

end

words = setup()
patch(words)
lilts {
    {"wavout", "zz", "scratch/junior.wav"}
}

lil("computes 10")
