local gest = require("gest/gest")
local asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
local morpheme = require("morpheme/morpheme")

-- corresponds to how symbols are
-- arranged in tilemaker
function coord(x, y)
    return (y - 1)*8 + x
end

function addvocab(vocab, x, y, w, doc, tok)
    local row = y
    local col = x
    local pos = coord(x, y)

    local v = {}
    v.doc = doc
    v.word = w
    v.tok = tok
    vocab[pos] = v
end

function genvocab()
    local vocab = {}
    voc = function (x, y, w, doc, tok)
        addvocab(vocab, x, y, w, doc, tok)
    end

    local behavior = gest.behavior
    local stp = behavior.step
    local gm = behavior.gliss_medium
    local lin = behavior.linear
    local gt = behavior.gate_50


    local shA = "364f9c"
    local shB = "ebaa8f"
    local shC = "c72639"
    local shD = "14d545"
    local shE = "d5141b"

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
            {0, 1, gm},
        },

        click_fmin = {
            {70, 1, gm},
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

        shapes = {
            {shA, 1, lin},
            {shE, 1, lin},
            {shC, 1, lin}
        },

        sync = {
            {1, 1, gt}
        }
    })

    voc(1, 1, pat_a {
    }, "test word.")

    voc(2, 1, pat_a {
        tickmode= {
            {1, 1, stp},
        },
        tickpat = {
            {0, 1, stp},
        },
        gate = {
            {0, 1, stp}
        }
    }, "silence.")

    return vocab
end

function write_vocab_asset(filename)
    local vocab = genvocab()
    asset:save(vocab, filename)
end

write_vocab_asset("vocab/toni/v_toni.b64")
