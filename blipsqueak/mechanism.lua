function mechanism(sr, core, gst, cnd_main)
    local pn = sr.paramnode
    local lvl = core.liln
    local param = core.paramf
    local ln = sr.node

    gest16 = gest.gest16fun(sr, core)

    -- cnd = cnd_main
    cnd = sig:new()
    cnd_main:get()

    -- hack, gest16 creates parameter node, wrap it
    -- in add to eval it immediately with ln

    ln(sr.add) {
        a = 0,
        b = gest16(gst, "gtempo", cnd_main, 0.75, 1.25)
    }

    lil("rephasor zz zz")
    cnd:hold()


    fg = gest16(gst, "pitch", cnd, 48, 72)

    global_pitch = gest16(gst, "gpitch", cnd, -7, 7)

    pitch_biased = pn(sr.add) {
        a = global_pitch,
        b = fg,
    }

    tg = gest16(gst, "timbre", cnd, 0.0, 10)
    vdepth  = gest16(gst, "vdepth", cnd, 0.0, 0.8)
    vrate = gest16(gst, "vrate", cnd, 4, 8)

    ag = gest16(gst, "amp", cnd, 0, 0.8)

    fdbk = gest16(gst, "fdbk", cnd, 0, 0.9)

    gate = gest16(gst, "gate", cnd, 0, 1)

    ampdur = gest16(gst, "ampdur", cnd, 0.001, 0.5)
    aspdur = gest16(gst, "aspdur", cnd, 0.003, 0.6)

    aspgt = gest16(gst, "aspgt", cnd, 0, 1)

    mod = pn(gst:node()) {
        name = "mod",
        conductor = lvl(cnd:getstr())
    }

    car = pn(gst:node()) {
        name = "car",
        conductor = lvl(cnd:getstr())
    }

    ampatk = gest16(gst, "ampatk", cnd, 0.001, 0.05)
    amprel = gest16(gst, "amprel", cnd, 0.001, 0.05)

    asp_freq = pn(sr.mtof) {
        input = pn(sr.add) {
            a = 50,
            b = gest16(gst, "aspfreq", cnd, 20, 60),
        }
    }

    asp_amt = gest16(gst, "aspamt", cnd, 0, 1)

    local g = warble.graph {
        -- pitch = fg,
        pitch = pitch_biased,
        mi = tg,
        fdbk = fdbk,
        amp = {
            val = ag,
            gate = gate,
            dur = ampdur,
            atk = ampatk,
            rel = amprel,
        },
        mod = mod,
        car = car,
        diagraf = diagraf,
        sr = sr,
        sig = sig,
        core = core,

        vib = {
            rate = vrate,
            depth = vdepth,
        },

        asp = {
            gate = aspgt,
            dur = aspdur,
            atk = param(0.01),
            rel = param(0.3),
            gain = param(1.5),
            bw = param(200),
            freq = asp_freq,
            val = asp_amt,
        },
    }

	l = g:generate_nodelist()
	g:compute(l)

    ln(sr.smoother) {
        input = gest16(gst, "gain", cnd, 0, 0.5),
        smooth = 0.003,
    }

    lil("mul zz zz")
    cnd:unhold()
end

return mechanism
