--[[
REGINA (IS LATE FOR WORK)

-- <@>
dofile("gestku/2022_12_13.lua")
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
param [expr 60 / 60]
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
    lil("regset [gensine [tabnew 8192]] 1")
    mkvoice("pitch", "gate", 1.5, 0.4)
    mkvoice("pitch2", "gate2", 1.3, 0.4)
    lil("add zz zz")
    mkvoice("pitch3", "gate3", 1.1, 0.4)
    lil("add zz zz")
    lil("dup; dup; bigverb zz zz 0.95 8000")
    lil("drop; mul zz [dblin -10]; dcblocker zz")
    lil("swap; mul zz [dblin -4]; add zz zz")
    lil([[
tenv [tick] 0.01 9.5 1.3
mul zz zz
unhold [regget 0]
gldone [grab glive]
]])
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

    qt = {1, 1}
    et = {2, 1}
    qt4 = {1, 4}
    sx = {4, 1}
    sx3 = {4, 3}
    ts = {8, 1}

    mkseq(words, "pitch", {
        mknote(0, qt),
        mknote(-3, qt),

        mknote(-5, sx),
        mknote(-3, sx),
        mknote(-1, sx),

        mknote(-5, sx),
        mknote(-3, sx),
        mknote(-1, sx),
        mknote(0, {1, 1}),
        mknote(-1, {2, 1}),

        mknote(0, qt),

        mknote(-3, {4, 3}),
        mknote(-1, {4, 1}),
        mknote(0, {1, 2}),

        mknote(2, {1, 1}),

        mknote(0, {1, 4}),
    })

    mkseq(words, "gate", {
        {1, {1, 7}, 1},
    })

    mkseq(words, "pitch2", {
        mknote(0, qt),
        mknote(0, qt),

        mknote(2, qt),
        mknote(0, qt),

        mknote(2, qt),
        mknote(4, qt),

        mknote(5, et),
        mknote(9, et),
        mknote(7, qt),

        mknote(0, et),
        mknote(12, qt),
        mknote(11, et),
        mknote(12, qt4),

    })

    mkseq(words, "gate2", {
        {0, qt, 1},
        {1, {1, 13}, 1},
    })

    mkseq(words, "pitch3", {
        mknote(5, {1, 3}),

        mknote(5, qt),
        mknote(2, qt),

        mknote(0, sx),
        mknote(2, sx),
        mknote(4, sx),
        mknote(0, sx),
        mknote(2, sx),
        mknote(4, sx),

        mknote(5, qt),
        mknote(4, et),

        mknote(5, et),
        mknote(4, et),
        mknote(7, qt),

        mknote(0, qt),

    })

    mkseq(words, "gate3", {
        {0, {1, 3}, 1},
        {1, {1, 9}, 1},
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
----#----
---------
####-####
#-#---#-#
#-#-#-#-#
#---#---#
----#----
--#####--
--#---#--
--#---#--
--#---#--
--#---#--
]]
end

return G
-- </@>
