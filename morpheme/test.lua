morpheme = require("morpheme/morpheme")
tal = require("tal/tal")
path = require("path/path")
pprint = require("util/pprint")

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

--append(m, mp)
append_morpheme(mp, {1, 3}, {
    a={{60, 3, 2}, {67, 1, 2}, {58, 2, 3}},
    b={{63, 1, 2}, {65, 1, 2}, {63, 1, 2}, {62, 1, 2}}
})

append_morpheme(mp, {1, 3}, {
    a={{72, 1, 2}, {70, 1, 2}, {74, 2, 3}},
    b={
        {60, 2, 2},
        {62, 2, 2},
        {63, 2, 2},
        {65, 2, 2},
        {67, 2, 2},
        {65, 2, 2},
        {59, 1, 2},
        {60, 1, 2},
        {62, 2, 2},
    }
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
