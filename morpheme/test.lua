morpheme = require("morpheme/morpheme")
tal = require("tal/tal")
path = require("path/path")
pprint = require("util/pprint")
lang = require("morpheme/testlang")

Space = lpeg.S(" \n\t")^0
Duration = lpeg.C(lpeg.R("09")^1)
Value = lpeg.C(lpeg.R("az","AZ")^1)
Behavior = lpeg.S("~+/_")

lil([[
gmemnew mem
gestvmnew gvm
]])

m = morpheme.morpheme({
    a={{60, 3, 2}, {67, 1, 2}, {58, 2, 3}},
    b={{63, 1, 2}, {65, 1, 2}, {63, 1, 2}, {62, 1, 2}}
}, {1, 3})

function verts(m)
    local out = {}
    for pname, p in pairs(m) do
        out[pname] = {}
        for k, v in pairs(p) do
            out[pname][k] = path.vertex(v)
        end
    end
    return out
end

function append(m, mp)
    for pname, p in pairs(m) do
        if mp[pname] == nil then
            mp[pname] = {}
        end
        for k, v in pairs(p) do
            table.insert(mp[pname], path.vertex(v))
        end
    end
end

function append_morpheme(mp, r, m)
    append(morpheme.morpheme(m, r), mp)
end

function compile_paths(words, mv)
    for label, p in pairs(mv) do
        tal.label(words, label)
        path.path(tal, words, p)
        tal.jump(words, label)
    end
end

words = {}

tal.start(words)

--mp = verts(m)
mp = {}

append_morpheme(mp, {1, 3}, {
    a={{60, 3, 2}, {67, 1, 2}, {58, 2, 3}},
    b={{63, 1, 2}, {65, 1, 2}, {63, 1, 2}, {62, 1, 2}}
})

notes = {
    tt = 59,
    d = 60,
    r = 62,
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
    return lang.eval(str, notes)
end


append_morpheme(mp, {1, 3}, {
    a=seq("d1 s D2^ Me2~"),
    b=seq("d2~ r me f s f tt1 d r2")
})

compile_paths(words, mp)

tal.compile_words(words, "mem", "[grab gvm]")

lil([[
phasor 1.5 0
hold zz
regset zz 0

gestvmnode [grab gvm] [gmemsym [grab mem] a] [regget 0]
mtof zz
blsaw zz

gestvmnode [grab gvm] [gmemsym [grab mem] b] [regget 0]
mtof zz
blsaw zz

add zz zz

butlp zz 800
mul zz [dblin -8]
wavout zz test.wav
computes 10
regget 0
unhold zz
]])
