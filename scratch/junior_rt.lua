--[[
-- <@>
dofile("scratch/junior_rt.lua")
-- </@>
--]]

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

local function phrase_to_mseq(morpheme, path, phrase, pros, vocab, pmt)
    local mseq = {}
    local merge = morpheme.merge

    for _,ph in pairs(phrase) do

        -- duration modifier
        local dur = ph[2] or {1, 1}
        local mrph = vocab[ph[1][2]][ph[1][1]]

        -- merge partial morphemes
        if ph[3] ~= nil then
            for _, pm in pairs(ph[3]) do
                mrph = merge(mrph, pmt[pm])
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
    for idx,_ in pairs(mseq) do
        mseq[idx][2] = path.fracmul(mseq[idx][2], scale)

        -- limited to 8-bit values
        assert(mseq[idx][2][1] <= 0xFF)
        assert(mseq[idx][2][2] <= 0xFF)
    end

    pros_scaled = {}
    pros_scaled.pitch = path.scale_to_morphseq(pros.pitch, mseq)
    pros_scaled.intensity = path.scale_to_morphseq(pros.intensity, mseq)

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

function addvocab(vocab, x, y, w)
    local row = y
    local col = x

    vocab[row][col] = w
end
-- <@>
function genvocab()
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local stp = gest.behavior.step

    local A='b275f8'
    local B='51f271'
    local C='9c6c5d'
    local D='5d71be'
    local E='ab8d71'

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
        },
        whisp = {
            {0x80, 1, gm},
            {0xff, 1, gm},
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
            {C, 1, gm},
            {E, 1, gm},
            {D, 1, lin},
            {B, 2, gl},
        },
        aspiration = asp.none,
    })

    local vocab = {}
    for row = 1, 8 do
        vocab[row] = {}
        for col = 1, 8 do
            vocab[row][col] = nil
        end
    end

    voc = function (x, y, w, doc)
        addvocab(vocab, x, y, w)
    end

    voc(1, 1, pat_a {
        gate = {
            {0, 1, stp},
        }
    }, "pause.")

    voc(2, 1, pat_a {}, "pattern a. 'halalayu'")
    voc(3, 1, pat_a {
        aspiration = asp.second,
        shapes = {
            {E, 2, lin},
            {D, 1, gl},
            {C, 1, lin},
        },
    }, "oohlay eddy")

    voc(4, 1, pat_a {
        shapes = {
            {E, 3, lin},
            {D, 1, gl},
            {A, 1, lin},
            {E, 1, gm},
            {A, 1, gm}
        },
        aspiration = asp.mid
    }, "oofla lowla")

    voc(5, 1, pat_a {
        aspiration = asp.longstart
    }, "ahpf! lay-oo")

    voc(6, 1, pat_a {
        shapes = {
            {A, 1, lin},
            {B, 1, lin},
            {A, 1, lin},
            {B, 1, lin},
            {A, 3, gl},
            {B, 3, gl},
        },
        aspiration = asp.longend,
    }, "ahlala")

    voc(7, 1, pat_a {
        shapes = {
            {C, 1, lin},
            {D, 1, lin},
        },
        aspiration = asp.none,
    }, "yi-eh")

    voc(8, 1, pat_b {}, "wah!")

    voc(1, 2, pat_b {
        aspiration = asp.longstart
    }, "hhhwah")

    voc(2, 2, pat_b {
        shapes = {
            {B, 1, gm},
            {A, 1, lin},
            {E, 1, gm},
            {A, 4, gm},
        },
        aspiration = asp.longend
    }, "wellwik-hhh")

    voc(3, 2, pat_c {}, "oomuleh-ya")
    voc(4, 2, pat_c {
        shapes = {
            {D, 1, lin},
            {E, 1, lin},
        },
        aspiration = asp.mid
    }, "echalon")
    voc(5, 2, pat_c {
        aspiration = asp.mid
    }, "ooflayah")
    voc(6, 2, pat_c {
        aspiration = asp.whisp
    }, "oovalef")

    return vocab
end
-- </@>

