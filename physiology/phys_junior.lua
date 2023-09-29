juniorphys = {}
function gesture(sr, gst, name, cnd)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr()),
        extscale = "[val [grab msgscale]]",
    }
end

function juniorphys.physiology(p)
    local physdat = {}
    local G = p.gest
    local cnd = p.cnd
    local lilts = p.lilts
    local lilt = p.lilt
    local sigrunes = p.sigrunes
    local sig = p.sig

    lilts {
        {"tubularnew", 8, 4},
        {"regset", "zz", 4},
        {"regmrk", 4},
    }

    lilts {
        {"shapemorf",
            G:get(),
            "[grab lut]",
            "[regget 4]",
            "[" .. G:gmemsymstr("shapes") .. "]",
            "[" .. table.concat(cnd:getstr(), " ") .. "]",
            "[val [grab msgscale]]"
        },
    }
    gesture(sigrunes, G, "pros_intensity", cnd)
    lilts {
        {"mul", "zz", 1.0 / 0xFF},
    }

    local intensity = sig:new()
    intensity:hold()

    lilt {"regget", 4}
    gesture(sigrunes, G, "inflection", cnd)
    lilt {"mul", "zz", 0.5}
    gesture(sigrunes, G, "pros_pitch", cnd)
    lilts {
        {"mul", "zz", 1.0 / 0xFF},
        {"scale", "zz", -14, 14},
        {"add", "zz", "zz"}
    }
    lilts {
        {"param", 63},
        {"add", "zz", "zz"},
    }
    gesture(sigrunes, G, "vib", cnd)
    lilts {
        {"mul", "zz", 1.0 / 0xFF},
    }
    local vib = sig:new()
    vib:hold()

    vib:get()
    lilts {
        {"scale", "zz", 6.5, 8},
    }

    vib:get()
    lilts {
        {"scale", "zz", 0.0, 0.8},
    }
    intensity:get()
    -- remap: < 0.5, return 0, other wise 0-1
    lilts {
        {"mul", "zz", 2},
        {"add", "zz", -1},
        {"limit", "zz", 0, 1},
        {"scale", "zz", 0, 3},
        {"add", "zz", "zz"},
    }
    lilts {
        {"sine", "zz", "zz"},
        {"add", "zz", "zz"},
    }
    vib:unhold()

    lilts {
        {"mtof", "zz"},
        {"param", 0.2},
        {"param", 0.15},
        {"param", 0.1},
        {"glot", "zz", "zz", "zz", "zz"}
    }

    local glot = sig:new()

    lilts {
        {"noise"},
        {"butlp", "zz", 1000},
        {"buthp", "zz", 1000},
        {"highshelf", "zz", 3000, 5, 0.5},
        {"mul", "zz", 0.5},
    }

    gesture(sigrunes, G, "aspiration", cnd)
    lilts {
        {"mul", "zz", 1.0 / 255.0},
        {"smoother", "zz", "0.005"},
        {"crossfade", "zz", "zz", "zz"}
    }

    lilts {
        -- whisper-y
        {"noise"},
        {"butbp", "zz", 1000, 300},
        {"butlp", "zz", 4000},
        -- {"butlp", "zz", 500},
        -- {"peakeq", "zz", 300, 300, 2.5},
        -- {"buthp", "zz", 200},
        {"mul", "zz", 1.3},
    }
    lil("swap")

    intensity:get()
    lilts {
        -- rescale so intensity curve: 0, 0.5 -> 0, 1
        {"mul", "zz", 2},
        {"limit", "zz", 0, 1},
        {"crossfade", "zz", "zz", "zz"}
    }

    intensity:unhold()

    glot:hold()

    glot:get()

    lilts {
        {"tubular", "zz", "zz"},
        {"butlp", "zz", 4000},
        {"buthp", "zz", 100},
        {"regclr", 4},
    }

    glot:get()

    -- use balance filter to control resonances of tubular
    lilt{"balance", "zz", "zz"}

    gesture(sigrunes, G, "gate", cnd)

    lilts {
        {"envar", "zz", 0.05, 0.2},
        {"mul", "zz", "zz"}
    }
    glot:unhold()

    lilts {
        {"mul", "zz", "[dblin " .. -3 .."]"},
    }

    lil("dcblocker zz")

    -- mouth gestures, to be used for visuals
    gesture(sigrunes, G, "mouth_x", cnd)
    lil("drop")
    lil("gestvmlast " .. G:get())
    physdat.mouth_x = pop()
    gesture(sigrunes, G, "mouth_y", cnd)
    lil("drop")
    lil("gestvmlast " .. G:get())
    physdat.mouth_y = pop()

    return physdat
end

return juniorphys
