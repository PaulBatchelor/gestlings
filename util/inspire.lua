#! ./cantor
core = require("util/core")
lilt = core.lilt
lilts = core.lilts
json = require("util/json")
mouth = require("avatar/mouth/mouth")
sdfdraw = require("avatar/sdfdraw")

descript = require("descript/descript")

pprint = require("util/pprint")
local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
gest = require("gest/gest")
tal = require("tal/tal")
morpheme = require("morpheme/morpheme")
path = require("path/path")
monologue = require("monologue/monologue")
sigrunes = require("sigrunes/sigrunes")
sig = require("sig/sig")

messagebox = {}
function messagebox.new()
    local buf = {}

    local lines = {}
    for i=1,4 do lines[i] = "" end

    buf.lines = lines
    buf.linepos = 1
    buf.scale = 1
    buf.font = "chicago"
    buf.nphrases = 4
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

function draw_textline(txt, ypos, font, scale)
    lilt {
        "uf2txtln",
        "[bpget [grab bp] 0]",
        "[grab " .. font .. " ]",
        0, ypos,
        "\"" .. txt .. "\"",
        scale
    }
end

function messagebox.draw(buf, lheight)
    lilt {"bpfill", "[bpget [grab bp] 0]", 0}
    for idx, line in pairs(buf.lines) do
        draw_textline(line, (idx-1)*lheight*buf.scale, buf.font, buf.scale)
    end
end

function messagebox.loadfont(fontname, filepath)
    lilt {"uf2load", fontname, filepath}
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

