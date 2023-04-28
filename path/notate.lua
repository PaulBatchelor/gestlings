symbols = require("symbols")
pprint = dofile("../util/pprint.lua")

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

lines = {}
table.insert(lines, {
brackl,
zero, one,
ratemulstart, two, three, four, five, ratemulend, div,
six, seven, div,
eight, nine, div,
ten, eleven, div,
twelve, thirteen, div,
fourteen, fifteen,
brackr
})

table.insert(lines, {
brackl,
zero, one, two, three, four,
five, six, seven, eight, nine,
ten, eleven, twelve, thirteen, fifteen, fifteen,
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

Nibble = Space * Number * Space
Div = (Space * Divider * Space)^0
Hex = Div * lpeg.Ct(Nibble*Nibble) * Div
RateMul = RateMulStart * Hex * Div * Hex * RateMulEnd
Value = lpeg.Ct(lpeg.Cg(Hex, "value") * lpeg.Cg(RateMul, "ratemul")^0)

Path = LBrack * (Value)^0 * RBrack * Space
--Line = lpeg.Ct((Space * lpeg.Cg(Symbol, "symbol") * Space))^1 * Null
Line = Path * Null * Space
Line = lpeg.Ct(Line)
Lines = lpeg.Ct(Line^0)

t = lpeg.match(Lines, hexstr)

-- pprint.pprint(t[1])
