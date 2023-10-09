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
function whistle(pitch, vib, trig, gate)
    lilts {
        {"noise"},
        {"butbp", zz, 1000, 50},
        {"buthp", zz, 1000},
    }

    trig:get()

    lilts {
        {"gtick", zz},
        {"tgate", zz, 0.1},
        {"smoother", zz, 0.001},
        {"scale", zz, 1.1, 1.8},
        {"mul", zz, zz},
    }

    pitch:get()
    pitch:get()

    lilts {
        {"mul", zz, 0.2},
        {"butbp", zz, zz, zz},
        -- {"mul", zz, 0.8},
    }

    pitch:get()
    lilts {
        {"blsquare", zz},
        {"mul", zz, 0.1},
        --{"mul", zz, 0.0},
    }

    pitch:get()
    lilts {
        {"butbp", zz, zz, 5},
    }

    lilts {
        {"add", zz, zz},
    }

    gate:get()
    lilts {
        {"envar", "zz", 0.2, 0.2},
        {"mul", "zz", "zz"}
    }
    lilts {
        {"mul", zz, "[dblin 3]"}
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
    genvals [tabnew 1] "0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1"
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
