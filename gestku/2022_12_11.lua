--[[
INIT

----------
-########-
----------
--######--
----------
-#-####-#-
-#------#-
-#--##--#-
-#------#-
-#--##--#-
-#------#-
-########-
----------

-- <@>
dofile("gestku/2022_12_11.lua")
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


function compile_path(p)
    words = {}

    tal.macro(words, "NUM", {"#24", "DEO"})
    tal.macro(words, "DEN", {"#25", "DEO"})
    tal.macro(words, "NEXT", {"#26", "DEO"})
    tal.macro(words, "NOTE", {"#33", "ADD", "NEXT"})
    tal.macro(words, "BHVR", {"#27", "DEO"})

    table.insert(words, "|0100")
    tal.label(words, "mel")

    path.path(tal, words, p)
    tal.jump(words, "mel")
    program_tal = table.concat(words, " ")
    tal.compile(program_tal, "mem", "[glget [grab glive]]")
end
-- </@>

-- <@>
function mkpatch()
patch = [[
glswapper [grab glive]
param [expr 120 / 60]
rline 0.95 1.05 2
mul zz zz
phasor zz 0

hold zz
regset zz 0

gestvmnode [glget [grab glive] ] [gmemsym [grab mem] mel] [regget 0]

mtof zz
blsaw zz
mul zz 0.5

butlp zz [rline 300 1000 2]

dup

dup
vardelay zz 0.9 [expr 60 / 96] 2
add zz zz
sine [rline 2 20 1] 1
mul zz zz

dup
verbity zz zz 0.999 0.9 0.0
drop
mul zz [dblin -15]
dcblocker zz
add zz zz

tenv [tick] 1 8 2
mul zz zz

unhold [regget 0]

gldone [grab glive]
]]
return patch
end
-- </@>

-- <@>

function sound()
    v = function (note, dur, behavior)
        x = {}

        x.note = note
        x.dur = dur
        x.bhvr = behavior

        return x
    end

    p = {
        v(7, {2,3}, 3),
        v(17, {2,5}, 3),

        v(9, {1,4}, 2),

        v(12, {1,7}, 3),
        v(5, {1, 3}, 3),
        v(7, {1, 4}, 1),
    }
    compile_path(p)
    lil(mkpatch())
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
