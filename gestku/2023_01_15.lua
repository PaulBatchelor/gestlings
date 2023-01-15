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
function sound()
    local lvl = core.liln
    local pn = sr.paramnode

    pulses = lvl([[
metro [rline 1 10 1]
tgate zz 0.01
env zz 0.001 0.001 0.01
    ]])

    local g = whistle.graph {
        freq = pn(sr.rline) {
            min = 30,
            max = 80,
            rate = 20
        },
        timbre = pn(sr.rline) {
            min = 0,
            max = 0.5,
            rate = 1,
        },
        amp = pulses,
        sig = sig,
        core = core,
        diagraf = diagraf,
        sigrunes = sr
    }

    l = g:generate_nodelist()
    g:compute(l)

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
