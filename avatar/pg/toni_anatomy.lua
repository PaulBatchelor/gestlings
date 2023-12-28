local mouth = require("avatar/mouth/mouth")
local avatar = require("avatar/avatar")
local sdfdraw = require("avatar/sdfdraw")
local json = require("util/json")
local core = require("util/core")
local pprint = require("util/pprint")
local anatomy = require("avatar/anatomy/anatomy")
local eye = require("avatar/eye/eye")

local lilt = core.lilt
-- local sqrcirc = mouth:squirc()
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

gestling_anatomy = asset:load("avatar/anatomy/a_toni.b64")

--local squirc = mouth:squirc()
-- local scale = 0.6
-- local squareoff = 0.5
-- local shader = {
--     {
--         "point",
--         "vec2", 0.0, -0.3, "add2",
--         "scalar", 0.5, "circle"
--     },
--     {
--         "point",
--         "vec2", -0.5, 0.5 - 0.25,
--         "vec2", -0.5, -0.3 - 0.25,
--         "vec2", 0.5, -0.3 - 0.25,
--         "vec2", 0.5, 0.5 - 0.25,
--         "poly4"
--     },
--     "union",
--     "scalar 0 regset",
--     "scalar 0 regget",
--     {"scalar", 0.01, "onion"},
-- 
--     {
--         "point",
--         "vec2", 0.0, -0.3, "add2",
--         "vec2", 0.35, 0.25, "ellipse"
--     },
--     "scalar 0 regset",
--     "scalar 0 regget",
--     {"scalar", 0.01, "onion"},
--     "add",
--     {
--         "point",
--         "vec2", 0.0, -0.3, "add2",
--         "scalar", 0.1, "circle"
--     },
--     "add",
--     "gtz",
-- 
--     squirc:generate(0.6, 2.0, 0.8, {0, 0.4}),
-- 
--     "add",
-- }

an = anatomy.new {
    syms = syms,
    vm = vm,
    sdfdraw = sdfdraw,
    avatar = avatar,
    lilt = lilt,
    --shader = shader,
    shader = gestling_anatomy.shader,
    asset = asset,
    --mouth_controller = mouth.name_to_mouth(squirc:name()),
    mouth_controller = mouth.name_to_mouth(gestling_anatomy.mouth),
    eye_controller = eye.name_to_eye(gestling_anatomy.eye),
}


av = anatomy.generate_avatar(an)

lil("bpnew bp 240 320")
avatar.setup(lilt)

lilt {"bpset", "[grab bp]", 0, 0, 0, 240, 320}

lilt {
    "bpline", "[bpget [grab bp] 0]",
    0, 320-60, 240, 320 - 60, 1
}

anatomy.apply_shape(an, "tri", 0.5)
anatomy.draw(an)
-- anatomy.draw(an)
lil("bppng [grab bp] tmp/toni_anatomy.png")
