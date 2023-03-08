--[[
dots? make it go fast? idk. life is stressful right now,
can't focus, and I'm running out of ideas with this thing.

-- <@>
dofile("gestku/2023_03_08.lua")
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
lil("opendb db /home/paul/proj/smp/a.db")
    lil([[ftlnew ftl
grab ftl
gensine [tabnew 8192 wt4]
param [ftladd zz]
]])

WT.sine = pop()

lil([[
crtwavk [grab db] wt1 gkkfjirki
grab wt1
param [ftladd zz]
]])

WT.wt1 = pop()

lil([[
crtwavk [grab db] wt2 gphqwqork
grab wt2
param [ftladd zz]
]])

WT.wt2 = pop()

lil([[
crtwavk [grab db] wt3 ghirdoqwr
grab wt3
param [ftladd zz]
]])

WT.wt4 = pop()

lil([[
gensinesum [tabnew 8192 wt5] "1 0 1 0 1 0 1 0 0" 1
param [ftladd zz]
]])

WT.sinesum = pop()

lil("drop")

lil("valnew button")
mcr.load_state()
mcr.parse_grid()
end
-- </@>
-- <@>

function articulate()
    G:start()

    morphemes = gen_vocab.morphemes()
    G:articulate(gestku.mseq.parse(mcr.sequence_get(), morphemes))

    G:compile()
end
-- </@>

-- <@>
function gatenode(cnd, name)
    local gst = G.gest
    local nd = gestku.sr.node
    gate = gest16(gst, "gate" .. name, cnd, 0, 1)
    nd(gate){}
end
-- </@>

-- <@>
function G:sound()
    local gst = G.gest
    local core = G.core
    local nd = gestku.sr.node
    local ln = gestku.core.liln

    articulate()
    gst:swapper()

    membuf = "[grab " .. G.gest.bufname .. "]"

    lil("phasor 5 0")
    local sig = gestku.sig
    local cnd = sig:new()
    cnd:hold()

    morpher(cnd, "a")

    lil("mul zz 0.6")
    lil([[
# attempts to make it sound less harsh
butlp zz 4000
peakeq zz 3000 3000 0.1]])

    gatenode(cnd, "a")

    lil("envar zz 0.01 0.2")
    lil("mul zz zz")

    lil("thresh [val [grab button]] 0.5 2")
    btrig = sig:new()
    btrig:hold()

    btrig:get()
    lil("tgate zz 0.005")
    lil("envar zz 0.001 0.001")
    btrig:get()
    lil("trand zz 1000 3000")
    lil("sine zz 0.3")
    lil("mul zz zz")
    lil("add zz zz")
    btrig:unhold()

    lil([[
dup; dup
bigverb zz zz 0.9 8000
drop
mul zz [dblin -15]
dcblocker zz
add zz zz]])

-- FADE
    lil([[
tenv [tick] 0.01 8 0.99
mul zz zz]])

    gst:done()
    cnd:unhold()
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
