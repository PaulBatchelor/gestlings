--[[
laughing goblin
-- <@>
dofile("gestku/2023_01_24.lua")
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
----------
--######--
----------
---#--#---
#--------#
##------##
#--####--#
---#--#---
---#--#---
---#--#---
----##----
----------
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=72})
end

mel = "d4/ l d,2^"
vocab = {
    A = {
        pitch = solf("d2./ f,4^"),
        timbre = s16("o_"),
        amp = s16("o2~ a1_"),
        fdbk = s16("a1_"),
        mod = s16("b"),
        car = s16("b"),
        gate =  s16("o1- o o o o o o o a_ a a a"),
        aspgt = s16("o1- o o o o o o o a_ a a a"),
        gain = s16("o_"),
    },
    B = {
        pitch = solf("d4/ f/"),
        timbre = s16("o_"),
        amp = s16("a1~ a1_"),
        fdbk = s16("a1_"),
        mod = s16("b"),
        car = s16("b"),
        gate =  s16("o1-"),
        aspgt = s16("o1-"),
        gain = s16("o_"),
    },
    C = {
        pitch = solf("d4/ m/"),
        timbre = s16("o_"),
        amp = s16("a1~ a1_"),
        fdbk = s16("a1_"),
        mod = s16("b"),
        car = s16("b"),
        gate =  s16("o1-"),
        aspgt = s16("o1-"),
        gain = s16("o_"),
    },
    D = {
        pitch = solf("d4/ m/ s, l, d,"),
        timbre = s16("a/ o_"),
        amp = s16("a1~ a1_"),
        fdbk = s16("o1_"),
        mod = s16("b"),
        car = s16("b"),
        gate =  s16("o1-"),
        aspgt = s16("a_"),
        gain = s16("o_"),
    },
    E = {
        pitch = solf("f4/ d/"),
        timbre = s16("o_"),
        amp = s16("a1~ a1_"),
        fdbk = s16("o1_"),
        mod = s16("b"),
        car = s16("b"),
        gate =  s16("o1-"),
        aspgt = s16("o1-"),
        gain = s16("o_"),
    },
    S = {
        pitch = solf("d1~"),
        timbre = s16("o1~"),
        fdbk = s16("a_"),
        amp = s16("a_"),
        mod = s16("b"),
        car = s16("b"),
        aspgt = s16("o1_"),
        gate = s16("o1_ "),
        gain = s16("a_"),
    },
}
head = {
    gate = function(words)
        gestku.tal.interpolate(words, 0)
    end,
    aspgt = function(words)
        gestku.tal.interpolate(words, 0)
    end

}
--SEQ = "3[A]SS4(BB)S"
SEQ = "3[A]4(BBB)CSDS2[A]E4(BB)CS"
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
        rate = 13 / 10
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

    tg = gest16(gst, "timbre", cnd, 0.0, 2.8)
    vdepth  = gest16(gst, "timbre", cnd, 0.0, 0.4)
    vrate = gest16(gst, "timbre", cnd, 6, 7)

    ag = gest16(gst, "amp", cnd, 0, 0.5)

    fdbk = gest16(gst, "fdbk", cnd, 0, 0.3)

    gate = gest16(gst, "gate", cnd, 0, 1)

    aspgt = gest16(gst, "aspgt", cnd, 0, 1)

    mod = pn(gst:node()) {
        name = "mod",
        conductor = lvl(cnd:getstr())
    }

    car = pn(gst:node()) {
        name = "car",
        conductor = lvl(cnd:getstr())
    }

    local g = warble.graph {
        pitch = fg,
        mi = tg,
        fdbk = fdbk,
        amp = {
            val = ag,
            gate = gate,
            dur = param(0.5),
            atk = param(0.2),
            rel = param(0.1),
        },
        mod = mod,
        car = car,
        diagraf = gestku.diagraf,
        sr = sr,
        sig = sig,
        core = gestku.core,

        vib = {
            rate = vrate,
            depth = param(0),
        },

        asp = {
            gate = aspgt,
            dur = param(0.1),
            atk = param(0.001),
            rel = param(0.3),
            val = param(0.0),
            gain = param(3.5),
            bw = param(150),
            freq = param(800),
        },
    }

	l = g:generate_nodelist()
	g:compute(l)

    ln(sr.smoother) {
        input = gest16(gst, "gain", cnd, 0, 0.5),
        smooth = 0.005,
    }

    lil("mul zz zz")

	gst:done()
    cnd:unhold()

    lil("mul zz [dblin -15]")
    lil([[
dup; dup;
bigverb zz zz 0.7 4000
drop;
dcblocker zz
mul zz [dblin -15];
add zz zz
    ]])


    lil("tgate [tick] 10; smoother zz 0.01; mul zz zz")
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
