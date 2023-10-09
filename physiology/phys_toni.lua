toniphys = {}
local zz = "zz"
function gesture(sr, gst, name, cnd)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr()),
        extscale = "[val [grab msgscale]]",
    }
end

function whistle_square(pitch)
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
end

function whistle_noise(pitch, trig)
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
end

function whistle(pitch, trig, gate)
    whistle_noise(pitch, trig)
    whistle_square(pitch)
    lilts {
        {"add", zz, zz},
    }
end

function toniphys.excitation(sig, pitch, trig, gate)
    local clk = sig:new()
    lilts {
        {"metro", "[rline 4 20 3]"},
    }
    clk:hold()
    lilts {
        {"regget", clk.reg},
        {"env", zz, 0.004, 0.001, 0.001},
        {"scale", zz, "[param 70]", "[param 96]"},
        {"mtof", zz},
        {"param", 0.5},
        {"sine", zz, zz},
        {"sine", "[mtof [rline 50 82 3]]", 1},
        {"biscale", zz, 0, 1},
        {"mul", zz, zz},
        {"regget", clk.reg},
        {"env", zz, 0.001, 0.01, 0.001},
        {"mul", zz, zz},
    }
    clk:get()
    lilts{
        {"env", zz, 0.002, 0.005, 0.002}
    }
    lilt {"crossfade", zz, 1, 1}
    whistle(pitch, trig, gate)
    lilt {"mul", zz, zz}
    lilts {
        {"metro", 2},
        {"tog", zz},
        {"smoother", zz, 0.01},
    }
    lilt{"crossfade", zz, zz, zz}
    clk:unhold()
end

function toniphys.create(p)
    p = p or {}
    local sig = sig or p.sig
    assert(sig ~= nil, "sig module not found")
    lilts {
        {"tubularnew", 9, 4},
    }
    tubular = sig:new()
    tubular:hold_data()
    p.tubular = tubular
    return p
end

function toniphys.tempwhistlesigs()
    lil("metro 0.5; tgate zz 1")
    local gate = sig:new()
    gate:hold()

    lil("add 0 0")
    local trig = sig:new()
    trig:hold()

    lil("mtof ".. "[rline 81 88 10]")
    local pitch = sig:new()
    pitch:hold()
    return pitch, trig, gate
end

function toniphys.clean(p)
    p.tubular:unhold()
end

function toniphys.filter(tubular, exc)
    tubular:get()
    exc:get()
    lil("tubular zz zz")
    exc:get()
    lil("balance zz zz")
end

function toniphys.fixed_tube_shape(sig, tubular, shape)
    lilt {
        "genvals",
        "[tabnew 1]",
        "\"" .. table.concat(shape, " ") .. "\""
    }
    local tractshape = sig:new()
    tractshape:hold_data()

    tubular:get()
    lil("tabnew [tubularsz zz]")

    local tractdiams = sig:new()
    tractdiams:hold_data()

    tractdiams:get()
    tractshape:get()
    lil([[
    tractdrm zz zz
    ]])

    tubular:get()
    tractdiams:get()
    lil("tubulardiams zz zz")
    tractshape:unhold()
    tractdiams:unhold()
end

function toniphys.gate(gate)
    gate:get()
    lilts {
        {"envar", "zz", 0.2, 0.2},
        {"mul", "zz", "zz"}
    }
end

function toniphys.postprocess()
    lil("dcblocker zz")
    lil("buthp zz 100")
    lil("limit zz -1 1")
end

function toniphys.physiology(p)
    local physdat = {}
    -- TODO
    return physdat
end

return toniphys
