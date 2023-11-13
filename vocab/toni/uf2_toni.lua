local asset = require("asset/asset")
local msgpack = require("util/MessagePack")
asset = asset:new {
    msgpack = msgpack,
    base64 = require("util/base64")
}

local uf2 = require("util/uf2")
local uf2gen = require("vocab/common/uf2gen")

uf2gen {
   tilemap = asset:load("vocab/toni/t_toni.b64"),
   uf2_filename = "fonts/toni.uf2",
   meta_filename = "vocab/toni/f_toni.b64",
   keyshapes_filename = "vocab/toni/k_toni.bin",
   uf2 = uf2,
   msgpack = msgpack,
   asset = asset
}
