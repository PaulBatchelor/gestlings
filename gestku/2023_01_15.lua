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
sigrunes = require("sigrunes/sigrunes")

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
function sound()
    local lvl = core.liln

    pulses = lvl([[
metro [rline 1 10 1]
tgate zz 0.08
env zz 0.004 0.001 0.01
    ]])

    local g = whistle.graph {
        freq = lvl("rline 70 85 2"),
        timbre = lvl("rline 0 1 3"),
        amp = pulses,
        sig = sig,
        core = core,
        diagraf = diagraf,
        sigrunes = sigrunes
    }

    l = g:generate_nodelist()
    -- g:dot("whistle.dot")
    g:compute(l)
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
