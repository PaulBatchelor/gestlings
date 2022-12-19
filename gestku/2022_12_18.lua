--[[
INTERNAL MALFUNCTION
-- <@>
dofile("gestku/2022_12_18.lua")
rtsetup()
setup()
-- </@>
--]]

-- <@>
G = {}

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
    ddd = 36,
    dd = 48,
    tt = 59,
    d = 60,
    r = 62,
    ra = 61,
    me = 63,
    f = 65,
    s = 67,
    l = 68,
    te = 70,
    t = 71,
    D = 72,
    R = 74,
    Me = 75,
}


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
        p=p.p or seq("d1"),
        g=p.g or gate("o_ c"),
        mod=p.mod or s16("b1_"),
        car=p.car or s16("b1_"),
        a=p.a or s16("b1_"),
        d=p.d or s16("c1_"),
        i=p.i or s16("a1_"),
        r=p.r or s16("a1_"),
        sz=p.sz or s16("o1_"),
        fdbk=p.fdbk or s16("c_"),
    }
end
-- </@>

-- <@>
A = {
    p=seq("d1 s D2^ Me2~"),
    g=gate("o_ c o c o2 c o c"),
    mod=s16("b1_ b c"),
    car=s16("b1_ c b"),
    a=s16("b1_ o f"),
    d=s16("c1_ o2"),
    i=s16("a2/ o1^"),
    r=s16("o2^ c1/"),
    sz=s16("o1^"),
    fdbk=s16("c/ h"),
}

B = pat {
    g=gate("o1_ c20"),
    a=s16("a1_"),
    d=s16("f1_"),
    p=seq("D1_"),
    r=s16("a1/ o3_"),
    sz=s16("o_"),
    i=s16("b1"),
    car=s16("c1"),
    mod=s16("f1"),
}

C = pat {
    p=seq("d1/ ddd3~"),
    g=gate("o3_"),
    a=s16("a1_"),
    d=s16("f1_"),
    i=s16("a1/ o a/ o/ c~"),
    fdbk=s16("m1_"),
    car=s16("b1_"),
    mod=s16("f1/ b_"),
    sz=s16("a1 n2^ f2_"),
    r=s16("d1/ g2^ d"),
}

D = pat {
    g=gate("o1_ c3 o1 c3 o3 c1 c4"),
    a=s16("a1_"),
    d=s16("c1_"),
    p=seq("d1/ me1/"),
    r=s16("g1_"),
    sz=s16("l_"),
    i=s16("b1/"),
    car=s16("b1"),
    mod=s16("b1"),
    fdbk=s16("b1"),
}

E = pat {
    g=gate("o1_ c3 o1 c3 o3 c1 c4 o c"),
    a=s16("a1_"),
    d=s16("c1_"),
    p=seq("me3/ d1_"),
    r=s16("g1_"),
    sz=s16("l_"),
    i=s16("b1/"),
    car=s16("b1"),
    mod=s16("b1"),
    fdbk=s16("b1"),
}

F = pat {
    p = seq("d2/ ra1_"),
    car=s16("d1_"),
    mod=s16("c1_"),
    g=gate("o1_"),
}

I = pat {
    p=seq("me1~ f s2 d2^ l"),
    g=gate("o1_ c o c o2 c o6 c2"),
    i=s16("b1/ f3~"),
    r=s16("d1/ g1_"),
    sz=s16("m3~ o1_"),
}


H = pat {
    p=seq("ddd3_"),
    g=gate("o3_"),
    a=s16("a1_"),
    d=s16("f1_"),
    i=s16("o1_"),
    fdbk=s16("m1_"),
    car=s16("b1_"),
    mod=s16("f1/ b1_"),
    sz=s16("a1 n2^ f2_"),
    r=s16("d1/ g2^ d"),
}

SEQ = {
    {A, {1, 2}},
    {D, {2, 1}},
    {F, {1, 1}},
    {C, {4, 1}},
    {H, {3, 1}},
    {C, {4, 1}},
    {C, {2, 1}},
    {I, {1, 1}},
    {E, {1, 1}},
    {C, {1, 5}},
    {B, {1, 4}},
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
function sound()
    lil(patch_setup(90))
    articulate()
    lil("regset [gensine [tabnew 8192]] 1")

    lil("regget 1")

    gesture("p")
    lil("mtof zz")
    gesture("car")
    gesture("mod")
    gest16("i", 0, 7)
    gest16("fdbk", 0, 0.9)
    lil("fmpair zz zz zz zz zz zz")
    lil("mul zz [dblin -8]")

    gesture("g")
    gesture("a")
    lil("div zz 16; scale zz 0.001 1.5")
    gesture("d")
    lil("div zz 16; scale zz 0.001 1.5")
    lil("envar zz zz zz")
    lil("mul zz zz")

    lil("dup; dup")

    gest16("sz", 0.1, 0.98)
    lil("param 10000")
    lil("bigverb zz zz zz zz; drop; dcblocker zz")
    lil("param -8")
    lil("dblin zz")
    lil("mul zz zz")
    gest16("r", 0, 1)
    lil("crossfade zz zz zz")
    lil("peakeq zz 80 80 2")
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

function G.symbol()
    return [[
####--##-#
----##--#-
####--##--
----##--#
####--#---
----##---#
-------#--
----------
------#-#-
--#-------
-----#----
]]
end

return G
-- </@>
