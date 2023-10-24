core = require("util/core")
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
    return asset:load("vocab/toni/v_toni.b64")
end

-- <@>
function patch(phystoni, gst)
    local pt = phystoni.create {
        sig = sig,
    }

    -- lilt {"phasor", 1/4, 0}
    lilt {"phasor", 1/3, 0}
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
function genproofword(word)
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
    }

    local silence = coord(2, 1)
    local word = coord(word[1], word[2])
    local phrase = {
        {word, dlong},
        {silence, dshort},
    }

    return phrase
end
-- </@>

-- <@>
function mkmonologue(shapelut, word)
    local prostab = asset:load("prosody/prosody.b64")

    local phrase = genproofword(word)

    mono = {
        {phrase, prostab.neutral},
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

    return o
end

-- <@>
function sound(dat, word)
    -- generate gestvm program
    local shapelut = dat.shapelut
    local gst = dat.gst
    local words = mkmonologue(shapelut, word)
    gst:compile(words)
    gst:swapper()
    patch(phystoni, gst)
    gst:done()
end
-- </@>

function generate_filename(w)
    return string.format("tmp/toni_proof/toni_%d_%d.wav", w[1], w[2])
end

function render_word(w)
    local ToniData = setup()
    print(string.format("rendering (%d, %d)", w[1], w[2]))
    sound(ToniData, w)
    lilt {
        "wavout", "zz", generate_filename(w)
    }
    lil("computes 3.5")
end

-- <@>
function run ()
    local words = {
        {1, 1},
        {3, 1},
        {6, 1},
        {7, 1},
        {8, 1},
    }
    local filenames = {}

    -- for i=1,8 do
    --     os.execute(string.format("espeak -w tmp/%d.wav \"%d\"", i, i))
    --     os.execute(string.format("sox tmp/%d.wav -r 44100 tmp/tmp.wav", i))
    --     os.execute(string.format("mv tmp/tmp.wav tmp/%d.wav", i))
    -- end

    os.execute("mkdir -p tmp/toni_proof/")
    for _,w in pairs(words) do
        render_word(w)
        table.insert(filenames, string.format("tmp/%d.wav", w[1]))
        table.insert(filenames, string.format("tmp/%d.wav", w[2]))
        table.insert(filenames, generate_filename(w))
        mnoreset()
    end

    sox_cmd =
        "sox " ..
        table.concat(filenames, " ") ..
        " tmp/toni_proof/proof.wav"

    os.execute(sox_cmd)

end
-- </@>

run()