function setup(inspire)
    load_fonts()
    local buf = messagebox.new()
    local gestling_name = inspire.gestling_name

    lil("sdfvmnew vm")

    lil("grab vm")
    vm = pop()
    inspire.vm = vm
    syms = sdfdraw.load_symbols(json)

    -- TODO rework placeholder avatar
    local trixie = mktrixie(vm, syms, 1)
    
    local mouthshapes = asset:load("avatar/mouth/mouthshapes1.b64")
    -- really only used to access specific shapes
    -- (right now it's "rest")
    trixie.mouthshapes = mkmouthtab(mouthshapes)

    -- used to generate monologue
    trixie.mouthlut = mkmouthlut(mouthshapes)

    -- used for shape lookup in avatar draw
    trixie.mouthidx = mkmouthidx(mouthshapes)

    buf.font = "fountain"

    -- lilt {"bpnew", "bp", 240, 60}
    lilt {"bpnew", "bp", 240, 320}
    lilt {"gfxnewz", "gfx", 240, 320, 1}
    lil("grab gfx; dup")
    lil("gfxopen tmp/" .. gestling_name .. ".h264")
    lil("gfxclrset 1 1.0 1.0 1.0")
    lil("gfxclrset 0 0.0 0.0 0.0")

    lil("drop")
    msgbox_width = 224
    window_padding = 4
    padding = 4 + window_padding
    -- to avoid rounded edges
    ylift = 4
    xcenter = (240 // 2) - (msgbox_width // 2) + padding
    -- message box
    lilt {
        "bpset",
        "[grab bp]", 0,
        xcenter, (320 - 60 - ylift) + padding,
        msgbox_width - 2*padding,
        60 - 2*padding
    }

    local avatar_padding = window_padding + 8
    -- avatar
    lilt {
        "bpset",
        "[grab bp]", 1,
        avatar_padding, avatar_padding,
        240 - 2*avatar_padding,
        (320 - 60) - 2*avatar_padding
    }

    -- window (canvas)
    lilt {
        "bpset",
        "[grab bp]", 2,
        window_padding, window_padding,
        240 - 2*window_padding, 320 - 2*window_padding
    }

    inspire.buf = buf
    inspire.trixie = trixie
    inspire.mouth = sqrcirc
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
function setup_sound(inspire)
    local gestling_name = inspire.gestling_name
    local character = inspire.character
    local phrases = inspire.phrases
    local phrasebook_id = inspire.phrasebook_name
    lil("blkset 49")
    lil("valnew msgscale")

    phrasebook_id = phrasebook_id or "default"
    print("phrasebook: " .. phrasebook_id)

    lil("shapemorfnew lut " .. character.shapes)
    lil("grab lut")
    local lut = pop()
    local lookup = shapemorf.generate_lookup(lut)
    local vocab = character.vocab
    local pb = character.phrasebook[phrasebook_id]
    local phrasebook = pb.phrases
    local gst = gest:new()
    local prostab = asset:load("prosody/prosody.b64")
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

    local words = monologue.to_words {
        tal = tal,
        path = path,
        morpheme = morpheme,
        vocab = vocab,
        monologue = mono,
        shapelut = lookup,
        mouthshapes = inspire.trixie.mouthlut
    }

    gst:compile(words)

    gst:swapper()
    lilts {
        {"phasor", 60, 0},
    }
    local cnd = sig:new()
    cnd:hold()

    local phys = dofile(character.physiology)
    local physdat = phys.physiology {
        gest = gst,
        cnd = cnd,
        lilt = lilt,
        lilts = lilts,
        sigrunes = sigrunes,
        sig = sig,
    }

    inspire.physdat = physdat

    gst:done()
    cnd:unhold()
    lil("wavout zz tmp/" .. gestling_name .. ".wav")
    valutil.set("msgscale", 1.0/30)
end


function process_block(block, t, rate, events)
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
                local cmd = core.split(cmdstr, " ")

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

-- AVATAR PLACEHOLDER CODE

function mksinger(vm, syms, name, id, bufsize)
    local singer = {
    }

    -- bufsize = bufsize or 256
    -- singer.bufname = name
    -- lilt {"bufnew", singer.bufname, bufsize}
    -- lilt {"grab", singer.bufname}
    -- singer.bytebuf = pop()
    singer.id = id

    singer.renderer = sdfdraw.mkrenderer(syms, singer.bufname, bufsize)
    return function(program)
        -- sdfdraw.generate_bytecode(syms, program, singer.bytebuf)
        singer.renderer:generate_bytecode(program)
        return singer
    end
end

function avatar_draw(vm, singer, mouth_x, mouth_y)
    -- local mouth = singer.open
    local m1 = nil
    local m2 = nil
    local mouth = nil

    local mouthshapes = singer.mouthshapes
    --local mouthvals = {mouthshapes.open, mouthshapes.close}
    local mouthvals = singer.mouthidx

    local cur, nxt, pos = gestvm_last_values(mouth_x)
    -- print(cur, nxt)
    m1 = mouthvals[cur]
    m2 = mouthvals[nxt]
    mouth = singer.sqrcirc:interp(m1, m2, pos)
    local cur, nxt, pos = gestvm_last_values(mouth_y)
    cur = cur / 0xFF
    nxt = nxt / 0xFF
    pos = (1 - pos)*cur + pos*nxt
    mouth = singer.sqrcirc:interp(mouthshapes.rest, mouth, pos)

    -- TODO re-introduce mouth interpolation using gesture
    singer.sqrcirc:apply_shape(vm, mouth)

    singer.renderer:draw(
        string.format("[bpget [grab bp] %d]", singer.id),
        "[grab vm]"
    )
end

--- placeholder avatar stuff
function mktrixie(vm, syms, id)
    local scale = 0.6
    local sqrcirc = mouth:squirc()

    local singer = mksinger(vm, syms, "trixie", id, 512) {
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

    singer.sqrcirc = sqrcirc

    return singer
end

function process_video(inspire, nframes)
    local evdata = {}
    local trixie = inspire.trixie

    local events = inspire.events
    local buf = inspire.buf
    local vm = inspire.vm

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

        -- hard-coded line height for now
        local lheight = 12
        messagebox.draw(buf, lheight)
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
        avatar_draw(vm,
            trixie,
            inspire.physdat.mouth_x,
            inspire.physdat.mouth_y
        )
        if (n == (60*1.7)) then
            lil("bppng [grab bp] tmp/screenshot.png")
        end
        lilt{"bptr", "[grab bp]", xoff, yoff, 240, 320, 0, 0, 0}
        lil("gfxzoomit")
        lil("grab gfx; dup")
        lil("gfxtransferz; gfxappend")
    end
end

function parse_script(script_txt)
    local events = {}

    fp = io.open(script_txt)
    assert(fp ~= nil, "couldn't open: " .. script_txt)
    script = fp:read("*all")
    fp:close()

    local dialogue = descript.parse(script)

    local t = 1
    local rate = 4
    phrases = {}
    last_nphrases = -1
    local character = {}
    local phrasebook_name = "default"
    local segmode = false
    local segments = {}
    local seglen = 1
    for _, block in pairs(dialogue) do
        -- TODO: convert into look-up table
        if block[1] == "block" then
            local start_time = t
            local start_pos = #events + 1
            t, rate = process_block(block, t, rate, events)
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
            local cmd = core.split(block[1], " ")
            textscale(events, t, tonumber(cmd[2]))
        elseif string.match(block[1], "^nphrases") ~= nil then
            local cmd = core.split(block[1], " ")
            last_nphrases = tonumber(cmd[2])
            nphrases(events, t, last_nphrases)
        elseif string.match(block[1], "^phrasebook") ~= nil then
            local cmd = core.split(block[1], " ")
            phrasebook_name = cmd[2]
        elseif string.match(block[1], "^phrase") ~= nil then
            local cmd = core.split(block[1], " ")
            table.insert(phrases, {cmd[2], cmd[3]})
            if segmode then
                print("inserting segment of length " .. seglen)
                table.insert(segments, seglen)
            end
        elseif string.match(block[1], "^character") ~= nil then
            local cmd = core.split(block[1], " ")
            print("using character '" .. cmd[2] .. "'")
            character = asset:load("characters/" .. cmd[2] .. ".b64")
        elseif string.match(block[1], "^font") ~= nil then
            local cmd = core.split(block[1], " ")
            set_font(events, t, cmd[2])
        elseif string.match(block[1], "^segmode") ~= nil then
            segmode = true
            segments = {}
        elseif string.match(block[1], "^seglen") ~= nil then
            local cmd = core.split(block[1], " ")
            seglen = tonumber(cmd[2])
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

function close_video(gestling_name)
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

function generate_mp4(gestling_name)
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

function inspire_init(script_txt, gestling_name)
    local inspire = {}
    local events, character, phrases, phrasebook_name = parse_script(script_txt)
    inspire.buf = buf
    inspire.events = events
    inspire.character = character
    inspire.phrases = phrases
    inspire.phrasebook_name = phrasebook_name
    inspire.gestling_name = gestling_name
    setup(inspire)
    return inspire
end

function main(script_txt, gestling_name)
    --events, character, phrases, phrasebook_name = parse_script(script_txt)
    -- setup_sound(gestling_name, character, phrases, phrasebook_name)
    inspire = inspire_init(script_txt, gestling_name)
    setup_sound(inspire)
    -- first pass to get duration
    nframes = process_video(inspire, -1)
    -- process_video(nframes, events)
    process_video(inspire, nframes)
    close_video(gestling_name)
    generate_mp4(gestling_name)
    ::bye::
end

if #arg < 2 then
    error("Usage: inspire dialogue.txt name")
end

main(arg[1], arg[2])

