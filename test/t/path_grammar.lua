msgpack = dofile("util/MessagePack.lua")
base64 = dofile("util/base64.lua")
asset = dofile("asset/asset.lua")
symtools = dofile("util/symtools.lua")
asset = asset:new({msgpack=msgpack, base64=base64})
pprint = dofile("util/pprint.lua")

-- make sure this is generated beforehand
symtab = asset:load("path/symtab.b64")

grammar = loadfile("path/grammar.lua")
grammar()
grammar = generate_path_grammar(symtab)

symtools.vars(symtab)()

gesture_path = {
bracket_left,
zero, one,
ratemulstart, two, three, four, five, ratemulend, linear,
divider,

six, seven,
ratemulstart, eight, seven, zero, three, ratemulend, step,
divider,
eight, nine,
ratemulstart, eight, eight, nine, nine, ratemulend, gliss_big,
divider,

ten, eleven,
ratemulstart, fifteen, eleven, ten, eleven, ratemulend, gliss_medium,
divider,
twelve, thirteen,
ratemulstart, one, two, twelve, thirteen, ratemulend, gliss_small,
divider,
fourteen, fifteen,
bracket_right
}

function test_path(symtab, gpath)
    local hexstr = symtools.hexstring(symtab, gpath)

    local t = lpeg.match(lpeg.Ct(grammar), hexstr)
    local out = {}
    for _,v in pairs(t) do
        if v.value ~= nil then
            table.insert(out, v.value[1])
            table.insert(out, v.value[2])
        end
        if v.ratemul ~= nil then
            table.insert(out, v.ratemul[1][1])
            table.insert(out, v.ratemul[1][2])
            table.insert(out, v.ratemul[2][1])
            table.insert(out, v.ratemul[2][2])
        end

        if v.behavior ~= nil then
            table.insert(out, v.behavior)
        end
    end
    out = table.concat(out)
    return out
end

ref=
"012345linear678703step898899gliss_largea"..
"bfbabgliss_mediumcd12cdgliss_smallef"

out = test_path(symtab, gesture_path)

verbose = os.getenv("VERBOSE")
verbose = verbose ~= nil and verbose == "1"
if out == ref then
    if verbose then
        print("Everything is okay!")
    end
    os.exit(0)
else
    if verbose then
        print("Test strings do not match:")
        print("ref: " .. ref)
        print("out: " .. out)
    end
    os.exit(1)
end
