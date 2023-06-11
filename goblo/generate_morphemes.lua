gestku = require("gestku/gestku")
warble = require("warble/warble")
pp = require("util/pprint")
json = require("util/json")

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

    global_pitch = gest16(gst, "gpitch", cnd, -12, 12)

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

function add_fraction(a, b)
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
        total = add_fraction(total, r)
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


    seqdur = morphseq_dur(seq)
    -- pp(seqdur)
    local s16 = gestku.seq.seqfun(gestku.morpho)
    global_pitch = s16("a1/ h4~ o1/")
    -- pp(global_pitch)
    pnorm = path_normalizer(global_pitch)
    -- pp(pnorm)
    total_ratemul =fracmul(pnorm, seqdur)
    -- pp(total_ratemul)
    global_pitch_rescaled = apply_ratemul(global_pitch, total_ratemul, G.path.vertex)
    -- pp(global_pitch_rescaled)
	G.morpheme.articulate(G.path,
	    G.tal, G.words, seq, head)

    label = "gpitch"
    G.tal.label(G.words, label)
    if head[label] ~= nil then
        head[label](G.words)
    end
    G.path.path(G.tal, G.words, global_pitch_rescaled)
    G.tal.jump(G.words, label)

    -- pp(G.words)
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
