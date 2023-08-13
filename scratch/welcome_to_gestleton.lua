msgpack = require("util/MessagePack")
pprint = require("util/pprint")
gest = require("gest/gest")
path = require("path/path")
tal = require("tal/tal")
sigrunes = require("sigrunes/sigrunes")
sig = require("sig/sig")
core = require("util/core")

-- make sure to generate msgpack data beforehand from XM
-- file with:
-- mnolth xmt -d scratch/welcome_to_gestleton.xm scratch/welcome_to_gestleton.bin
fp = io.open("scratch/welcome_to_gestleton.bin", "r")
mpbytes = fp:read("*all")
fp:close()
module_data = msgpack.unpack(mpbytes)

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

    for _, pat in pairs(patterns) do
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
    return cells
end

function extract_notes(cells, chan)
    local notes = {}
    local last_note = nil
    local notedur = 1
    for rowpos,row in pairs(cells) do
        local nt = row[chan].note
        if nt ~= nil then
            if nt == 97 then
                nt = -1
            else
                -- FT2 seems to think 72=C4, when it should
                -- be 60=C4
                nt = nt - 12
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
    vtx = path.vertex
    gm = gest.behavior.gliss_medium
    step = gest.behavior.step
    last_pitch = 0

    for idx,nt in pairs(notes) do
        local notenum = nt[1]
        local gateval = 1
        local dur = {4, nt[2]}
        local note_behavior = gm

        if notenum < 0 then
            notenum = last_pitch
            gateval = 0

            -- since this a note off, make note transition
            -- a step

            if idx > 1 then
                p_pitch[idx - 1].bhvr = step
            end

            -- also make this current note a step
            -- a cut in a note probably means you don't want to
            -- gliss to the next note
            note_behavior = step
        end

        table.insert(p_pitch, vtx{notenum, dur, note_behavior})
        table.insert(p_gate, vtx{gateval, dur, step})
        last_pitch = nt[1]
    end

    return p_pitch, p_gate
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

    p_pitch, p_gate = create_paths(notes)

    local voice = chan
    pitch_label = "pitch" .. voice
    gate_label = "gate" .. voice

    voice_data.pitch = p_pitch
    voice_data.gate = p_gate
    voice_data.pitch_label = pitch_label
    voice_data.gate_label = gate_label
    return voice_data
end

words = {}

voices = {}

for chan=1,4 do
    local voice_data = create_voice_data(chan)
    table.insert(voices, voice_data)
end

tal.begin(words)

function compile_voice_sequence(words, voice)
    local pitch_label = voice.pitch_label
    local gate_label = voice.gate_label
    local p_pitch = voice.pitch
    local p_gate = voice.gate
    tal.label(words, pitch_label)
    path.path(tal, words, p_pitch)
    tal.jump(words, pitch_label)
    tal.label(words, gate_label)
    path.path(tal, words, p_gate)
    tal.jump(words, gate_label)
end

vocal_data = voices[1]
--for _, voc in pairs(voices) do
--    compile_voice_sequence(words, voc)
--end
compile_voice_sequence(words, vocal_data)

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

function synthesize_voice(voice_data)
    local pitch_label = voice_data.pitch_label
    local gate_label = voice_data.gate_label
    gesture(sigrunes, G, pitch_label, cnd)

    lilts {
        {"mtof", "zz"},
        {"blsaw", "zz"},
    }

    gesture(sigrunes, G, gate_label, cnd)

    lilts {
        {"envar", "zz", 0.01, 0.1},
        {"mul", "zz", "zz"}
    }

    lilts {
        {"mul", "zz", "[dblin -6]"},
        {"butlp", "zz", "800"}
    }
end

-- for idx, voc in pairs(voices) do
--     synthesize_voice(voc)
--     if idx > 1 then
--         lil("add zz zz")
--     end
-- end
synthesize_voice(vocal_data)

cnd:unhold()
lilts {
    {"wavout", "zz", "test.wav"},
    {"computes", 40}
}
