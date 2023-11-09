refgen = require("vocab/common/refgen")

local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

local core = require("util/core")
local lilt = core.lilt

refgen.generate {
    name = "toni",
    vocab = asset:load("vocab/toni/v_toni.b64"),
    tilemap = asset:load("vocab/toni/t_toni.b64"),
    lilt = lilt,
}
