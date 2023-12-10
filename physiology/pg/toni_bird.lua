core = require("util/core")
lilt = core.lilt
lilts = core.lilts
sig = require("sig/sig")
sigrunes = require("sigrunes/sigrunes")
phystoni = require("physiology/phys_toni")
gest = require("gest/gest")
asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
morpheme = require("morpheme/morpheme")
monologue = require("monologue/monologue")
tal = require("tal/tal")
path = require("path/path")


mnorealloc(10, 16)

function genvocab()
    return asset:load("vocab/toni/v_toni.b64")
end

-- <@>
function patch(phystoni, gst)
    local pt = phystoni.create {
        sig = sig,
    }

    lilt {"phasor",
        string.format("[rline %g %g 0.3]", 1/2, 1/4),
        0
    }
    local cnd = sig:new()
    cnd:hold_cabnew()

    phystoni.physiology {
        core = core,
        sig = sig,
        gst = gst,
        cnd = cnd,
    }
    cnd:unhold()
end

function patch_debug(phystoni, gst)
    local pt = phystoni.create {
        sig = sig,
    }

    -- lilt {"phasor",
    --     string.format("[rline %g %g 0.3]", 1/2, 1/4),
    --     0
    -- }
    lilt {"phasor", 60, 0}
    local cnd = sig:new()
    cnd:hold_cabnew()

    lil("valnew msgscale")
    valutil.set("msgscale", 1.0 / (3*60))
    phystoni.physiology {
        core = core,
        sig = sig,
        gst = gst,
        cnd = cnd,
        use_msgscale = true,
    }
    cnd:unhold()
end
-- </@>

-- <@>
function coord(x, y)
    return (y - 1)*8 + x
end
-- </@>

-- <@>
function genproofword()
    return phrase
end
-- </@>

-- <@>
function apply_call_sequence(call_sequence, pros_sequence)
    local pros_pos = 1
    for _, call in pairs(call_sequence) do
        if pros_pos > #pros_sequence then
            pros_pos = 1
        end
        pros_sequence[pros_pos](call)
        pros_pos = pros_pos + 1
    end
