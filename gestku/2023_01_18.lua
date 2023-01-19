--[[
Whistle Antiphon
-- <@>
dofile("gestku/2023_01_18.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
gestku = require("gestku/gestku")
whistle = require("whistle/whistle")

s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)
G = gestku:new()

function G.symbol()
    return [[
#-#-####
--#----#
#-##-#--
#-#--###
#-##-#--
-----#--
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=61})
end

mel3 = "d4 s2 t-8 D^ l4~ f d2~ r-4/ d2.~"
vocab = {
    A = {
        pitch = solf(mel3),
        timbre = s16("d3/ o8 a1"),
        amp = s16("o11 c1"),
    },
    S = {
        pitch = solf(mel3),
        timbre = s16("d2/o1"),
        amp = s16("c"),
    },
}

SEQ = "11[A]A2[S]"
SEQ = gestku.mseq.parse(SEQ, vocab)

-- </@>

-- <@>
function G:sound()
    local lvl = gestku.core.liln
    local sr = gestku.sr
    local pn = sr.paramnode
    local ln = sr.lilnode
    local sig = gestku.sig
    local cnd = sig:new()
    local gst = G.gest

    ln(sr.phasor) {
        rate = 13 / 10
    }

    cnd:hold()

    local seq = SEQ

    G:start()
    G:articulate(seq)
    G:compile()

	gst:swapper()

    -- fg = gest16(gst, "pitch", cnd, 45, 79)
    fg = pn(gst:node()) {
        name = "pitch",
        conductor = lvl(cnd:getstr())
    }

    tg = gest16(gst, "timbre", cnd, 0.0, 0.8)

    ag = pn(sr.dblin) {
        db = gest16(gst, "amp", cnd, -40, 0)
    }

    local g = whistle.graph {
		freq = fg,
		timbre = tg,
		amp = ag,
        sig = sig,
        core = gestku.core,
        diagraf = gestku.diagraf,
        sigrunes = sr
    }

	l = g:generate_nodelist()
	g:compute(l)

	gst:done()
    cnd:unhold()

    lil([[
dup; dup; verbity zz zz 0.9 0.1 0.1; drop; mul zz [dblin -10];
add zz zz
    ]])


    lil("mul zz [dblin 5]")
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
