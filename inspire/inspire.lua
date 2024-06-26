messagebox = {}
Inspire = {}
function messagebox.new()
    local buf = {}

    local lines = {}
    for i=1,4 do lines[i] = "" end

    buf.lines = lines
    buf.linepos = 1
    buf.scale = 1
    buf.font = "chicago"
    buf.nphrases = 4
    buf.draw_avatar = true
    return buf
end

function messagebox.append(buf, ch)
    if buf.lines[buf.linepos] == nil then
        error("NIL: " .. buf.linepos)
    end
    buf.lines[buf.linepos] =
        buf.lines[buf.linepos] .. ch
end

function messagebox.remove(buf)
    buf.lines[buf.linepos] =
        string.sub(buf.lines[buf.linepos], 1, -2)
end

function messagebox.newline(buf)
    buf.linepos = buf.linepos + 1
end

function messagebox.clear(buf)
    for i=1,4 do buf.lines[i] = "" end
    buf.linepos = 1
end

function draw_textline(txt, ypos, font, scale, lilt)
    lilt {
        "uf2txtln",
        "[bpget [grab bp] 0]",
        "[grab " .. font .. " ]",
        0, ypos,
        "\"" .. txt .. "\"",
        scale
    }
end

function messagebox.draw(buf, lheight, lilt)
    lilt {"bpfill", "[bpget [grab bp] 0]", 0}
    for idx, line in pairs(buf.lines) do
        draw_textline(line, (idx-1)*lheight*buf.scale, buf.font, buf.scale, lilt)
    end
end

function messagebox.loadfont(fontname, filepath)
    local uf2load_cmd = {"uf2load", fontname, filepath}
    lil(table.concat(uf2load_cmd, " "))
end

function load_fonts()
    messagebox.loadfont("chicago", "fonts/chicago12.uf2")
    messagebox.loadfont("fountain_joined", "fonts/fountain_joined.uf2")
    messagebox.loadfont("fountain", "fonts/fountain.uf2")
    messagebox.loadfont("protorunes", "fonts/protorunes.uf2")
    messagebox.loadfont("plotter", "fonts/plotter.uf2")
end

local function mkmouth(name)
    return function(shape)
        local mth = {}
        mth.name = name
        mth.shape = shape
        return mth
    end
end

function mkmouthtab(mouthshapes)
    local lut = {}
    for _, mth in pairs(mouthshapes) do
        lut[mth.name] = mth.shape
    end

    return lut
end

function mkmouthlut(mouthshapes)
    local lut = {}

    for idx, mth in pairs(mouthshapes) do
        lut[mth.name] = idx
    end

    return lut
end

function mkmouthidx(mouthshapes)
    local lut = {}

    for idx, mth in pairs(mouthshapes) do
        lut[idx] = mth.shape
    end

    return lut
end

