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
lilt{"bppng", "[grab bp]", "test.png"}


map:draw()
