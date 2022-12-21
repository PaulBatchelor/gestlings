--[[
excuse me sir may I try some? pretty please? FINE BE THAT WAY.
-- <@>
dofile("gestku/2022_12_20.lua")
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
        rate=p.rate or s16("a_"),
        pitch=p.pitch or s16("h_"),
        timbre=p.timbre or s16("h_"),
        gate=p.gate or gate("o_"),
        atk=p.atk or s16("c_"),
        rel=p.rel or s16("c_"),
        patk=p.patk or s16("m_"),
        prel=p.prel or s16("a_"),
    }
end

function copy(p, r)
    r = r or {}
    local out = {}
    for k,v in pairs(p) do
        if r[k] ~= nil then
            out[k] = r[k]
        else
            out[k] = v
        end
    end

    return out
end

A = pat {
    rate = s16("e3/ c_"),
    timbre = s16("o_"),
    pitch = s16("a3^ d1/ o1_"),
}

B = copy(A, {
    rate = s16("e3/ a_"),
    timbre = s16("o1_"),
    pitch = s16("f3^ c1/ a1_"),
    patk = s16("m_"),
    prel = s16("m_"),
    atk = s16("a/ m_"),
    rel = s16("a/ m_"),
})

C = copy(B,{
    pitch = s16("d^ h d h o"),
    rate = s16("e^ a e"),
    timbre = s16("o3^ a1_"),
})

D = copy(C,{
    pitch = s16("a/ o a o a o"),
    rate = s16("e/ h_"),
    timbre = s16("o3^ a1_"),
    patk = s16("m_"),
    prel = s16("m_"),
    atk = s16("d_"),
    rel = s16("d_"),
    gate = gate("o4_ c1_")
})

S = pat {
    gate = gate("c_"),
}

SEQ = {
    {A, {1, 3}},
    {S, {1, 2}},
    {B, {1, 3}},
    {S, {1, 2}},
    {C, {1, 3}},
    {S, {2, 1}},
    {D, {1, 2}},
    {S, {1, 4}},
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
function param(x)
    lil(string.format("param %g", x))
end
function sound()
    lil(patch_setup(90))
    articulate()

    lil("regget 0")
    gesture("rate")
    lil("add zz 1; rephasor zz zz")
    lil("phsclk zz 1")

    gesture("gate")
lil([[
mul zz zz

hold zz
regset zz 1

regget 1]])
    gest16("patk", 0.001, 0.05)
    param(0.001)
    gest16("prel", 0.01, 0.4)
    lil("env zz zz zz zz")

lil("param 0")
gest16("pitch", 7, 24)
lil([[
scale zz zz zz
add zz 72
hold zz
regset zz 2

noise
butlp zz 2000
peakeq zz 500 250 2
mtof [regget 2]
add [regget 2] 0.1
mtof zz
sub [regget 2] 0.1
mtof zz
sub zz zz
butbp zz zz zz
mul zz [dblin 10]

blsquare [mtof [regget 2] ]
mul zz [dblin -3]
butlp zz 300
buthp zz 300
]])
gest16("timbre", 0, 1)
lil([[
crossfade zz zz zz

regget 1
]])

gest16("atk", 0.001, 0.01)
param(0.001)
gest16("rel", 0.005, 0.05)
lil([[
env zz zz zz zz

mul zz zz

mul zz [dblin 4]
dup
dup
bigverb zz zz 0.55 8000
drop
mul zz [dblin -7]
dcblocker zz
add zz zz
]])
    lil("regget 0; unhold zz")
    lil("regget 1; unhold zz")
    lil("regget 2; unhold zz")

    lil("tgate [tick] 10.5; envar zz 0.001 0.01; mul zz zz")
    lil("gldone [grab glive]")

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
