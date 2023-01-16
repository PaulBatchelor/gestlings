--[[
excuse me sir may I try some? pretty please? FINE BE THAT WAY.
-- <@>
dofile("gestku/2023_01_15.lua")
rtsetup()
setup()
-- </@>

-- <@>
lil("glreset [grab glive]")
lil("unholdall")
-- </@>
--]]

-- <@>
G = {}

function G.symbol()
    return [[
---------
-#-----#-
--#---#--
---#-#---
---------
-#-----#-
---------
---------
--#####--
---------
---------
---------
---------
]]
end

tal = require("tal/tal")
path = require("path/path")
morpheme = require("morpheme/morpheme")
pprint = require("util/pprint")
morpho = require("morpheme/morpho")
append = morpheme.appender(path)
whistle = require("whistle/whistle")
core = require("util/core")
sig = require("sig/sig")
diagraf = require("diagraf/diagraf")
sr = require("sigrunes/sigrunes")
gest = require("gest/gest")
mseq = require("morpheme/mseq")

GST = gest:new()

function rtsetup()
lil([[
hsnew hs
rtnew [grab hs] rt

func out {} {
    hsout [grab hs]
    hsswp [grab hs]
}

func playtog {} {
    hstog [grab hs]
}
]])
end

function setup()
	GST:create()
end

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

SEQ = "ASBSCSDSES"
SEQ = mseq.parse(SEQ, vocab, {1, 1})

-- </@>

-- <@>
function gest16(name, cnd, mn, mx)
    local pn = sr.paramnode
    local lvl = core.liln

	local node = pn(sr.scale) {
		input = pn(sr.mul) {
			a = pn(GST:node()) {
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
function sound()
    local lvl = core.liln
    local pn = sr.paramnode
    local ln = sr.lilnode
    local cnd = sig:new()

    ln(sr.phasor) {
        rate = 1.0
    }

    cnd:hold()

	words = {}
	tal.start(words)
	morpheme.articulate(path, tal, words, SEQ)
	GST:compile(words)

	GST:swapper()

	fg = gest16("pitch", cnd, 45, 79)

    tg = gest16("timbre", cnd, 0.0, 0.8)

    ag = pn(sr.dblin) {
        db = gest16("amp", cnd, -40, 0)
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

	GST:done()
    cnd:unhold()

    lil([[
dup; dup; verbity zz zz 0.1 0.1 0.1; drop; mul zz [dblin -10];
add zz zz
    ]])
end

function run()
    sound()
    lil("out")
end

function G.patch()
    setup()
    sound()
end

return G
-- </@>
