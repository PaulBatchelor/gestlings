gestku = require("gestku/gestku")
warble = require("warble/warble")

s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)
G = gestku:new()

head = {
    gate = function(words)
        gestku.tal.interpolate(words, 0)
    end,
    aspgt = function(words)
        gestku.tal.interpolate(words, 0)
    end

}

function mkseq()
    local m = G.morpheme

    pm_pitch_upslide = {
        pitch = s16("a/ o"),
    }

    pm_timbre_upslide = {
        timbre = s16("a/ o"),
    }

    pm_fm_flat = {
        mod = s16("b_"),
        car = s16("b_"),
        fdbk = s16("a_"),
    }

    pm_vib_none = {
        vrate = s16("a_"),
        vdepth = s16("a_"),
    }

    pm_amp_full = {
        amp = s16("o"),
    }

    pm_gate_none = {
        gate = s16("a_"),
    }

    pm_asp_default = {
        aspdur = s16("h_"),
        aspgt = s16("a_"),
        aspfreq = s16("b_"),
        aspamt = s16("b_"),
    }

    pm_amp_default = {
        ampdur = s16("c_"),
        ampatk = s16("c_"),
        amprel = s16("c_"),
    }

    pm_gain_full = {
        gain = s16("o_"),
    }

    pm_gain_silence = {
        gain = s16("a_"),
    }

    local mother = {}

    mother = m.merge(mother, pm_pitch_upslide)
    mother = m.merge(mother, pm_timbre_upslide)
    mother = m.merge(mother, pm_fm_flat)
    mother = m.merge(mother, pm_vib_none)
    mother = m.merge(mother, pm_amp_full)
    mother = m.merge(mother, pm_gate_none)
    mother = m.merge(mother, pm_asp_default)
    mother = m.merge(mother, pm_amp_default)
    mother = m.merge(mother, pm_gain_full)

    mother = m.template(mother)

    default = mother{}

    A = default
    S = m.merge(default, pm_gain_silence)

    vocab = {
        A = A,
        S = S
    }
    SEQ = "2[A]2(S)"
    SEQ = gestku.mseq.parse(SEQ, vocab)
    return SEQ
end

function G:sound()
    local lvl = gestku.core.liln
    local sr = gestku.sr
    local pn = sr.paramnode
    local ln = sr.node
    local sig = gestku.sig
    local cnd = sig:new()
    local gst = G.gest
    local param = gestku.core.paramf

    ln(sr.phasor) {
        rate = 15 / 10
    }

    cnd:hold()

    local seq = mkseq()

    G.words = {}
	G.tal.start(G.words)

	G.morpheme.articulate(G.path,
	    G.tal, G.words, seq, head)

    G.gest:compile(G.words)

	gst:swapper()

    fg = gest16(gst, "pitch", cnd, 60, 72)
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
            a = 60,
            b = gest16(gst, "aspfreq", cnd, 20, 60),
        }
    }

    asp_amt = gest16(gst, "aspamt", cnd, 0, 1)

    local g = warble.graph {
        pitch = fg,
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
        diagraf = gestku.diagraf,
        sr = sr,
        sig = sig,
        core = gestku.core,

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
            freq = param(200),
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

	gst:done()
    cnd:unhold()


    -- lil("dup; butlp zz 1000; softclip zz 2; add zz zz")
    -- lil("lowshelf zz 200 4.0 0.5")
    lil("mul zz [dblin -6]")
    lil([[
dup; dup;
bigverb zz zz 0.8 8000
drop;
dcblocker zz
mul zz [dblin -20];
add zz zz
    ]])

    --lil("tgate [tick] 10; smoother zz 0.01; mul zz zz")
    lil("tgate [tick] 14; smoother zz 0.01; mul zz zz")
end

G:setup()
G:sound()
lil("wavout zz test.wav")
lil("computes 10")
