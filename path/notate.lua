symbols = require("symbols")

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

lines = {}
table.insert(lines, {
brackl, one, two, three, four, five
})

table.insert(lines, {
six, seven, eight, nine, nine, nine, brackr
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
