--[[
INQUISITIVE BIRD

-- <@>
dofile("gestku/2022_12_12.lua")
rtsetup()
setup()
-- </@>
--]]

-- <@>
G = {}

tal = require("tal/tal")
path = require("path/path")
pprint = require("util/pprint")

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


function compile_path(rate, gate, pitch)
    words = {}

    tal.macro(words, "NUM", {"#24", "DEO"})
    tal.macro(words, "DEN", {"#25", "DEO"})
    tal.macro(words, "NEXT", {"#26", "DEO"})
    tal.macro(words, "BHVR", {"#27", "DEO"})

    table.insert(words, "|0100")

    tal.label(words, "rate")
    path.path(tal, words, rate)
    tal.jump(words, "rate")

    tal.label(words, "gate")
    path.path(tal, words, gate)
    tal.jump(words, "gate")

    tal.label(words, "pitch")
    path.path(tal, words, pitch)
    tal.jump(words, "pitch")

    program_tal = table.concat(words, " ")
    tal.compile(program_tal, "mem", "[glget [grab glive]]")
end
-- </@>

-- <@>
function mkpatch()
patch = [[
glswapper [grab glive]
param [expr 120 / 60]
phasor zz 0
hold zz
regset zz 0

gestvmnode [glget [grab glive] ] [gmemsym [grab mem] rate] [regget 0]
metro zz

gestvmnode [glget [grab glive] ] [gmemsym [grab mem] gate] [regget 0]
mul zz zz
env zz 0.001 0.001 0.001


gestvmnode [glget [grab glive] ] [gmemsym [grab mem] pitch] [regget 0]
mtof zz
sine zz 0.5
mul zz zz
dup
dup
bigverb zz zz 0.7 10000
drop
mul zz [dblin -10]
dcblocker zz
add zz zz

tenv [tick] 0.1 8 2
mul zz zz
unhold [regget 0]
gldone [grab glive]
]]
return patch
end
-- </@>

-- <@>

function sound()
    v = function (val, dur, behavior)
        x = {}

        x.val = val
        x.dur = dur
        x.bhvr = behavior

        return x
    end

    rate = {
        v(10, {1,1}, 0),
        v(20, {1,2}, 1),

        v(20, {1,2}, 0),
        v(4, {1,2}, 1),

        v(40, {2,1}, 0),
        v(20, {2,1}, 0),

        v(10, {1,3}, 0),
    }

    gate = {
        v(1, {1,1}, 1),
        v(0, {1,2}, 1),

        v(1, {1,2}, 1),
        v(0, {1,2}, 1),

        v(1, {4,1}, 1),
        v(0, {4,0}, 1),
        v(1, {4,1}, 1),
        v(0, {4,0}, 1),

        v(1, {1,3}, 1),
    }

    pitch = {
        v(75, {2,1}, 3),
        v(84, {1,1}, 3),
        v(60, {2,1}, 3),
        v(60, {1,1}, 3),

        v(70, {1,1}, 0),
        v(40, {1,1}, 0),
        v(60, {1,1}, 0),
        v(50, {1,1}, 0),

        v(75, {2,1}, 3),
        v(76, {2,1}, 3),

        v(50, {1,3}, 3),
    }

    compile_path(rate, gate, pitch)
    lil(mkpatch())
end
-- </@>
-- <@>

function run()
    sound()
    lil("out")
end

function G.patch()
    setup()
    sound()
end

function G.symbol()
    return [[
----------
-#####----
-#---####-
-#-#------
-#---####-
----------
-#--#-----
-##-####--
-#--#--#--
-------#--
-#--#-----
-#--###---
----------
]]
end

return G
-- </@>
