-- core = require("util/core")
-- gest = require("gest/gest")
-- pprint = require("util/pprint")
-- tal = require("tal/tal")
-- path = require("path/path")
-- sig = require("sig/sig")
-- sigrunes = require("sigrunes/sigrunes")
-- 
lilts = core.lilts
zz = "zz"


ritualmusic = {}

function generate_chant()
    return test_path, chant_pitch
end

function ritualmusic.generate_gesture_paths(data)
    -- local test_path, chant_pitch = generate_chant()

    lil("shapemorfnew lutrm shapes/tubesculpt_testshapes.b64")
    lil("grab lutrm")
    local lut = pop()
    local lookup = shapemorf.generate_lookup(lut)

    data.lookup = lookup
    local vt = path.vertex
    local gm = gest.behavior.gliss_medium
    local step = gest.behavior.step
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local g50 = gest.behavior.gate_50


    shapes = {
        "2b1d8a",
        "4e8a8e",
        "83ae8a",
        "172828",
        "54f27d",
        "8abe8d",
    }

    data.test_path = {
        -- 32 + 4 bars rest
        vt{shapes[1], {1, 32}, step},
        vt{shapes[1], {1, 32}, step},
        vt{shapes[1], {1, 32}, step},
        vt{shapes[1], {1, 32}, step},
        vt{shapes[1], {1, 16}, gm},

        vt{shapes[1], {1, 3}, gm},
        vt{shapes[2], {1, 2}, gm},
        vt{shapes[3], {1, 2}, gm},
        vt{shapes[6], {1, 4}, lin},
        vt{shapes[4], {1, 3}, gm},

        vt{shapes[1], {1, 3}, gm},
        vt{shapes[2], {1, 2}, gm},
        vt{shapes[3], {1, 2}, gm},
        vt{shapes[6], {1, 4}, lin},
        vt{shapes[4], {1, 3}, gm},

        vt{shapes[1], {1, 3}, gm},
        vt{shapes[2], {1, 2}, gm},
        vt{shapes[3], {1, 2}, gm},
        vt{shapes[6], {1, 4}, lin},
        vt{shapes[4], {1, 3}, gm},

        vt{shapes[1], {1, 3}, gm},
        vt{shapes[2], {1, 2}, gm},
        vt{shapes[3], {1, 2}, gm},
        vt{shapes[6], {1, 4}, lin},
        vt{shapes[4], {1, 3}, gm},

        vt{shapes[1], {1, 3}, gm},
        vt{shapes[2], {1, 2}, gm},
        vt{shapes[3], {1, 2}, gm},
        vt{shapes[6], {1, 4}, lin},
        vt{shapes[4], {1, 3}, gm},

        vt{shapes[1], {1, 3}, gm},
        vt{shapes[2], {1, 2}, gm},
        vt{shapes[3], {1, 2}, gm},
        vt{shapes[6], {1, 4}, lin},
        vt{shapes[4], {1, 3}, gm},

        vt{shapes[1], {1, 3}, gm},
    }

    data.chant_pitch = {
        -- 32 + 4 bars rest
        vt{12, {1, 32}, step},
        vt{12, {1, 32}, step},
        vt{12, {1, 32}, step},
        vt{12, {1, 32}, step},
        vt{12, {1, 16}, gm},

        vt{12+2, {1, 3}, gm},
        vt{12+2, {1, 8}, lin},
        vt{12+3, {1, 3}, gm},
        vt{12, {1, 3}, gm},

        vt{12+2, {1, 3}, gm},
        vt{12+2, {1, 8}, lin},
        vt{12+3, {1, 3}, gm},
        vt{12, {1, 3}, gm},

        vt{12, {1, 2}, lin},
        vt{12, {1, 2}, lin},
        vt{12 - 3, {1, 4}, lin},
        vt{12 - 3, {1, 3}, gm},

        vt{12+2, {1, 3}, gm},
        vt{12+2, {1, 8}, lin},
        vt{12+3, {1, 3}, gm},
        vt{12, {1, 3}, gm},

        vt{12, {1, 2}, lin},
        vt{12, {1, 2}, lin},
        vt{12 - 3, {1, 4}, lin},
        vt{12 - 3, {1, 3}, gm},

        vt{12+2, {1, 3}, gm},
        vt{12+2, {1, 8}, lin},
        vt{12+3, {1, 3}, gm},
        vt{12, {1, 3}, gm},

        vt{12, {1, 2}, lin},
        vt{12, {1, 2}, lin},
        vt{12 - 3, {1, 4}, lin},
        vt{12 - 3, {1, 3}, gm},


        vt{12, {1, 8}, lin},
        vt{12-4, {1, 5}, gl},
        vt{12+24+12, {1, 4}, step},
    }

    data.bell_strike = {

        -- 32 + 4 bars rest
        vt{1, {1, 32}, step},
        vt{1, {1, 32}, step},
        vt{1, {1, 32}, step},
        vt{1, {1, 32}, step},
        vt{1, {1, 16}, step},

        vt{1, {1, 14}, step},

        vt{1, {1, 14}, g50},
        vt{1, {1, 14}, g50},
        vt{1, {1, 14}, g50},
        vt{1, {1, 14}, g50},
        vt{1, {1, 14}, g50},
    }
    data.hum_level = {
        -- 32 + 4 bars rest
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 16}, step},

        vt{0, {1, 14}, lin},
        vt{1, {1, 14}, step},
    }

    data.vox_gate = {
        -- 32 + 4 bars rest
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 16}, step},

        vt{0, {1, 14}, step},

        vt{0, {1, 3}, step},
        vt{1, {1, 8}, step},
        vt{0, {1, 3}, step},

        vt{0, {1, 3}, step},
        vt{1, {1, 8}, step},
        vt{0, {1, 3}, step},

        vt{0, {1, 3}, step},
        vt{1, {1, 8}, step},
        vt{0, {1, 3}, step},

        vt{0, {1, 3}, step},
        vt{1, {1, 8}, step},
        vt{0, {1, 3}, step},

        vt{0, {1, 3}, step},
        vt{1, {1, 8}, step},
        vt{0, {1, 3}, step},

        vt{0, {1, 3}, step},
        vt{1, {1, 8}, step},
        vt{0, {1, 3}, step},

        vt{1, {1, 16}, step},
        vt{0, {1, 1}, step},
    }

    data.breakdown = {
        -- 32 + 4 bars rest
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 16}, step},

        vt{0, {1, 14}, step},
        vt{0, {1, 14*5}, lin},
        vt{1, {1, 14}, step},
    }

    data.reverb = {
        -- 32 + 4 bars rest
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32 - 8}, gm},
        vt{1, {1, 8}, step},
        vt{1, {1, 16}, step},

        vt{1, {1, 14}, step},
    }

    data.static = {
        -- 32 + 4 bars rest
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 32}, step},
        vt{0, {1, 16}, lin},

        vt{1, {1, 8}, step},
        vt{1, {1, 14}, step},
    }
