core = require("util/core")
rt = require("util/rt")
lilt = core.lilt
lilts = core.lilts
sig = require("sig/sig")
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
    local stp = behavior.stp
    pat_a = morpheme.template({
        gate = {
            {1, 1, stp},
        }
    })

    local vocab = {}
    add = function(key, mrph)
        local w = {}
        w.word = mrph
        table.insert(vocab, w)
    end

    add("A", pat_a{})
    add("S", pat_a{
        gate = {
            {0, 1, stp}
        }
    })

    return vocab
end

function patch(phystoni)
    local pt = phystoni.create {
        sig = sig,
    }

    -- set up tract filter, use fixed shape for testing
    local tubular = pt.tubular
    local shape = {
        0.1, 0.1, 0.1, 0.1, 0.1, 0.4, 0.3, 0.9
    }

    phystoni.fixed_tube_shape(sig, tubular, shape)

    -- create excitation signal
    local pitch, trig, gate = phystoni.tempwhistlesigs()

    phystoni.excitation(sig, core, pitch, trig, gate)
    pitch:unhold()
    trig:unhold()

    local exc = sig:new()
    exc:hold()

    -- process excitation with tract filter
    phystoni.filter(tubular, exc)
    exc:unhold()
    phystoni.gate(gate)
    gate:unhold()
    phystoni.postprocess()
    phystoni.clean(pt)
end

function mkmonologue()
    local prostab = asset:load("prosody/prosody.b64")

    local phrase = {
        {1, {1, 1}},
        {2, {1, 1}}
    }

    local vocab = genvocab()

    mono = {
        {phrase, prostab.neutral}
    }

    local words = monologue.to_words {
        tal = tal,
        path = path,
        morpheme = morpheme,
        vocab = vocab,
        monologue = mono,
    }

    -- TODO: test and see if this actually works?
end

mkmonologue()
patch(phystoni)

lil("wavout zz tmp/test.wav")
lil("computes 10")
