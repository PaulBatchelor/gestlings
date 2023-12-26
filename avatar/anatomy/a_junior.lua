local mouth = require("avatar/mouth/mouth")
local sqrcirc = mouth:squirc()

local asset = require("asset/asset")
local scale = 0.6
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

local shader = {
    {
        "point",
        "vec2", 0.45*scale, -0.33*scale, "add2",
        "scalar", 0.4*scale, "circle"
    },
    "scalar 0 regset",
    "scalar 0 regget",
    {"scalar", 0.02*scale, "onion"},
    {
        "point",
        "vec2", 0.45*scale, -0.33*scale, "add2",
        "scalar", 0.15*scale, "circle",
        "add"
    },
    "gtz",

    {
        "point",
        "vec2", -0.45*scale, -0.33*scale, "add2",
        "scalar", 0.4*scale, "circle"
    },
    "scalar 1 regset",
    "scalar 1 regget",
    {"scalar", 0.02*scale, "onion"},
    {
        "point",
        "vec2", -0.45*scale, -0.33*scale, "add2",
        "scalar", 0.15*scale, "circle",
        "add"
    },
    "gtz",

    "add",

    "point",
    {"vec2", 0.65*scale, 0.5*scale, "ellipse"},
    {"scalar", 0.02*scale, "onion"},
    "scalar 0 regget scalar 1 regget",
    "add",
    "swap subtract",
    "add",

    sqrcirc:generate(scale, 0.8, 0.05, {0, 0.3}),

    "add",
    -- "point vec2 0.75 0.6 ellipse gtz",
    "gtz",
}

local gestling_anatomy = {}

gestling_anatomy.shader = shader
gestling_anatomy.mouth = sqrcirc:name()

asset:save(gestling_anatomy, "avatar/anatomy/a_junior.b64")
