--[[
-- <@>
dofile("gestku/2023_03_29.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
pprint = require("util/pprint")
-- </@>

-- <@>
gestku = require("gestku/gestku")
G = gestku:new()

function G.symbol()
    return [[
##-#---##-#-----
##---#-##---#---
----------------
##-#---##-#-----
##---#-##---#---
----------------
##-#---##-#---#-
##---#-##---#-#-
]]
end
-- </@>

-- <@>
WT = {}
s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)
json = require("util/json")
morpher = require("gestku/bits/morpher")
gen_vocab = require("gestku/bits/vocab_march_2023")
mcr = require("gestku/bits/microrunes")

mcr.vocab = gen_vocab.bitrunes()
mcr.grid_current_preset = "init"
mcr.grid_state_file = "gestku/2023_03_08.json"

function G:init()
end
-- </@>
-- <@>

function articulate()
end
-- </@>

-- <@>
function gatenode(cnd, name)
end
-- </@>

-- <@>
function G:sound()
-- gest = require("gest/gest")
-- sr = require("sigrunes/sigrunes")
-- dg = require("diagraf/diagraf")
-- sig = require("sig/sig")
-- core = require("util/core")
-- tal = require("tal/tal")
-- path = require("path/path")
local gest = gestku.gest
local sr = gestku.sr
local dg = gestku.diagraf
local sig = gestku.sig
local core = gestku.core
local tal = gestku.tal
local path = gestku.path



--gst = gest:new{tal=tal}
--gst:create()
gst = G.gest

grf = dg.Graph:new{sig=sig}
ng = core.nodegen(dg.Node, grf)
pg = core.paramgen(ng)
pn = sr.paramnode

bhvr = gest.behavior

vx = path.vertex

freq_path = {
    vx({0, {1, 1}, bhvr.linear}),
    vx({0, {1, 1}, bhvr.linear}),
    vx({0, {2, 1}, bhvr.linear}),
    vx({0, {2, 1}, bhvr.linear})
}

words = {}
tal.start(words)
tal.label(words, "freq")
tal.interpolate(words, 0)
path.path(tal, words, freq_path)
tal.jump(words, "freq")

lil("genvals [tabnew 1] \"0 2 4 7 9 12 14 16\"")
lil("regset zz 0; regmrk 0")

lil([[
tabload "shapes/julia_ah.raw"
regset zz 1
regmrk 1
tractnew
regset zz 2
regmrk 2
tractshape [regget 2] [regget 1]
]])

gst:compile(words)
con = grf:connector()

cnd = ng(sr.phasor) {rate = 4}

freq_ctrl = ng(gst:node()) {name = "freq"}

con(cnd, freq_ctrl.conductor)

mtof = ng(sr.mtof) {}

-- con(freq_ctrl, scaler.input)
-- con(freq_ctrl, mtof.input)
-- con(scaler, mtof.input)

qgliss = ng(sr.qgliss) {
    tab = function(self) return "[regget 0]" end,
}

qglissrand = ng(sr.rline) {min=0.4, max=0.8, rate=2}

con(qglissrand, qgliss.gliss)

freqrand = ng(sr.rline) {min=0.1, max=2, rate=1.1}

LFO = ng(sr.sine) {freq = 1, amp = 1}

con(freqrand, LFO.freq)

LFO_scaler = ng(sr.biscale){min=0, max=1}
con(LFO, LFO_scaler.input)

con(LFO_scaler, qgliss.input)
con(freq_ctrl, qgliss.clock)

add1 = ng(sr.add){b=48 + 3}
con(qgliss, add1.a)
con(add1, mtof.input)
-- sine = ng(sr.sine) {amp = 0.1}
-- con(mtof, sine.freq)

glottis = ng(sr.glottis) {}
con(mtof, glottis.freq)
mul1 = ng(sr.mul){b = 0.5}
con(glottis, mul1.a)

tract = ng(sr.tract) {
    tract = function(self) return "[regget 2]" end
}

con(mul1, tract.input)

l = grf:generate_nodelist()
grf:compute(l)

lil([[
regclr 0
regclr 1
regclr 2
]])

lil([[
butlp zz 5000
butlp zz 5000

dup
dup
bigverb zz zz [rline 0.9 0.98 0.3] [param 8000]
add zz zz
mul zz [dblin [rline -15 -20 0.4] ]
dcblocker zz
add zz zz
]])
--lil("wavout zz test.wav")
--lil("computes 15")
end
-- </@>

-- <@>
function run()
    G:run()
end
function altrun()
    mcr.run_grid()
end
-- </@>

-- <@>
return G
-- </@>
