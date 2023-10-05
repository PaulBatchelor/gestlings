local asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
local pprint = require("util/pprint")

tiles = asset:load("scratch/gestleton_tiles.b64")

palette = {
    a = 2,
    b = 3,
    -- grass
    c = 4,
    d = 5,
    e = 6,
    f = 7,
    -- dirt
    g = 8,
    h = 9,
    i = 10,
    j = 11,

    -- road
    k = 12,
    l = 13,

    -- junior (24x24 sprite)
    m = 14,
    n = 15,
    o = 16,
    p = 17,

    q = 18,
    r = 19,
    s = 20,
    t = 21,

    u = 22,
    v = 23,
    w = 24,
    x = 25,

    y = 26,
    z = 27,
    A = 28,
    B = 29,
}

palette["."] = 1

-- pprint(tiles[2])

lil("bpnew bp 256 256")
lil("grab bp")
lil("bpset [grab bp] 0 0 0 256 256")
lil("bpget [grab bp] 0")
mainreg = pop()

function draw_glyph(tile, xpos, ypos)
    local width = 8
    for rowpos, row in pairs(tile) do
        rowstr = ""
        for x=1,width do
            local shft = (x - 1)*2
            local bits = ((row & (0x3 << shft)) >> shft)
            c = -1

            if bits == 1 then
                c = 1
            elseif bits == 0 then
                c = 0
            end

            if c >= 0 then
                btprnt.draw(mainreg,
                    xpos*8 + (x - 1),
                    ypos*8 + (rowpos - 1),
                    c)
            end
        end
    end
end

function draw_map(mapname)
    map = io.open(mapname, "r")

    rowpos = 0
    for line in map:lines() do
        for i=1,#line do
            local ch = string.char(string.byte(line, i))
            local tile_id = palette[ch]
            if tile_id ~= nil then
                draw_glyph(tiles[tile_id].data, i-1, rowpos)
            end
        end
        rowpos = rowpos + 1
    end
end

draw_map("scratch/map.txt")
draw_map("scratch/map2.txt")

lil("bppng [grab bp] tmp/gestleton_proto.png")
