core = require("util/core")
sig = require("sig/sig")
lilts = core.lilts
lilt = core.lilt
pprint = require("util/pprint")
gest = require("gest/gest")
path = require("path/path")
tal = require("tal/tal")
morpheme = require("morpheme/morpheme")
sigrunes = require("sigrunes/sigrunes")

local function gcd(m, n)
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end

local function lcm(m, n)
    return (m ~= 0 and n ~= 0) and
        m * n / gcd(m, n) or 0
end

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
    local stp = gest.behavior.step

    local p_shapes = {}

    pat_a = morpheme.template({
        shapes = {
            {A, 2, lin},
            {B, 1, gl},
            {C, 1, lin},
            {D, 1, gm},
            {E, 2, gm}
        },

        aspiration = {
            {0xFF, 1, gm},
            {0x0, 5, stp},
        },

        inflection = {
            {0x0, 3, step},
        },

        gate = {
            {1, 5, stp},
            {0, 1, stp},
        }
    })


    local m = {}

    local app = morpheme.appender(path)
    infl = {
        flat = {inflection = {{0x0, 3, lin}}},
        rise = {inflection = {{0x0, 3, lin}, {0x4, 1, stp}}},
        downup = {inflection = {{0x4, 1, gl}, {0x0, 1, gl}, {0x2, 1, stp}}},
        fall = {inflection = {{0x4, 3, lin}, {0x0, 1, stp}}}
    }

    asp = {
        start = {
            {0xFF, 1, gm},
            {0x0, 5, stp},
        },

        second = {
            {0x0, 1, gm},
            {0xFF, 1, gm},
            {0x0, 4, stp},
        },

        mid = {
            {0x0, 1, gm},
            {0xFF, 1, gm},
            {0x0, 4, stp},
        },

        longstart = {
            {0xFF, 1, gm},
            {0x0, 1, stp},
        },

        longend = {
            {0x00, 1, gm},
            {0xFF, 1, stp},
        },

        none = {
            {0x00, 1, stp},
        }
    }


    pat_b = morpheme.template(pat_a {
        shapes = {
            {D, 1, lin},
            {A, 1, lin},
        },
        aspiration = asp.none,
    })

    pat_c = morpheme.template(pat_b {
        shapes = {
            {B, 4, gl},
            {C, 1, lin},
            {D, 1, gl},
        },
        aspiration = asp.none,
    })

    local vocab = {
        ka = pat_a {},
        xy = pat_a {
            aspiration = asp.second,
            shapes = {
                {E, 2, lin},
                {D, 1, gl},
                {C, 1, lin},
            },
        },
        gy = pat_a {
            shapes = {
                {E, 3, lin},
                {D, 1, gl},
                {A, 1, lin},
                {E, 1, gm},
                {A, 1, gm}
            },
            aspiration = asp.mid
        },
        ra = pat_a {
            aspiration = asp.longstart
        },
        ti= pat_a {
            shapes = {
                {A, 1, lin},
                {B, 1, lin},
                {A, 1, lin},
                {B, 1, lin},
                {A, 3, gl},
                {B, 3, gl},
            },
            aspiration = asp.longend,
        },
        qi= pat_a {
            aspiration = asp.none,
        },
        nu = pat_b {},
        thu = pat_b {
            aspiration = asp.longstart
        },
        no = pat_b {
            aspiration = asp.longend
        },
        na = pat_c { },
        ne = pat_c {
            aspiration = asp.mid
        },
        ku = pat_c {
            aspiration = asp.longstart
        },
        ty={},
        ma={},
        zha={},
        ge={},
        pause = pat_a {
            gate = {
                {0, 1, stp},
            }
        }
    }

    local merge = morpheme.merge

    dur_reg = {1, 1}
    dur_short = {3, 2}
    dur_long = {2, 3}

    local phrase = {
        {"na"},
        {"ne"},
        {"ku"},
        {"nu"},
        {"pause"},
    }

    local mseq = {}

    for _,ph in pairs(phrase) do
        local dur = dur_reg
        table.insert(mseq, {vocab[ph[1]], dur})
    end

    local pros_flat = 0x80
    local pros_up = 0x80 + 0x40
    local pros_pitch = {
        {pros_flat, 3, lin},
        {pros_up, 1, gm},
    }

    pros_pitch = path.scale_to_morphseq(pros_pitch, mseq)

    for _,mrph in pairs(mseq) do
        local dur = mrph[2]
        local mo = mrph[1]
        app(m, dur, mo)
    end

    local words = {}
    tal.begin(words)

    tal.label(words, "hold")
    tal.halt(words)
    tal.jump(words, "hold")

    morpheme.compile_noloop(tal, path, words, m, nil, lookup)

    tal.label(words, "pros_pitch")
    path.path(tal, words, pros_pitch)
    tal.jump(tal, "hold")
    return words
end

function gesture(sr, gst, name, cnd)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr())
    }
end

function patch(words)
    lil("blkset 49")
    local G = gest:new()
    G:create()
    G:compile(words)
    lilts {
        {"phasor", 1.8, 0},
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
    gesture(sigrunes, G, "inflection", cnd)
    lilt {"mul", "zz", 0.5}
    gesture(sigrunes, G, "pros_pitch", cnd)
    lilts {
        {"mul", "zz", 1.0 / 0xFF},
        {"scale", "zz", -12, 12},
        {"add", "zz", "zz"}
    }
    lilts {
        {"param", 63},
        {"add", "zz", "zz"},
        -- {"sine", 7, 0.1},
        -- {"add", "zz", "zz"},
        {"mtof", "zz"},
        {"param", 0.2},
        {"param", 0.15},
        {"param", 0.1},
        {"glot", "zz", "zz", "zz", "zz"}
    }

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

    gesture(sigrunes, G, "aspiration", cnd)
    lilts {
        {"mul", "zz", 1.0 / 255.0},
        {"smoother", "zz", "0.005"},
        {"crossfade", "zz", "zz", "zz"}
    }

    lilts {
        {"tubular", "zz", "zz"},
        {"butlp", "zz", 4000},
        {"buthp", "zz", 100},
        {"regclr", 4},
    }

    gesture(sigrunes, G, "gate", cnd)
    -- lil("gestvmlast " .. gst:get())
    -- voice_data.gate_gesture = pop()

    lilts {
        {"envar", "zz", 0.05, 0.2},
        {"mul", "zz", "zz"}
    }


    lilts {
        {"mul", "zz", "[dblin " .. -6 .."]"},
    }

    lil("dcblocker zz")

end

consonance = {
"b", "c", "d", "f", "g", "gh", "h", "k", "l", "m", "n",
"p", "q", "r", "s", "t", "v", "w", "x", "y", "z",
"zh", "th",
}

vowel = {
"a", "e", "i", "o", "u", "y", "uo"
}

function generate_words(nwords)
    local wordlist = {}
    for _ = 1,nwords do
        local v = vowel[math.random(#vowel)]
        local c = consonance[math.random(#consonance)]
        local word = c .. v
        print (word)
        -- wordlist[word] = true
    end

    -- for v,_ in pairs(wordlist) do
    --     print(v)
    -- end
end

-- generate_words(16)
words = setup()
patch(words)
lilts {
    {"wavout", "zz", "scratch/junior.wav"}
}

lil("computes 10")
