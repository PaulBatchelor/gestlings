--[[
-- <@>
dofile("physiology/pg/toni_mech.lua")
-- </@>

-- I'm not clearing all the registers apparently
-- Run this block when "regnxt" failure errors
-- pop up
-- <@>
lil("unholdall")
for i=1,16 do
    lil(string.format("regclr %d", i - 1))
end
-- </@>
--]]

core = require("util/core")
rt = require("util/rt")
lilt = core.lilt
lilts = core.lilts
sig = require("sig/sig")
sigrunes = require("sigrunes/sigrunes")
-- phystoni = require("physiology/phys_toni")
gest = require("gest/gest")
asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
morpheme = require("morpheme/morpheme")
monologue = require("monologue/monologue")
tal = require("tal/tal")
path = require("path/path")

function genvocab()
    return asset:load("vocab/toni/v_toni.b64")
end

-- <@>
function patch(phystoni, gst)
    local pt = phystoni.create {
        sig = sig,
    }

    lilt {"phasor", 1/4, 0}
    local cnd = sig:new()
    cnd:hold_cabnew()

    phystoni.physiology {
        core = core,
        sig = sig,
        gst = gst,
        cnd = cnd
    }
    cnd:unhold()
end
-- </@>

-- <@>
function coord(x, y)
    return (y - 1)*8 + x
end
-- </@>

-- <@>
function genphrase()
    dlong = {1, 2}
    dshort = {1, 1}

    local w = {
        test = coord(1, 1),
        silence = coord(2, 1),
        wh_long = coord(3, 1),
        p_shp_a = coord(4, 1),
        p_shp_b = coord(5, 1),
        wh_mel1 = coord(6, 1),
        wh_mel2 = coord(7, 1),
        wh_mel3 = coord(8, 1),
        cl_a = coord(4, 2),
        cl_b = coord(5, 2),
        cl_c = coord(6, 2),
    }

    local phrase = {
--        {w.cl_a, dlong},
        {w.cl_b, dlong},
        {w.cl_c, dlong},
        {w.silence, short},
    }

    return phrase
end
-- </@>

-- <@>
function mkmonologue(shapelut)
    local prostab = asset:load("prosody/prosody.b64")

    local phrase = genphrase()

    mono = {
        {phrase, prostab.neutral},
        {phrase, prostab.question},
        {phrase, prostab.some_jumps},
        {phrase, prostab.some_jumps_v2},
        {phrase, prostab.excited},
    }

    local vocab = genvocab()


    head = {
        trig = function(words)
            tal.interpolate(words, 0)
        end,
        tickpat = function(words)
            tal.interpolate(words, 0)
        end,
        sync = function(words)
            tal.interpolate(words, 0)
        end,
    }

    local words = monologue.to_words {
        tal = tal,
        path = path,
        morpheme = morpheme,
        vocab = vocab,
        monologue = mono,
        head = head,
        shapelut = shapelut,
    }

    print("program size: ", #words)
    return words
end
-- </@>

function setup()
    -- shapemorf stuff
    local shape_fname = "shapes/s_toni.b64"
    lil("shapemorfnew lut " .. shape_fname)
    lil("grab lut")
    local lut = pop()
    local shapelut = shapemorf.generate_lookup(lut)

    -- gestvm stuff
    local gst = gest:new {
        tal = tal,
        sigrunes = sigrunes,
        core = core,
    }
    gst:create()

    local o = {}

    o.gst = gst
    o.shapelut = shapelut

    rt.setup()
    return o
end

-- <@>
function sound(dat)
    local phystoni = dofile("physiology/phys_toni.lua")
    -- generate gestvm program
    local shapelut = dat.shapelut
    local gst = dat.gst
    local words = mkmonologue(shapelut)
    gst:compile(words)
    gst:swapper()
    patch(phystoni, gst)
    gst:done()
end
-- </@>

ToniData = setup()

-- <@>
function run ()
    print("run")
    sound(ToniData)
    rt.out()
end
-- </@>
