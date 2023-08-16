msgpack = require("util/MessagePack")
pprint = require("util/pprint")
gest = require("gest/gest")
path = require("path/path")
tal = require("tal/tal")
sigrunes = require("sigrunes/sigrunes")
sig = require("sig/sig")
core = require("util/core")
ritualmusic = require("scratch/ritual_music")

-- make sure to generate msgpack data beforehand from XM
-- file with:
-- mnolth xmt -d scratch/welcome_to_gestleton.xm scratch/welcome_to_gestleton.bin
fp = io.open("scratch/welcome_to_gestleton.bin", "r")
mpbytes = fp:read("*all")
fp:close()
module_data = msgpack.unpack(mpbytes)

lil("shapemorfnew lut scratch/yahshapes2.b64")
-- lil("shapemorfnew lut shapes/tubesculpt_testshapes.b64")
lil("grab lut")
lut = pop()
lookup = shapemorf.generate_lookup(lut)


-- might be the other way around

-- yahshapes 1
-- shape_close = "d46393"
-- shape_open = "5d75c6"

-- yahshapes 2
shape_close = "639be4"
shape_open = "d8d9f5"

for k,v in pairs(lookup) do
    print(k, v)
end

-- for k,v in pairs(module_data.header.ptable) do
--     print(k)
-- end

-- pprint(module_data.header.ptable)
-- pprint(module_data.header.song_length)

function getbyte(data, pos)
    local b = data[pos]
    pos = pos + 1
    return b, pos
end

function getcell(patdata, pos)
    b, pos = getbyte(patdata, pos)
    cell = {}

    if (b & 0x80) then
        if ((b & 0x01) > 0) then
            cell.note, pos = getbyte(patdata, pos)
        end
        if ((b & 0x02) > 0) then
            cell.instr, pos = getbyte(patdata, pos)
        end
        if ((b & 0x04) > 0) then
            cell.vol, pos = getbyte(patdata, pos)
        end
        if ((b & 0x08) > 0) then
            cell.effect, pos = getbyte(patdata, pos)
        end
        if ((b & 0x10) > 0) then
            cell.param, pos = getbyte(patdata, pos)
        end
    else
        cell.note = b
    end

    return cell, pos
end

