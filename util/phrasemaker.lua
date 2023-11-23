#! ./cantor
grid = monome_grid
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
monologue = require("monologue/monologue")

mnorealloc(10, 16)
function genvocab(vocab)

    -- before, this used to load the asset every time
    -- (good for live coding). Now it reads data from
    -- a bundle loaded once (good for re-use)
    -- this hack here tries to have it both ways
    if type(vocab) == "string" then
        -- not actually data, but a filename pointing
        -- to data.
        vocab = asset:load(vocab)
    end
    return vocab
end
-- </@>

-- <@>
function genpros()
    local prosody_filename = "prosody/prosody.b64"
    local pros = asset:load(prosody_filename)
    return pros
end
-- </@>

-- <@>
function genphrase(sentence)
    local sentence = sentence or { 1 }
    local phrase = {}
    local reg = {1, 1}

    for _,word in pairs(sentence) do
        table.insert(phrase, {word, reg})
    end

    return phrase
end
-- </@>

-- <@>
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
-- </@>

-- <@>
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
-- </@>

-- <@>
function genphrase_v2(sentence, vocab)
    print("genphrase_v2")

    local sentence = sentence or { 1 }
    local phrase = {}
    local reg = {1, 1}
    local durs = {
        dur1 = {1, 1},
        dur2 = {1, 2},
        dur3 = {1, 3}
    }

    words = split_up_words(sentence, vocab)

    print(#words)
    for _, wrd in pairs(words) do
        local outword = process_word(wrd, vocab, durs)
        pprint(outword)
        table.insert(phrase, outword)
    end

    return phrase
end
-- </@>

-- TODO Centralize this function (see util/inspire.lua)
function mkmouthlut(mouthshapes)
    local lut = {}

    for idx, mth in pairs(mouthshapes) do
        lut[mth.name] = idx
    end

    return lut
end


-- <@>
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

    -- mouthshapes
    local mouthshapes = asset:load("avatar/mouth/mouthshapes1.b64")
    local mouthlut = mkmouthlut(mouthshapes)

    local mono = {
        -- {phrase, neutral},
        {phrase, pros.meter_rise},
        {phrase, pros.meter_fall},
        {phrase, pros.meter_jumps_rise},
        {phrase, pros.meter_jumps_fall},
        {phrase, pros.meter_bigjumps_rise},
        {phrase, pros.meter_jumps_fall},
        -- {phrase, question},
        -- {phrase, some_jumps},
        -- {phrase, deflated},
        -- {phrase, excited},
        -- {phrase, whisper},
    }

    local words = monologue.to_words {
        tal = tal,
        path = path,
        morpheme = morpheme,
        vocab = vocab,
        monologue = mono,
        prosody = pros,
        shapelut = data.lookup,
        mouthshapes = mouthlut
    }
    return words
end
-- <@>

function patch_setup(vocab_filename, shapes_file)
    lilt {"shapemorfnew", "lut", shapes_file}
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
    data.vocab = genvocab(vocab_filename)

    return data
end

-- <@>
function patch(words, data)
    local G = data.G

    G:compile(words)

    G:swapper()
    lilts {
        {"phasor", 60, 0},
    }

    local cnd = sig:new()
    cnd:hold()

    data.gestlingphys.physiology {
        gest = G,
        cnd = cnd,
        lilt = lilt,
        lilts = lilts,
        sigrunes = sigrunes,
        sig = sig,
        core = core,
        use_msgscale = true,
    }

    G:done()
    cnd:unhold()
    valutil.set("msgscale", 1.0 / (3*60))
end
-- </@>

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

function sound(phrasebook_file, vocab_filename, shapes_file, phys)
    rtsetup()
    local data = patch_setup(vocab_filename, shapes_file)
    data.gestlingphys = phys
    words = genwords(data, genphrase())
    patch(words, data)
    valutil.set("msgscale", 1.0 / (2*60))
    fp = io.open(phrasebook_file)
    phrasebook = {}

    for ln in fp:lines() do
        table.insert(phrasebook, ln)
    end
    fp:close()
    data.phrasebook = phrasebook
    data.gestlingphys = phys
    lil("out")
    return data
end

function bitrune_setup(data, uf2_file, keyshapes_file, phrases_file)
    data.m = grid.open("/dev/ttyACM0")
    data.br = bitrune.new(uf2_file, keyshapes_file, phrases_file)
    bitrune.terminal_setup(data.br)
end


-- TODO load from character data file via CLI

if #arg < 3 then
    print("Usage: phrasemaker characters/foo.b64 vocab/foo/pb_foo.txt vocab/foo/p_foo.b64")
    error("not enough args")
end

local charfile = arg[1]
local character = asset:load(charfile)
--local character = asset:load("characters/junior.b64")
-- TODO make this work with the character phrasebook
--local phrasebook_file = "vocab/junior/pb_junior_verses.txt"
local phrasebook_file = arg[2]
--local phrases_file = "vocab/junior/p_junior_verses.b64"
local phrases_file = arg[3]
local vocab_filename = character.vocab
local uf2_file = character.uf2
local keyshapes_file = character.keyshapes
local shapes_file = character.shapes
gestlingphys = dofile(character.physiology)

gestling_data = sound(phrasebook_file,
                      vocab_filename,
                      shapes_file,
                      gestlingphys)
bitrune_setup(gestling_data, uf2_file, keyshapes_file, phrases_file)

--<@>
function eval_sentence(phrase, vocab_filename)
    gestling_data.vocab = genvocab(vocab_filename)
    local words = genwords(gestling_data, phrase)
    patch(words, gestling_data)
    lil("out")
end
--</@>

-- <@>
function coord(x, y)
    return ((y - 1) * 8) + x
end

-- <@>
function altrun(vocab_filename)
    --local vocab_filename = "vocab/junior/v_junior.b64"
    local dat = gestling_data
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
            print(phrase)
            -- pprint(sentence)
            -- local split_words = split_up_words(sentence, dat.vocab)
            -- pprint(split_words)
            -- pprint(process_word(split_words[2], vocab))
            --genphrase_v2(sentence, dat.vocab)
            if #sentence > 0 then
                print("eval")
                eval_sentence(genphrase_v2(sentence, dat.vocab), vocab_filename)
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
    local dat = gestling_data
    local br = dat.br
    print("bye")
    bitrune.terminal_reset(br)
    bitrune.del(br)
    grid.close(dat.m)
end
--</@>

altrun(vocab_filename)
quit()