end

function chant(gst, cnd)
    lil("param [regnxt -1]")
    local r_tubular = pop()
    lilts {
        {"tubularnew", 20.0, -1},
        {"regset", zz, r_tubular},

        {
            "shapemorf",
            gst:get(),
            "[grab lutrm]",
            "[regget " .. r_tubular .. "]",
            "[" .. gst:gmemsymstr("vowshapes") .. "]",
            "[" .. table.concat(cnd:getstr(), " ") .. "]"
        },
    }

    lilts {
        {"regget", r_tubular},
    }

    gesture(sigrunes, gst, "chantpitch", cnd)

    lilts {
        {"param", 33 + 7 - 12},
        {"add", zz, zz},
        {"jitseg", 0.3, -0.3, 0.5, 2, 1},
        {"add", zz, zz},
        {"mtof", zz},
        {"param", 0.3},
        {"param", 0.1},
        {"param", 0.0},
        {"glot", zz, zz, zz, zz},
    }

    gesture(sigrunes, gst, "voxgate", cnd)

    lilts {
        {"envar", zz, 0.1, 0.2},
        {"mul", zz, zz},
        {"tubular", zz, zz, zz},
        {"butlp", zz, 8000},
        -- {"lowshelf", zz, 80, 2, 0.5},
        {"mul", zz, "[dblin -3]"},
    }
end

function static()
    lilts {
        {"chaosnoise", "[rline 0.9 1.8 1]", 120, 0.9},
        {"buthp", zz, 100},
        {"highshelf", zz, 4000, 8, 0.5},
        {"mul", zz, "[dblin -1]"},
    }
end

function hum(gst, cnd)
    lilts {
        {"blsquare", 60},
        {"sine", 5, 1},
        {"biscale", zz, 100, 600},
        {"butlp", zz, zz},
        {"mul", zz, "[dblin -15]"},
    }
    gesture(sigrunes, gst, "humlevel", cnd)
    lil("mul zz zz")
end

function gesture(sr, gst, name, cnd)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr())
    }
end