function extract_cells(patterns)
    local cells = {}
    local nchans = module_data.header.nchannels
    local songlen = module_data.header.song_length
    local ptable = module_data.header.ptable

    -- for _, pat in pairs(patterns) do
    for i=1,songlen do
        local pat = patterns[ptable[i] + 1]

        if pat ~= nil then
            -- local patdata = patterns[1].data
            local patdata = pat.data
            local pos = 1
            local currow = {}
            while (pos <= #patdata) do
                cell, pos = getcell(patdata, pos)
                table.insert(currow, cell)
                if (#currow == nchans) then
                    table.insert(cells, currow)
                    currow = {}
                end
            end
        end
    end
    return cells
end

function extract_notes(cells, chan)
    local notes = {}
    local last_note = nil
    local notedur = 1
    local transpose = 5
    for rowpos,row in pairs(cells) do
        local nt = row[chan].note
        if nt ~= nil then
            if nt == 97 then
                nt = -1
            else
                -- FT2 seems to think 72=C4, when it should
                -- be 60=C4
                nt = nt - 12

                -- change the key, if we want to
                nt = nt + transpose

                if chan == 4 or chan == 3 then
                    nt = nt - 12
                end
            end
            if last_note ~= nil then
                table.insert(notes, {last_note, notedur})
            end
            last_note = nt
            notedur = 1
        else
            notedur = notedur + 1
            -- print("-")
        end
    end
    if last_note ~= nil then
        table.insert(notes, {last_note, notedur})
    end
    return notes
end

function create_paths(notes)
    local p_pitch = {}
    local p_gate = {}
    local p_retrig = {}
    vtx = path.vertex
    gm = gest.behavior.gliss_medium
    -- there is no gliss_small yet
    gs = gest.behavior.gliss_medium
    step = gest.behavior.step
    g50 = gest.behavior.gate_50
    last_pitch = 0
    local shp = {shape_close, shape_open}

    for idx,nt in pairs(notes) do
        local notenum = nt[1]
        local gateval = 1
        local dur = {4, nt[2]}
        local note_behavior = gm
        local retrig_behavior = g50
        local yahstate = 0

        if notenum < 0 then
            notenum = last_pitch
            gateval = 0

            -- since this a note off, make note transition
            -- a step

            if idx > 1 then
                p_pitch[idx - 1].bhvr = step
            end

            -- also keep the 'ya'-nvelope open
            --
            if idx > 1 then
                -- retrig has 3 segments
                local ridx = 3*(idx - 1)
                p_retrig[ridx].bhvr = step
                -- p_retrig[ridx].val = 1 --shp[1]
                p_retrig[ridx].val = shp[1 + 1] -- open

                -- keep this rest segment open too
                yahstate = 1
            end

            -- also make this current note a step
            -- a cut in a note probably means you don't want to
            -- gliss to the next note
            note_behavior = step
            retrig_behavior = step
        end

        table.insert(p_pitch, vtx{notenum, dur, note_behavior})
        table.insert(p_gate, vtx{gateval, dur, step})

        -- the 'ya' envelope shape:
        -- take the note and split it two parts
        -- first part: 'ah' (open), gliss
        -- second part: 'yi' (closed), gliss

        retrig_dur1 = {dur[1]*4, dur[2]*3}
        retrig_dur1[1] = retrig_dur1[1] * 2
        retrig_dur2 = {dur[1]*4, dur[2]*1}

        table.insert(p_retrig, vtx{shp[1 + 1], retrig_dur1, step})
        table.insert(p_retrig, vtx{shp[1 + 1], retrig_dur1, gs})
        table.insert(p_retrig, vtx{shp[yahstate + 1], retrig_dur2, gs})
        if nt[1] > 0 then
            last_pitch = nt[1]
        end
    end

    return p_pitch, p_gate, p_retrig
end

function lilt(tab)
    lil(table.concat(tab, " "))
end

function lilts(lines)
    for _, line in pairs(lines) do
        lilt(line)
    end
end

function create_voice_data(chan)
    local voice_data = {}

    local patterns = module_data.patterns
    local cells = extract_cells(module_data.patterns)
    local notes = extract_notes(cells, chan)

    p_pitch, p_gate, p_retrig = create_paths(notes)

    local voice = chan
    local pitch_label = "pitch" .. voice
    local gate_label = "gate" .. voice
    local retrig_label = "retrig" .. voice

    voice_data.pitch = p_pitch
    voice_data.gate = p_gate
    voice_data.retrig = p_retrig
    voice_data.pitch_label = pitch_label
    voice_data.gate_label = gate_label
    voice_data.retrig_label = retrig_label
    voice_data.id = chan
    return voice_data
end

words = {}

voices = {}

for chan=1,4 do
    local voice_data = create_voice_data(chan)
    table.insert(voices, voice_data)
end

tal.begin(words)
tal.label(words, "hold")
tal.halt(words)
tal.jump(words, "hold")

function compile_voice_sequence(words, voice)
    local pitch_label = voice.pitch_label
    local gate_label = voice.gate_label
    local retrig_label = voice.retrig_label
    local p_pitch = voice.pitch
    local p_gate = voice.gate
    local p_retrig = voice.retrig

    -- pitch program
    tal.label(words, pitch_label)
    path.path(tal, words, p_pitch)
    --tal.jump(words, pitch_label)
    tal.jump(words, "hold")

    -- gate program
    tal.label(words, gate_label)
    path.path(tal, words, p_gate)
    -- tal.jump(words, gate_label)
    -- tal.halt(words)
    tal.jump(words, "hold")

    -- retrig program
    tal.label(words, retrig_label)
    -- tal.interpolate(words, 0)
    path.path(tal, words, p_retrig, lookup)
    -- tal.jump(words, retrig_label)
    -- tal.halt(words)
    tal.jump(words, "hold")
end

for _, voc in pairs(voices) do
    compile_voice_sequence(words, voc)
end

-- pprint(words)
rmdata = {}
ritualmusic.generate_gesture_paths(rmdata)
ritualmusic.generate_tal(path, tal, rmdata, words)

G = gest:new()
G:create()
G:compile(words)

lilts {
    {"phasor", (153 / 60), 0},
}

cnd = sig:new()
cnd:hold()

function gesture(sr, gst, name, cnd)
    sr.node(gst:node()){
        name = name,
        conductor = core.liln(cnd:getstr())
    }
end

cutoffs = {
    4000, 3000, 3000, 2000
}

levels = {
    -4, -3, -3, 0
}

vibs = {
    {6.5, 0.5}, {6.4, 0.3}, {6.3, 0.7}, {6.3, 0.1}
}

tract_sizes = {
    8, 12, 17, 20
}

tract_effort = {
    0.4, 0.3, 0.6, 0.8
}

breathiness = {
    {0.1, 0.1}, {0.2, 0.2}, {0.05, 0.05}, {0.05, 0.05}
}

oversample = {
    4, 4, 3, 3
}

highpass = {
    500, 300, 100, 30
}

lowpass = {
    3000, 4000, 4000, 5000
}

function synthesize_voice(voice_data, gst, cnd)
    local pitch_label = voice_data.pitch_label
    local gate_label = voice_data.gate_label
    local retrig_label = voice_data.retrig_label
    local local_cnd = cnd

    local vid = voice_data.id
    cnd:get()
    lilts {
        {"param", 1.0},
        {"jitseg", 0.98, 1.02, 1, 3, 1},
        {"jitseg", 0, 0.3, 0.5, 1, 1},
        {"crossfade", "zz", "zz", "zz"},
        {"rephasor", "zz", "zz"}
    }

    local jitcnd = sig:new()
    jitcnd:hold()
    local_cnd = jitcnd

    lilts {
        {"tubularnew", tract_sizes[vid], oversample[vid]},
        {"regset", "zz", 4},
        {"regmrk", 4},
    }

    lilts {
        {"shapemorf",
            gst:get(),
            "[grab lut]",
            "[regget 4]",
            "[" .. gst:gmemsymstr(retrig_label) .. "]",
            "[" .. table.concat(local_cnd:getstr(), " ") .. "]"
        },
    }

    lilt {"regget", 4}

    gesture(sigrunes, gst, pitch_label, local_cnd)

    lilts {
        {"sine", vibs[vid][1], vibs[vid][2]},
        {"add", "zz", "zz"},
        {"mtof", "zz"},
        {"param", tract_effort[vid]},
        {"param", breathiness[vid][1]},
        {"param", breathiness[vid][2]},
        {"glot", "zz", "zz", "zz", "zz"}
        -- {"blsaw", "zz"},
    }

    lilts {
        {"tubular", "zz", "zz"},
        {"butlp", "zz", lowpass[vid]},
        {"buthp", "zz", highpass[vid]},
        {"regclr", 4},
    }

    gesture(sigrunes, gst, gate_label, local_cnd)

    lilts {
        {"envar", "zz", 0.05, 0.2},
        {"mul", "zz", "zz"}
    }


    lilts {
        {"mul", "zz", "[dblin " .. levels[vid] .."]"},
    }

    -- gesture(sigrunes, gst, retrig_label, local_cnd)

    -- -- lil("dup; mul zz 0.5; wavout zz retrig.wav")
    -- lilts {
    --     -- {"gtick", "zz"},
    --     -- {"env", "zz", 0.01, 0.01, 0.1},
    --     {"scale", "zz", cutoffs[vid]*0.05, cutoffs[vid]*1.0},
    --     {"butlp", "zz", "zz"}
    -- }
    --
    --


    if (local_cnd ~= cnd) then
        local_cnd:unhold()
    end
end

for idx, voc in pairs(voices) do
    synthesize_voice(voc, G, cnd)
    if idx > 1 then
        lil("add zz zz")
    end
end
lil("dcblocker zz")
lil("mul zz [dblin -7]")


ritualmusic.bell(G, cnd)
lil("add zz zz")
ritualmusic.chant(G, cnd)
lil("add zz zz")

noiseamt = sig:new()
gesture(sigrunes, G, "static", cnd)
noiseamt:hold()

ritualmusic.static(G, cnd)
noiseamt:get()
lil("mul zz zz")
lil("add zz zz")

lil("dup")
lil("vardelay zz 0.0 0.1 0.5")

gesture(sigrunes, G, "breakdown", cnd)
brk = sig:new()
brk:hold()
brk:get()
core.lilts {
    {"expmap", zz, 8},
    {"scale", zz, 1, 60},
    {"softclip", zz, zz},
}    
brk:unhold()
lil("dup")
gesture(sigrunes, G, "reverb", cnd)
revamt = sig:new()
revamt:hold()

lil("param 0.85")
lil("param 0.97")
revamt:get()
lil("crossfade zz zz zz")

lil("param 7000")
lil("param 10000")
revamt:get()
lil("crossfade zz zz zz")
lil("bigverb zz zz zz zz")
lil("drop")
lil("dcblocker zz")

lil("param -13")
lil("param -10")
revamt:get()
lil("crossfade zz zz zz")
revamt:unhold()
lil("dblin zz")
lil("mul zz zz")

ritualmusic.hum(G, cnd)
noiseamt:get()
lil("mul zz zz")
lil("add zz zz")
noiseamt:unhold()

lil("add zz zz")

cnd:unhold()
lilts {
    {"wavout", "zz", "test.wav"},
    {"computes", 101.3}
}

::quit::
return nil
