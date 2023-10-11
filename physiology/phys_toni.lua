toniphys = {}
local zz = "zz"

function whistle_square(lilts, pitch)
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

function whistle_noise(lilts, pitch, trig)
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

function whistle(lilts, pitch, trig, gate)
    whistle_noise(lilts, pitch, trig)
    whistle_square(lilts, pitch)
    lilts {
        {"add", zz, zz},
    }
end

--function toniphys.excitation(sig, core, pitch, trig, gate)
function toniphys.excitation(pt)
    local sig = pt.sig
    local core = pt.core
    local pitch = pt.pitch
    local trig = pt.trig
    local gate = pt.gate
    local lilts = core.lilts
    local lilt = core.lilt
    local clk = sig:new()

    if pt.click_rate ~= nil then
        pt.click_rate(pt)
    else
        lil("rline 4 20 3")
    end

    lilts {
        {"metro", zz},
    }

    if pt.tickpat ~= nil then
        pt.tickpat(pt)
        lilt {"gtick", zz}
    else
        lilt {"param", 0}
    end

    if pt.tickmode ~= nil then
        pt.tickmode(pt)
    else
        lilt {"param", 1}
    end
    lilt {"crossfade", zz, zz, zz}

    clk:hold()
    lilts {
        {"regget", clk.reg},
        {"env", zz, 0.004, 0.001, 0.001},
    }

    if pt.click_fmin ~= nil then
        pt.click_fmin(pt)
    else
        lilt {"param", 70}
    end

    if pt.click_fmax ~= nil then
        pt.click_fmax(pt)
    else
        lilt {"param", 96}
    end
    lilts {
        {"scale", zz, zz, zz},
    }

    if pt.pros_pitch_sig ~= nil then
        pt.pros_pitch_sig:get()
        lilt {"scale", zz, -12, 12}
        lilt {"add", zz, zz}
    end

    lilts {
        {"mtof", zz},
        {"param", 0.5},
        {"sine", zz, zz},
    }

    if pt.amfreq ~= nil then
        pt.amfreq(pt)
    else
        lilt {"param", 60}
    end

    if pt.pros_pitch_sig ~= nil then
        pt.pros_pitch_sig:get()
        lilt {"scale", zz, -12, 12}
        lilt {"add", zz, zz}
    end

    lilt {"mtof", zz}
    lilt {"param", 1}
    lilts {
        {"sine", zz, zz},
        {"biscale", zz, 0, 1},
        {"mul", zz, zz},
        {"regget", clk.reg},
        {"env", zz, 0.0015, 0.01, 0.0015},
        {"mul", zz, zz},
    }
    clk:get()
    lilts{
        {"env", zz, 0.002, 0.005, 0.002}
    }
    -- constant
    lil ("param 1")
    -- reverse signals so pulse amount 100% is pulse
    lil ("swap")
    if pt.pulse_amt ~= nil then
        pt.pulse_amt(pt)
    else
        lilt {"param", 8}
    end

    lilt {"mul", zz, 1.0 / 8.0}
    lilt {"crossfade", zz, zz, zz}
    whistle(lilts, pitch, trig, gate)
    lilt {"mul", zz, "[dblin 3]"}
    lilt {"mul", zz, zz}

    if pt.whistle_amt ~= nil then
        pt.whistle_amt(pt)
    else
        lilts {
            {"metro", 2},
            {"tog", zz},
            {"smoother", zz, 0.01},
        }
    end
    lilt {"mul", zz, 1.0 / 8.0}
    lilt {"crossfade", zz, zz, zz}
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

function toniphys.tempwhistlesigs(localsig)
    sig = sig or localsig
    assert(sig ~= nil, "sig module must be loaded")
    lil("metro 0.3; tgate zz 1")
    local gate = sig:new()
    gate:hold_cabnew()

    lil("add 0 0")
    local trig = sig:new()
    trig:hold_cabnew()

    lil("mtof ".. "[rline 81 88 10]")
    local pitch = sig:new()
    pitch:hold_cabnew()
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
    lil("mul zz [dblin 6]")
    -- lil("peakeq zz 1000 1000 2")
    lil("limit zz -1 1")
end

function gesture_param(name)
    return function(pt)
        assert(pt.gst ~= nil, "Gesture not loaded")
        pt.gst:gesture(name, pt.cnd)
    end
end

function setup_shapemorf(gst, tubular, cnd, use_msgscale)
    msgscale = nil
    if use_msgscale == true then
        msgscale = "[val [grab msgscale]]"
    end
    lilts {
        {"shapemorf",
            gst:get(),
            "[grab lut]",
            "[" .. table.concat(tubular:getstr(), " ") .. "]",
            "[" .. gst:gmemsymstr("shapes") .. "]",
            "[" .. table.concat(cnd:getstr(), " ") .. "]",
            -- "[val [grab msgscale]]"
            msgscale
        },
    }
end

function toniphys.physiology(p)
    local physdat = {}
    local sig = p.sig
    local core = p.core
    local gst = p.gst
    local cnd = p.cnd

    local pt = toniphys.create {
        sig = sig,
        core = core,
        cnd = cnd,
        gst = gst,
        click_rate = gesture_param("click_rate"),
        whistle_amt = gesture_param("whistle_amt"),
        pulse_amt = gesture_param("pulse_amt"),
        click_fmin = gesture_param("click_fmin"),
        click_fmax = gesture_param("click_fmax"),
        amfreq = gesture_param("amfreq"),
        tickmode = gesture_param("tickmode"),
        tickpat = gesture_param("tickpat"),
        pros_pitch = gesture_param("pros_pitch"),
    }

    -- set up tract filter, use fixed shape for testing
    local tubular = pt.tubular
    local shape = {
        0.1, 0.1, 0.1, 0.1, 0.1, 0.4, 0.3, 0.9
    }
    local use_msgscale = false
    local use_shapemorf = true

    if use_shapemorf then
        setup_shapemorf(gst, tubular, cnd, use_msgscale)
    else
        toniphys.fixed_tube_shape(sig, tubular, shape)
    end

    gst:gesture("pitch", cnd)

    if pt.pros_pitch ~= nil then
        pt.pros_pitch(pt)
        lilt {"mul", zz, 1.0/0xFF}
        pt.pros_pitch_sig = sig:new()
        pt.pros_pitch_sig:hold()

        pt.pros_pitch_sig:get()
        lilt {"scale", zz, -12, 12}
        lilt {"add", zz, zz}
    end

    lil("mtof zz")
    local pitch = sig:new()
    pitch:hold()

    gst:gesture("trig", cnd)
    lil("gtick zz")
    local trig = sig:new()
    trig:hold()

    pt.pitch = pitch
    pt.trig = trig 
    pt.gate = gate 
    -- toniphys.excitation(sig, core, pitch, trig, gate)
    toniphys.excitation(pt)
    if pt.pros_pitch_sig ~= nil then
        pt.pros_pitch_sig:unhold()
    end
    pitch:unhold()
    trig:unhold()

    local exc = sig:new()
    exc:hold()

    -- process excitation with tract filter
    toniphys.filter(tubular, exc)
    exc:unhold()
    local gate = sig:new()
    gst:gesture("gate", cnd)
    gate:hold()
    toniphys.gate(gate)
    gate:unhold()
    toniphys.postprocess()
    toniphys.clean(pt)
    return physdat
end

return toniphys
