gestku = require("gestku/gestku")
warble = require("warble/warble")

G = gestku:new()

function multimerge(merge, A, P)
    for _, B in pairs(P) do
        A = merge(A, B)
    end
    return A
end

function mkseq(seq, morpho)
    local m = G.morpheme
    local s16 = seq.seqfun(morpho)
    local mm = function(A, P)
        return multimerge(m.merge, A, P)
    end

    pm_pitch_upslide = {
        pitch = s16("a/ o"),
    }

    pm_pitch_losigh = {
        pitch = s16("b4/ a1~"),
    }

    pm_pitch_huhlo = {
        pitch = s16("a4/ c1~"),
    }

    pm_pitch_hisigh = {
        pitch = s16("h4/ c1~"),
    }

    pm_pitch_wambo = {
        pitch = s16("f1/ d2 f1 d2 a3 b1~"),
    }

    pm_pitch_hambo = {
        pitch = s16("n1/ j2 n1 j2 c3 d1~"),
    }

    pm_pitch_chippy = {
        pitch = s16("o1/ a4~ o1/ a4~ o1/ a4~ o1/ a4~"),
        -- pitch = s16("o1~"),
        gate = s16("o1- o o o o o o o"),
        ampdur = s16("a/ c~"),
        ampatk = s16("b_"),
        amprel = s16("n_"),
        amp = s16("a3_ a1~"),
        gain = s16("o2~ b1~ a1/"),
    }

    pm_timbre_upslide = {
        timbre = s16("a/ o"),
    }

    pm_timbre_sharpdown = {
        timbre = s16("o~ a"),
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
        amp = s16("o3_ o1~"),
    }

    pm_gate_none = {
        gate = s16("a_"),
    }

    pm_asp_default = {
        aspdur = s16("h3_ h1/"),
        aspgt = s16("a_"),
        aspfreq = s16("e3_ e1/"),
        aspamt = s16("b3_ b1/"),
    }

    pm_asp_breathy = {
        aspdur = s16("a3_ a1/"),
        aspgt = s16("a3_"),
        aspamt = s16("i3/ j1~"),
        aspfreq = s16("f1/ a2"),
    }

    pm_amp_default = {
        ampdur = s16("c_"),
        ampatk = s16("c_"),
        amprel = s16("c_"),
    }

    pm_gain_full = {
        gain = s16("o3_ o1/"),
    }

    pm_gain_silence = {
        gain = s16("a2_ a1~"),
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

    local A = default
    B = mm(A, {pm_asp_breathy, pm_pitch_losigh})
    C = mm(B, {pm_pitch_hisigh})
    D = mm(default, {pm_pitch_chippy})
    E = mm(D, {pm_pitch_hisigh})
    F = mm(D, {pm_pitch_huhlo})
    H = mm(A, {pm_pitch_huhlo, pm_timbre_sharpdown})
    I = mm(A, {pm_pitch_wambo, pm_timbre_sharpdown})
    J = mm(A, {pm_pitch_hambo, pm_timbre_sharpdown, pm_asp_breathy})
    local S = m.merge(default, pm_gain_silence)

    vocab = {
        S = S,
        A = A,
        B = B,
        C = C,
        D = D,
        E = E,
        F = F,
        H = H,
        I = I,
        J = J,
    }


    --SEQ = "D2(S)DA2[C]2(S)2[B]2(S)"
    SEQ = "JSDSESFSHSIS"
    SEQ = gestku.mseq.parse(SEQ, vocab)
    return SEQ
end

function mechanism(sr, core, gst, cnd)
    local pn = sr.paramnode
    local lvl = core.liln
    local param = core.paramf
    local ln = sr.node

    gest16 = gestku.gest.gest16fun(sr, core)

    fg = gest16(gst, "pitch", cnd, 48, 72)
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

    local seq = mkseq(gestku.seq, gestku.morpho)

    G.words = {}
	G.tal.start(G.words)

    head = {
        gate = function(words)
            gestku.tal.interpolate(words, 0)
        end,
        aspgt = function(words)
            gestku.tal.interpolate(words, 0)
        end

    }


	G.morpheme.articulate(G.path,
	    G.tal, G.words, seq, head)
    G.gest:compile(G.words)

	gst:swapper()
    mechanism(sr, gestku.core, gst, cnd)
    cnd:unhold()
	gst:done()


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
