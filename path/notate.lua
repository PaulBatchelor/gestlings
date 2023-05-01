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

zero="zero"
one="one"
two="two"
three="three"
four="four"
five="five"
six="six"
seven="seven"
eight="eight"
nine="nine"
ten="ten"
eleven="eleven"
twelve="twelve"
thirteen="thirteen"
fourteen="fourteen"
fifteen="fifteen"
brackl="bracket_left"
brackr="bracket_right"
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

Space = lpeg.S(" \n\t")^0
LBrack = lpeg.P(string.format("%02x", symtab["bracket_left"]))
RBrack = lpeg.P(string.format("%02x", symtab["bracket_right"]))
One = lpeg.P(string.format("%02x", symtab["one"]))
Two = lpeg.P(string.format("%02x", symtab["two"]))
Three = lpeg.P(string.format("%02x", symtab["three"]))
Four = lpeg.P(string.format("%02x", symtab["four"]))
Five = lpeg.P(string.format("%02x", symtab["five"]))
Six = lpeg.P(string.format("%02x", symtab["six"]))
Seven = lpeg.P(string.format("%02x", symtab["seven"]))
Eight = lpeg.P(string.format("%02x", symtab["eight"]))
Nine = lpeg.P(string.format("%02x", symtab["nine"]))
Ten = lpeg.P(string.format("%02x", symtab["ten"]))
Eleven = lpeg.P(string.format("%02x", symtab["eleven"]))
Twelve = lpeg.P(string.format("%02x", symtab["twelve"]))
Thirteen = lpeg.P(string.format("%02x", symtab["thirteen"]))
Fourteen = lpeg.P(string.format("%02x", symtab["fourteen"]))
Fifteen = lpeg.P(string.format("%02x", symtab["fifteen"]))
Zero = lpeg.P(string.format("%02x", symtab["zero"]))
RateMulStart = lpeg.P(string.format("%02x", symtab["ratemulstart"]))
RateMulEnd = lpeg.P(string.format("%02x", symtab["ratemulend"]))
Null = lpeg.P("00")
Divider = lpeg.P(string.format("%02x", symtab["divider"]))
Linear = lpeg.P(string.format("%02x", symtab["linear"]))
Step = lpeg.P(string.format("%02x", symtab["step"]))
GlissBig = lpeg.P(string.format("%02x", symtab["gliss_big"]))
GlissMedium = lpeg.P(string.format("%02x", symtab["gliss_medium"]))
GlissSmall = lpeg.P(string.format("%02x", symtab["gliss_small"]))

Symbol = LBrack + RBrack + One + Two + Three + Four
Number =
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
Behavior = Space * (
    Linear / "linear" +
    Step / "step" +
    GlissBig / "gliss_large" +
    GlissMedium / "gliss_medium" +
    GlissSmall / "gliss_small"
    ) * Space
Nibble = Space * Number * Space
Div = (Space * Divider * Space)^0
Hex = Div * lpeg.Ct(Nibble*Nibble) * Div
RateMul = RateMulStart * Hex * Div * Hex * RateMulEnd
Value = lpeg.Ct(lpeg.Cg(Hex, "value") *
                lpeg.Cg(lpeg.Ct(RateMul), "ratemul")^0 *
                lpeg.Cg(Behavior, "behavior")^0
                )

Path = LBrack * (Value)^0 * RBrack * Space
--Line = lpeg.Ct((Space * lpeg.Cg(Symbol, "symbol") * Space))^1 * Null
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
