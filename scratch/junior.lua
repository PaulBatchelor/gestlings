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

local function phrase_to_mseq(morpheme, path, phrase, pros, vocab)
    local mseq = {}
    local merge = morpheme.merge

    for _,ph in pairs(phrase) do

        -- duration modifier
        local dur = ph[2] or {1, 1}
        local mrph = vocab[ph[1]]

        -- merge partial morphemes
        if ph[3] ~= nil then
            for _, pm in pairs(ph[3]) do
                mrph = merge(mrph, pm)
            end
        end

        table.insert(mseq, {mrph, dur})
    end

    local mseq_dur = path.morphseq_dur(mseq)
    -- print(mseq_dur[1], mseq_dur[2])

    -- normalize: condense entire phrase into one beat
    -- for some reason, we don't flip
    -- best I can think of:
    -- rescale each rate multiplier relative to the duration
    -- divide each morpheme rate multiplier by the total duration
    -- duration needs to be converted to rate (flip)
    -- fraction division does an inversion on second operand (flip)
    -- maybe those flips cancel out?
    local scale = mseq_dur
    -- print("before")
    -- pprint(mseq[1])
    for idx,_ in pairs(mseq) do
        mseq[idx][2] = path.fracmul(mseq[idx][2], scale)

        -- limited to 8-bit values
        assert(mseq[idx][2][1] <= 0xFF)
        assert(mseq[idx][2][2] <= 0xFF)
    end
    -- print("after")
    -- pprint(mseq[1])

    pros_scaled = {}
    pros_scaled.pitch = path.scale_to_morphseq(pros.pitch, mseq)
    pros_scaled.intensity = path.scale_to_morphseq(pros.intensity, mseq)

    -- print("before")
    -- print(#pros)
    -- pprint(pros[2])
    -- print("after")
    -- pprint(pros_scaled[2])
    return mseq, pros_scaled
end

local function append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)
    for _,mrph in pairs(mseq) do
        local dur = mrph[2]
        local mo = mrph[1]
        app(m, dur, mo)
    end

    for _, v in pairs(pros.pitch) do
        table.insert(pros_pitch, v)
    end

    for _, v in pairs(pros.intensity) do
        table.insert(pros_intensity, v)
    end
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
        },

        vib = {
            {0, 3, stp},
            {0, 1, gm},
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
        },

        all = {
            {0xFF, 1, stp},
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

    dur_reg = {1, 1}
    dur_short = {3, 2}
    dur_long = {2, 3}

    crazy_vib = {
        vib = {{0x00, 1, gm}, {0xFF, 1, gm}},
    }

    med_vib = {
        vib = {{0x40, 1, gm}},
    }

    local phrase = {
        {"na", dur_reg, {infl.rise, med_vib}},
        {"ne", dur_short, {infl.downup}},
        {"ku", dur_reg, {infl.fall}},
        {"nu", dur_long, {infl.downup, crazy_vib}},
        {"pause", dur_reg},
    }

    -- local mseq = {}

    -- for _,ph in pairs(phrase) do
    --     local dur = dur_reg
    --     table.insert(mseq, {vocab[ph[1]], dur})
    -- end

    local pros_flat = 0x80
    local pros_up = 0x80 + 0x40
    local pros_up_more = 0x80 + 0x70
    local pros_up_mild  = 0x80 + 0x30
    local pros_down_mild  = 0x80 - 0x04
    local pros_down = 0x80 - 0x40
    local pros_down_more = 0x00

    local question = {
        pitch = {
            {pros_flat, 3, stp},
            {pros_flat, 1, lin},
            {pros_up_mild, 1, stp},
        },
        intensity = {
            {0x80, 1, stp},
        }
    }

    local neutral = {
        pitch = {
            {pros_flat, 1, stp},
        },
        intensity = {
            {0x80, 1, stp},
        }
    }

    local whisper = {
        pitch = {
            {pros_flat, 1, stp},
        },
        intensity = {
            {0x20, 1, lin},
            {0x00, 1, stp},
        }
    }

    local some_jumps = {
        pitch = {
            {pros_flat, 1, lin},
            {pros_up, 1, lin},
            {pros_flat, 2, lin},
            {pros_down_mild, 1, stp},
        },
        intensity = {
            {0x80, 1, stp},
        }
    }

    local deflated = {
        pitch = {
            {pros_flat, 1, lin},
            {pros_down_mild, 2, gm},
            {pros_down, 4, lin},
            {pros_down_more, 4, stp},
        },
        intensity = {
            {0x80, 1, lin},
            {0x70, 1, stp},
        }
    }

    local excited = {
        pitch = {
            {pros_flat, 1, lin},
            {pros_up_more, 1, lin},
            {pros_flat, 1, lin},
            {pros_up_more, 1, lin},
            {pros_flat, 1, lin},
            {pros_up_more, 1, lin},
            {pros_down_mild, 1, lin},
            {pros_up_more, 2, stp},
        },
        intensity = {
            {0x80, 1, lin},
            {0xFF, 2, stp},
        }
    }


    pros_pitch = {}
    pros_intensity = {}
    mseq, pros = phrase_to_mseq(morpheme, path, phrase, neutral, vocab)
    append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)

    mseq, pros = phrase_to_mseq(morpheme, path, phrase, question, vocab)
    append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)

    mseq, pros = phrase_to_mseq(morpheme, path, phrase, some_jumps, vocab)
    append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)

    mseq, pros = phrase_to_mseq(morpheme, path, phrase, deflated, vocab)
    append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)

    mseq, pros = phrase_to_mseq(morpheme, path, phrase, excited, vocab)
    append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)

    mseq, pros = phrase_to_mseq(morpheme, path, phrase, whisper, vocab)
    append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)

    local words = {}
    tal.begin(words)

    tal.label(words, "hold")
    tal.halt(words)
    tal.jump(words, "hold")

    morpheme.compile_noloop(tal, path, words, m, nil, lookup)

    tal.label(words, "pros_pitch")
    path.path(tal, words, pros_pitch)
    tal.jump(tal, "hold")

    tal.label(words, "pros_intensity")
    path.path(tal, words, pros_intensity)
    tal.jump(tal, "hold")
    return words
