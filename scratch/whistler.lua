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


local vtx = path.vertex
local gm = gest.behavior.gliss_medium
local gl = gest.behavior.gliss
local lin = gest.behavior.linear
local stp = gest.behavior.step

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

local G = gest:new()
G:create()
G:compile(words)

lilts {
    {"phasor", 55.0 / 60.0, 0},
}

local cnd = sig:new()
cnd:hold()

function gesture(sr, gst, name, cnd)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr())
    }
end

gesture(sigrunes, G, "pitch", cnd)

lilts {
    --{"param", 69 + 12},
    {"add", zz, 69 + 12},
    {"sine", 5.5, 0.2},
}

lilts {
    {"add", zz, zz},
    {"mtof", zz},
}
    local pitch = sig:new()
    pitch:hold()

-- lilts {
--     {"noise"},
--     {"mul", zz, 1},
-- }
--     pitch:get()
-- 
-- 
-- lilts {
--     {"sine", zz, 0.5},
-- 
--     {"param 0"},
--     {"tgate", zz, 0.1},
--     {"envar", zz, 0.1, 0.1},
--     {"scale", zz, 0.5, 0.0},
--     {"crossfade", zz, zz, zz},
-- }
--     pitch:get()
--     pitch:get()
-- 
-- lilts {
--     {"mul", zz, 0.2},
--     {"butbp", zz, zz, zz},
--     {"mul", zz, 0.8},
-- }
--

lilts {
    {"noise"},
    {"butbp", zz, 1000, 30},
    {"buthp", zz, 1000},
    {"mul", zz, 1.1},
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

lilts {
    {"mul", zz, "[dblin -5]"}
}

gesture(sigrunes, G, "gate", cnd)
lilts {
    {"envar", "zz", 0.2, 0.2},
    {"mul", "zz", "zz"}
}

lilts {
    {"dup"},
    {"vardelay zz 0.0 0.2 0.5"},
    {"dup"},
    {"bigverb zz zz 0.97 10000"},
    {"drop; mul zz [dblin -18]"},
    {"swap; mul zz [dblin -3]"},
    {"add", zz, zz},
}

lilts {
    {"wavout", zz, "test.wav"}
}

lil("computes 40")
