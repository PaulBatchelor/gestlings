gmapgen = require("levels/gestleton/mapgen")
asset = require("asset/asset")
asset = asset.instantiate()
pprint = require("util/pprint")

map = gmapgen:new()

tilemap = asset:load("levels/gestleton/tiles.b64")

pprint(tilemap[1])

function lilt(tab)
    lil(table.concat(tab, " "))
end

lilt{"bpnew", "bp", 320, 240}
lilt{"bpset", "[grab bp]", 0, 0, 0, 320, 240}

lil("bpget [grab bp] 0")
reg = pop()

tile = tilemap[1]

function draw_tile(tile, xpos, ypos)
    ypos = ypos * 8
    xpos = xpos * 8
    for y = 1, 8 do
        for x = 1, 8 do
            local row = tile[y]
            local val =
                row &
                ((1 << 2*(x - 1)) |
                 (1 << 2*(x - 1) + 1))
            val = val >> (2*(x - 1))
            local s= 0

            if val == 1 then s = 1 end
            btprnt.draw(reg, xpos + x, ypos + y, s)
        end
    end
end

draw_tile(tilemap[1], 1, 1)
draw_tile(tilemap[2], 2, 1)
draw_tile(tilemap[3], 1, 2)
draw_tile(tilemap[4], 2, 2)

lilt{"bppng", "[grab bp]", "test.png"}


map:draw()
