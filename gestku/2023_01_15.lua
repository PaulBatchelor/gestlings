--[[
Paging Doctor Distant
-- <@>
dofile("gestku/2023_01_15.lua")
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

pprint = require("util/pprint")
morpho = require("morpheme/morpho")
whistle = require("whistle/whistle")
core = require("util/core")
sig = require("sig/sig")
diagraf = require("diagraf/diagraf")
sr = require("sigrunes/sigrunes")
mseq = require("morpheme/mseq")
-- </@>

-- <@>
seq = require("seq/seq")
s16 = seq.seqfun(morpho)
-- </@>


-- <@>

vocab = {
    A = {
        pitch = s16("a3^ d1/ o1^"),
        timbre = s16("a1~"),
        amp = s16("o3^ a1 o3 a1"),
    },

    B = {
        pitch = s16("o2/ a1^"),
        timbre = s16("o1~"),
        amp = s16("o3^ a1~ "),
    },

    S = {
        pitch = s16("a1^"),
        timbre = s16("a1~"),
        amp = s16("a1~ "),
    },

    C = {
        pitch = s16("b3/ a1~"),
        timbre = s16("o1~"),
        amp = s16("o1/ h1~ "),
    },

    D = {
        pitch = s16("o3^ h1 o3 h1 o3 h1"),
        timbre = s16("c1~"),
        amp = s16("g3/ n1~ "),
    },

    E = {
        pitch = s16("o1~ m n o m n g f e g f e"),
        timbre = s16("o1~"),
        amp = s16("g3/ n1~ "),
    },
}

SEQ = "DSD2(C)S4(BBB)S4(BB)EASDCS"
SEQ = mseq.parse(SEQ, vocab, {1, 1})

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
    local ln = sr.node
    local cnd = sig:new()
    local gst = G.gest

    ln(sr.phasor) {
        rate = (75 / 60)
    }

    cnd:hold()

    G:start()
    G:articulate(SEQ)
    G:compile()

	gst:swapper()

	fg = gest16(gst, "pitch", cnd, 45, 79)

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

	gst:done()
    cnd:unhold()

    lil([[
dup; dup; verbity zz zz 0.1 0.1 0.1; drop; mul zz [dblin -10];
add zz zz
    ]])

    lil("mul zz [dblin 5]")
    lil("tgate [tick] 10; mul zz zz")
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
