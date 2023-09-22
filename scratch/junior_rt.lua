--[[
-- <@>
dofile("scratch/junior_rt.lua")
-- </@>
--]]

local grid = monome_grid
core = require("util/core")
sig = require("sig/sig")
lilts = core.lilts
lilt = core.lilt
pprint = require("util/pprint")
gest = require("gest/gest")
path = require("path/path")
tal = require("tal/tal")
morpheme = require("morpheme/morpheme")
sigrunes = require("sigrunes/sigrunes")
local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
local monologue = require("monologue/monologue")
local juniorphys = require("physiology/phys_junior")

-- <@>
function genvocab()
    local vocab = asset:load("vocab/junior/v_junior.b64")
    return vocab[1]
end
-- </@>

-- <@>
function genpros()
    local pros = asset:load("prosody/prosody.b64")
    return pros
end
-- </@>

-- <@>
function genphrase(sentence)
    local dur_reg = {1, 1}
    local dur_short = {3, 2}
    local dur_long = {2, 3}

    local sentence = sentence or { 1 }
    local phrase = {}
    local reg = {1, 1}

    for _,word in pairs(sentence) do
        table.insert(phrase, {word, reg})
    end

    return phrase
end
-- </@>

function genwords(data, phrase)
    local lookup = data.lookup
    local vocab = data.vocab
    pros = genpros()

    local question = pros.question
    local neutral = pros.neutral
    local whisper = pros.whisper
    local some_jumps = pros.some_jumps
    local deflated = pros.deflated
    local excited = pros.excited

    local mono = {
        {phrase, neutral},
        {phrase, question},
        {phrase, some_jumps},
        {phrase, deflated},
        {phrase, excited},
        {phrase, whisper},
    }

    local words = monologue.to_words {
        tal = tal,
        path = path,
        morpheme = morpheme,
        vocab = vocab,
        monologue = mono,
        prosody = pros,
        shapelut = data.lookup
    }
    return words
end

function patch_setup()
    lil("shapemorfnew lut shapes/junior.b64")
    lil("grab lut")
    lut = pop()

    lookup = shapemorf.generate_lookup(lut)
    lil("blkset 49")
    lil("valnew msgscale")
    local G = gest:new()
    G:create()
    local data = {}

    data.G = G
    data.lut = lut
    data.lookup = shapemorf.generate_lookup(lut)
    data.vocab = genvocab()

    return data
end

function patch(words, data)
    local G = data.G

    G:compile(words)

    G:swapper()
    lilts {
        {"phasor", 60, 0},
    }

    local cnd = sig:new()
    cnd:hold()

    juniorphys.physiology {
        gest = G,
        cnd = cnd,
        lilt = lilt,
        lilts = lilts,
        sigrunes = sigrunes,
        sig = sig,
    }

    G:done()
    cnd:unhold()
end

function rtsetup()
lil([[
hsnew hs
rtnew [grab hs] rt
# I'm pretty sure you can't crossfade with gestlive
hscf [grab hs] 0

func out {} {
    hsout [grab hs]
    hsswp [grab hs]
}

func playtog {} {
    hstog [grab hs]
}
]])
end

function sound()
    rtsetup()
    local data = patch_setup()
    words = genwords(data, genphrase())
    patch(words, data)
    valutil.set("msgscale", 1.0 / (2*60))
    fp = io.open("vocab/junior/pb_junior.txt")
    phrasebook = {}

    for ln in fp:lines() do
        table.insert(phrasebook, ln)
    end
    fp:close()
    data.phrasebook = phrasebook
    lil("out")
    return data
end

function bitrune_setup(data)
    data.m = grid.open("/dev/ttyACM0")
    data.br = bitrune.new("fonts/junior.uf2",
                          "vocab/junior/k_junior.bin",
                          "vocab/junior/p_junior.b64")
    bitrune.terminal_setup(data.br)
end


junior_data = sound()
bitrune_setup(junior_data)

--<@>
function eval_sentence(sentence)
    junior_data.vocab = genvocab()
    local words = genwords(junior_data, genphrase(sentence))
    patch(words, junior_data)
    lil("out")
end
--</@>

-- <@>
function coord(x, y)
    return ((y - 1) * 8) + x
end

function run()
    print("run")
    local wrds = {
        coord(6, 3),
        coord(7, 3),
        coord(8, 3),
        coord(1, 4),
        coord(2, 4),
        coord(3, 4),
    }
    -- local sent = {wrds[1], wrds[2], wrds[1], 1}

    local sent = {}

    for _, w in pairs({1, 2, 3, 4, 5, 6}) do
        table.insert(sent, wrds[w])
    end
    table.insert(sent, 1)
    junior_data.vocab = genvocab()
    local words = genwords(junior_data, genphrase(sent))
    patch(words, junior_data)
    lil("out")
end
-- </@>
-- <@>
function altrun()
    local dat = junior_data
    local br = dat.br
    local m = dat.m
    local zeroquad = {0, 0, 0, 0, 0, 0, 0, 0}
    print("running bitrune")

    bitrune.start(br)
    bitrune.update_display(br)
    while bitrune.running(br) do
        local events = grid.get_input_events(m)
        for _,e in pairs(events) do
            if e[3] == 1 then
                print(e[1], e[2])
                bitrune.monome_press(br, e[1], e[2] - 8)
            end
        end
        local chars = bitrune.getchar()

        for _,c in pairs(chars) do
            bitrune.process_input(br, c)
        end

        if bitrune.message_available(br) then
            local msg = bitrune.message_pop(br)
            print(msg)
            msg = core.split(msg, " ")
            sentence = {}
            for _,word in pairs(msg) do
                table.insert(sentence, tonumber(word, 16))
            end
            local linepos = bitrune.linepos(br)
            local phrase = dat.phrasebook[linepos + 1]
            pprint(sentence)
            print("phrase: " .. phrase)
            if #sentence > 0 then
                eval_sentence(sentence)
            end
        end
        if bitrune.please_draw(br) then
            bitrune.update_display(br)
            bitrune.draw(br)
            local quadL, quadR = bitrune.quads(br)

            -- clears top quad LEDs on zero
            grid.update(m, zeroquad, zeroquad)
            grid.update_zero(m, quadL, quadR)
        end
        grid.usleep(80)
    end
    print("stopping bitrune")
    grid.all(m, 0)
end
-- </@>
function quit()
    local dat = junior_data
    local br = dat.br
    print("bye")
    bitrune.terminal_reset(br)
    bitrune.del(br)
    grid.close(dat.m)
end

--</@>

