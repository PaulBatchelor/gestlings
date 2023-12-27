local mouth = require("avatar/mouth/mouth")
local sqrcirc = mouth:squirc()
local eye = require("avatar/eye/eye")

local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

local squirc = mouth:squirc()
local cyclops = eye:cyclops()
local shader = {
    {
        "point",
        "vec2", 0.0, -0.3, "add2",
        "scalar", 0.5, "circle"
    },
    {
        "point",
        "vec2", -0.5, 0.5 - 0.25,
        "vec2", -0.5, -0.3 - 0.25,
        "vec2", 0.5, -0.3 - 0.25,
        "vec2", 0.5, 0.5 - 0.25,
        "poly4"
    },
    "union",

    "scalar 0 regset",
    "scalar 0 regget",
    {"scalar", 0.01, "onion"},
    cyclops:generate(0.0, -0.3),
    "add",

    "gtz",
    squirc:generate(0.6, 2.0, 0.8, {0, 0.4}),
    "add",
}

local gestling_anatomy = {}

gestling_anatomy.shader = shader
gestling_anatomy.mouth = squirc:name()
gestling_anatomy.eye = cyclops:name()

asset:save(gestling_anatomy, "avatar/anatomy/a_toni.b64")
