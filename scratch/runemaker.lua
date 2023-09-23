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

-- fp:write("symbols = {}\n")
symbols = {}
fmt = string.format

-- gpos = 1
-- gly = glyphs[gpos]

for gpos, gly in pairs(glyphs) do
    for pos, row in pairs(gly) do
        local id = string.byte(chars, gpos)
        local sym = {}
        -- fp:write(fmt("symbol[0x%02x] = {\n", id))
        sym.id = id
        sym.width = 7
        sym.name = string.char(id)
        sym.bits = {}
        -- fp:write(fmt("    id = 0x%02x,\n",id))
        -- fp:write("    width = 7,\n")
        -- fp:write(fmt("    name = \"%s\",\n", string.char(id)))
        -- fp:write("    bits = {\n")
        for pos, row in pairs(gly) do
            local rowstr = ""
            -- fp:write("        \"")
            for x=1,#row do
                if row[x] == 1 then
                    --fp:write("#")
                    rowstr = rowstr .. "#"
                elseif row[x] == 0 then
                    --fp:write("-")
                    rowstr = rowstr .. "-"
                end
            end
            table.insert(sym.bits, rowstr)
            -- fp:write("\",\n")
        end
        symbols[id] = sym
        -- fp:write("    }\n")
        -- fp:write("}\n")
    end
end

uf2.generate(symbols, "fonts/protorunes.uf2")
