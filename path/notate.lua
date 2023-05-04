pprint = dofile("util/pprint.lua")
msgpack = dofile("util/MessagePack.lua")
base64 = dofile("util/base64.lua")
asset = dofile("asset/asset.lua")
asset = asset:new({msgpack=msgpack, base64=base64})

function generate_symtab()
    return asset:load("path/symtab.b64")
end

function generate_hexstring(symtab, lines)
    local hexstr = ""
    for _,ln in pairs(lines) do
        local s = {}
        for _,c in pairs(ln) do
            table.insert(s, string.format("%02x", symtab[c]))
        end
        table.insert(s, "00")
        hexstr = hexstr .. table.concat(s, " ") .. "\n"
    end
    return hexstr
end

function symtab_vars(symtab)
    local evalstr = ""
    for k,_ in pairs(symtab) do
        evalstr= evalstr .. string.format("%s=%q", k, k)
    end
    return load(evalstr)
end

symtab = generate_symtab()
symvars = symtab_vars(symtab)
symvars()

lines = {}
table.insert(lines, {
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
})

table.insert(lines, {
bracket_left,
three, twelve,
ratemulstart, zero, two, zero, one, ratemulend, gliss_medium,
divider,
three, fourteen,
divider,
four, zero,
divider,
four, three,
divider,
four, seven,
bracket_right
})

hexstr = generate_hexstring(symtab, lines)
out = io.open("path/notation.hex", "w")
out:write(hexstr)
out:close()
