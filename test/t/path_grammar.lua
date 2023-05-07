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

proportional_gesture_path = {
bracket_left,
zero, zero,
ratemulstart, one, one, ratemulend, linear,
divider,
fifteen, fifteen,
ratemulstart, three, three, ratemulend, step,
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
            if #v.ratemul == 2 then
                table.insert(out, v.ratemul[1][1])
                table.insert(out, v.ratemul[1][2])
                table.insert(out, v.ratemul[2][1])
                table.insert(out, v.ratemul[2][2])
            elseif #v.ratemul == 1 then
                table.insert(out, v.ratemul[1][1])
                table.insert(out, v.ratemul[1][2])
            end
        end

        if v.behavior ~= nil then
            table.insert(out, v.behavior)
        end
    end
    out = table.concat(out)
    return out
end

function compare(out, ref)
    local err = 0
    if out == ref then
        if verbose then
            -- print("Everything is okay!")
        end
        err = 0
    else
        if verbose then
            print("Test strings do not match:")
            print("ref: " .. ref)
            print("out: " .. out)
        end
        err = 1
    end
    return err
end

verbose = os.getenv("VERBOSE")
verbose = (verbose ~= nil and verbose == "1")

ref=
"012345linear678703step898899gliss_largea"..
"bfbabgliss_mediumcd12cdgliss_smallef"

prop_ref= "0011linearff33step"


err = 0

out = test_path(symtab, gesture_path)
err = err + compare(out, ref)

prop_out = test_path(symtab, proportional_gesture_path)
err = err + compare(prop_out, prop_ref)

if err > 0 then
    if verbose then
        print(string.format("%d test(s) failed", err))
    end
    os.exit(1)
end
