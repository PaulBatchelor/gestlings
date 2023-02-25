--[[
dates worked on: 2/20, 2/21, 2/22

GOAL: get two voices
-- <@>
dofile("gestku/play.lua")
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

function morpheme2voice(M, name)
    local out = {}

    for k,v in pairs(M) do
        out[k .. name] = v
    end

    return out
end

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
        gate = s16("p_ a p a p a p a p a p a p a p a"),
    }

    M = morpheme2voice(M, "a")

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
function gmorphfmparam(gst, op, param, sig)
    local cmd = string.format("gmorphfmparam %s %s %s %s",
        gst, op, param, sig)
    lil(cmd)
end

function wtpos_values(name)
    local wtpos = {"wtpos4", "wtpos3", "wtpos2", "wtpos1"}

    for k, v in pairs(wtpos) do
        wtpos[k] = v .. name
    end

    return wtpos
end

function seqnode(cnd, name)
    local ln = gestku.core.liln
    gestku.sr.node(G.gest:node()) {
        name = "seq" .. name,
        conductor = ln(cnd:getstr())
    }
end

function gatenode(cnd, name)
    local gst = G.gest
    local nd = gestku.sr.node
    gate = gest16(gst, "gate" .. name, cnd, 0, 1)
    nd(gate){}
end
-- </@>

-- <@>
function morpher(cnd, name)
    local gst = G.gest
    local sig = gestku.sig
    local core = G.core
    gmorphfmnew(gst,
        "[grab ftl]",
        wtpos_values(name),
        0)

    gfm = core.reserve()

    seqnode(cnd, name)

    lil([[
sine 6 0.07
add zz zz
mtof zz]])

    local pitch = sig:new()
    pitch:hold()

    gfmstr = "[" .. core.reggetstr(gfm) .. "]"
    gmorphfmparam(gfmstr, 0, "frqmul", 8)
    gmorphfmparam(gfmstr, 0, "fdbk", 0)
    gmorphfmparam(gfmstr, 0, "modamt", 0)

    gmorphfmparam(gfmstr, 1, "frqmul", 4)
    gmorphfmparam(gfmstr, 1, "fdbk", 0)
    gmorphfmparam(gfmstr, 1, "modamt", 1)

    gmorphfmparam(gfmstr, 2, "frqmul", 3)
    gmorphfmparam(gfmstr, 2, "fdbk", 0)
    gmorphfmparam(gfmstr, 2, "modamt", 1)

    gmorphfmparam(gfmstr, 3, "frqmul", 1)
    gmorphfmparam(gfmstr, 3, "fdbk", 0)
    gmorphfmparam(gfmstr, 3, "modamt", 1)

    lil(string.format("gmorphfm %s %s %s",
        gfmstr,
        "[" .. cnd:getstr() .. "]",
        "[" .. pitch:getstr() .. "]"
        ))
    pitch:unhold()
    core.liberate(gfm)
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

    lil("phasor 1 0")
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

    lil([[
dup; dup
bigverb zz zz 0.6 4000
drop
mul zz [dblin -10]
dcblocker zz
add zz zz]])

    lil([[
tenv [tick] 0.1 9 1
mul zz zz]])

    gst:done()
    cnd:unhold()
end
-- </@>

function run()
    G:run()
end

return G
-- </@>
