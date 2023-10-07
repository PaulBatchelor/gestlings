--[[
-- <@>
dofile("physiology/pg/toni_sounds.lua")
-- </@>
--]]

core = require("util/core")
rt = require("util/rt")
lilt = core.lilt
lilts = core.lilts
sig = require("sig/sig")
zz = "zz"

function setup()
end

-- <@>
function excitation()
    lilts {
        {"metro", "[rline 4 15 2]"},
        {"hold"},
        {"regset", zz, 0},
        {"regmrk", 0},

        {"regget", 0},
        {"env", zz, 0.004, 0.001, 0.001},
        {"scale", zz, "[param 70]", "[param 96]"},
        {"mtof", zz},
        {"param", 0.5},
        {"sine", zz, zz},
        {"sine", "[mtof 72]", 1},
        {"biscale", zz, 0, 1},
        {"mul", zz, zz},
        {"regget", 0},
        {"env", zz, 0.001, 0.01, 0.001},
        {"mul", zz, zz},
        -- {"softclip", zz, 2},
    }
end
-- </@>

-- <@>
function patch()
    lilts {
        {"tubularnew", 8, 4},
        {"regset", "zz", 4},
        {"regmrk", 4},
    }
    lil( [[
    genvals [tabnew 1] "0.1 0.3 0.1 0.3 0.1 0.1 0.1 0.5"
    regset zz 3

    tabnew [tubularsz [regget 4] ]
    regset zz 6

    tractdrm [regget 6] [regget 3]
    tubulardiams [regget 4] [regget 6]
    ]])
    excitation()
    local exc = sig:new()
    exc:hold()
    lil("regget 4")
    exc:get()
    lil("tubular zz zz")
    exc:get()
    lil("balance zz zz")
    exc:unhold()
    lilt {"dcblocker zz"}
    lilt{"buthp", zz, 100}
    lil("limit zz -1 1")
    lil("regget 0")
    lil("unhold zz")
end
-- </@>
-- [[
-- <@>
lil("unholdall")
-- </@>
-- ]]

-- lilt {"wavout", zz, "tmp/test.wav"}

-- lil("computes 10")
setup()
rt.setup()

function run()
    patch()
    rt.out()
end
