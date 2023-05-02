symbols = require("symbols")
pprint = dofile("../util/pprint.lua")
msgpack = dofile("../util/MessagePack.lua")
base64 = dofile("../util/base64.lua")
asset = dofile("../asset/asset.lua")
asset = asset:new({msgpack=msgpack, base64=base64})
path_grammar = dofile("grammar.lua")

function generate_symtab(symbols)
    local symtab = {}

    for id, sym in pairs(symbols) do
        symtab[sym.name] = id
    end
    return symtab
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

symtab = generate_symtab(symbols)
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
print(hexstr)

function generate_grammar(pathgram)
    local Space = lpeg.S(" \n\t")^0
    local Null = lpeg.P("00")
    local Line = pathgram * Null * Space
    Line = lpeg.Ct(Line)
    local Lines = lpeg.Ct(Line^0)
    return Lines
end

Path = path_grammar.generate(symtab)

Grammar = generate_grammar(Path)

behaviors = {
    linear = 0,
    step = 1,
    gliss_medium = 2,
    gliss_large = 3,
    gliss_small = 4,
}

function parse(Lines, hexstr)
    local t = lpeg.match(Lines, hexstr)

    local ratemul = {1, 1}
    local behavior = behaviors["linear"]
    local gpath = {}

    for _,v in pairs(t[2]) do
        local val = tonumber("0x" .. v.value[1] .. v.value[2])
        if v.behavior ~= nil then
            behavior = behaviors[v.behavior]
        end

        if v.ratemul ~= nil then
            local num, den
            num = v.ratemul[1]
            num = tonumber("0x" .. num[1] .. num[2])
            den = v.ratemul[2]
            den = tonumber("0x" .. den[1] .. den[2])
            ratemul = {num, den}
        end
        local vertex = {
            val,
            ratemul,
            behavior
        }
        table.insert(gpath, vertex)
    end
    return gpath
end

gpath = parse(Grammar, hexstr)
asset:save(gpath, "path.bin.txt")
