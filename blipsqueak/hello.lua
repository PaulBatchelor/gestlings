warble = require("warble/warble")

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
    gpath_rescaled = path.scale_to_morphseq(gpath, mseq)

    tal.label(words, name)
    path.path(tal, words, gpath_rescaled)
    tal.jump(words, name)
end

function mkconductor(sig, sr, rate)
    local cnd = sig:new()
    sr.node(sr.phasor) {
        rate = 14 / 10
    }
    cnd:hold()

    return cnd
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

    cnd = mkconductor(sig, sr, 14/10)

    lines = mechanism(sr, core, gst, diagraf, cnd)
    -- asset:save(lines, "blipsqueak/mechanism.b64")
    
    -- lines = asset:load("blipsqueak/mechanism.b64")
    -- for _, l in pairs(lines) do
    --     if type(l) == "table" then
    --         l = table.concat(l, " ")
    --     end
    --     print(l)
    --     lil(l)
    -- end

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