function setup(inspire, modules)
    load_fonts()
    modules = modules or {}
    local buf = messagebox.new()
    local gestling_name = inspire.gestling_name

    local mod_sdfdraw = sdfdraw or modules.sdfdraw
    local mod_json = json or modules.json
    local mod_asset = asset or modules.asset
    local mod_core = core or modules.core
    local mod_anatomy = anatomy or modules.anatomy
    local mod_eye = eye or modules.eye

    local lilt = mod_core.lilt
    local lilts = mod_core.lilts
    local audio_only = inspire.audio_only

    lil("sdfvmnew vm")

    lil("grab vm")
    vm = pop()
    inspire.vm = vm
    syms = mod_sdfdraw.load_symbols(mod_json)

    buf.font = "fountain"

    -- lilt {"bpnew", "bp", 240, 60}
    lilt {"bpnew", "bp", 240, 320}
    lilt {"gfxnewz", "gfx", 240, 320, 1}
    if audio_only == false then
        lil("grab gfx; dup")
        lil("gfxopen tmp/" .. gestling_name .. ".h264")
        lil("gfxclrset 1 1.0 1.0 1.0")
        lil("gfxclrset 0 0.0 0.0 0.0")
        lil("drop")
    end
    msgbox_width = 224
    window_padding = 4
    padding = 4 + window_padding
    -- to avoid rounded edges
    ylift = 4
    xcenter = (240 // 2) - (msgbox_width // 2) + padding
    -- message box
 
    buf.draw_avatar = true
    lilt {
        "bpset",
        "[grab bp]", 0,
        xcenter, (320 - 60 - ylift) + padding,
        msgbox_width - 2*padding,
        60 - 2*padding
    }

    -- window (canvas)
    lilt {
        "bpset",
        "[grab bp]", 2,
        window_padding, window_padding,
        240 - 2*window_padding, 320 - 2*window_padding
    }

    inspire.avatar_dims = avatar.setup(lilt)
    inspire.buf = buf
    buf.inspire = inspire
    local ec = nil

    if inspire.character.anatomy.eye ~= nil then
        ec = mod_eye.name_to_eye(inspire.character.anatomy.eye)
    end

    inspire.anatomy_controller = mod_anatomy.new({
        syms = syms,
        vm = vm,
        sdfdraw = sdfdraw,
        avatar = avatar,
        lilt = lilt,
        shader = inspire.character.anatomy.shader,
        asset = asset,
        mouth_controller =
            mouth.name_to_mouth(inspire.character.anatomy.mouth),
        eye_controller = ec,
        mouth_scale = inspire.character.anatomy.mouth_scale
    })

    mod_anatomy.generate_avatar(inspire.anatomy_controller)
end

function new_event(t, name, data)
    return {t, name, data}
end

function append(events, t, ch)
    table.insert(events, new_event(t, "append", ch))
end

function remove(events, t, ch)
    table.insert(events, new_event(t, "remove"))
end

function newline(events, t)
    table.insert(events, new_event(t, "newline", nil))
end

function pause(events, t)
    table.insert(events, new_event(t, "pause", nil))
end

function clear(events, t)
    table.insert(events, new_event(t, "clear", nil))
end

function textscale(events, t, scale)
    table.insert(events, new_event(t, "scale", scale))
end

function nphrases(events, t, n)
    table.insert(events, new_event(t, "nphrases", n))
end

function blockdur_data(dur, nphrases)
    local data = {}
    data.dur = dur
    data.nphrases = nphrases
    return data
end

function blockdur(events, t, dur, pos, nphrases)
    local data = blockdur_data(dur, nphrases)
    table.insert(events, pos, new_event(t, "blockdur", data))
end

function set_font(events, t, n)
    table.insert(events, new_event(t, "set_font", n))
end

function set_draw_avatar(events, t, n)
    table.insert(events, new_event(t, "set_draw_avatar", n))
end

function set_varibounce(events, t, val)
    table.insert(events, new_event(t, "set_varibounce", val))
end

function set_bouncerate(events, t, val)
    table.insert(events, new_event(t, "set_bouncerate", val))
end

function set_bounceamp(events, t, val)
    table.insert(events, new_event(t, "set_bounceamp", val))
end

function set_bouncereset(events, t, vals)
    table.insert(events, new_event(t, "set_bouncereset", vals))
end

function set_eyespeed(events, t, speed)
    table.insert(events, new_event(t, "set_eyespeed", speed))
end

function set_eyestate(events, t, state)
    table.insert(events, new_event(t, "set_eyestate", state))
end

-- for this trailer, the symbols have virtually
-- no grammer. every value is a 'word', and
-- each word has the same duration. there are no
-- partial morphemes
function sentence_to_phrase(sentence)
    local phrase = {}
    local dur = {1, 1}
    for _,wrd in pairs(sentence) do
        table.insert(phrase, {wrd, dur})
    end
    print("sentence to phrase")
    return phrase
end

function split_up_words(sentence, vocab)
    local words = {}
    local last_word = {}

    for _, letter in pairs(sentence) do
        local v = vocab[letter]
        assert(v ~= nil)
        if v.tok ~= nil and v.tok == "divider" then
            table.insert(words, last_word)
            last_word = {}
        else
            table.insert(last_word, letter)
       end
    end

    return words
end

function process_word(word, vocab, durs)
    local outword = {-1, {1, 1}}

    for _, c in pairs(word) do
        assert(vocab[c] ~= nil)
        local tok = vocab[c].tok
        local d = {1, 1}
        if tok ~= nil and durs[tok] ~= nil then
            outword[2] = durs[tok]
        else
            if outword[1] < 0 then
                outword[1] = c
            else
                if outword[3] == nil then
                    outword[3] = {}
                end

                table.insert(outword[3], c)
            end
        end
    end

    return outword
end

function poetic_phrase(sentence, vocab)
    local sentence = sentence or { 1 }
    local phrase = {}
    local reg = {1, 1}
    local durs = {
        dur1 = {1, 1},
        dur2 = {1, 2},
        dur3 = {1, 3}
    }

    words = split_up_words(sentence, vocab)

    for _, wrd in pairs(words) do
        local outword = process_word(wrd, vocab, durs)
        table.insert(phrase, outword)
    end

    return phrase
end

-- function setup_sound(gestling_name, character, phrases, phrasebook_id)
function Inspire.setup_sound(inspire, modules)
    local gestling_name = inspire.gestling_name
    local character = inspire.character
    local phrases = inspire.phrases
    local phrasebook_id = inspire.phrasebook_name
    modules = modules or {}
    lil("blkset 49")
    lil("valnew msgscale")

    phrasebook_id = phrasebook_id or "default"
    print("phrasebook: " .. phrasebook_id)
    local mod_gest = gest or modules.gest
    local mod_tal = tal or modules.tal
    local mod_asset = asset or modules.asset
    local mod_monologue = monologue or modules.monologue
    local mod_morpheme = morpheme or modules.morpheme
    local mod_path = path or modules.path
    local mod_core = core or modules.core
    local lilts = mod_core.lilts
    local lilt = mod_core.lilt
    local mod_sig = sig or modules.sig
    local mod_sigrunes = sigrunes or modules.sigrunes

    lil("shapemorfnew lut " .. character.shapes)
    lil("grab lut")
    local lut = pop()
    local lookup = shapemorf.generate_lookup(lut)
    local vocab = character.vocab
    local pb = character.phrasebook[phrasebook_id]
    local phrasebook = pb.phrases
    local gst = mod_gest:new {
        tal = mod_tal,
        sigrunes = mod_sigrunes,
        core = mod_core
    }
    local prostab = mod_asset:load("prosody/prosody.b64")
    gst:create()

    local mono = {}

    for _, phr in pairs(phrases) do
        local sentence = phrasebook[phr[1]]
        assert(sentence ~= nil,
            "Could not find phrase '" .. phr[1] .. "'")
        -- a "sentence" is just a collection of symbols
        -- these will need to be converted to the phrase
        -- format an array of tuples consisting of
        -- (word, duration, partial_morphemes)
        -- this isn't done beforehand because the
        -- symbols are needed for notation

        -- different characters will have different
        -- grammars most likely, so that will need
        -- to be consolidated somehow
        -- this one is quite rudimentary
        local phrase = nil
        if pb.notation == "simple" then
            phrase = sentence_to_phrase(sentence)
        elseif pb.notation == "poetic" then
            phrase = poetic_phrase(sentence, character.vocab)
        else
            error("notation system not supported: " .. pb.notation)
        end

        -- the converted phrase can now be added to the
        -- "monologue" format used to create gesture
        -- programs. It is paired with the prosody

        local pros = prostab[phr[2]]

        assert(pros ~= nil,
            "Could not find prosody curve '" .. phr[2] .. "'")
        table.insert(mono, {phrase, pros})
    end

    local head = nil
    local phys = dofile(character.physiology)

    if phys.tal_head ~= nil then
        head = phys.tal_head { tal = mod_tal }
    end

    local av = inspire.anatomy_controller.avatar_controller
    local words = mod_monologue.to_words {
        tal = mod_tal,
        path = mod_path,
        morpheme = mod_morpheme,
        vocab = vocab,
        monologue = mono,
        shapelut = lookup,
        mouthshapes = av.mouthlut,
        head = head
    }

    gst:compile(words)

    gst:swapper()
    lilts {
        {"phasor", 60, 0},
    }
    local cnd = mod_sig:new()
    cnd:hold()

    local physdat = phys.physiology {
        gest = gst,
        cnd = cnd,
        lilt = lilt,
        lilts = lilts,
        sigrunes = mod_sigrunes,
        sig = mod_sig,
        core = mod_core,
        use_msgscale = true,
    }

    inspire.physdat = physdat

    gst:done()
    cnd:unhold()
    lil("wavout zz tmp/" .. gestling_name .. ".wav")
    valutil.set("msgscale", 1.0/30)
end


function process_block(block, t, rate, events, split)
    clear(events, t)
    for i =2,#block do
        line = block[i]
        local c = 1
        while c <= #line do
            ::top::
            local ch = string.char(string.byte(line, c))
            if ch == "<" then
                local cmdstr = ""
                c = c + 1
                ch = string.char(string.byte(line, c))
                while (ch ~= ">") do
                    cmdstr = cmdstr .. ch
                    c = c + 1
                    ch = string.char(string.byte(line, c))
                end
                local cmd = split(cmdstr, " ")

                if cmd[1] == "PAUSE" then
                    pause(events, t)
                    t = t + rate*tonumber(cmd[2])
                elseif cmd[1] == "BACKSPACE" then
                    local ntimes = tonumber(cmd[2])

                    for i=1,ntimes do
                        remove(events, t)
                        t = t + rate
                    end
                elseif cmd[1] == "RATE" then
                    rate = tonumber(cmd[2])
                elseif cmd[1] == "EYESPEED" then
                    -- TODO change eye speed
                    local speed = tonumber(cmd[2])
                    print("eyespeed " ..  tonumber(cmd[2]))
                    set_eyespeed(events, t, speed)
                elseif cmd[1] == "EYE" then
                    -- apply eye states
                    local eyestates = {}
                    for i=2,#cmd do
                        table.insert(eyestates, cmd[i])
                    end
                    set_eyestate(events, t, eyestates)
                else
                    error("invalid inline command: " .. cmd[1])
                end

                c = c + 1
                -- ch = string.char(string.byte(line, c))
                goto top
            end
            append(events, t, ch)
            t = t + rate
            c = c + 1
        end
        newline(events, t)
    end
    return t, rate
end

function process_events(evdata, buf, n)
    local event_handler = evdata.event_handler
    while (evdata.evpos <= #evdata.events) and (evdata.last_event[1] <= n) do
        local f = event_handler[evdata.last_event[2]]

        if f ~= nil then
            f(buf, evdata.last_event[3])
        else
            error("unknown event " .. evdata.last_event[2])
        end

        evdata.evpos = evdata.evpos + 1

        if evdata.evpos > #evdata.events then
            evdata.last_event = nil
            break
        end

        evdata.last_event = evdata.events[evdata.evpos]
    end
end

function mktrixie(vm, syms, id, modules)
    local mod_mouth = mouth or modules.mouth
    local scale = 0.6
    local sqrcirc = mod_mouth:squirc()
    local mod_avatar = avatar or modules.avatar
    local mod_core = core or modules.core
    local lilt = mod_core.lilt
    -- TODO: save to disk as data, and store in character data bundle
    local shader = {
        {
            "point",
            "vec2", 0.45*scale, -0.33*scale, "add2",
            "scalar", 0.4*scale, "circle"
        },
        "scalar 0 regset",
        "scalar 0 regget",
        {"scalar", 0.02*scale, "onion"},
        {
            "point",
            "vec2", 0.45*scale, -0.33*scale, "add2",
            "scalar", 0.15*scale, "circle",
            "add"
        },
        "gtz",

        {
            "point",
            "vec2", -0.45*scale, -0.33*scale, "add2",
            "scalar", 0.4*scale, "circle"
        },
        "scalar 1 regset",
        "scalar 1 regget",
        {"scalar", 0.02*scale, "onion"},
        {
            "point",
            "vec2", -0.45*scale, -0.33*scale, "add2",
            "scalar", 0.15*scale, "circle",
            "add"
        },
        "gtz",

        "add",

        "point",
        {"vec2", 0.65*scale, 0.5*scale, "ellipse"},
        {"scalar", 0.02*scale, "onion"},
        "scalar 0 regget scalar 1 regget",
        "add",
        "swap subtract",
        "add",

        sqrcirc:generate(scale, 0.8, 0.05, {0, 0.3}),

        "add",
        -- "point vec2 0.75 0.6 ellipse gtz",
        "gtz",
    }

    -- asset:save(shader, "tmp/a_junior.b64")
    -- shader = asset:load("tmp/a_junior.b64")
    local singer =
        mod_avatar.mkavatar(sdfdraw, vm, syms, "trixie", id, 512, lilt)(shader)

    singer.sqrcirc = sqrcirc

    return singer
end

function Inspire.process_video(inspire, nframes, modules)
    local evdata = {}
    -- local trixie = inspire.trixie

    local events = inspire.events
    local buf = inspire.buf
    local vm = inspire.vm
    local ac = inspire.anatomy_controller

    modules = modules or {}
    local mod_core = core or modules.core
    local lilt = mod_core.lilt
    local mod_avatar = core or modules.avatar
    local audio_only = inspire.audio_only
    local mod_anatomy = anatomy or modules.anatomy

    local event_handler = {
        append = function(mb, data)
            messagebox.append(mb, data)
        end,

        newline = function(mb, data)
            messagebox.newline(mb)
        end,

        pause = function(mb, data)
            -- kill time
        end,

        clear = function(mb, data)
            messagebox.clear(mb)
        end,

        remove = function(mb, data)
            messagebox.remove(mb)
        end,

        scale = function(mb, data)
            mb.scale = data
        end,

        blockdur = function(mb, data)
            local dur = data.dur
            local nphrases = data.nphrases
            assert(nphrases > 0, "invalid nphrases amount")
            valutil.set("msgscale", nphrases / dur)
        end,

        nphrases = function(mb, n)
            mb.nphrases = n
        end,

        set_font = function(mb, font)
            mb.font = font
        end,

        set_draw_avatar = function(mb, state)
            mb.draw_avatar = state
        end,

        set_varibounce = function(mb, state)
            mb.inspire.varibounce = state
        end,

        set_bouncerate = function(mb, val)
            -- lots of deep reaching here...
            local ac = mb.inspire.anatomy_controller
            local av = ac.avatar_controller
            local bouncer = av.bouncer
            bouncer.set_rate(bouncer, val)
        end,

        set_bounceamp = function(mb, val)
            -- lots of deep reaching here...
            local ac = mb.inspire.anatomy_controller
            local av = ac.avatar_controller
            local bouncer = av.bouncer
            bouncer.set_amp(bouncer, val)
        end,

        set_bouncereset = function(mb, vals)
            local ac = mb.inspire.anatomy_controller
            local av = ac.avatar_controller
            local bouncer = av.bouncer
            bouncer.reset(bouncer, vals.rate, vals.amp)
        end,

        set_eyespeed = function(mb, speed)
            local ac = mb.inspire.anatomy_controller
            local ec = ac.eye_controller
            if ec ~= nil then
                ec:lerp_speed(speed)
            end
        end,
        set_eyestate = function(mb, state)
            local ac = mb.inspire.anatomy_controller
            local ec = ac.eye_controller
            if ec ~= nil then
                ec:apply(state)
            end
        end,
    }

    evdata.events = events
    evdata.event_handler = event_handler
    evdata.evpos = 1
    evdata.last_event = evdata.events[evdata.evpos]

    if nframes < 0 then
        nframes_max = 60*60*3 -- 3 minutes
        nframes = 1
        while (nframes < nframes_max) do
            process_events(evdata, buf, nframes)
            nframes = nframes + 1
            if evdata.evpos > #evdata.events then
                evdata.last_event = nil
                break
            end
        end
        return nframes
    end

    -- local xoff = 320//2 - 200//2
    -- local yoff = 240//2 - 60//2
    local xoff = 0
    local yoff = 0

    for n=1,nframes do
        if (n % 60) == 0 then
            print(n, string.format("%02d%%", math.floor(n*100/nframes)))
        end

        process_events(evdata, buf, n)
        lil("compute 15")

        if audio_only == false then
            -- hard-coded line height for now
            local lheight = 12
            messagebox.draw(buf, lheight, lilt)
            lil("grab gfx; dup")
            lilt{"gfxrectf", xoff, yoff, 240, 320, 1}
            lil("dup")
            -- TODO padding info in data somewhere
            -- right now, it's in two places (DRY)
            window_padding = 4
            lilt{
                "bproundrect",
                "[bpget [grab bp] 2]",
                0, 0,
                240 - 2*window_padding, 320 - 2*window_padding,
                16, 1
            }

            msgbox_divider = (320 - 60 - 8)
            lilt {
                "bpline",
                "[bpget [grab bp] 2]",
                0, msgbox_divider,
                240, msgbox_divider,
                1
            }
            -- lil("bpoutline [bpget [grab bp] 1] 1")
            if buf.draw_avatar == true then
                -- mod_avatar.draw(vm,
                --     trixie,
                --     inspire.physdat.mouth_x,
                --     inspire.physdat.mouth_y,
                --     inspire.avatar_dims,
                --     n
                -- )
                if inspire.varibounce then
                    mod_anatomy.update_bounce(ac)
                end
                mod_anatomy.draw(ac,
                    inspire.physdat.mouth_x,
                    inspire.physdat.mouth_y,
                    inspire.avatar_dims,
                    n
                )

            end
            lilt{"bptr", "[grab bp]", xoff, yoff, 240, 320, 0, 0, 0}
            lil("gfxzoomit")
            lil("grab gfx; dup")
            lil("gfxtransferz; gfxappend")
        end
    end
end

function parse_script(script_txt, modules)
    modules = modules or {}
    local events = {}

    fp = io.open(script_txt)
    assert(fp ~= nil, "couldn't open: " .. script_txt)
    script = fp:read("*all")
    fp:close()

    local mod_descript = descript or modules.descript
    local dialogue = mod_descript.parse(script)
    local mod_core = core or modules.core
    local mod_asset = asset or modules.asset

    local t = 1
    local rate = 4
    phrases = {}
    last_nphrases = -1
    local character = {}
    local phrasebook_name = "default"
    local segmode = false
    local segments = {}
    local seglen = 1
    local split = mod_core.split
    for _, block in pairs(dialogue) do
        -- TODO: convert into look-up table
        if block[1] == "block" then
            local start_time = t
            local start_pos = #events + 1
            t, rate = process_block(block, t, rate, events, split)
            local end_time = t
            local total_dur = end_time - start_time

            -- segment mode!
            -- the main idea is to get segments in a block with
            -- various lengths
            -- each phrase segment would get a proportional
            -- value using a "phraselen" command
            -- then, each phrase would get their own
            -- blockdur event.
            -- the proportional values would be used to calculate
            -- each phrase duration in units of frames. Any
            -- "leftover" frames get appeneded to the last
            -- phrase.
            -- segment mode would explicitely turned on
            -- before adding phrases, then turned off
            -- after the block command
            

            if segmode then
                print("we are in segmode!")
                assert(last_nphrases == #segments,
                    string.format("segment (%d)/nphrases (%d) mismatch",
                        #segments, last_nphrases))

                local total_seglen = 0
                local nsegs = #segments

                -- compute sum of all segments
                for _,v in pairs(segments) do
                    total_seglen = total_seglen + v
                end

                assert(total_seglen > 0, "invalid seglen")
                local frames_per_unit = total_dur // total_seglen

                local toffset = 0

                for idx, seg in pairs(segments) do
                    local segframes = seg*frames_per_unit

                    if idx == nsegs then
                        segframes = total_dur - toffset
                    end

                    -- sweep through event list and insert
                    -- in order

                    local t = start_time + toffset
                    for i=start_pos, #events do
                        if (i < #events) then
                            local cur = events[i]
                            local nxt = events[i + 1]

                            if t >= cur[1] and t <= nxt[1] then
                                local data = blockdur_data(segframes, 1)
                                table.insert(events, i + 1,
                                    new_event(t, "blockdur", data))
                                break
                            end
                        else
                            -- if it's the largest, just
                            -- append at the end
                            print("appending at end")
                        end
                    end
                    -- blockdur(events, 
                    --     start_time + toffset,
                    --     segframes,
                    --     start_pos + (idx - 1),
                    --     1)
                    toffset = toffset + segframes
                end
                -- reset
                segmode = false
                segments = {}
                seglen = 1
            else
                blockdur(events, start_time, total_dur, start_pos, last_nphrases)
            end

        elseif string.match(block[1], "^scale") ~= nil then
            local cmd = split(block[1], " ")
            textscale(events, t, tonumber(cmd[2]))
        elseif string.match(block[1], "^nphrases") ~= nil then
            local cmd = split(block[1], " ")
            last_nphrases = tonumber(cmd[2])
            nphrases(events, t, last_nphrases)
        elseif string.match(block[1], "^phrasebook") ~= nil then
            local cmd = split(block[1], " ")
            phrasebook_name = cmd[2]
        elseif string.match(block[1], "^phrase") ~= nil then
            local cmd = split(block[1], " ")
            table.insert(phrases, {cmd[2], cmd[3]})
            if segmode then
                print("inserting segment of length " .. seglen)
                table.insert(segments, seglen)
            end
        elseif string.match(block[1], "^character") ~= nil then
            local cmd = split(block[1], " ")
            print("using character '" .. cmd[2] .. "'")
            character = mod_asset:load("characters/" .. cmd[2] .. ".b64")
        elseif string.match(block[1], "^font") ~= nil then
            local cmd = split(block[1], " ")
            set_font(events, t, cmd[2])
        elseif string.match(block[1], "^segmode") ~= nil then
            segmode = true
            segments = {}
        elseif string.match(block[1], "^seglen") ~= nil then
            local cmd = split(block[1], " ")
            seglen = tonumber(cmd[2])
        elseif string.match(block[1], "^noavatar") ~= nil then
            set_draw_avatar(events, t, false)
        elseif string.match(block[1], "^varibounce") ~= nil then
            set_varibounce(events, t, true)
        elseif string.match(block[1], "^bouncerate") ~= nil then
            local cmd = split(block[1], " ")
            set_bouncerate(events, t, tonumber(cmd[2]))
        elseif string.match(block[1], "^bounceamp") ~= nil then
            local cmd = split(block[1], " ")
            set_bounceamp(events, t, tonumber(cmd[2]))
        elseif string.match(block[1], "^bouncereset") ~= nil then
            local cmd = split(block[1], " ")
            local vals = {}
            vals.rate = tonumber(cmd[2])
            vals.amp = tonumber(cmd[3])
            set_bouncereset(events, t, vals)
        else
            local cmd = split(block[1], " ")
            error("Invalid command: " .. cmd[1])
        end
    end

    local last = -1
    for idx,e in pairs(events) do
        if e[1] < last then
            error(string.format("ruh-roh %d < %d", e[1], last))
        end
        last = e[1]
    end

    -- TODO create table to hold these values
    return events, character, phrases, phrasebook_name
end

function Inspire.close_video(gestling_name, modules)
    local mod_core = core or modules.core
    local lilts = mod_core.lilts
    lilts {
        {"grab", "gfx"},
        {"gfxclose"},
        {
            "gfxmp4",
            "tmp/" .. gestling_name .. ".h264",
            "tmp/" .. gestling_name .. "_nosound.mp4"
        },
    }
end

function Inspire.audio_only(inspire)
    inspire.audio_only = true
end

function Inspire.generate_mp4(gestling_name)
    ffmpeg_args = {
        "export AV_LOG_FORCE_NOCOLOR=1;",
        "ffmpeg",
        "-hide_banner", "-loglevel", "error", "-y",
        "-i", "tmp/" .. gestling_name .. "_nosound.mp4",
        "-i", "tmp/" .. gestling_name .. ".wav",
        "-pix_fmt", "yuv420p",
        "-acodec", "aac",
        "-b:a", "320k",
        "res/" .. gestling_name .. ".mp4"
    }
    os.execute(table.concat(ffmpeg_args, " "))
end


-- a quick and dirty way to load all the required modules
-- simply dump them in a table and have the functions
-- read from this as a fallback
-- note that if a module name is globlly defined (assumed
-- previously loaded), it will use that before loading
function Inspire.load_modules()
    local m = {}
    m.descript = descript or require("descript/descript")
    m.core = core or require("util/core")

    if asset == nil then
        local asset = require("asset/asset")
        local asset = asset:new{
            msgpack = require("util/MessagePack"),
            base64 = require("util/base64")
        }
        m.asset = asset
    else
        m.asset = asset
    end

    m.sdfdraw = sdfraw or require("avatar/sdfdraw")
    m.json = json or require("util/json")
    m.mouth = mouth or require("avatar/mouth/mouth")
    m.avatar = avatar or require("avatar/avatar")
    m.tal = tal or require("tal/tal")
    m.gest = gest or require("gest/gest")
    m.monologue = monologue or require("monologue/monologue")
    m.morpheme = monologue or require("morpheme/morpheme")
    m.path = path or require("path/path")
    m.sig = sig or require("sig/sig")
    m.sigrunes = sigrunes or require("sigrunes/sigrunes")
    m.anatomy = anatomy or require("avatar/anatomy/anatomy")
    m.eye = eye or require("avatar/eye/eye")
    return m
end

function Inspire.parse_script(script_txt, modules)
    return parse_script(script_txt, modules)
end

function Inspire.init(script_txt, gestling_name, modules)
    local inspire = {}
    modules = modules or {}
    local events, character, phrases, phrasebook_name =
        parse_script(script_txt, modules)
    inspire.buf = buf
    inspire.events = events
    inspire.character = character
    inspire.phrases = phrases
    inspire.phrasebook_name = phrasebook_name
    inspire.gestling_name = gestling_name
    inspire.audio_only = false
    inspire.varibounce = false
    return inspire
end

function Inspire.setup(inspire, modules)
    modules = modules or {}
    setup(inspire, modules)
end

return Inspire
