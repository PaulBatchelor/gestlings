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

function mkseq(seq, morpho)
    vocab = asset:load("blipsqueak/morphemes.b64")
    words = asset:load("blipsqueak/words.b64")

    SEQ = words.HELLO .. words.IAM .. words.PLEASED .. words.WELCOME
    SEQ = mseqlang.parse(SEQ, vocab)
    return SEQ
end

function mechanism(sr, core, gst, cnd_main)
    local pn = sr.paramnode
    local lvl = core.liln
    local param = core.paramf
    local ln = sr.node

    gest16 = gest.gest16fun(sr, core)

    -- cnd = cnd_main
    cnd = sig:new()
    cnd_main:get()

    -- hack, gest16 creates parameter node, wrap it
    -- in add to eval it immediately with ln

    ln(sr.add) {
        a = 0,
        b = gest16(gst, "gtempo", cnd_main, 0.75, 1.25)
    }

    lil("rephasor zz zz")
    cnd:hold()


    fg = gest16(gst, "pitch", cnd, 48, 72)

    global_pitch = gest16(gst, "gpitch", cnd, -7, 7)

    pitch_biased = pn(sr.add) {
        a = global_pitch,
        b = fg,
    }

    tg = gest16(gst, "timbre", cnd, 0.0, 10)
    vdepth  = gest16(gst, "vdepth", cnd, 0.0, 0.8)
    vrate = gest16(gst, "vrate", cnd, 4, 8)

    ag = gest16(gst, "amp", cnd, 0, 0.8)

    fdbk = gest16(gst, "fdbk", cnd, 0, 0.9)

    gate = gest16(gst, "gate", cnd, 0, 1)

    ampdur = gest16(gst, "ampdur", cnd, 0.001, 0.5)
    aspdur = gest16(gst, "aspdur", cnd, 0.003, 0.6)

    aspgt = gest16(gst, "aspgt", cnd, 0, 1)

    mod = pn(gst:node()) {
        name = "mod",
        conductor = lvl(cnd:getstr())
    }

    car = pn(gst:node()) {
        name = "car",
        conductor = lvl(cnd:getstr())
    }

    ampatk = gest16(gst, "ampatk", cnd, 0.001, 0.05)
    amprel = gest16(gst, "amprel", cnd, 0.001, 0.05)

    asp_freq = pn(sr.mtof) {
        input = pn(sr.add) {
            a = 50,
            b = gest16(gst, "aspfreq", cnd, 20, 60),
        }
    }

    asp_amt = gest16(gst, "aspamt", cnd, 0, 1)

    local g = warble.graph {
        -- pitch = fg,
        pitch = pitch_biased,
        mi = tg,
        fdbk = fdbk,
        amp = {
            val = ag,
            gate = gate,
            dur = ampdur,
            atk = ampatk,
            rel = amprel,
        },
        mod = mod,
        car = car,
        diagraf = diagraf,
        sr = sr,
        sig = sig,
        core = core,

        vib = {
            rate = vrate,
            depth = vdepth,
        },

        asp = {
            gate = aspgt,
            dur = aspdur,
            atk = param(0.01),
            rel = param(0.3),
            gain = param(1.5),
            bw = param(200),
            freq = asp_freq,
            val = asp_amt,
        },
    }

	l = g:generate_nodelist()
	g:compute(l)

    ln(sr.smoother) {
        input = gest16(gst, "gain", cnd, 0, 0.5),
        smooth = 0.003,
    }

    lil("mul zz zz")
    cnd:unhold()
end

function gcd(m, n)
    while n ~= 0 do
        local q = m
        m = n
        n = q % n
    end
    return m
end

function lcm(m, n)
    return (m ~= 0 and n ~= 0) and
        m * n / gcd(m, n) or 0
end

function fracadd(a, b)
    if a[2] == 0 then return b end
    if b[2] == 0 then return a end
    local s = lcm(a[2], b[2])
    local as = s / a[2]
    local bs = s / b[2]
    return {as*a[1] + bs*b[1], s}
end

function reduce(a)
    out = a
    local s = gcd(out[1], out[2])

    if (s ~= 0) then
        out[1] = out[1] / s
        out[2] = out[2] / s
    end

    return out
end

function fracmul(a, b)
    local out = {a[1]*b[1], a[2]*b[2]}

    return reduce(out)
end

function morphseq_dur(mseq)
    local total = {0, 0}
    for _, m in pairs(mseq) do
        local r = m[2]
        total = fracadd(total, r)
    end
    -- r is a ratemultiplier against a normalize
    -- path with dur 1. 2/1 is 2x faster, or dur 1/2.
    -- inverse to get duration
    -- this can be multiplied with normalized path
    -- to stretch/squash it out
    return {total[2], total[1]}
end

function path_normalizer(p)
    local total = 0

    for _, v in pairs(p) do
        total = total + v[2]
    end

    return {total, 1}
end

function apply_ratemul(p, r, vertexer)
    path_with_ratemul = {}

    for _,v in pairs(p) do
        local v_rm = {
            v[1],
            reduce({r[1], v[2]*r[2]}),
            v[3]
        }
        table.insert(path_with_ratemul, vertexer(v_rm))
    end

    return path_with_ratemul
end

function create_aligned_path(path, tal, words, mseq, gpath, name)
    local seqdur = morphseq_dur(mseq)
    local pnorm = path_normalizer(gpath)
    local total_ratemul = fracmul(pnorm, seqdur)
    local gpath_rescaled =
        apply_ratemul(gpath, total_ratemul, path.vertex)

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
