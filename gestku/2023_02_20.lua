--[[
dates worked on: 2/20, 2/21
-- <@>
dofile("gestku/2023_02_20.lua")
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
----------
-####-----
------###-
----------
-----##---
-------##-
-####-----
----------
-###-###--
----------
]]
end
-- </@>

-- <@>
WT = {}
s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)

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

WT.wt3 = pop()

lil([[
gensinesum [tabnew 8192 wt5] "1 0 1 0 1 0 1 0 0" 1
param [ftladd zz]
]])

WT.sinesum = pop()

lil("drop")

end
-- </@>
-- <@>
function articulate()
    G:start()
    local b = gestku.gest.behavior
    local gm = b.gliss_medium
    local lin = b.linear

    local M = {
        seq = gestku.nrt.eval([[
d2 m4 r t, d l,1
d4 m s f m s D t s1
d2. m4 r t, d1
]], {base=58}),
        wtpos1 = {
            {WT.sine, 2, gm},
            {WT.wt1, 2, gm},
        },
        wtpos2 = {
            {WT.sine, 1, gm},
        },
        wtpos3 = {
            {WT.sine, 1, gm},
        },
        wtpos4 = {
            {WT.sine, 1, gm},
        },
        gate = s16("p_ a p a p a"),
    }

    G:articulate({{M, {1,10}}})

    G:compile()
end
-- </@>

-- <@>
function gmorphfmnew(gst, ftl, wtpos, algo)
    lil("gmorphfmnew " ..  gst:get() ..
        " " .. ftl .. " " ..
        "[" .. gst:gmemsymstr(wtpos[1]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[2]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[3]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[4]) .. "] " ..
        algo)
end
-- </@>

-- <@>
function G:sound()
    local gst = G.gest
    local nd = gestku.sr.node
    local ln = gestku.core.liln

    articulate()
    gst:swapper()

membuf = "[grab " .. G.gest.bufname .. "]"

gmorphfmnew(gst,
    "[grab ftl]",
    {"wtpos4", "wtpos3", "wtpos2", "wtpos1"},
    0)
-- lil("gmorphfmnew " ..  gst:get() ..  " [grab ftl] " ..
--     "[gmemsym " .. membuf .. " wtpos4 " .. "] " ..
--     "[gmemsym " .. membuf .. " wtpos3 " .. "] " ..
--     "[gmemsym " .. membuf .. " wtpos2 " .. "] " ..
--     "[gmemsym " .. membuf .. " wtpos1 " .. "] " ..
--     "0")
--

lil("regset zz 0; regmrk 0")
lil("phasor 1 0")

local sig = gestku.sig
local cnd = sig:new()
cnd:hold()

gestku.sr.node(G.gest:node()) {
    name = "seq",
    conductor = ln(cnd:getstr())
}


lil([[
sine 6 0.07
add zz zz
mtof zz
]])

pitch = sig:new()
pitch:hold()

lil([[
gmorphfmparam [regget 0] 0 frqmul 8
gmorphfmparam [regget 0] 0 fdbk 0
gmorphfmparam [regget 0] 0 modamt 0

gmorphfmparam [regget 0] 1 frqmul 4
gmorphfmparam [regget 0] 1 fdbk 0
gmorphfmparam [regget 0] 1 modamt 1

gmorphfmparam [regget 0] 2 frqmul 3
gmorphfmparam [regget 0] 2 fdbk 0
gmorphfmparam [regget 0] 2 modamt 1

gmorphfmparam [regget 0] 3 frqmul 1
gmorphfmparam [regget 0] 3 fdbk 0
gmorphfmparam [regget 0] 3 modamt 1
]])

lil(string.format("gmorphfm %s %s %s",
    "[regget 0]",
    "[" .. cnd:getstr() .. "]",
    "[" .. pitch:getstr() .. "]"
    ))

lil("mul zz 0.6")
lil([[
# attempts to make it sound less harsh
butlp zz 4000
peakeq zz 3000 3000 0.1
]])

gate = gest16(gst, "gate", cnd, 0, 1)
nd(gate){}
lil("envar zz 0.01 0.2")
lil("mul zz zz")

lil([[
dup; dup
bigverb zz zz 0.6 4000
drop
mul zz [dblin -10]
dcblocker zz
add zz zz

tenv [tick] 0.1 9 1
mul zz zz

]])


    gst:done()
    cnd:unhold()
    pitch:unhold()
end
-- </@>

function run()
    G:run()
end

return G
-- </@>
