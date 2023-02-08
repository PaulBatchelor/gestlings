--[[
time to pollinate
-- <@>
dofile("gestku/2023_02_07.lua")
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
#---#---#
---------
--#####--
--#---#--
#-#---#-#
--#---#--
--#####--
---------
#---#---#
---------
----#----
----###--
----#----
----#----
----#----
---------
]]
end
-- </@>

-- <@>
function G:init()
    lil([[ftlnew ftl
grab ftl
gensinesum [tabnew 8192] "1 1 1 1 0 0 0.1 0.1"
ftladd zz
gensinesum [tabnew 8192] "1 1 0 0.5 0 0.2"
ftladd zz
gensinesum [tabnew 8192] "0 1 1 0.0 1 0.2 0 0.1 0.1"
ftladd zz
gensinesum [tabnew 8192] "0 0 0 1.0 0 0.0 0 0.0 0.0"
ftladd zz
gensinesum [tabnew 8192] "1 0 1 0 1 0 1 0 1"
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
        v{0, {1, 2}, b.linear},
        v{1, {1, 2}, b.linear},
        v{2, {1, 2}, b.linear},
        v{0, {1, 2}, b.linear},
        v{1, {1, 2}, b.linear},
        v{3, {1, 4}, b.linear},
        v{4, {1, 2}, b.linear},
    }

    tal.label(words, "ftpos")
    path.path(tal, words, p)
    tal.jump(words, "ftpos")

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

phasor 3 0
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
"[mtof [add 48 [" .. G.gest:nodestring("seq", "[regget 2]")  .. "]]] " ..
"[param 0.0] "
)

lil([[
mul zz [dblin -15]
valp1 zz 3000

dup
clkdel zz [param 0.5] \
    [rephasor [regget 2] [expr 4/3] ] \
    [param 1.0]
mul zz [dblin -5]
butlp zz 1000
add zz zz


mul zz [dblin -3]
unhold [regget 0]
unhold [regget 1]
unhold [regget 2]
]])
    gst:done()
    lil("tgate [tick] 10; smoother zz 0.1; mul zz zz")
end
-- </@>

function run()
    G:run()
end

return G
-- </@>
