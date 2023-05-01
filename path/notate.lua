symbols = require("symbols")
pprint = dofile("../util/pprint.lua")
msgpack = dofile("../util/MessagePack.lua")
base64 = dofile("../util/base64.lua")
asset = dofile("../asset/asset.lua")
asset = asset:new({msgpack=msgpack, base64=base64})

symtab = {}

for id, sym in pairs(symbols) do
    symtab[sym.name] = id
end

zero = "zero"
one = "one"
two = "two"
three = "three"
four = "four"
five = "five"
six = "six"
seven = "seven"
eight = "eight"
nine = "nine"
ten = "ten"
eleven = "eleven"
twelve = "twelve"
thirteen = "thirteen"
fourteen = "fourteen"
fifteen = "fifteen"
brackl = "bracket_left"
brackr = "bracket_right"
div = "divider"
ratemulstart = "ratemulstart"
ratemulend = "ratemulend"
linear = "linear"
step = "step"
gliss_big = "gliss_big"
gliss_medium = "gliss_medium"
gliss_small= "gliss_small"

lines = {}
table.insert(lines, {
brackl,
zero, one,
ratemulstart, two, three, four, five, ratemulend, linear,
div,

six, seven,
ratemulstart, eight, seven, zero, three, ratemulend, step,
div,
eight, nine,
ratemulstart, eight, eight, nine, nine, ratemulend, gliss_big,
div,

ten, eleven,
ratemulstart, fifteen, eleven, ten, eleven, ratemulend, gliss_medium,
div,
twelve, thirteen,
ratemulstart, one, two, twelve, thirteen, ratemulend, gliss_small,
div,
fourteen, fifteen,
-- ratemulstart, fourteen, fourteen, fourteen, fourteen, ratemulend,
brackr
})

table.insert(lines, {
brackl,
three, twelve,
ratemulstart, zero, two, zero, one, ratemulend, gliss_medium,
div,
three, fourteen,
div,
four, zero,
div,
four, three,
div,
four, seven,
brackr
})

hexstr = ""
for _,ln in pairs(lines) do
    local s = {}
    for _,c in pairs(ln) do
        table.insert(s, string.format("%02x", symtab[c]))
    end
    table.insert(s, "00")
    hexstr = hexstr .. table.concat(s, " ") .. "\n"
end

print(hexstr)

function generate_path_grammar(symtab)
    local Space = lpeg.S(" \n\t")^0
    local LBrack = lpeg.P(string.format("%02x", symtab["bracket_left"]))
    local RBrack = lpeg.P(string.format("%02x", symtab["bracket_right"]))
    local One = lpeg.P(string.format("%02x", symtab["one"]))
    local Two = lpeg.P(string.format("%02x", symtab["two"]))
    local Three = lpeg.P(string.format("%02x", symtab["three"]))
    local Four = lpeg.P(string.format("%02x", symtab["four"]))
    local Five = lpeg.P(string.format("%02x", symtab["five"]))
    local Six = lpeg.P(string.format("%02x", symtab["six"]))
    local Seven = lpeg.P(string.format("%02x", symtab["seven"]))
    local Eight = lpeg.P(string.format("%02x", symtab["eight"]))
    local Nine = lpeg.P(string.format("%02x", symtab["nine"]))
    local Ten = lpeg.P(string.format("%02x", symtab["ten"]))
    local Eleven = lpeg.P(string.format("%02x", symtab["eleven"]))
    local Twelve = lpeg.P(string.format("%02x", symtab["twelve"]))
    local Thirteen = lpeg.P(string.format("%02x", symtab["thirteen"]))
    local Fourteen = lpeg.P(string.format("%02x", symtab["fourteen"]))
    local Fifteen = lpeg.P(string.format("%02x", symtab["fifteen"]))
    local Zero = lpeg.P(string.format("%02x", symtab["zero"]))
    local RateMulStart = lpeg.P(string.format("%02x", symtab["ratemulstart"]))
    local RateMulEnd = lpeg.P(string.format("%02x", symtab["ratemulend"]))
    local Divider = lpeg.P(string.format("%02x", symtab["divider"]))
    local Linear = lpeg.P(string.format("%02x", symtab["linear"]))
    local Step = lpeg.P(string.format("%02x", symtab["step"]))
    local GlissBig = lpeg.P(string.format("%02x", symtab["gliss_big"]))
    local GlissMedium = lpeg.P(string.format("%02x", symtab["gliss_medium"]))
    local GlissSmall = lpeg.P(string.format("%02x", symtab["gliss_small"]))

    local Symbol = LBrack + RBrack + One + Two + Three + Four
    local Number =
        Zero / "0" +
        One / "1" +
        Two / "2" +
        Three / "3" +
        Four / "4" +
        Five / "5" +
        Six / "6" +
        Seven / "7" +
        Eight / "8" +
        Nine / "9" +
        Ten / "a" +
        Eleven / "b" +
        Twelve / "c" +
        Thirteen / "d" +
        Fourteen / "e" +
        Fifteen / "f"
    local Behavior = Space * (
        Linear / "linear" +
        Step / "step" +
        GlissBig / "gliss_large" +
        GlissMedium / "gliss_medium" +
        GlissSmall / "gliss_small"
        ) * Space
    local Nibble = Space * Number * Space
    local Div = (Space * Divider * Space)^0
    local Hex = Div * lpeg.Ct(Nibble*Nibble) * Div
    local RateMul = RateMulStart * Hex * Div * Hex * RateMulEnd
    local Value = lpeg.Ct(lpeg.Cg(Hex, "value") *
                    lpeg.Cg(lpeg.Ct(RateMul), "ratemul")^0 *
                    lpeg.Cg(Behavior, "behavior")^0
                    )

    local Path = LBrack * (Value)^0 * RBrack * Space
    return Path
end

Space = lpeg.S(" \n\t")^0
Null = lpeg.P("00")

Path = generate_path_grammar(symtab)
Line = Path * Null * Space
Line = lpeg.Ct(Line)
Lines = lpeg.Ct(Line^0)

t = lpeg.match(Lines, hexstr)

-- pprint.pprint(t[2])

local behaviors = {
    linear = 0,
    step = 1,
    gliss_medium = 2,
    gliss_large = 3,
    gliss_small = 4,
}
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

asset:save(gpath, "path.bin.txt")
