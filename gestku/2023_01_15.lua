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
lil([[
gmemnew mem
glnew glive
]])
end

-- </@>

-- <@>
seq = require("seq/seq")
s16 = seq.seqfun(morpho)
-- </@>


-- <@>
A = {
	pitch = s16("a3^ d1/ o1^"),
	timbre = s16("a1/ o1^"),
	amp = s16("o3^ a1 o3 a1"),
}

SEQ = {
    {A, {1, 1}},
    {A, {2, 1}},
}
-- </@>

-- <@>
function articulate()
    words = {}

    mp = {}

    tal.start(words)
    for _,s in pairs(SEQ) do
        append(mp, s[2], s[1])
    end


    morpheme.compile(tal, path, words, mp)

    tal.compile_words(words, "mem", "[glget [grab glive]]")
end
-- </@>

-- <@>
function sound()
	-- local lil = print
    local lvl = core.liln
    local pn = sr.paramnode
    local ln = sr.lilnode
    local cnd = sig:new()

    ln(sr.phasor) {
        rate = 1.0
    }
    cnd:hold()
	-- sr.lilnode_debug(true)

	lil("glswapper [grab glive]")
	articulate()

    pulses = lvl([[
metro [rline 1 10 1]
tgate zz 0.01
env zz 0.001 0.001 0.01
    ]])


	fg = pn(sr.add) {
		a = pn(sr.gesture) {
			name = "pitch",
			conductor = lvl(cnd:getstr())
		},
		b = 60
	}

	tg = pn(sr.scale) {
		input = pn(sr.mul) {
			a = pn(sr.gesture) {
				name = "timbre",
				conductor = lvl(cnd:getstr())
			},
			b = 1.0 / 16.0
		},
		min = 0.0,
		max = 0.5
	}

	ag = pn(sr.scale) {
		input = pn(sr.mul) {
			a = pn(sr.gesture) {
				name = "amp",
				conductor = lvl(cnd:getstr())
			},
			b = 1.0 / 16.0
		},
		min = 0.0,
		max = 0.8
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

    cnd:unhold()

--     lil([[
-- dup; dup; verbity zz zz 0.1 0.1 0.1; drop; mul zz [dblin -10];
-- add zz zz
--     ]])
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
