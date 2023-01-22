--[[
The Shadow of the Warbler
-- <@>
dofile("gestku/2023_01_22.lua")
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
###-----
#-#-----
###-#---
----#--#
----#-#-
----##--
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=61})
end

mel3 = "d4 s2 t-8 D^ l4~ f d2~ r-4/ d2.~"
mel = "d8~ s4 f8 t-8 l s f s d t,- t-4 l8 f4 s4 t,-/ d1~"
vocab = {
    A = {
        pitch = solf(mel),
        timbre = s16("d3/ o8 a1"),
        amp = s16("o11 c1"),
        fdbk = s16("a2/ o1 c1 a"),
    },
    S = {
        pitch = solf(mel3),
        timbre = s16("d2/o1"),
        fdbk = s16("a"),
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
    G:articulate(seq)
    G:compile()

	gst:swapper()

    fg = pn(gst:node()) {
        name = "pitch",
        conductor = lvl(cnd:getstr())
    }

    tg = gest16(gst, "timbre", cnd, 0.0, 2.8)
    vdepth  = gest16(gst, "timbre", cnd, 0.0, 0.4)
    vrate = gest16(gst, "timbre", cnd, 6, 7)

    ag = pn(sr.dblin) {
        db = gest16(gst, "amp", cnd, -40, 0)
    }

    fdbk = gest16(gst, "fdbk", cnd, 0, 0.3)

    local g = warble.graph {
        pitch = fg,
        mi = tg,
        fdbk = fdbk,
        amp = {
            val = ag
        },
        mod = param(1.0),
        car = param(1.0),
        diagraf = gestku.diagraf,
        sr = sr,
        sig = sig,
        core = gestku.core,

        vib = {
            rate = vrate,
            depth = vdepth,
        }
    }

	l = g:generate_nodelist()
	g:compute(l)

	gst:done()
    cnd:unhold()

    lil("mul zz [dblin -15]")
    lil([[
dup;
vardelay zz 0.1 0.6 0.8
dup;
bigverb zz zz 0.9 4000
drop;
dcblocker zz
mul zz [dblin -10];
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