function bell(gst, cnd)
    gesture(sigrunes, gst, "bell", cnd)
    lilts {
        {"gtick", zz},
        {"tgate", zz, 0.003},
        {"smoother", zz, 0.005},
        -- {"noise"},
        -- {"butlp", zz, 300},
        -- {"butlp", zz, 300},
        -- {"mul", zz, zz},
        {"dup"},

        {"modalres", zz, 400*0.8, 20*0.1},
        {"swap"},
        {"modalres", zz, 450, 20},
        {"add", zz, zz},
        {"mul", zz, "[dblin 3]"},
        -- {"limit", zz, -0.5, 0.5},
        {"dcblocker", zz},
        {"buthp", zz, 60},

        {"dup"},
        -- -- s m
        {"modalres", zz, 300, 200*0.5},
        {"mul", zz, "[dblin -30]"},
        -- m s
        {"swap"},
        -- m s s
        {"dup"},
        -- m s m
        {"modalres", zz, 880, 880*0.5},
        {"mul", zz, "[dblin -16]"},
        -- m m s
        {"swap"},
        -- m m m
        {"modalres", zz, 880*1.321, 880*0.5},
        {"mul", zz, "[dblin -15]"},
        {"add", zz, zz},
        {"add", zz, zz},

        {"dcblocker", zz},
        -- {"mul", zz, "[dblin -18]"},
        {"limit", zz, -0.9, 0.9},
    }
end

function reverb(gst, cnd)
    local brk = sig:new()
    lilts {
        {"dup"},
    }
    gesture(sigrunes, gst, "breakdown", cnd)
    brk:hold()

    brk:get()
    lilts {
        {"expmap", zz, 8},
        {"scale", zz, 1, 60},
        {"softclip", zz, zz},
        {"dup"},
        {"bigverb", zz, zz, 0.97, 10000},
        {"drop"},
        {"dcblocker", zz},
        {"mul", zz, "[dblin -10]"},
    }

    -- lilts {
    --     {"add", 0, 1},
    --     {"sine", 10, 1},
    --     {"biscale", zz, 0, 1}
    -- }
    -- -- brk:get()
    -- lilts {
    --     {"add", 0, 1},
    --     {"expmap", zz, -5},
    --     {"crossfade", zz, zz, zz},
    --     {"mul", zz, zz}
    -- }

    lilts {
        {"add", zz, zz},
    }
    brk:unhold()
end

function ritualmusic.generate_tal(path, tal, data, words)
    tal.label(words, "vowshapes")
    path.path(tal, words, data.test_path, data.lookup)
    tal.jump(words, "vowshapes")

    tal.label(words, "bell")
    tal.interpolate(words, 0)
    path.path(tal, words, data.bell_strike)
    --tal.halt(words)
    --tal.jump(words, "bell")
    tal.jump(words, "hold")

    tal.label(words, "voxgate")
    path.path(tal, words, data.vox_gate)
    --tal.halt(words)
    -- tal.jump(words, "voxgate")
    tal.jump(words, "hold")

    tal.label(words, "chantpitch")
    path.path(tal, words, data.chant_pitch)
    --tal.halt(words)
    --tal.jump(words, "chantpitch")
    tal.jump(words, "hold")

    tal.label(words, "breakdown")
    path.path(tal, words, data.breakdown)
    --tal.halt(words)
    tal.jump(words, "hold")

    tal.label(words, "humlevel")
    path.path(tal, words, data.hum_level)
    --tal.halt(words)
    tal.jump(words, "hold")

    tal.label(words, "reverb")
    path.path(tal, words, data.reverb)
    --tal.halt(words)
    tal.jump(words, "hold")

    tal.label(words, "static")
    path.path(tal, words, data.static)
    --tal.halt(words)
    tal.jump(words, "hold")
end

function ritualmusic.bell(gst, cnd)
    bell(gst, cnd)
end

function ritualmusic.chant(gst, cnd)
    chant(gst, cnd)
end

function ritualmusic.static(gst, cnd)
    static(gst, cnd)
end

function ritualmusic.hum(gst, cnd)
    hum(gst, cnd)
end

function render()
    local rmdata = {}

    local words = {}
    tal.begin(words)
    ritualmusic.generate_gesture_paths(rmdata)

    ritualmusic.generate_tal(path, tal, rmdata, words)

    g = gest:new{tal = tal}
    g:create()
    g:compile(words)

    lilts {
        {"phasor", (153 / 60), 0},
    }

    cnd = sig:new()
    cnd:hold()

    bell(g, cnd)
    static()
    lil("add zz zz")
    chant(g, cnd)
    lil("add zz zz")
    reverb(g, cnd)
    hum(g, cnd)
    lil("add zz zz")
    lil("limit zz -0.99 0.99")

    cnd:unhold()

    lilts {
        {"wavout", "zz", "test.wav"},
        {"computes", 38 + 6.8}
    }
end

-- render()
return ritualmusic
