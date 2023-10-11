core = require("util/core")
rt = require("util/rt")
lilt = core.lilt
lilts = core.lilts
sig = require("sig/sig")
sigrunes = require("sigrunes/sigrunes")
phystoni = require("physiology/phys_toni")
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
    local behavior = gest.behavior
    local stp = behavior.step
    local gm = behavior.gliss_medium
    local lin = behavior.linear
    local gt = behavior.gate_50
    pat_a = morpheme.template({
        gate = {
            {1, 1, stp},
        },
        pitch = {
            {84, 1, gm},
            {84 + 5, 1, gm},
        },
        -- TODO remove whistle trigger or make it sound better
        trig = {
            {0, 1, gt},
        },

        click_rate = {
            {8, 1, lin},
            {20, 1, gm},
            {4, 1, lin},
            {20, 1, lin},
        },

        whistle_amt = {
            {0, 3, gm},
            {8, 1, gm},
        },

        pulse_amt = {
            {0, 1, stp},
        },

        click_fmin = {
            {70, 1, stp},
        },

        click_fmax = {
            {92, 1, lin},
            {99, 1, lin},
        },

        amfreq = {
            {48, 1, lin},
            {96, 1, lin},
            {60, 1, gm},
        },

        tickmode = {
            {0, 1, gm},
            {1, 3, stp},
        },

        tickpat = {
            {1, 2, gt},
            {1, 1, gt},
            {1, 2, gt},
            {1, 1, gt},
            {1, 2, gt},
            {1, 2, gt},
            {1, 2, gt},
            {1, 1, gt},
            {1, 2, gt},
            {1, 1, gt},
            {1, 2, gt},
            {1, 2, gt},
        },
    })

    local vocab = {}
    add = function(key, mrph)
        local w = {}
        w.word = mrph
        table.insert(vocab, w)
    end

    add("A", pat_a{})
    add("S", pat_a {
        tickmode= {
            {1, 1, stp},
        },
        tickpat = {
            {0, 1, stp},
        },
        gate = {
            {0, 1, stp}
        }
    })

    return vocab
end

function patch(phystoni, gst)
    local pt = phystoni.create {
        sig = sig,
    }

    -- set up tract filter, use fixed shape for testing
    local tubular = pt.tubular
    local shape = {
        0.1, 0.1, 0.1, 0.1, 0.1, 0.4, 0.1, 0.1
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
end

function mkmonologue(gst)
    local prostab = asset:load("prosody/prosody.b64")

    local phrase = {
        {1, {1, 2}},
        {1, {1, 1}},
        {2, {1, 1}},
    }

    local vocab = genvocab()

    mono = {
        {phrase, prostab.neutral},
        {phrase, prostab.question},
        {phrase, prostab.some_jumps},
        {phrase, prostab.some_jumps_v2},
        {phrase, prostab.excited},
    }

    head = {
        trig = function(words)
            tal.interpolate(words, 0)
        end,
        tickpat = function(words)
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
    }

    return words
end

function sound()
    local gst = gest:new {
        tal = tal,
        sigrunes = sigrunes,
        core = core,
    }
    gst:create()
    local words = mkmonologue()
    gst:compile(words)
    gst:swapper()
    patch(phystoni, gst)
    gst:done()
end

sound()
lil("wavout zz tmp/test.wav")
lil("computes 20")
