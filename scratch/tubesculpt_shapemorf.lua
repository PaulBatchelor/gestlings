gest = require("gest/gest")
pprint = require("util/pprint")
tal = require("tal/tal")
path = require("path/path")

lil("shapemorfnew lut shapes/tubesculpt_testshapes.b64")
lil("grab lut")
lut = pop()
-- lut = shapemorf.load("shapes/tubesculpt_testshapes.b64")
lookup = shapemorf.generate_lookup(lut)

for k,v in pairs(lookup) do
    print(k, v)
end

gm = gest.behavior.gliss_medium
lin = gest.behavior.linear

os.exit()
vt = path.vertex
test_path = {
    vt{"oo", {1, 1}, gm},
    vt{"ah", {1, 1}, gm},
    vt{"oo", {1, 1}, lin},
    vt{"ah", {1, 1}, lin}
}

words = {}

tal.begin(words)
-- pprint(test_path)

tal.label(words, "vowshapes")
path.path(tal, words, test_path, lookup)
tal.jump(words, "vowshapes")
pprint(words)

g = gest:new{tal = tal}
g:create()
g:compile(words)

program = {
"tubularnew 17.0 -1",
"regset zz 0",
-- "tabnew [tubularsz [regget 0]]",
-- "regset zz 1",
-- 'tractdrmtab [genvals [tabnew 1] "1 2 1 1 1 4 9 3"] [regget 1]',
-- 
-- "regget 0",
-- "regget 1",
-- "tubulardiams zz zz",

table.concat({
    -- gvm, lut, tubular, program , conductor
    "shapemorf",
    g:get(),                                -- gestvm getter
    "[grab lut]",                           -- LUT
    "[regget 0]",                           -- tubular
    "[" .. g:gmemsymstr("vowshapes") .. "]",-- program
    "[phasor 1 0]"                          -- conductor
}, " "),

"regget 0",
"param 80",
"param 0.3",
"param 0.1",
"param 0.0",
"glot zz zz zz zz",
"tubular zz zz zz",
"butlp zz 3000",
"mul zz 0.8",
"dup",
"wavouts zz zz test.wav",
}

for _, line in pairs(program) do
    lil(line)
end

lil("computes 10")

-- shapemorf.del(lut)