end

function gesture(sr, gst, name, cnd)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr()),
        extscale = "[val [grab msgscale]]",
    }
end

function patch(words)
    lil("blkset 49")
    lil("valnew msgscale")
    local G = gest:new()
    G:create()
    G:compile(words)
    lilts {
        {"phasor", 60, 0},
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
            "[" .. table.concat(cnd:getstr(), " ") .. "]",
            "[val [grab msgscale]]"
        },
    }
    gesture(sigrunes, G, "pros_intensity", cnd)
    lilts {
        {"mul", "zz", 1.0 / 0xFF},
    }

    local intensity = sig:new()
    intensity:hold()

    lilt {"regget", 4}
    gesture(sigrunes, G, "inflection", cnd)
    lilt {"mul", "zz", 0.5}
    gesture(sigrunes, G, "pros_pitch", cnd)
    lilts {
        {"mul", "zz", 1.0 / 0xFF},
        {"scale", "zz", -14, 14},
        {"add", "zz", "zz"}
    }
    lilts {
        {"param", 63},
        {"add", "zz", "zz"},
    }
    gesture(sigrunes, G, "vib", cnd)
    lilts {
        {"mul", "zz", 1.0 / 0xFF},
    }
    local vib = sig:new()
    vib:hold()

    vib:get()
    lilts {
        {"scale", "zz", 6.5, 8},
    }

    vib:get()
    lilts {
        {"scale", "zz", 0.0, 0.8},
    }
    intensity:get()
    -- remap: < 0.5, return 0, other wise 0-1
    lilts {
        {"mul", "zz", 2},
        {"add", "zz", -1},
        {"limit", "zz", 0, 1},
        {"scale", "zz", 0, 3},
        {"add", "zz", "zz"},
    }
    lilts {
        {"sine", "zz", "zz"},
        {"add", "zz", "zz"},
    }
    vib:unhold()

    lilts {
        {"mtof", "zz"},
        {"param", 0.2},
        {"param", 0.15},
        {"param", 0.1},
        {"glot", "zz", "zz", "zz", "zz"}
    }

    local glot = sig:new()

    lilts {
        {"noise"},
        {"butlp", "zz", 1000},
        {"buthp", "zz", 1000},
        {"highshelf", "zz", 3000, 5, 0.5},
        {"mul", "zz", 0.5},
    }

    gesture(sigrunes, G, "aspiration", cnd)
    lilts {
        {"mul", "zz", 1.0 / 255.0},
        {"smoother", "zz", "0.005"},
        {"crossfade", "zz", "zz", "zz"}
    }

    lilts {
        -- whisper-y
        {"noise"},
        {"butbp", "zz", 1000, 300},
        {"butlp", "zz", 4000},
        -- {"butlp", "zz", 500},
        -- {"peakeq", "zz", 300, 300, 2.5},
        -- {"buthp", "zz", 200},
        {"mul", "zz", 1.3},
    }
    lil("swap")

    intensity:get()
    lilts {
        -- rescale so intensity curve: 0, 0.5 -> 0, 1
        {"mul", "zz", 2},
        {"limit", "zz", 0, 1},
        {"crossfade", "zz", "zz", "zz"}
    }

    intensity:unhold()

    -- gesture(sigrunes, G, "aspiration", cnd)
    -- lilts {
    --     {"mul", "zz", 1.0 / 255.0},
    --     {"smoother", "zz", "0.005"},
    --     {"crossfade", "zz", "zz", "zz"}
    -- }

    glot:hold()

    glot:get()

    lilts {
        {"tubular", "zz", "zz"},
        {"butlp", "zz", 4000},
        {"buthp", "zz", 100},
        {"regclr", 4},
    }

    glot:get()

    -- use balance filter to control resonances of tubular
    lilt{"balance", "zz", "zz"}

    gesture(sigrunes, G, "gate", cnd)
    -- lil("gestvmlast " .. gst:get())
    -- voice_data.gate_gesture = pop()

    lilts {
        {"envar", "zz", 0.05, 0.2},
        {"mul", "zz", "zz"}
    }

    lilts {
        {"mul", "zz", "[dblin " .. -3 .."]"},
    }

    lil("dcblocker zz")

    -- cnd:get()
    -- lil("scale zz 200 400")
    -- lil("sine zz 0.3")
    -- lil("add zz zz")
    cnd:unhold()
    glot:unhold()

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

durs = {3, 2.5, 2, 4, 3, 3.5}

for idx,_ in pairs(durs) do
    durs[idx] = math.floor(durs[idx]*60)
end
durpos = 1
counter = 0
for n=1,60*20 do
    if counter <= 0 and durpos <= #durs then
        counter = durs[durpos]
        valutil.set("msgscale", 1.0 / counter)
        durpos = durpos + 1
    end
    lil("compute 15")
    counter = counter - 1
end
-- lil("computes 30")
