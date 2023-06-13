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
sig = require("sig/sig")
diagraf = require("diagraf/diagraf")

function mechanism(sr, core, gst, diagraf, cnd_main)
    local pn = sr.paramnode
    local lvl = core.liln
    local param = core.paramf
    local ln = sr.node

    local lines = {}

    function eval(s)
        table.insert(lines, s)
        if type(s) == "table" then
            s = table.concat(s, " ")
        end
        lil(s)
    end

    sr.node_eval(eval)
    gest16 = gest.gest16fun(sr, core)

    -- cnd = cnd_main
    cnd = sig:new()
    cnd_main:get(eval)

    -- hack, gest16 creates parameter node, wrap it
    -- in add to eval it immediately with ln

    ln(sr.add) {
        a = 0,
        b = gest16(gst, "gtempo", cnd_main, 0.75, 1.25)
    }

    eval({"rephasor", "zz", "zz"})
    cnd:hold(eval)


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

    g.eval = eval
	l = g:generate_nodelist()
	g:compute(l)

    ln(sr.smoother) {
        input = gest16(gst, "gain", cnd, 0, 0.5),
        smooth = 0.003,
    }

    eval({"mul", "zz", "zz"})
    cnd:unhold(eval)

    return lines
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

    vocab = asset:load("blipsqueak/morphemes.b64")
    local slice = {}
    for k, _ in pairs(vocab.A) do
        slice[k] = {{0, 1, 0}}
    end
    mseq = {{slice, {1, 1}}}


    words = {}
	tal.start(words)

    global_pitch = {{0, 0, 0}}
    global_tempo = {{0, 0, 0}}

    tal.label(words, "gpitch")
    path.path(tal, words, global_pitch)
    tal.jump(words, "gpitch")

    tal.label(words, "gtempo")
    path.path(tal, words, global_tempo)
    tal.jump(words, "gtempo")

	morpheme.articulate(path, tal, words, mseq, head)

    gst:compile(words)

	gst:swapper()

    local cnd = sig:new()
    lil("mul 0 0")
    cnd:hold()

    lines = mechanism(sr, core, gst, diagraf, cnd)
    patch_data = core.analyze_patch(lines)
    ext = {
        cnd=cnd.reg
    }
    core.insert_register_macros(lines, patch_data, ext)
    asset:save({info=patch_data, patch=lines}, "blipsqueak/mechanism.b64")
end

sound()