end
function mkmonologue(shapelut)
    local prostab = asset:load("prosody/prosody.b64")

    dlong = {1, 2}
    dshort = {1, 1}
    dshorter = {2, 1}

    local w = {
        test = coord(2, 1),
        silence = coord(1, 1),
        wh_long = coord(3, 1),
        p_shp_a = coord(4, 1),
        p_shp_b = coord(5, 1),
        wh_mel1 = coord(6, 1),
        wh_mel2 = coord(7, 1),
        wh_mel3 = coord(8, 1),
        wh_mel4 = coord(1, 2),
        wh_mel5 = coord(2, 2),
        wh_rise = coord(3, 2),
    }

    local call_a = {
        {w.wh_mel2, dshort},
        {w.wh_long, dshort},
        {w.wh_mel3, dlong},
        {w.silence, dshort},
    }

    local call_b = {
        {w.wh_mel2, dshort},
        {w.wh_long, dshort},
        {w.wh_mel1, dlong},
        {w.silence, dshort},
    }

    local call_c = {
        {w.wh_mel2, dshorter},
        {w.wh_mel2, dshorter},
        {w.wh_mel2, dshorter},
        {w.wh_mel1, dlong},
        {w.wh_long, dshort},
        {w.silence, dshort},
    }

    local call_d = {
        {w.wh_mel4, dlong},
        {w.wh_mel3, dshorter},
        {w.silence, dshort},
    }

    local call_e = {
        {w.wh_mel5, dlong},
        {w.wh_long, dshorter},
        {w.wh_mel4, dshorter},
        {w.silence, dshort},
    }

    local call_f = {
        {w.wh_mel5, dshorter},
        {w.wh_mel1, dshorter},
        {w.wh_mel1, dshorter},
        {w.silence, dlong},
    }

    local call_g = {
        {w.wh_rise, dlong},
        {w.silence, dlong},
    }

    local space = {
        {w.silence, dshort},
    }

    mono = {}

    mono_insert = function(call, pros)
        table.insert(mono, {call, pros})
    end

    prosfun = function(pros)
        return function(call)
            mono_insert(call, pros)
        end
    end

    question = prosfun(prostab.question)
    neutral = prosfun(prostab.neutral)
    excited = prosfun(prostab.excited)
    jumps = prosfun(prostab.some_jumps)

    local spaces = {
        space, space, space, space
    }

    local call_sequence = {
        call_d, space, space,
        call_c, space,
        call_b, space, space,
        call_a, space,
        call_a, space
    }

    local call_sequence_2 = {
        call_g,
        call_f, call_f, space,
        call_f, space, space,
        call_e, space, space,
    }

    local pros_sequence = {
        neutral, jumps,
        question, neutral,
        neutral, neutral,
        excited, neutral,
    }


    apply_call_sequence(spaces, pros_sequence)
    apply_call_sequence(call_sequence, pros_sequence)
    apply_call_sequence(spaces, pros_sequence)
    apply_call_sequence(call_sequence_2, pros_sequence)

    local vocab = genvocab()

    head = {
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

    local words = monologue.to_words {
        tal = tal,
        path = path,
        morpheme = morpheme,
        vocab = vocab,
        monologue = mono,
        head = head,
        shapelut = shapelut,
    }

    print("program size: ", #words)
    return words
end
-- </@>

function setup()
    -- shapemorf stuff
    local shape_fname = "shapes/s_toni.b64"
    lil("shapemorfnew lut " .. shape_fname)
    lil("grab lut")
    local lut = pop()
    local shapelut = shapemorf.generate_lookup(lut)

    -- gestvm stuff
    local gst = gest:new {
        tal = tal,
        sigrunes = sigrunes,
        core = core,
    }
    gst:create()

    local o = {}

    o.gst = gst
    o.shapelut = shapelut

    return o
end

function debug_score(shapelut)
    local prostab = asset:load("prosody/prosody.b64")

    dlong = {1, 2}
    dshort = {1, 1}
    dshorter = {2, 1}

    local w = {
        test = coord(2, 1),
        silence = coord(1, 1),
        wh_long = coord(3, 1),
        p_shp_a = coord(4, 1),
        p_shp_b = coord(5, 1),
        wh_mel1 = coord(6, 1),
        wh_mel2 = coord(7, 1),
        wh_mel3 = coord(8, 1),
        wh_mel4 = coord(1, 2),
        wh_mel5 = coord(2, 2),
        wh_rise = coord(3, 2),
    }

    local clickpat_a = coord(4, 1)

    local call_a = {
        {w.wh_mel2, dshort},
        {w.wh_long, dshort},
        {w.wh_mel3, dlong},
        {w.silence, dshort},
    }

    local debug_call = {
        {clickpat_a, dshort},
        {w.silence, dshort},
    }

    print(coord(7, 1))
    local debug_call_2 = {
        {7, {1, 2}},
        -- {4, {1, 1}},
        {1, {1, 1}},
    }

    local space = {
        {w.silence, dshort},
    }

    mono = {}

    mono_insert = function(call, pros)
        table.insert(mono, {call, pros})
    end

    prosfun = function(pros)
        return function(call)
            mono_insert(call, pros)
        end
    end

    question = prosfun(prostab.question)
    neutral = prosfun(prostab.neutral)
    excited = prosfun(prostab.excited)
    jumps = prosfun(prostab.some_jumps)

    local spaces = {
        space, space, space, space
    }

    local call_sequence = {
        call_d, space, space,
        call_c, space,
        call_b, space, space,
        call_a, space,
        call_a, space
    }

    local call_sequence_2 = {
        call_g,
        call_f, call_f, space,
        call_f, space, space,
        call_e, space, space,
    }

    local pros_sequence = {
        neutral, jumps,
        question, neutral,
        neutral, neutral,
        excited, neutral,
    }

    debug_sequence = {
        debug_call_2, debug_call_2, debug_call_2
    }

    apply_call_sequence(debug_sequence, pros_sequence)

    local vocab = genvocab()

    head = {
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

    local words = monologue.to_words {
        tal = tal,
        path = path,
        morpheme = morpheme,
        vocab = vocab,
        monologue = mono,
        head = head,
        shapelut = shapelut,
    }

    print("program size: ", #words)
    return words
end

function sound(dat)
    -- generate gestvm program
    local shapelut = dat.shapelut
    local gst = dat.gst
    local words = mkmonologue(shapelut)
    gst:compile(words)
    gst:swapper()
    patch(phystoni, gst)
    gst:done()
end

function sound_debug(dat)
    local shapelut = dat.shapelut
    local gst = dat.gst
    local words = debug_score(shapelut)
    gst:compile(words)
    gst:swapper()
    patch_debug(phystoni, gst)
    gst:done()
end
-- </@>

function generate_filename(w)
    return string.format("tmp/toni_proof/toni_%d_%d.wav", w[1], w[2])
end

function render()
    local ToniData = setup()
    -- sound(ToniData)
    sound_debug(ToniData)
    lilt {
        "wavout", "zz", "tmp/toni_bird.wav"
    }
    lil("computes 10")
end

-- <@>
function run ()
    render()
end
-- </@>

run()
