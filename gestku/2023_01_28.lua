--[[
goblin trying to remember the lyrics to a song
-- <@>
dofile("gestku/2023_01_28.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
-- </@>
-- <@>
gestku = require("gestku/gestku")
warble = require("warble/warble")

s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)
G = gestku:new()

function G.symbol()
    return [[
--------------
-######-------
--------------
--#--#-----#--
#----------##-
##--###----#-#
#-----#----#--
---------###--
-----##--###--
----#--#--#---
-----##-------
--------------
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=60})
end

function pat(p)
    return {
        pitch = p.pitch or solf("d4~s,dr4.m8r4d2."),
        timbre = p.timbre or s16("f2 d f d3 f1 d2 f6"),
        fdbk = p.fdbk or s16("f2^ g b l3 h1 i2 f6"),
        vrate = p.vrate or s16("f_"),
        vdepth = p.vdepth or s16("k_"),
        amp = p.amp or s16("o"),
        mod = p.mod or s16("b_"),
        car = p.car or s16("b_"),
        gate =  p.gate or s16("a_"),
        aspdur = p.aspdur or s16("h_"),
        aspgt = p.aspgt or s16("a_"),
        gain = p.gain or s16("o_"),
        gdur = p.gdur or s16("a_"),
        ampdur = p.ampdur or s16("c_"),
        ampatk = p.atk or s16("c_"),
        amprel = p.rel or s16("c_"),
        aspfreq = p.aspfreq or s16("b_"),
        aspamt = p.aspamt or s16("b_"),
    }
end

function clone(M, p)
    local o = {}
    p = p or {}

    for k,v in pairs(M) do
        o[k] = p[k] or v
    end

    return o
end

sing = pat {
}

mutter = pat {
    pitch = solf("d,2/ d,,4_"),
    timbre = s16("i_"),
    fdbk = s16("a_"),
    vrate = s16("a_"),
    vdepth = s16("a_"),
    gain = s16("o15_ a1"),
    aspgt = s16("o-"),
    gate = s16("o-"),
    amp = s16("a/ o"),
    ampatk = s16("p_"),
    amprel= s16("p_"),
    ampdur = s16("p_"),
    aspdur = s16("f_"),
}

mutter2 = pat {
    pitch = solf("d,,4/ r,, d,, s,, r,, d,,_"),
    timbre = s16("i_"),
    fdbk = s16("a_"),
    vrate = s16("a_"),
    vdepth = s16("a_"),
    gain = s16("o15_ a1"),
}

excited = pat {
    pitch = solf("d,4/ d^ d,/ d'^"),
    timbre = s16("i_"),
    fdbk = s16("a_"),
    vrate = s16("a_"),
    vdepth = s16("a_"),
    gain = s16("o15_ a1"),
}

vocab = {
    A = clone(sing),
    B = clone(mutter),
    C = clone(sing, {
        pitch = solf("d4~s,dm2^"),
        timbre = s16("d1"),
        fdbk = s16("d"),
    }),
    D = clone(mutter2),
    E = clone(sing, {
        pitch = solf("d4~s,dm2^"),
        timbre = s16("d_"),
        fdbk = s16("f_"),
        gain = s16("o15_ a1"),
        aspamt = s16("j_"),
    }),
    F = clone(excited),
    G = clone(mutter, {
        pitch = solf("d,,2/ r,,4_"),
    }),
    S = clone(sing, {
        gain = s16("a_")
    })
}

head = {
    gate = function(words)
        gestku.tal.interpolate(words, 0)
    end,
    aspgt = function(words)
        gestku.tal.interpolate(words, 0)
    end

}

SEQ = "2[C]2(S)B2(S)DSSESGS2[ES]2(F)S4[A]2[S]"
SEQ = gestku.mseq.parse(SEQ, vocab)

-- </@>

-- <@>
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
        -- rate = 13 / 10
        rate = 15 / 10
    }

    cnd:hold()

    local seq = SEQ

    G:start()
    G:articulate(seq, head)
    G:compile()

	gst:swapper()

    fg = pn(gst:node()) {
        name = "pitch",
        conductor = lvl(cnd:getstr())
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

function run()
    G:sound()
    lil("out")
end

function G.patch()
    G:setup()
    G:sound()
end

return G
-- </@>
