mouth = require("avatar/mouth/mouth")
core = require("util/core")
lilt = core.lilt
sdfdraw = require("avatar/sdfdraw")
json = require("util/json")

local asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

function mkmouthtab(mouthshapes)
    local lut = {}
    for _, mth in pairs(mouthshapes) do
        lut[mth.name] = mth.shape
    end

    return lut
end

mouthshapes1 = asset:load("avatar/mouth/mouthshapes1.b64")
shapes = mkmouthtab(mouthshapes1)

-- shapes = {
--     open = {
--         circleness = 0.7,
--         roundedge = 0.1,
--         circrad = 0.35,
--         points = {
--             {-0.4, 0.4},
--             {-0.05, -0.4},
--             {0.05, -0.4},
--             {0.4, 0.4},
--         }
--     },
-- 
--     close = {
--         circleness = 0.7,
--         roundedge = 0.1,
--         circrad = 0.1,
--         points = {
--             {-0.4, 0.4},
--             {-0.05, -0.4},
--             {0.05, -0.4},
--             {0.4, 0.4},
--         }
--     },
-- 
--     rest = {
--         circleness = 0.1,
--         roundedge = 0.03,
--         circrad = 0.1,
--         points = {
--             {-0.8, 0.1},
--             {-0.8, -0.1},
--             {0.8, -0.1},
--             {0.8, 0.1},
--         }
--     },
-- 
--     tri = {
--         circleness = 0.0,
--         roundedge = 0.05,
--         circrad = 0.35,
--         points = {
--             {-0.4, 0.4},
--             {-0.05, -0.4},
--             {0.05, -0.4},
--             {0.4, 0.4},
--         }
--     },
-- 
--     triflip = {
--         circleness = 0.0,
--         roundedge = 0.05,
--         circrad = 0.35,
--         points = {
--             {-0.4, -0.4},
--             {-0.05, 0.4},
--             {0.05, 0.4},
--             {0.4, -0.4},
--         }
--     },
-- 
--     wide = {
--         circleness = 0.5,
--         roundedge = 0.1,
--         circrad = 0.35,
--         points = {
--             {-0.6, -0.4},
--             {-0.05, 0.4},
--             {0.05, 0.4},
--             {0.6, -0.4},
--         }
--     },
--     
--     upwider = {
--         circleness = 0.3,
--         roundedge = 0.09,
--         circrad = 0.35,
--         points = {
--             {-1.1, 0.4},
--             {-0.05, 0.1},
--             {0.05, 0.1},
--             {1.1, 0.4},
--         }
--     },
-- 
--     smallcirc = {
--         circleness = 1.0,
--         roundedge = 0.09,
--         circrad = 0.2,
--         points = {
--             {-0.2, 0.2},
--             {-0.2, -0.2},
--             {0.2, -0.2},
--             {0.2, 0.2},
--         }
--     },
-- 
--     bigcirc = {
--         circleness = 1.0,
--         roundedge = 0.09,
--         circrad = 0.5,
--         points = {
--             {-0.2, 0.2},
--             {-0.2, -0.2},
--             {0.2, -0.2},
--             {0.2, 0.2},
--         }
--     },
-- 
--     smallsqr = {
--         circleness = 0.0,
--         roundedge = 0.01,
--         circrad = 0.5,
--         points = {
--             {-0.2, 0.2},
--             {-0.2, -0.2},
--             {0.2, -0.2},
--             {0.2, 0.2},
--         }
--     },
-- 
--     bigsqr = {
--         circleness = 0.0,
--         roundedge = 0.01,
--         circrad = 0.5,
--         points = {
--             {-0.4, 0.4},
--             {-0.4, -0.4},
--             {0.4, -0.4},
--             {0.4, 0.4},
--         }
--     },
-- }

sqrc = mouth.squirc()

width = 320
height = 320
lilt {"bpnew", "bp", width, height}

mouthsz = width / 4

syms = sdfdraw.load_symbols(json)

mouthprog = sqrc:generate(1.0, 1.0, 1.0, {0, 0})

renderer = sdfdraw.mkrenderer(syms, "mouth", 256)

renderer:generate_bytecode(mouthprog)

lil("bpfnt_default font")
lil("sdfvmnew vm; grab vm")
vm = pop()

shapelist = {
    "open",
    "close",
    "rest",
    "tri",
    "triflip",
    "wide",
    "upwider",
    "smallcirc",
    "bigcirc",
    "smallsqr",
    "bigsqr",
}

for idx, name in pairs(shapelist) do
    local xpos = ((idx - 1)% 4)*mouthsz
    local ypos =  ((idx - 1)// 4)*mouthsz
    sqrc:apply_shape(vm, shapes[name], 1.0)
    lilt {"bpset", "[grab bp]", 0, xpos, ypos, mouthsz, mouthsz}
    renderer:draw("[bpget [grab bp] 0]", "[grab vm]")
    lilt {"bptxtbox", "[bpget [grab bp] 0]", "[grab font]", 0, 0, name}
end

lilt {"bppng", "[grab bp]", "res/mouthshapes1.png"}
