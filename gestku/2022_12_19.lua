--[[
UP THERE
-- <@>
dofile("gestku/2022_12_19.lua")
rtsetup()
setup()
-- </@>

-- <@>
lil("glreset [grab glive]")
-- </@>
--]]

-- <@>
G = {}

function G.symbol()
    return [[
---------
----#----
---#-#---
--#---#--
-#--#--#-
----#----
----#----
----#----
----#----
----#----
---------
----#----
---------
]]
end

tal = require("tal/tal")
path = require("path/path")
morpheme = require("morpheme/morpheme")
pprint = require("util/pprint")
morpho = require("morpheme/morpho")

append = morpheme.appender(path)

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
function patch_setup(tempo)
    out = string.format([[
glswapper [grab glive]
param [expr %d / 60]
phasor zz 0
hold zz
regset zz 0
]], tempo)
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
notes = {
    ff = -7,
    ss = -5,
    lle = -4,
    ll = -3,
    tte = -2,
    tt = -1,
    d = 0,
    r = 2,
    m = 4,
    f = 5,
    fi = 6,
    s = 7,
    le = 8,
    l = 9,
    t = 11,
    te = 10,
    D = 12,
    R = 14,
    M = 16,
    F = 17,
    S = 19,
    L = 21,
    T = 23,
    DD = 24,
}

for k,v in pairs(notes) do
    notes[k] = v + 58
end

function seq(str)
    return morpho.eval(str, notes)
end
-- </@>

-- <@>
gates = {
    o = 1,
    c = 0
}

function gate(str)
    return morpho.eval(str, gates)
end
-- </@>

-- <@>
step16 = {
    a = 0,
    b = 1,
    c = 2,
    d = 3,
    e = 4,
    f = 5,
    g = 6,
    h = 7,
    h = 8,
    i = 9,
    j = 10,
    k = 11,
    l = 12,
    m = 13,
    n = 14,
    o = 15,
}

function s16(str)
    return morpho.eval(str, step16)
end
-- </@>

-- <@>
function gesture(name)
    gestvmnode("[glget [grab glive]]",
               "mem",
               name,
               "[regget 0]")
end

function gest16(name, mn, mx)
    gesture(name)
    lil(string.format(
        "div zz 16; scale zz %g %g", mn, mx))
end
-- </@>

-- <@>
function pat(p)
    return {
        ga=p.ga or gate("o1_"),
        pa=p.pa or seq("d1~"),

        gb=p.gb or gate("o1_"),
        pb=p.pb or seq("d1~"),

        gc=p.gc or gate("o1_"),
        pc=p.pc or seq("s1~"),

        gd=p.gd or gate("o1_"),
        pd=p.pd or seq("d1~"),

        ge=p.ge or gate("o1_"),
        pe=p.pe or seq("m1~"),

    }
end

A = pat { }

B = pat {
    pa = seq("d~"),
    pb = seq("tte~"),
    pe = seq("f~ s"),
}

C = pat {
    pa = seq("ff~"),
    pb = seq("ll~"),
    pc = seq("s2~ f~"),
    pd = seq("tte~ d~"),
    pe = seq("D1~ R2^"),
}


D = pat {
    pa = seq("ff~"),
    pa = seq("d3~"),
    pb = seq("lle~"),
    pe = seq("f1~"),
}

E = pat {
    pe = seq("R~"),
}

SEQ = {
    {A, {1, 3}},
    {B, {1, 1}},
    {C, {1, 1}},
    {D, {1, 3}},
    -- {C, {1, 3}},
    -- {D, {1, 3}},
    -- {A, {1, 3}},
    -- {B, {1, 3}},
    -- {C, {1, 3}},
    -- {D, {1, 3}},
}
-- </@>

-- <@>
function articulate()
    words = {}

    mp = {}

    tal.start(words)

    for _,s in pairs(SEQ) do
        append(mp, s[2], s[1])
    end


    morpheme.compile(tal, path, words, mp)

    tal.compile_words(words, "mem", "[glget [grab glive]]")
end
-- </@>

-- <@>
function voice(p)
    lil("regget 1")
    gesture("p" .. p.id)
    if (p.offset ~= nil) then
        lil(string.format("add zz %g", p.offset))
    end
    lil("mtof zz")
    param(1)
    param(1)
    param(p.mi or 1)
    param(0.1)
    lil("fmpair zz zz zz zz zz zz")
    if p.vol ~= nil then
        lil(string.format("mul zz [dblin %g]", p.vol))
    end

    gesture("g" .. p.id)
    param(0.01)
    param(0.01)
    lil("envar zz zz zz")
    lil("mul zz zz")
end
-- </@>

-- <@>
function param(x)
    lil(string.format("param %g", x))
end
function sound()
    lil(patch_setup(70))
    articulate()
    lil("regset [gensinesum [tabnew 8192] '1 0.1 0.1 0.1'] 1")

    voice{id="a", offset=-24, mi=8.1, vol=-6}
    voice{id="b", offset=-11.99, mi=4, vol=-8}
    lil("add zz zz")
    voice{id="c", offset=-12, mi=2, vol=0}
    lil("add zz zz")
    voice{id="d", mi=1, vol=-3}
    lil("add zz zz")
    voice{id="e", mi=2, vol=-5}
    lil("add zz zz")

    lil("mul zz [dblin -20]")
    lil("dup; vardelay zz 0.0 0.2 0.9; dup")
    param(0.98)
    lil("param 10000")
    lil("bigverb zz zz zz zz; drop; dcblocker zz")
    lil("buthp zz 200")
    lil("mul zz [dblin -15]")
    lil("swap; mul zz [dblin -5]")
    lil("add zz zz")

    lil("tenv [tick] 0.1 8 1; mul zz zz")
    lil("tgate [tick] 10.5; smoother zz 0.01; mul zz zz")
    lil("regget 0; unhold zz; gldone [grab glive]")
    lil("unholdall")
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
