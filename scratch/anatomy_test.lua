-- attempts to extract the anatomy drawing portion
-- from Inspire, in the hopes of refactoring
-- this code into something more modular

local mouth = require("avatar/mouth/mouth")
local avatar = require("avatar/avatar")
local sdfdraw = require("avatar/sdfdraw")
local json = require("util/json")
local core = require("util/core")
local pprint = require("util/pprint")
local anatomy = require("avatar/anatomy")

local lilt = core.lilt
local scale = 0.6
local sqrcirc = mouth:squirc()
local asset = require("asset/asset")
msgpack = require("util/MessagePack")
asset = asset:new{
    msgpack = msgpack,
    base64 = require("util/base64")
}

lil("sdfvmnew vm")
lil("grab vm")
vm = pop()
syms = sdfdraw.load_symbols(json)
id = 1

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

an = anatomy.new {
    syms = syms,
    vm = vm,
    sdfdraw = sdfdraw,
    avatar = avatar,
    lilt = lilt,
    shader = shader,
    asset = asset,
    mouth_controller = sqrcirc,
}

av = anatomy.generate_avatar(an)

lil("bpnew bp 240 320")
local window_padding = 4
local avatar_padding = window_padding + 8

-- avatar
local avatar_dims = {
    avatar_padding, avatar_padding,
    240 - 2*avatar_padding,
    (320 - 60) - 2*avatar_padding
}

-- set up drawing region for avatar
lilt {
    "bpset",
    "[grab bp]", 1,
    avatar_dims[1], avatar_dims[2],
    avatar_dims[3], avatar_dims[4]
}

anatomy.apply_shape(an, "rest", 0.5)
anatomy.draw(an)
lil("bppng [grab bp] tmp/anatomy_test.png")
