function mkmacro(words, name, program)
    table.insert(words, "%" .. name)
    table.insert(words, "{")
    for _,v in pairs(program)
    do
        table.insert(words, v)
    end
    table.insert(words, "}")
end

function mklabel(words, label)
    table.insert(words, "@" .. label)
end

function mknum(words, val)
    table.insert(words, "#" .. string.format("%02x", val))
end

function mknote(words, note)
    table.insert(words, "#" .. string.format("%02x", note))
    table.insert(words, "NOTE")
    table.insert(words, "BRK")
end

function mkdur(words, num, den)
    mknum(words, num)
    table.insert(words, "NUM")
    mknum(words, den)
    table.insert(words, "DEN")
end

function mkbehavior(words, id)
    mknum(words, id)
    table.insert(words, "BHVR")
end

function mkjump(words, label)
    table.insert(words, ";" .. label)
    table.insert(words, "JMP2")
end

function compile_tal(tal)
    lil([[
    gmemnew mem
    gestvmnew gvm
    ]])

    gestvm_compile("mem", program_tal)
    lil("gmemcpy [grab mem] [grab gvm]")
end
function mkpath(words, path)
    for _, v in pairs(path)
    do
        if v.note ~= nil then
            mknote(program_words, v.note)
        end

        if v.dur ~= nil then
            mkdur(program_words, v.dur[1], v.dur[2])
        end

        if v.bhvr ~= nil then
            mkbehavior(program_words, v.bhvr)
        end
    end
end

patch =
[[
phasor 2 0

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

wavout zz simple_path.wav

computes 10
]]



program_words = {}

mkmacro(program_words, "NUM", {"#24", "DEO"})
mkmacro(program_words, "DEN", {"#25", "DEO"})
mkmacro(program_words, "NEXT", {"#26", "DEO"})
mkmacro(program_words, "NOTE", {"#33", "ADD", "NEXT"})
mkmacro(program_words, "BHVR", {"#27", "DEO"})

-- I forget what this is called
table.insert(program_words, "|0100")

mklabel(program_words, "mel")


v = function (note, dur, behavior)
    x = {}

    x.note = note
    x.dur = dur
    x.bhvr = behavior

    return x
end

path =
{
    v(7, {1,2}, 2),
    v(2, {1, 1}),
    v(4),
    v(9, {1, 2}, 3)
}

mkpath(program_words, path)
mkjump(program_words, "mel")

program_tal = table.concat(program_words, " ")
compile_tal(program_tal)
lil(patch)
