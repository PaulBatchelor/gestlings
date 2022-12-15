--[[
ROBO-GIGUE

-- <@>
dofile("gestku/2022_12_14.lua")
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

function tal_setup(words)
    tal.macro(words, "NUM", {"#24", "DEO"})
    tal.macro(words, "DEN", {"#25", "DEO"})
    tal.macro(words, "NEXT", {"#26", "DEO"})
    tal.macro(words, "BHVR", {"#27", "DEO"})

    table.insert(words, "|0100")
end

function compile_tal(words)
    program_tal = table.concat(words, " ")
    tal.compile(program_tal, "mem", "[glget [grab glive]]")
end

function compile_path(words, p, name)
    tal.label(words, name)
    path.path(tal, words, p)
    tal.jump(words, name)
end
-- </@>

-- <@>
function patch_setup()
    out = [[
glswapper [grab glive]
param [expr 180 / 60]
phasor zz 0
hold zz
regset zz 0
]]
    return out
end
-- </@>

-- <@>
function gestvmnode(glive, membuf, program, conductor)
    lil(string.format(
        "gestvmnode %s [gmemsym [grab %s] %s] %s",
        glive, membuf, program, conductor))

end
-- </@>

-- <@>
function mkvoice(pitch, gate, mi, fb)
    lil("regget 1")
    gestvmnode("[glget [grab glive]]",
        "mem",
        pitch,
        "[regget 0]")

    if (mi == nil) then mi = 1.3 end
    if (fb == nil) then fb = 0 end
    patch = {
        "mtof zz",
        string.format("fmpair zz zz 1 1 %g %g", mi, fb),
        -- "blsaw zz",
        "mul zz 0.1",
        -- "butlp zz 500"
    }

    for _, str in pairs(patch) do
        lil(str)
    end

    if (gate ~= nil) then
        gestvmnode("[glget [grab glive]]",
            "mem",
            gate,
            "[regget 0]")
        lil("smoother zz 0.02")
        lil("mul zz zz")
    end
end
-- </@>

-- <@>
function mkpatch()
    lil(patch_setup())
    -- lil("param 8000")

    gestvmnode("[glget [grab glive]]",
        "mem",
        "pitch",
        "[regget 0]")
    lil("dup")
    lil("sub zz 24")
    lil("mtof zz")
    lil("glottis zz 0.9")
    lil("swap")
    lil("add zz 12")
    lil("mtof zz")
    lil("bitnoise zz 1")
    lil("mul zz 0.5")
    lil("add zz zz")
    lil("valp1 zz 1000")
    gestvmnode("[glget [grab glive]]",
        "mem",
        "phonemes",
        "[regget 0]")
    lil("mul zz 0.2")
    lil("vowelmorph zz zz 0.1")
    lil("dcblocker zz")
    lil("chorus zz 0.3 1 0.5 0.007")
    lil("peakeq zz 80 60 4")
    lil("dup; dup; verbity zz zz 0.9 0.1 0.1")
    lil("drop; dcblocker zz; mul zz 0.2; add zz zz")
    lil([[
tenv [tick] 0.01 9.5 1.3
mul zz zz
unhold [regget 0]
gldone [grab glive]
]])
lil("unholdall")
end
-- </@>

-- <@>
function mknote(nt, dur)
    return {63 + nt, dur, 2}
end
-- </@>

-- <@>
function mkseq(words, name, seq)
    out = {}

    v = function (val, dur, behavior)
        x = {}

        x.val = val
        x.dur = dur
        x.bhvr = behavior

        return x
    end

    for _,p in pairs(seq) do
        table.insert(out, v(p[1], p[2], p[3]))
    end

    compile_path(words, out, name)
end
-- </@>

-- <@>
function sound()
    words = {}
    tal_setup(words)
    mkseq(words, "pitch", {
        {72, {2, 2}, 2},
        {75, {2, 2}, 2},
        {70, {2, 3}, 2},
        {72, {2, 2}, 2},
        {75, {2, 2}, 2},
        {70, {2, 3}, 2},
        {72, {2, 2}, 2},
        {75, {2, 2}, 2},
        {70, {2, 3}, 2},
        {84, {1, 2}, 0},
    })

    mkseq(words, "phonemes", {
        {0, {2, 1}, 2},
        {1, {2, 1}, 2},
        {2, {2, 1}, 2},
        {3, {2, 1}, 2},
        {4, {2, 1}, 2},
        {0, {2, 1}, 2},
        {1, {2, 1}, 2},
        {2, {2, 1}, 2},
        {3, {2, 1}, 2},
        {4, {1, 3}, 3},
    })

    compile_tal(words)
    mkpatch()
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
---###---
-###-###-
-#-----#-
-#-#-#-#-
##-----##
#-------#
#-#-#-#-#
#-#-#-#-#
#-------#
#########
]]
end

return G
-- </@>
