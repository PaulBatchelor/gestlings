msgpack = require("util/MessagePack")
base64 = require("util/base64")
asset = require("asset/asset")
asset = asset:new({msgpack=msgpack, base64=base64})

morpheme = require("morpheme/morpheme")
seq = require("seq/seq")
morpho = require("morpheme/morpho")
mseqlang = require("morpheme/mseq")

function multimerge(merge, A, P)
    for _, B in pairs(P) do
        A = merge(A, B)
    end
    return A
end

function mouthpos (pos)
    local seq = {}
    if type(pos) == "number" then
        table.insert(seq, {pos, 1, 1})
    else
        for _, v in pairs(pos) do
            table.insert(seq, {v, 1, 1})
        end
    end

    return {
        mouthpos = seq
    }
end
function mkvocab(seq, morpho, morpheme)
    local m = morpheme
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
    mother = m.merge(mother, mouthpos({0, 1}))

    mother = m.template(mother)

    default = mother{}

    local A = default
    B = mm(A, {pm_asp_breathy, pm_pitch_losigh, mouthpos({1, 2, 1})})
    C = mm(B, {pm_pitch_hisigh, mouthpos({2, 3, 1})})
    D = mm(default, {pm_pitch_chippy, mouthpos({3, 4, 2, 3, 4, 3, 4})})
    E = mm(D, {pm_pitch_hisigh, mouthpos({4, 5, 1, 4})})
    F = mm(D, {pm_pitch_huhlo, mouthpos({5, 3})})
    H = mm(A, {pm_pitch_huhlo, pm_timbre_sharpdown, mouthpos({6, 3})})
    I = mm(A, {pm_pitch_wambo, pm_timbre_sharpdown, mouthpos({7, 0, 1})})
    J = mm(A, {pm_pitch_hambo, pm_timbre_sharpdown, pm_asp_breathy, mouthpos({8, 5, 0, 1})})
    local S = m.merge(default, pm_gain_silence, mouthpos({0}))

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

    return vocab
end

local vocab = mkvocab(seq, morpho, morpheme)
asset:save(vocab, "blipsqueak/morphemes.b64")

parse = mseqlang.parse2
words = {
    HELLO=parse("AS"),
    IAM=parse("DE4(D)3(A)S"),
    PLEASED=parse("2(IJ)B2(F)S"),
    WELCOME=parse("2(JCB)H4[S]")
}

asset:save(words, "blipsqueak/words.b64")
