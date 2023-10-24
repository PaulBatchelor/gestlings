-- simple counting system vocabulary using pitches, base 8
-- 1: do re
-- 2: do mi
-- 3: do fa
-- 4: do so
-- 5: re do
-- 6: me do
-- 7: fa do
-- 8: so do

path = require("path/path")
tal = require("tal/tal")
sig = require("sig/sig")
sigrunes = require("sigrunes/sigrunes")
gest = require("gest/gest")
core = require("util/core")
lilts = core.lilts
pprint = require("util/pprint")

gm = gest.behavior.gliss_medium
stp = gest.behavior.step
vtx = path.vertex
numlut = {
    {0, 2}, -- do re (1)
    {0, 4}, -- do mi (2)
    {0, 5}, -- do fa (3)
    {0, 7}, -- do so (4)

    {2, 0}, -- re do (5)
    {4, 0}, -- mi do (6)
    {5, 0}, -- fa do (7)
    {7, 0}, -- so do (8)
}

function render_number(num)
    long = {3, 2}
    short = {3, 1}
    pitch = {
        vtx {numlut[num][1], long, gm},
        vtx {numlut[num][2], short, stp}
    }

    gate = {
        vtx {1, {1, 1}, stp},
        vtx {0, {1, 1}, stp},
    }

    local words = {}

    tal.begin(words)
    tal.label(words, "hold")
    tal.halt(words)
    tal.jump(words, "hold")

    tal.label(words, "pitch")
    path.path(tal, words, pitch)
    tal.jump(words, "hold")

    tal.label(words, "gate")
    path.path(tal, words, gate)
    tal.jump(words, "hold")

    gst = gest:new()
    gst:create()
    gst:compile(words)

    lilts {
        {"phasor", 2, 0}
    }
    cnd = sig:new()
    cnd:hold()

    zz = "zz"
    gst:gesture("pitch", cnd)
    lilts {
        {"param", 63},
        {"add", zz, zz},
        {"mtof", zz},
        {"blsaw", zz},
        {"butlp", zz, 800},
        {"mul", zz, "[dblin -6]"}
    }
    gst:gesture("gate", cnd)
    lilts {
        {"envar", zz, 0.1, 0.2},
        {"mul", zz, zz},
    }

    filename = string.format("tmp/%d.wav", num)
    print("rendering " .. filename)
    lil(string.format("wavout zz " .. filename))
    lil("computes 0.7")
end

for i=1,8 do
    render_number(i)
    mnoreset()
end
