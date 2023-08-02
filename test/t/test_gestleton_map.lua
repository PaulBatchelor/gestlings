gmapgen = require("levels/gestleton/mapgen")
asset = require("asset/asset")
asset = asset.instantiate()

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

map = gmapgen:new{asset=asset}

map:draw(reg)
chksm = "552aa1a26dd08755e71bc59421b008cc"
rc, msg = pcall(lil, "bpverify [grab bp] " .. chksm)

verbose = os.getenv("VERBOSE")
if rc == false then
    if verbose ~= nil and verbose == "1" then
        print(msg)
    end
    os.exit(1)
else
    os.exit(0)
end
