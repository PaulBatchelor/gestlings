-- attempts to extract the anatomy drawing portion
-- from Inspire, in the hopes of refactoring
-- this code into something more modular

local mouth = require("avatar/mouth/mouth")
local avatar = require("avatar/avatar")
local sdfdraw = require("avatar/sdfdraw")
local json = require("util/json")
local core = require("util/core")
local pprint = require("util/pprint")
local anatomy = require("avatar/anatomy/anatomy")

local lilt = core.lilt
local scale = 0.6
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
id = 1

gestling_anatomy = asset:load("avatar/anatomy/a_junior.b64")

an = anatomy.new {
    syms = syms,
    vm = vm,
    sdfdraw = sdfdraw,
    avatar = avatar,
    lilt = lilt,
    shader = gestling_anatomy.shader,
    asset = asset,
    mouth_controller = mouth.name_to_mouth(gestling_anatomy.mouth),
}

av = anatomy.generate_avatar(an)

lil("bpnew bp 240 320")
avatar.setup(lilt)

anatomy.apply_shape(an, "rest", 0.5)
anatomy.draw(an)
lil("bppng [grab bp] tmp/anatomy_test.png")
