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

function toniphys.excitation(pt)
    local sig = pt.sig
    local core = pt.core
    local pitch = pt.pitch
    local trig = pt.trig
    local gate = pt.gate
    local lilts = core.lilts
    local lilt = core.lilt
    local clk = sig:new()

    -- use dirtysine to get add more grit to spectrum
    lil("gensinesum [tabnew 8192] \"1 0.1 0.01 0 0 0.1\"")
    local dirtysine = sig:new()
    dirtysine:hold_data()

    dirtysine:get()

    if pt.click_rate ~= nil then
        pt.click_rate(pt)
    else
        lil("rline 4 20 3")
    end

    if pt.sync ~= nil then
        pt.sync(pt)
        lilt {"gtick", zz}
    else
        lilt {"param", 0}
    end

    -- metrosync, restarts at beginning of morpheme
    lilts {
        {"metrosync", zz, zz},
    }

    -- use an explicit tick pattern instead of metro
    if pt.tickpat ~= nil then
        pt.tickpat(pt)
        lilt {"gtick", zz}
    else
        lilt {"param", 0}
    end

    -- blend between two tick signals
    if pt.tickmode ~= nil then
        pt.tickmode(pt)
    else
        lilt {"param", 1}
    end
    lilt {"crossfade", zz, zz, zz}

    -- percussive pitch envelope
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
        -- {"param", 0.5},
        -- {"sine", zz, zz},
        {"oscf", zz, zz, 0},
        {"mul", zz, 0.2},
    }

    -- apply AM to click signal
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
    }

    -- constant amplitude signal (no AM)
    lilt {"param", 1}
    -- swap the AM modulator / constant around
    -- so AM_AMT makes sense
    lilt {"swap"}

    -- apply AM to click signal
    if pt.amamt ~= nil then
        pt.amamt(pt)
        lilt {"mul", zz, 1/0xFF}
    else
        lilt {"param", 1}
    end

    lilts {
        {"crossfade", zz, zz, zz},
        {"mul", zz, zz},
    }

    -- amplitude envelope
    lilts {
        {"regget", clk.reg},
        {"env", zz, 0.001, 0.001, 0.001},
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
    dirtysine:unhold()
end

function toniphys.create(p)
    p = p or {}
    local sig = sig or p.sig
    assert(sig ~= nil, "sig module not found")
    p.lilts {
        {"tubularnew", 4, 4},
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

function toniphys.gate(gate, gst, cnd, msgscale, lilts)
    gate:get()
    gst:gesture("atk", cnd, msgscale)
    lilts {
        {"mul", zz, 1/0xFF},
        {"scale", zz, 0.001, 0.4},
    }
    gst:gesture("rel", cnd, msgscale)
    lilts {
        {"mul", zz, 1/0xFF},
        {"scale", zz, 0.001, 0.4},
    }
    lilts {
        -- {"envar", "zz", 0.2, 0.2},
        {"envar", "zz", "zz", "zz"},
        {"mul", "zz", "zz"}
    }
end

function toniphys.postprocess()
    lil("dcblocker zz")
    lil("buthp zz 100")
    lil("mul zz [dblin 5]")
    lil("limit zz -1 1")
end

function gesture_param(name, msgscale)
    return function(pt)
        assert(pt.gst ~= nil, "Gesture not loaded")
        pt.gst:gesture(name, pt.cnd, msgscale)
    end
end

function setup_shapemorf(gst, tubular, cnd, use_msgscale, lilts)
    local msgscale = nil
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
            msgscale
        },
    }
end

function toniphys.tal_head(p)
    local tal = tal or p.tal
    return {
        trig = function(words)
            tal.interpolate(words, 0)
        end,
        tickpat = function(words)
            tal.interpolate(words, 0)
        end,
        sync = function(words)
            tal.interpolate(words, 0)
        end,
    }
end

function toniphys.physiology(p)
    local physdat = {}
    local sig = p.sig
    local core = p.core
    local gst = p.gst or p.gest
    local cnd = p.cnd
    local msgscale = nil
    local use_msgscale = p.use_msgscale or false
    local lilts = p.lilts
    local lilt = p.lilt

    if use_msgscale == true then
        msgscale = "[val [grab msgscale]]"
    end

    local pt = toniphys.create {
        sig = sig,
        core = core,
        cnd = cnd,
        gst = gst,
        lilts = lilts,
        click_rate = gesture_param("click_rate", msgscale),
        whistle_amt = gesture_param("whistle_amt", msgscale),
        pulse_amt = gesture_param("pulse_amt", msgscale),
        click_fmin = gesture_param("click_fmin", msgscale),
        click_fmax = gesture_param("click_fmax", msgscale),
        amfreq = gesture_param("amfreq", msgscale),
        tickmode = gesture_param("tickmode", msgscale),
        tickpat = gesture_param("tickpat", msgscale),
        pros_pitch = gesture_param("pros_pitch", msgscale),
        sync = gesture_param("sync", msgscale),
        amamt = gesture_param("amamt", msgscale),
    }

    -- set up tract filter, use fixed shape for testing
    local tubular = pt.tubular
    local shape = {
        0.1, 0.1, 0.1, 0.1, 0.1, 0.4, 0.3, 0.9
    }
    local use_msgscale = p.use_msgscale or false
    local use_shapemorf = true

    if use_shapemorf then
        setup_shapemorf(gst, tubular, cnd, use_msgscale, lilts)
    else
        toniphys.fixed_tube_shape(sig, tubular, shape)
    end

    gst:gesture("pitch", cnd, msgscale)

    if pt.pros_pitch ~= nil then
        pt.pros_pitch(pt)
        lilt {"mul", zz, 1.0/0xFF}
        pt.pros_pitch_sig = sig:new()
        pt.pros_pitch_sig:hold()

        pt.pros_pitch_sig:get()
        lilt {"scale", zz, 0, 0}
        lilt {"add", zz, zz}
    end

    lil("mtof zz")
    local pitch = sig:new()
    pitch:hold()

    gst:gesture("trig", cnd, msgscale)
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
    gst:gesture("gate", cnd, msgscale)
    gate:hold()
    toniphys.gate(gate, gst, cnd, msgscale, lilts)
    gate:unhold()
    toniphys.postprocess()
    toniphys.clean(pt)

    -- mouth gestures, to be used for visuals
    gst:gesture("mouth_x", cnd, msgscale)
    lil("drop")
    lil("gestvmlast " .. gst:get())
    physdat.mouth_x = pop()
    gst:gesture("mouth_y", cnd, msgscale)
    lil("drop")
    lil("gestvmlast " .. gst:get())
    physdat.mouth_y = pop()

    return physdat
end

return toniphys
