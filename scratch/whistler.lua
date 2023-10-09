--[[
re, dore dodo refasol farefado
mimiresi fadomido laremifa
soldo solla dofa dodo remisoldo
re, mila solla dore fasisol fasi
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

lilts = core.lilts
zz = "zz"

function generate_score()
    local vtx = path.vertex
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local stp = gest.behavior.step
    local gt = gest.behavior.gate_50

    doh = 0
    re = 2
    mi = 4
    fa = 5
    so = 7
    la = 9
    ti = 11

    Q = {1, 1}
    E = {2, 1}
    S = {4, 1}
    T = {3, 1}

    local melpath = {
        -- Verse 1
        vtx{re, Q, gm},
        vtx{doh, E, gm},
        vtx{re, E, gm},

        vtx{doh, E, gm},
        vtx{doh, E, gm},

        vtx{re, T, gm},
        vtx{fa, T, gm},
        vtx{so, T, gm},

        vtx{fa, E, gm},
        vtx{re, E, gm},
        vtx{fa, E, gm},
        vtx{doh, {2, 3 + 2}, gm},

        -- Verse 2
        vtx{mi, E, gm},
        vtx{mi, E, gm},
        vtx{re, E, gm},
        vtx{ti, E, gm},

        vtx{fa, S, gl},
        vtx{doh, S, gl},
        vtx{mi, S, gl},
        vtx{doh, S, gl},

        vtx{la, E, gm},
        vtx{re, E, gm},
        vtx{mi, E, gm},
        vtx{fa, {2,3 + 2}, gm},

        -- Verse 3
        vtx{so, E, gm},
        vtx{doh, {2, 3}, gm},
        vtx{so, E, gm},
        vtx{la, {2, 3}, gm},

        vtx{doh, E, gm},
        vtx{fa, E, gm},

        vtx{doh, E, gm},
        vtx{doh, E, gm},

        vtx{re, S, gm},
        vtx{mi, S, gm},
        vtx{so, E, gm},
        vtx{doh, {2,1 + 3}, stp},

        -- Verse 4

        vtx{re, Q, gm},
        vtx{mi, E, gm},
        vtx{la, E, gm},

        vtx{so, E, gm},
        vtx{la, E, gm},

        vtx{doh, E, gm},
        vtx{re, E, gm},

        vtx{fa, T, gm},
        vtx{ti, T, gm},
        vtx{so, T, gm},

        vtx{fa, E, gl},
        vtx{ti, {2, 3 + 2}, stp},
        vtx{ti, {1, 2}, lin},
        vtx{doh, {1, 1}, stp},
    }

    local gatepath = {
        vtx {1, {1, 7}, stp},
        vtx {0, {1, 1}, stp},

        vtx {1, {1, 6}, stp},
        vtx {0, {1, 1}, stp},

        vtx {1, {1, 8}, stp},
        vtx {0, {1, 1}, stp},

        vtx {1, {1, 8 + 1}, stp},
        vtx {0, {1, 1}, stp},
    }

    local vibpath = {
        vtx {0, {1, 7}, lin},
        vtx {1, {1, 1}, stp},

        vtx {0, {1, 6}, lin},
        vtx {2, {1, 1}, stp},

        vtx {0, {1, 8}, lin},
        vtx {2, {1, 1}, stp},

        vtx {0, {1, 8 + 1}, lin},
        vtx {4, {1, 1}, stp},
    }

    on = 1
    off = 0
    local trigpath = {
        -- Verse 1
        vtx{off, Q, stp},
        vtx{off, E, stp},
        vtx{off, E, stp},

        vtx{off, E, stp},
        vtx{on, E, gt},

        vtx{off, T, stp},
        vtx{off, T, stp},
        vtx{off, T, stp},

        vtx{off, E, stp},
        vtx{off, E, stp},
        vtx{off, E, stp},
        vtx{off, {2, 3 + 2}, stp},

        -- Verse 2
        vtx{off, E, stp},
        vtx{on, E, gt},
        vtx{off, E, stp},
        vtx{off, E, stp},

        vtx{off, S, stp},
        vtx{off, S, stp},
        vtx{off, S, stp},
        vtx{off, S, stp},

        vtx{off, E, stp},
        vtx{off, E, stp},
        vtx{off, E, stp},
        vtx{off, {2,3 + 2}, stp},

        -- Verse 3
        vtx{off, E, stp},
        vtx{off, {2, 3}, stp},
        vtx{off, E, stp},
        vtx{off, {2, 3}, stp},

        vtx{off, E, stp},
        vtx{off, E, stp},

        vtx{off, E, stp},
        vtx{on, E, gt},

        vtx{off, S, stp},
        vtx{off, S, stp},
        vtx{off, E, stp},
        vtx{off, {2,1 + 3}, stp},

        -- Verse 4

        vtx{off, Q, stp},
        vtx{off, E, stp},
        vtx{off, E, stp},

        vtx{off, E, stp},
        vtx{off, E, stp},

        vtx{off, E, stp},
        vtx{off, E, stp},

        vtx{off, T, stp},
        vtx{off, T, stp},
        vtx{off, T, stp},

        vtx{off, E, stp},
        vtx{off, {2, 3 + 2}, stp},
        vtx{off, {1, 2}, stp},
        vtx{off, {1, 1}, stp},
    }

    words = {}
    tal.begin(words)
    tal.label(words, "hold")
    tal.halt(words)
    tal.jump(words, "hold")

    tal.label(words, "pitch")
    path.path(tal, words, melpath)
    tal.jump(words, "hold")

    tal.label(words, "gate")
    path.path(tal, words, gatepath)
    tal.jump(words, "hold")

    tal.label(words, "vib")
    path.path(tal, words, vibpath)
    tal.jump(words, "hold")

    tal.label(words, "trig")
    tal.interpolate(words, 0)
    path.path(tal, words, trigpath)
    tal.jump(words, "hold")
    return words
end

function gesture(sr, gst, name, cnd)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr())
    }
