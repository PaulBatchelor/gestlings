warble = require("warble/warble")
pp = require("util/pprint")
json = require("util/json")

msgpack = require("util/MessagePack")
base64 = require("util/base64")
asset = require("asset/asset")
asset = asset:new({msgpack=msgpack, base64=base64})

core = require("util/core")
sigrunes = require("sigrunes/sigrunes")
gest = require("gest/gest")
tal = require("tal/tal")
morpheme = require("morpheme/morpheme")
path = require("path/path")
seq = require("seq/seq")
morpho = require("morpheme/morpho")
mseqlang = require("morpheme/mseq")
sig = require("sig/sig")
diagraf = require("diagraf/diagraf")
mechanism = require("blipsqueak/mechanism")

function mkseq(seq, morpho)
    vocab = asset:load("blipsqueak/morphemes.b64")
    words = asset:load("blipsqueak/words.b64")

    SEQ = words.HELLO .. words.IAM .. words.PLEASED .. words.WELCOME
    SEQ = mseqlang.parse(SEQ, vocab)
    return SEQ
end

function create_aligned_path(path, tal, words, mseq, gpath, name)
    -- local seqdur = morphseq_dur(mseq)
    -- local pnorm = path_normalizer(gpath)
    -- local total_ratemul = fracmul(pnorm, seqdur)
    -- local gpath_rescaled =
    --     apply_ratemul(gpath, total_ratemul, path.vertex)

    gpath_rescaled = path.scale_to_morphseq(gpath, mseq)

    head = head or {}

    tal.label(words, name)
    -- if head[label] ~= nil then
    --     head[label](G.words)
    -- end
    path.path(tal, words, gpath_rescaled)
    tal.jump(words, name)
end

function sound()
    local lvl = core.liln
    local sr = sigrunes
    local pn = sr.paramnode
    local ln = sr.node
    local cnd = sig:new()
    local gst = gest:new{tal=tal}
    local param = core.paramf
    local words = {}

    gst:create()
    local mseq = mkseq(seq, morpho)

    words = {}
	tal.start(words)

    head = {
        gate = function(words)
            tal.interpolate(words, 0)
        end,
        aspgt = function(words)
            tal.interpolate(words, 0)
        end

    }

    local s16 = seq.seqfun(morpho)
    global_pitch = s16("h1/ k2~ h1/ d h i2~ h4_")
    global_tempo = s16("d1/ f d4 c")

    create_aligned_path(path, tal, words, mseq, global_pitch, "gpitch")
    create_aligned_path(path, tal, words, mseq, global_tempo, "gtempo")

	morpheme.articulate(path, tal, words, mseq, head)

    gst:compile(words)

	gst:swapper()

    gest16 = gest.gest16fun(sr, core)
    ln(sr.phasor) {
        rate = 14 / 10
    }

    cnd:hold()
    mechanism(sr, core, gst, cnd)
    cnd:unhold()
	gst:done()

    lil("mul zz [dblin -6]")
    lil([[
dup; dup;
bigverb zz zz 0.8 8000
drop;
dcblocker zz
mul zz [dblin -20];
add zz zz
    ]])
end

sound()
lil("wavout zz test.wav")
lil("computes 10")
