V = {}
function morpheme2voice(M, name)
    local out = {}

    for k,v in pairs(M) do
        out[k .. name] = v
    end

    return out
end

function morpheme_append_op(m, op, id)
    for k, v in pairs(op) do
        m[k .. id] = v
    end
end

function table_to_number(tab)
    local len = #tab / 2
    local r1 = 0
    local r2 = 0
    for i = 1, len do
        local shift = 1 << (i - 1)
        r1 = r1 | (shift * tab[i])
        r2 = r2 | (shift * tab[i + len])
    end
    local n = r1 | (r2 << len) | (1 << (len * 2))
    return n
end

function V.morphemes()
    local b = gestku.gest.behavior
    local gm = b.gliss_medium
    local lin = b.linear
    local stp = b.step

    op3 = {
        wtpos = {
            {WT.sine, 2, gm},
            {WT.wt4, 2, gm},
        },
        modamt = {
            {1, 1, gm},
        },
        frqmul = {
            {1, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
    }

    op2 = {
        wtpos = {
            {WT.sine, 1, gm},
        },
        modamt = {
            {1, 1, stp},
        },
        frqmul = {
            {1, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
    }

    op1 = {
        wtpos = {
            {WT.sine, 1, gm},
        },
        frqmul = {
            {4, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
        modamt = {
            {1, 1, stp},
        },
    }

    op0 = {
        wtpos = {
            {WT.sine, 1, gm},
        },
        frqmul = {
            {8, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
        modamt = {
            {0, 1, stp},
        },
    }

    local M = {
        seq = gestku.nrt.eval("d1", {base=54}),
        gate = s16("p3_ p1~"),
    }

    morpheme_append_op(M, op3, 3)
    morpheme_append_op(M, op2, 2)
    morpheme_append_op(M, op1, 1)
    morpheme_append_op(M, op0, 0)

    mother = gestku.morpheme.template(M)

    morphemes = {}

    local A = mother {
        seq = gestku.nrt.eval("d,,~", {base=54}),
    }

    morpheme_append_op(A, {
        wtpos = {
            {WT.wt2, 1, gm},
            {WT.wt4, 1, lin},
        },
        modamt = {
            {1, 1, gm},
        },
        frqmul = {
            {1, 1, stp},
        },
        fdbk = {
            {0, 1, gm},
        },
    }, 3)

    local B = mother {
        seq = gestku.nrt.eval("r8t4d8/s4~", {base=54}),
        gate = s16("p4/a1~"),
    }

    local C = mother {
        gate = s16("a_"),
    }

    local D = mother {
        seq = gestku.nrt.eval("D''", {base=54}),
        gate = s16("p1_a4"),
    }

    morpheme_append_op(D, {
        wtpos = {
            {WT.sine, 1, gm},
        },
        modamt = {
            {3, 1, stp},
        },
        frqmul = {
            {1, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
    }, 3)


    morpheme_append_op(D, {
        wtpos = {
            {WT.sine, 1, gm},
        },
        modamt = {
            {0, 1, stp},
        },
        frqmul = {
            {1, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
    }, 2)

    local tone = gestku.morpheme.template(D)

    E = tone {
        seq = gestku.nrt.eval("r4~ m2 d4^", {base=54}),
        gate = s16("f1/ k~"),
    }

    F = tone {
        seq = gestku.nrt.eval("s4~ f+2 l4^", {base=54}),
        gate = s16("k1/ l~"),
    }

    GG = tone {
        seq = gestku.nrt.eval("m~ d f+ d m d f+ d", {base=54}),
        gate = s16("h1/"),
    }

    H = tone {
        seq = gestku.nrt.eval("d m s d m s r f+ l r f+ l", {base=54}),
        gate = s16("h1/"),
    }

    morpheme_append_op(H, {
        wtpos = {
            {WT.sine, 1, gm},
        },
        modamt = {
            {1, 3, lin},
            {8, 1, gm},
            -- {1, 1, lin},
            -- {3, 1, lin},
        },
        frqmul = {
            {1, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
    }, 3)

    I = tone {
        seq = gestku.nrt.eval("d8 D4 t8 D2", {base=54}),
        gate = s16("h1/ l~"),
    }

    morphemes.A = morpheme2voice(A, "a")
    morphemes.B = morpheme2voice(B, "a")
    morphemes.C = morpheme2voice(C, "a")
    morphemes.D = morpheme2voice(D, "a")
    morphemes.E = morpheme2voice(E, "a")
    morphemes.F = morpheme2voice(F, "a")
    morphemes.G = morpheme2voice(GG, "a")
    morphemes.H = morpheme2voice(H, "a")
    morphemes.I = morpheme2voice(I, "a")

    return morphemes
end

function V.bitrunes()
    vocab = {}
    vocab[table_to_number({
        1, 1,
        1, 1,
    })] = "2(A)"

    vocab[table_to_number({
        1,
        1,
    })] = "4(B)"

    vocab[table_to_number({
        0,
        1,
    })] = "3(C)"

    vocab[table_to_number({
        1,
        0,
    })] = "4(D)"

    vocab[table_to_number({
        0, 0, 0,
        1, 1, 1
    })] = "2[E]"

    vocab[table_to_number({
        1, 1, 1,
        0, 0, 0,
    })] = "2[F]"

    vocab[table_to_number({
        0, 0,
        1, 1,
    })] = "G"

    vocab[table_to_number({
        1, 1, 1, 0, 1,
        1, 0, 1, 1, 1,
    })] = "H"

    vocab[table_to_number({
        1, 0, 1,
        1, 1, 1,
    })] = "2[I]"
    return vocab
end

return V
