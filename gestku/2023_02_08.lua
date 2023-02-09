--[[
crystalline cosmic soup
-- <@>
dofile("gestku/2023_02_08.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
gestku = require("gestku/gestku")
G = gestku:new()

function G.symbol()
    return [[
---------
---###---
---###---
---------
-#-----#-
-#-----#-
-#-----#-
--#####--
---------
]]
end
-- </@>

-- <@>
function G:init()
lil("opendb db /home/paul/proj/smp/a.db")
    lil([[ftlnew ftl
grab ftl
# gensinesum [tabnew 8192 wt1] "1 1 1 1 0 0 0.1 0.1"
crtwavk [grab db] wt1 gkkfjirki
grab wt1
ftladd zz
crtwavk [grab db] wt2 gphqwqork
grab wt2
ftladd zz
crtwavk [grab db] wt3 ghirdoqwr
grab wt3
ftladd zz
gensinesum [tabnew 8192 wt4] "0 0 0 1.0 0 0.0 0 0.0 0.0"
ftladd zz
gensinesum [tabnew 8192 wt5] "1 0 1 0 1 0 1 0 1"
ftladd zz
drop
]])
end
-- </@>
-- <@>
function articulate()
    local tal = G.tal
    local path = G.path
    local b = G.gest.behavior
    local v = path.vertex
    local words = G.words
    local seq = {
        0, 3, 0, 3, 7, 3, 7, 3,
        0, 3, 0, 3, 7, 3, 7, 3,
        0, 3, 0, 3, 8, 3, 8, 3,
        0, 3, 0, 3, 8, 3, 8, 3,
        0, 3, 0, 3, 9, 3, 9, 3,
        0, 3, 0, 3, 9, 3, 9, 3,
        0, 3, 0, 3, 8, 3, 8, 3,
        0, 3, 0, 3, 8, 3, 8, 3,
    }

    p = {
        v{1, {2, 1}, b.linear},
        v{0, {1, 1}, b.linear},
        v{1, {2, 1}, b.linear},
        v{2, {1, 1}, b.linear},
    }

    tal.label(words, "ftpos")
    path.path(tal, words, p)
    tal.jump(words, "ftpos")

    p = {
        v{1, {1, 2}, b.linear},
        v{0, {1, 3}, b.linear},
        v{1, {2, 1}, b.linear},
        v{2, {1, 1}, b.linear},
    }

    tal.label(words, "ftpos2")
    path.path(tal, words, p)
    tal.jump(words, "ftpos2")

    p = {
        v{0, {1, 3}, b.linear},
        v{2, {1, 3}, b.linear},
    }

    tal.label(words, "ftpos3")
    path.path(tal, words, p)
    tal.jump(words, "ftpos3")

    p = {
        v{2, {1, 2}, b.linear},
        v{1, {1, 4}, b.linear},
        v{0, {1, 1}, b.linear},
    }

    tal.label(words, "ftpos4")
    path.path(tal, words, p)
    tal.jump(words, "ftpos4")

    seq_path = {}

    for _,val in pairs(seq) do
        table.insert(seq_path, v{val, {4, 1}, b.gliss_medium})
    end

    tal.label(words, "seq")
    path.path(tal, words, seq_path)
    tal.jump(words, "seq")
end
-- </@>

-- <@>
function G:sound()
local gst = G.gest
lil([[
sine 0.2 1
hold zz
regset zz 0

phasor 2 0
hold zz
regset zz 2

sine [rline 4 12 1] 1
hold zz
regset zz 1
]])

    G:start()
    articulate()
    G:compile()

    gst:swapper()

-- goscmorph gestvm ftlist ptr conductor freq fdbk

lil("goscmorph " ..
"[glget [grab " .. G.gest.name .."]] " ..
"[grab ftl] " ..
"[gmemsym [grab " .. G.gest.bufname .. "] ftpos] " ..
"[regget 2] " ..
"[mtof 40] " ..
"[param 0.0] "
)

lil("goscmorph " ..
"[glget [grab " .. G.gest.name .."]] " ..
"[grab ftl] " ..
"[gmemsym [grab " .. G.gest.bufname .. "] ftpos2] " ..
"[regget 2] " ..
"[mtof [expr 40 + 7] ] " ..
"[param 0.0] "
)

lil("add zz zz")

lil("goscmorph " ..
"[glget [grab " .. G.gest.name .."]] " ..
"[grab ftl] " ..
"[gmemsym [grab " .. G.gest.bufname .. "] ftpos3] " ..
"[regget 2] " ..
"[mtof [expr 40 + 7 + 7] ] " ..
"[param 0.0] "
)

lil("add zz zz")


lil("goscmorph " ..
"[glget [grab " .. G.gest.name .."]] " ..
"[grab ftl] " ..
"[gmemsym [grab " .. G.gest.bufname .. "] ftpos4] " ..
"[regget 2] " ..
"[mtof [expr 40 + 7 + 7 - 3] ] " ..
"[param 0.0] "
)

lil("add zz zz")

lil([[
buthp zz 500
blsaw [mtof [expr 40 - 12] ]
butlp zz 1000
mul zz 0.6
peakeq zz 100 100 3
add zz zz
]])

lil([[
mul zz [dblin -10]
valp1 zz 1000

dup
dup
bigverb zz zz 0.97 10000
drop
mul zz [dblin -10]
dcblocker zz
swap
mul zz [dblin -6]
add zz zz


mul zz [dblin -3]
unhold [regget 0]
unhold [regget 1]
unhold [regget 2]
]])
    gst:done()
    lil("tgate [tick] 10.5; smoother zz 0.1; mul zz zz")
end
-- </@>

function run()
    G:run()
end

return G
-- </@>
