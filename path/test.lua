tal = require("tal/tal")
path = require("path/path")
pprint = require("util/pprint")

v = function (note, dur, behavior)
    x = {}

    x.note = note
    x.dur = dur
    x.bhvr = behavior

    return x
end

words = {}

tal.macro(words, "NUM", {"#24", "DEO"})
tal.macro(words, "DEN", {"#25", "DEO"})
tal.macro(words, "NEXT", {"#26", "DEO"})
tal.macro(words, "NOTE", {"#33", "ADD", "NEXT"})
tal.macro(words, "BHVR", {"#27", "DEO"})

-- pad to 0x0100, which is when the first page
-- of memory ends
table.insert(words, "|0100")
tal.label(words, "mel")

p = {
    v(7, {2,1}, 2),
    v(5),
    v(7),
    v(0, {2,5}),

    v(7, {2,1}, 2),
    v(10),
    v(9),
    v(5, {2,3}),

    v(3, {1, 1}, 3),

    v(7, {2,1}, 2),
    v(5),
    v(7),
    v(12, {2,5}),

    v(15, {3,2}, 2),
    v(10),
    v(9),
    v(5, {1,1}),

    v(0, nil, 0),
}

path.path(tal, words, p)
tal.jump(words, "mel")

pprint(words)

program_tal = table.concat(words, " ")
tal.compile(program_tal, "mem", "gvm")

patch =
[[
phasor [expr 145 / 60] 0

hold zz
regset zz 0

gestvmnode [grab gvm] [gmemsym [grab mem] mel] [regget 0]

mtof zz
blsaw zz
mul zz 0.5

butlp zz 800

dup
dup
verbity zz zz 0.1 0.1 0.1
drop
mul zz [dblin -15]
dcblocker zz
add zz zz

unhold [regget 0]

dup
wavouts zz zz test.wav

computes 10
]]

lil(patch)
