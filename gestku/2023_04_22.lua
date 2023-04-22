--[[
etude in 14
-- <@>
dofile("gestku/2023_04_22.lua")
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
-------------
#-#-#-#-#-#-#
#-#-#-#-#-#-#
-------------
---#-----#---
--#-#---#-#--
-#---#-#---#-
#-----#-----#
-------------
#-#-#-#-#-#-#
#-#-#-#-#-#-#
-------------
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=60})
end

function pat(p)
    return {
        pitch = p.pitch or solf("d4~rmfsdltDsfmrm"),
        timbre = p.timbre or s16("a/ f"),
        fdbk = p.fdbk or s16("a_"),
        vrate = p.vrate or s16("b/ n"),
        vdepth = p.vdepth or s16("a/ f"),
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

-- function clone(M, p)
--     local o = {}
--     p = p or {}
-- 
--     for k,v in pairs(M) do
--         o[k] = p[k] or v
--     end
-- 
--     return o
-- end

sing = {
    pitch = solf("d4~rmfsdltDsfmrm"),
    timbre = s16("a/ f"),
    fdbk = s16("a_"),
    vrate = s16("b/ n"),
    vdepth = s16("a/ f"),
    amp = s16("o"),
    mod = s16("b_"),
    car = s16("b_"),
    gate = s16("a_"),
    aspdur = s16("h_"),
    aspgt = s16("a_"),
    gain = s16("o_"),
    gdur = s16("a_"),
    ampdur = s16("c_"),
    ampatk = s16("c_"),
    amprel = s16("c_"),
    aspfreq = s16("b_"),
    aspamt = s16("b_"),
}

sing = gestku.morpheme.template(sing)

vocab = {
    A = sing {},
    B = sing {
        pitch = solf("l4~fdlfl sfmfmrdr"),
    },
    C = sing {
        pitch = solf("m4~rDtlsfmrdt,rfl"),
    },
    D = sing {
        pitch = solf("s4~fmr l,t,dfmr msfm"),
    },
    E = sing {
        -- pitch = solf("r4~d fm sf tR Dsmrd2"),
        pitch = solf("r4~d fm sf lt Dsfmrm"),
    },
    F = sing {
        pitch = solf("d2"),
        timbre = s16("c/ a"),
    },
    S = sing {
        gain = s16("a_")
    }
}

head = {
    gate = function(words)
        gestku.tal.interpolate(words, 0)
    end,
    aspgt = function(words)
        gestku.tal.interpolate(words, 0)
    end

}

SEQ = "4[AABCDE]2[F]3[S]"
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


    lil("mul zz [dblin -6]")
    lil([[
dup; dup;
bigverb zz zz 0.85 8000
drop;
dcblocker zz
mul zz [dblin -20];
add zz zz
    ]])

    lil("tgate [tick] 18; smoother zz 0.01; mul zz zz")
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
