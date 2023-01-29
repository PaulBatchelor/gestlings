--[[
snoring goblin
-- <@>
dofile("gestku/2023_01_29.lua")
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
---------####-
-###-###---#--
#---------#---
##--###--####-
#-----#-------
--------------
---------#----
--########----
--------------
--------------
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=72})
end

function pat(p)
    return {
        pitch = p.pitch or solf("d4"),
        timbre = p.timbre or s16("b2_"),
        fdbk = p.fdbk or s16("a2_"),
        vrate = p.vrate or s16("a_"),
        vdepth = p.vdepth or s16("a_"),
        amp = p.amp or s16("o7_ o1~"),
        mod = p.mod or s16("b_"),
        car = p.car or s16("b_"),
        gate =  p.gate or s16("a_"),
        aspdur = p.aspdur or s16("h_"),
        aspgt = p.aspgt or s16("a_"),
        gain = p.gain or s16("a1/ o15_"),
        gdur = p.gdur or s16("a_"),
        ampdur = p.ampdur or s16("c_"),
        ampatk = p.ampatk or s16("c_"),
        amprel = p.amprel or s16("c_"),
        aspfreq = p.aspfreq or s16("a4/ n1_"),
        aspamt = p.aspamt or s16("p7_ p1~"),
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

inhale = pat {}
exhale = pat {
    aspfreq = s16("n4/ a1_"),
    aspamt = s16("a/ c_"),
    pitch = solf("l2./ r8_"),
    gate = s16("o1- o o o o o o o2"),
    timbre = s16(
        "b1/ d^ b_ " ..
        "b1/ d^ b_ " ..
        "b1/ d^ b_ " ..
        "b1/ d^ b_ " ..
        "a1/ c^ a_ " ..
        "a1/ c^ a_ " ..
        "a1/ c^ a_ " ..
        "a2/ c^ a_ "
    ),
    fdbk = s16("c2/ a1_"),
    amp  = s16("a_"),
    gain = s16("o8/ b1~"),
    ampatk = s16("o_"),
    amprel = s16("o_"),
    vrate = s16("h_"),
    vdepth = s16("o/ a_"),
}

vocab = {
    A = clone(inhale),
    B = clone(exhale),
    S = clone(inhale, {
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

SEQ = "2[ABSABSAB2[S]]"
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
        rate = 14.7 / 10
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
            b = gest16(gst, "aspfreq", cnd, 12, 24),
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
            gain = param(2.5),
            bw = param(200),
            freq = asp_freq,
            val = asp_amt,
        },
    }

	l = g:generate_nodelist()
	g:compute(l)

    ln(sr.smoother) {
        input = gest16(gst, "gain", cnd, 0, 0.5),
        smooth = 0.001,
    }

    lil("mul zz zz")

	gst:done()
    cnd:unhold()


    -- lil("dup; butlp zz 1000; softclip zz 2; add zz zz")
    -- lil("lowshelf zz 200 4.0 0.5")
    lil("mul zz [dblin -6]")
    lil([[
dup; dup;
bigverb zz zz 0.7 8000
drop;
dcblocker zz
mul zz [dblin -14];
add zz zz
    ]])

    lil("tgate [tick] 10.6; smoother zz 0.01; mul zz zz")
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
