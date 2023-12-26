
local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

lil("shapemorfnew lut shapes/s_toni.b64")
lil("grab lut")
lut = pop()
lookup = shapemorf.generate_lookup(lut)

asset:save(lookup, "shapes/l_toni.b64")
