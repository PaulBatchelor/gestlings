pprint = require("util/pprint")
fp = io.open("runes/runes.txt", "r")
core = require("util/core")
lilts = core.lilts
uf2 = require("util/uf2")

linepos = 1
glyphs = {}
curglyph = {}
for line in fp:lines() do
    local row = {}

    for i=1,#line do
        local c = string.char(string.byte(line, i))
        if (c == "#") then
            table.insert(row, 1)
        elseif (c == "-") then
            table.insert(row, 0)
        end
    end
    table.insert(curglyph, row)
    linepos = linepos + 1
    if linepos > 7 then
        table.insert(glyphs, curglyph)
        curglyph = {}
        linepos = 1
    end
end
fp:close()

chars = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

fp = io.stdout

symbols = {}
fmt = string.format

for gpos, gly in pairs(glyphs) do
    for pos, row in pairs(gly) do
        local id = string.byte(chars, gpos)
        local sym = {}
        sym.id = id
        sym.width = 7
        sym.name = string.char(id)
        sym.bits = {}
        for pos, row in pairs(gly) do
            local rowstr = ""
            for x=1,#row do
                if row[x] == 1 then
                    rowstr = rowstr .. "#"
                elseif row[x] == 0 then
                    rowstr = rowstr .. "-"
                end
            end
            table.insert(sym.bits, rowstr)
        end
        symbols[id] = sym
    end
end

uf2.generate(symbols, "fonts/protorunes.uf2")
