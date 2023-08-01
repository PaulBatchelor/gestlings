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

-- designed to fit nicely on mobile
width = 240 - 8*8
height = 320 - 8*8
zoom = 2

width = width * zoom
height = height * zoom

lilt{"bpnew", "bp", width, height}
lilt{"bpset", "[grab bp]", 0, 0, 0, width, height}

lil("bpget [grab bp] 0")
reg = pop()

tile = tilemap[1]

function draw_tile(tile, xpos, ypos, zoom)
    ypos = ypos * 8 * zoom
    xpos = xpos * 8 * zoom
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
            for zy = 1,zoom do
                for zx = 1,zoom do
                    btprnt.draw(reg,
                        xpos + zoom*(x - 1) + (zx - 1),
                        ypos + zoom*(y - 1) + (zy - 1),
                        s)
                end
            end
        end
    end
end


function draw_box(x, y, w, h)
    -- draw corners
    local x2 = x + 1 + w
    local y2 = y + 1 + h
    draw_tile(tilemap[1], x, y, zoom)
    draw_tile(tilemap[2], x2, y, zoom)
    draw_tile(tilemap[3], x2, y2, zoom)
    draw_tile(tilemap[4], x, y2, zoom)

    -- draw edges
    for i = 1, h do
        draw_tile(tilemap[5], x, y+i, zoom)
        draw_tile(tilemap[6], x2, y+i, zoom)
    end
    for i = 1, w do
        draw_tile(tilemap[8], x+i, y, zoom)
        draw_tile(tilemap[7], x+i, y2, zoom)
    end
end
nrows = 32
ncols = 22
draw_box(0, 0, ncols - 2, nrows - 2)
-- draw_box(ncols//2 - 4 - 1, nrows//2 - 4 - 1, 8, 8)
draw_box(4, 4, ncols - 8 - 2, nrows - 8 - 2)

lilt{"bppng", "[grab bp]", "test.png"}


map:draw()
