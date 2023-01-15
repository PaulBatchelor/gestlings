-- trying out sequencing language for morpheme
-- test_string = "A2(BC)"
--test_string = "ABC"
--test_string = "2(AB3(EF))CD4[G]"

seq = require("seq/seq")
morpho = require("morpheme/morpho")
morpheme = require("morpheme/morpheme")
gest = require("gest/gest")
tal = require("tal/tal")
path = require("path/path")

pprint = require("util/pprint")

local Space = lpeg.S(" \t\n")^0
local Morpheme = lpeg.R("AZ")*lpeg.R("az")^0*Space
local Exp, Pat, S = lpeg.V"Exp", lpeg.V"Pat", lpeg.V"S"
local Mul = lpeg.V"Mul"
local Div = lpeg.V"Div"
local Seq = lpeg.V"Seq"
local Num = lpeg.R("09")^1
local LParen = lpeg.P("(")
local RParen = lpeg.P(")")
local LBrack = lpeg.P("[")
local RBrack = lpeg.P("]")

local G = lpeg.P {
	Exp,
	-- Exp = lpeg.Ct(Mul) + lpeg.Ct(Pat);
	Exp = lpeg.Ct((Space*Seq*Space)^0);
	--Pat = lpeg.Cg(Morpheme)^0 + lpeg.Cg(Mul)^0;
	Pat = Mul;
	Seq = lpeg.Cg(Morpheme) + lpeg.Ct(Mul) + lpeg.Ct(Div);
	Mul =
		lpeg.Cg(Num, "mul") *
		LParen * lpeg.Cg(lpeg.Ct(Seq^1), "seq") *
		RParen;
	Div =
		lpeg.Cg(Num, "div") *
		LBrack * lpeg.Cg(lpeg.Ct(Seq^1), "seq") *
		RBrack

}

test_string = "ABC2(AA)4(BB2(BA2(AAA)))B2[C]"
t = lpeg.match(G, test_string)

r = {1, 1}

s16 = seq.seqfun(morpho)

lookup = {
	A = {
		seq = s16("a_ o a o"),
		exp = s16("a/ o a/ o "),
	},
	B = {
		seq = s16("a/ o"),
		exp = s16("o/ h"),
	},
	C = {
		seq = s16("a~ b c d e f g"),
		exp = s16("h~ o a/ o"),
	},
}

function iterate(x, m, r, out)
	for _, v in pairs(x) do
		if type(v) == "string" then
			table.insert(out, {m[v], {r[1], r[2]}})
		else
			r_new = {r[1], r[2]}
			if v.div ~= nil then
				r_new[2] = r_new[2] * v.div
			elseif v.mul ~= nil then
				r_new[1] = r_new[1] * v.mul
			end
			iterate(v.seq, m, r_new, out)
		end
	end
end

S = {}

iterate(t, lookup, r, S)

words = {}
tal.start(words)
morpheme.articulate(path, tal, words, S)

g = gest:new{conductor="[regget 0]"}
g:create()
g:compile(words)


lil("phasor 1.5 0; hold zz; regset zz 0")
g:swapper()
g:node_old("seq")
lil(string.format("mul zz %g", 1.0 / 16.0))
lil("scale zz 0 24")
lil("add zz 53")
lil("mtof zz")
lil("blsaw zz")
g:node_old("exp")
lil(string.format("mul zz %g", 1.0 / 16.0))
lil("scale zz 300 1000")
lil("butlp zz zz")
lil("mul zz 0.3")

lil("wavout zz test.wav")
lil("unhold [regget 0]")
lil("computes 10")