end

function generate_signals(G, cnd)
    gesture(sigrunes, G, "vib", cnd)
    lilts {
        {"mul", zz, 0.25}
    }
    local vib = sig:new()

    vib:hold()

    gesture(sigrunes, G, "pitch", cnd)

    lilts {
        --{"param", 69 + 12},
        {"add", zz, 69 + 12},
    }

    lilts {
        {"dup"},
        {"add", zz, 2}
    }

    gesture(sigrunes, G, "trig", cnd)
    local trig = sig:new()

    trig:hold()

    trig:get()
    lilts {
        {"gtick", zz},
        {"tgate", zz, 0.1},
        {"envar", zz, 0.2, 0.2},
        {"crossfade", zz, zz, zz}
    }

    vib:get()
    lilt {"scale", zz, 5.3, 5.5}
    vib:get()
    lilt {"scale", zz, 0.1, 0.5}
    lilts {
        {"sine", zz, zz},
    }

    lilts {
        {"add", zz, zz},
        {"mtof", zz},
    }
    local pitch = sig:new()
    pitch:hold()

    local gate = sig:new()
    gesture(sigrunes, G, "gate", cnd)
    gate:hold()
    return pitch, vib, trig, gate
end

function whistle(pitch, vib, trig, gate)
    lilts {
        {"noise"},
        {"butbp", zz, 1000, 50},
        {"buthp", zz, 1000},
    }

    trig:get()

    lilts {
        {"gtick", zz},
        {"tgate", zz, 0.1},
        {"smoother", zz, 0.001},
        {"scale", zz, 1.1, 1.8},
        {"mul", zz, zz},
    }

    pitch:get()
    pitch:get()

    lilts {
        {"mul", zz, 0.2},
        {"butbp", zz, zz, zz},
        -- {"mul", zz, 0.8},
    }

    pitch:get()
    lilts {
        {"blsquare", zz},
        {"mul", zz, 0.1},
        --{"mul", zz, 0.0},
    }

    pitch:get()
    lilts {
        {"butbp", zz, zz, 5},
    }

    lilts {
        {"add", zz, zz},
    }

    gate:get()
    lilts {
        {"envar", "zz", 0.2, 0.2},
        {"mul", "zz", "zz"}
    }
    lilts {
        {"mul", zz, "[dblin 3]"}
    }

end
function reverb()
    lilts {
        {"dup"},
        {"vardelay zz 0.0 0.3 0.5"},
        {"dup"},
        {"bigverb zz zz 0.93 10000"},
        {"drop; mul zz [dblin -18]"},
        {"swap; mul zz [dblin -3]"},
        {"add", zz, zz},
    }
end

words = generate_score()
local G = gest:new()
G:create()
G:compile(words)

lilts {
    {"phasor", 55.0 / 60.0, 0},
}

local cnd = sig:new()
cnd:hold()


pitch, vib, trig, gate = generate_signals(G, cnd)
whistle(pitch, trig, vib, gate)
pitch:unhold()
vib:unhold()
trig:unhold()
cnd:unhold()
gate:unhold()
reverb()

lilts {
    {"wavout", zz, "test.wav"}
}

lil("computes 47")
