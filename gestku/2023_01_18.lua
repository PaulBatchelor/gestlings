--[[
-- <@>
dofile("gestku/2023_01_18.lua")
G:rtsetup()
G:setup()
-- </@>

-- <@>
lil("glreset [grab glive]")
lil("unholdall")
-- </@>
--]]

-- <@>
gestku = require("gestku/gestku")
tal = require("tal/tal")
path = require("path/path")
morpheme = require("morpheme/morpheme")
pprint = require("util/pprint")
morpho = require("morpheme/morpho")
whistle = require("whistle/whistle")
core = require("util/core")
sig = require("sig/sig")
diagraf = require("diagraf/diagraf")
sr = require("sigrunes/sigrunes")
mseq = require("morpheme/mseq")
seq = require("seq/seq")
nrt = require("nrt/nrt")

s16 = seq.seqfun(morpho)

G = gestku:new {
    tal = tal,
    morpheme = morpheme,
    path = path
}

function G.symbol()
    return [[
###-------
#-#-------
###-------
----------
-#--------
----------
-#--------
----------
-#--------
----------
----------
-------###
-------#-#
-------###
]]
end
-- </@>


-- <@>

function solf(s)
    return nrt.eval(s, {base=60})
end

mel2 = "drm rmf mfs ftD"
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
SEQ = mseq.parse(SEQ, vocab)

-- </@>

-- <@>
function gest16(gst, name, cnd, mn, mx)
    local pn = sr.paramnode
    local lvl = core.liln

	local node = pn(sr.scale) {
		input = pn(sr.mul) {
			a = pn(gst:node()) {
				name = name,
				conductor = lvl(cnd:getstr())
			},
			b = 1.0 / 16.0
		},
		min = mn,
		max = mx
	}

	return node
end

function G:sound()
    local lvl = core.liln
    local pn = sr.paramnode
    local ln = sr.lilnode
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
        core = core,
        diagraf = diagraf,
        sigrunes = sr
    }

	l = g:generate_nodelist()
	g:compute(l)

    -- lil("sine 1000 0.3")
    -- cnd:get()
    -- lil("phsclk zz 1")
    -- lil("env zz 0.001 0.001 0.001; mul zz zz; add zz zz")
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
