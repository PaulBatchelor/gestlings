-- attempts to extract the anatomy drawing portion
-- from Inspire, in the hopes of refactoring
-- this code into something more modular

local mouth = require("avatar/mouth/mouth")
local avatar = require("avatar/avatar")
local sdfdraw = require("avatar/sdfdraw")
local json = require("util/json")
local core = require("util/core")
local pprint = require("util/pprint")

local lilt = core.lilt
local scale = 0.6
local sqrcirc = mouth:squirc()
local asset = require("asset/asset")
msgpack = require("util/MessagePack")
asset = asset:new{
    msgpack = msgpack,
    base64 = require("util/base64")
}


function mkmouthtab(mouthshapes)
    local lut = {}
    for _, mth in pairs(mouthshapes) do
        lut[mth.name] = mth.shape
    end

    return lut
end

function mkmouthlut(mouthshapes)
    local lut = {}

    for idx, mth in pairs(mouthshapes) do
        lut[mth.name] = idx
    end

    return lut
end

function mkmouthidx(mouthshapes)
    local lut = {}

    for idx, mth in pairs(mouthshapes) do
        lut[idx] = mth.shape
    end

    return lut
end
    
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

-- "shader" can be stored as data as an asset
-- asset:save(shader, "tmp/a_junior2.b64")
-- shader = asset:load("tmp/a_junior2.b64")

local av = avatar.mkavatar(sdfdraw,
    vm,
    syms,
    "avatar",
    id, 512, lilt)(shader)

-- sqrcirc: aka the logic for rigging the mouth
av.sqrcirc = sqrcirc

local mouthshapes = asset:load("avatar/mouth/mouthshapes1.b64")
av.mouthshapes = mkmouthtab(mouthshapes)
av.mouthlut = mkmouthlut(mouthshapes)
av.mouthidx = mkmouthidx(mouthshapes)

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

av.sqrcirc:apply_shape(vm, av.mouthshapes.bigsqr, 0.5)
-- for just drawing stills, only these arguments are
-- needed. Animating the mouth will take more time
avatar.draw(vm, av)

lil("bppng [grab bp] tmp/anatomy_test.png")
