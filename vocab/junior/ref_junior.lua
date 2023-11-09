refgen = require("vocab/common/refgen")

local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

local core = require("util/core")
local lilt = core.lilt

refgen.generate {
    name = "junior",
    vocab = asset:load("vocab/junior/v_junior.b64"),
    tilemap = asset:load("vocab/junior/t_junior.b64"),
    lilt = lilt,
}