function genpros()
    local pros = {}

    local pros_flat = 0x80
    local pros_up = 0x80 + 0x40
    local pros_up_more = 0x80 + 0x70
    local pros_up_mild  = 0x80 + 0x30
    local pros_down_mild  = 0x80 - 0x04
    local pros_down = 0x80 - 0x40
    local pros_down_more = 0x00

    pros.question = {
        pitch = {
            {pros_flat, 3, stp},
            {pros_flat, 1, lin},
            {pros_up_mild, 1, stp},
        },
        intensity = {
            {0x80, 1, stp},
        }
    }

    pros.neutral = {
        pitch = {
            {pros_flat, 1, stp},
        },
        intensity = {
            {0x80, 1, stp},
        }
    }

    pros.whisper = {
        pitch = {
            {pros_flat, 1, stp},
        },
        intensity = {
            {0x20, 1, lin},
            {0x00, 1, stp},
        }
    }

    pros.some_jumps = {
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

    pros.deflated = {
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

    pros.excited = {
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

    return pros
end

-- <@>
function genphrase()
    local dur_reg = {1, 1}
    local dur_short = {3, 2}
    local dur_long = {2, 3}

    phrase = {}
    local reg = {1, 1}
    -- select the word
    local wrd = {3, 2}
    local pause = {1, 1}
    -- local wrd = "qi"
    for i=1,3 do
        table.insert(phrase, {wrd, reg})
    end
    table.insert(phrase, {pause, reg})
    return phrase
end
-- </@>

function genpartmorphs ()
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local stp = gest.behavior.step

    infl = {
        flat = {inflection = {{0x0, 3, lin}}},
        rise = {inflection = {{0x0, 3, lin}, {0x4, 1, stp}}},
        downup = {inflection = {{0x4, 1, gl}, {0x0, 1, gl}, {0x2, 1, stp}}},
        fall = {inflection = {{0x4, 3, lin}, {0x0, 1, stp}}}
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

    local pm = {
        flat = infl.flat,
        rise = infl.rise,
        downup = infl.downup,
        fall = infl.fall,
        crazy_vib = crazy_vib,
        med_vib = med_vib
    }

    return pm
end

function genwords(data, phrase)
    -- lil("shapemorfnew lut shapes/junior.b64")
    -- lil("grab lut")
    -- lut = pop()
    -- lookup = shapemorf.generate_lookup(lut)
    local lookup = data.lookup

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

    local m = {}

    local pm = data.pm

    -- local phrase = {
    --     {"na", dur_reg, {"rise", "med_vib"}},
    --     {"ne", dur_short, {"downup"}},
    --     {"ku", dur_reg, {"fall"}},
    --     {"nu", dur_long, {"downup", "crazy_vib"}},
    --     {"pause", dur_reg},
    -- }

    -- phrase = genphrase()

    -- local mseq = {}

    -- for _,ph in pairs(phrase) do
    --     local dur = dur_reg
    --     table.insert(mseq, {vocab[ph[1]], dur})
    -- end

    -- local vocab = genvocab()
    local vocab = data.vocab

    local app = morpheme.appender(path)

    pros = genpros()

    local question = pros.question
    local neutral = pros.neutral
    local whisper = pros.whisper
    local some_jumps = pros.some_jumps
    local deflated = pros.deflated
    local excited = pros.excited

    local monologue = {
        {phrase, neutral},
        {phrase, question},
        {phrase, some_jumps},
        {phrase, deflated},
        {phrase, excited},
        {phrase, whisper},
    }

    pros_pitch = {}
    pros_intensity = {}

    for _,stanza in pairs(monologue) do
        mseq, pros = phrase_to_mseq(morpheme, path, stanza[1], stanza[2], vocab, pm)
        append_to_sequence(app, m, pros_pitch, pros_intensity, mseq, pros)
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

function patch_setup()
    lil("shapemorfnew lut shapes/junior.b64")
    lil("grab lut")
    lut = pop()

    lookup = shapemorf.generate_lookup(lut)
    lil("blkset 49")
    lil("valnew msgscale")
    local G = gest:new()
    G:create()
    local data = {}

    data.G = G
    data.lut = lut
    data.lookup = shapemorf.generate_lookup(lut)
    data.vocab = genvocab()
    data.pm = genpartmorphs()

    return data
end

function patch(words, data)
    local G = data.G

    G:compile(words)
    G:swapper()
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
    G:done()
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

function rtsetup()
lil([[
hsnew hs
rtnew [grab hs] rt
# I'm pretty sure you can't crossfade with gestlive
hscf [grab hs] 0

func out {} {
    hsout [grab hs]
    hsswp [grab hs]
}

func playtog {} {
    hstog [grab hs]
}
]])
end

function sound()
    rtsetup()
    local data = patch_setup()
    words = genwords(data, genphrase())
    patch(words, data)
    valutil.set("msgscale", 1.0 / (3*60))
    lil("out")
    return data
end

local junior_data = sound()

--<@>
function run()
    print("run")
    junior_data.vocab = genvocab()
    local words = genwords(junior_data, genphrase())
    patch(words, junior_data)
    lil("out")
end
--</@>

