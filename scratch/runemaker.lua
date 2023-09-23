pprint = require("util/pprint")
fp = io.open("runes/runes.txt", "r")
core = require("util/core")
lilts = core.lilts

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

nrows = 2
ncols = 20
glyphwidth = 8
glyphheight = 8

width = ncols*glyphwidth
height = nrows*glyphheight
lilts {
    {"bpnew", "bp", width, height},
    {"bpset", "[grab bp]", 0, 0, 0, width, height},
}

for gpos, gly in pairs(glyphs) do
    print((gpos - 1)% ncols, (gpos - 1)// ncols)
    xoff = ((gpos - 1)% ncols)*glyphwidth
    yoff = ((gpos - 1)// ncols)*glyphheight
    for pos, row in pairs(gly) do
        for x=1,#row do
            local bit = row[x]
            lilts {
                {
                    "bprectf", "[bpget [grab bp] 0]",
                    xoff+x, yoff+pos,
                    1, 1, bit
                }
            }
        end
    end
end

lilts {
    {"bppng", "[grab bp]", "scratch/runes.png"}
}
