gest = require("gest/gest")
pprint = require("util/pprint")
tal = require("tal/tal")
path = require("path/path")

lil("shapemorfnew lut shapes/tubesculpt_testshapes.b64")
lil("grab lut")
lut = pop()
lookup = shapemorf.generate_lookup(lut)

for k,v in pairs(lookup) do
    print(k, v)
end

gm = gest.behavior.gliss_medium
gl = gest.behavior.gliss
lin = gest.behavior.linear

shapes = {
    "2b1d8a",
    "4e8a8e",
    "83ae8a",
    "172828",
    "54f27d",
    "8abe8d",
}

mantra = {
    -- 1, 2, {1, 2}, 3, 4, {3, 4}, 5, 6, {5, 6}
    1, 2, {1, 2}, {1, 4},
    3, 4, {3, 4}, {5, 4},
    5, 6, {5, 6}, {1, 6},
}

function mantra_to_path(mantra, shapes)
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local vt = path.vertex
    local mantra_path = {}
    local dur = {1, 1}

    for _,m in pairs(mantra) do
        if type(m) == "table" then
            table.insert(mantra_path, vt{shapes[m[1]], dur, lin})
            table.insert(mantra_path, vt{shapes[m[2]], dur, gl})
        else
            table.insert(mantra_path, vt{shapes[m], dur, gm})
        end
    end

    return mantra_path
end

vt = path.vertex
test_path = mantra_to_path(mantra, shapes)
-- test_path = {
--     vt{shapes[1], {1, 1}, gm},
--     vt{shapes[2], {1, 1}, gm},
--     vt{shapes[1], {1, 1}, lin},
--     vt{shapes[2], {1, 1}, gl},
-- 
--     vt{shapes[3], {1, 1}, gm},
--     vt{shapes[4], {1, 1}, gm},
--     vt{shapes[3], {1, 1}, lin},
--     vt{shapes[4], {1, 1}, gl},
-- 
--     vt{shapes[5], {1, 1}, gm},
--     vt{shapes[6], {1, 1}, gm},
--     vt{shapes[5], {1, 1}, lin},
--     vt{shapes[6], {1, 1}, gl}
-- }

words = {}

tal.begin(words)
-- pprint(test_path)

tal.label(words, "vowshapes")
path.path(tal, words, test_path, lookup)
tal.jump(words, "vowshapes")
-- pprint(words)

g = gest:new{tal = tal}
g:create()
g:compile(words)

program = {
"tubularnew 20.0 -1",
"regset zz 0",
-- "tabnew [tubularsz [regget 0]]",
-- "regset zz 1",
-- 'tractdrmtab [genvals [tabnew 1] "1 2 1 1 1 4 9 3"] [regget 1]',
-- 
-- "regget 0",
-- "regget 1",
-- "tubulardiams zz zz",

"expmap [flipper [phasor 0.05 0]] 3",
"hold zz",
"regset zz 2",

table.concat({
    -- gvm, lut, tubular, program , conductor
    "shapemorf",
    g:get(),
    "[grab lut]",
    "[regget 0]",
    "[" .. g:gmemsymstr("vowshapes") .. "]",
    -- "[phasor [scale [expmap [flipper [phasor 0.05 0]] 3] 1 8] 0]"
    "[phasor [scale [regget 2] 1 8] 0]"
}, " "),

"regget 0",
"param 30",
"jitseg 0.3 -0.3 0.5 2 1",
-- "jitseg 10.3 -2.3 0.5 2 1",
"add zz zz",
"scale [regget 2] -2 19",
"add zz zz",
"mtof zz",
-- "param 0.3",
"scale [regget 2] 0.2 0.7",
"param 0.1",
"param 0.0",
"glot zz zz zz zz",
"tubular zz zz zz",
"butlp zz 3000", "mul zz [dblin [scale [regget 2] -3 -8]]",
"dup", "dup",
"bigverb zz zz [scale [regget 2] 0.9 0.97] 10000",
"drop", "dcblocker zz", "mul zz [dblin [scale [regget 2] -16 -13]]",
"add zz zz",
"mul zz [dblin -2]",
"dup",
"wavouts zz zz tmp/mouthsounds.wav",
"unhold [regget 2]"
}

for _, line in pairs(program) do
    lil(line)
end

lil("computes 80")
