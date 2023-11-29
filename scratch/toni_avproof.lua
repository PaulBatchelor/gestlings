
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
pprint = require("util/pprint")

function genvocab()
    return asset:load("vocab/toni/v_toni.b64")
end

-- <@>
function patch(phystoni, gst)
    local pt = phystoni.create {
        sig = sig,
    }

    -- lilt {"phasor", 1/4, 0}
    lilt {"phasor", 1/3, 0}
    local cnd = sig:new()
    cnd:hold_cabnew()

    phystoni.physiology {
        core = core,
        sig = sig,
        gst = gst,
        cnd = cnd
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
function genproofword(word)
    dlong = {1, 2}
    dshort = {1, 1}

    local w = {
        test = coord(1, 1),
        silence = coord(2, 1),
        wh_long = coord(3, 1),
        p_shp_a = coord(4, 1),
        p_shp_b = coord(5, 1),
        wh_mel1 = coord(6, 1),
        wh_mel2 = coord(7, 1),
        wh_mel3 = coord(8, 1),
    }

    local silence = coord(1, 1)
    local word = coord(word[1], word[2])
    local phrase = {
        {word, dlong},
        {silence, dshort},
    }

    return phrase
end
-- </@>

-- <@>
function mkmonologue(shapelut, word)
    local prostab = asset:load("prosody/prosody.b64")

    local phrase = genproofword(word)

    mono = {
        {phrase, prostab.neutral},
    }

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

-- <@>
function sound(dat, word)
    -- generate gestvm program
    local shapelut = dat.shapelut
    local gst = dat.gst
    local words = mkmonologue(shapelut, word)
    gst:compile(words)
    gst:swapper()
    patch(phystoni, gst)
    gst:done()
end
-- </@>

function generate_filename(w)
    return string.format("tmp/toni_proof/toni_%d_%d.wav", w[1], w[2])
end

function render_word(w)
    local ToniData = setup()
    print(string.format("rendering (%d, %d)", w[1], w[2]))
    sound(ToniData, w)
    lilt {
        "wavout", "zz", generate_filename(w)
    }
    lil("computes 3.5")
end

-- <@>
function generate_sounds (words)
    local filenames = {}
    local word_wavs = {}

    os.execute("mkdir -p tmp/toni_proof/")
    for _,w in pairs(words) do
        render_word(w)
        table.insert(filenames, string.format("tmp/%d.wav", w[1]))
        table.insert(filenames, string.format("tmp/%d.wav", w[2]))
        local wwav = generate_filename(w)
        table.insert(filenames, wwav)
        table.insert(word_wavs, wwav)
        mnoreset()
    end

    sox_cmd =
        "sox " ..
        table.concat(filenames, " ") ..
        " tmp/toni_proof/proof.wav"

    os.execute(sox_cmd)

    return word_wavs
end

function mkglyph(fdata, wordpos, outdir, charname)
    local wx = wordpos[1]
    local wy = wordpos[2]
    local word = fdata[(wy - 1)*8 + wx]
    local height = 6 -- bitrune fixed height
    local width = word.width
    local png = string.format("%s/%s_%01d_%01d.png", outdir, charname, wx, wy)
    local bits = word.bits

    local block_size = 8
    local padding = 4
    local glyph_width = 2*padding + width*block_size
    local glyph_height = 2*padding + height*block_size
    local canvas_width = 128
    local canvas_height = 128
    assert(glyph_width <= canvas_width)
    assert(glyph_height <= canvas_height)
    lilt {"bpnew", "bp", canvas_width, canvas_height}
    lilt {
        "bpset",
        "[grab bp]", 0,
        -- center glyph
        (canvas_width - glyph_width) / 2,
        (canvas_height - glyph_height) / 2,
        glyph_width, glyph_height
    }

    lilt {"bpoutline", "[bpget [grab bp] 0]", 1}

    for h=1,height do
        local row = bits[h]
        for w=1,width do
            local c = string.byte(row, w)
            c = string.char(c)
            if c == "#" then
                lilt {
                    "bprectf",
                    "[bpget [grab bp] 0]",
                    padding + (w - 1)*block_size,
                    padding + (h - 1)*block_size,
                    block_size, block_size,
                    1
                }
            end
        end
    end

    lilt{"bppng", "[grab bp]", png}

    return png
end

function generate_glyphs(words)
    local font_datafile = "vocab/toni/f_toni.b64"
    local outdir = "tmp/toni_proof"
    local charname = "toni"
    local fdata = asset:load(font_datafile)
    local filenames = {}

    for _,wp in pairs(words) do
        local pngfile = mkglyph(fdata, wp, outdir, charname)
        table.insert(filenames, pngfile)
        mnoreset()
    end

    return filenames
end

function generate_videos(pngs, wavs, words, outdir, charname)
    local filenames = {}
    for idx, wp in pairs(words) do
        local mp4_basename =
            string.format("%s_%01d_%01d.mp4",
                charname,
                wp[1], wp[2])
        local mp4 = outdir .. "/" .. mp4_basename
        local ffmpeg_flags = {
            "ffmpeg", "-y", "-loop", "1", "-r 60",
            "-i", pngs[idx],
            "-i", wavs[idx],
            "-c:v", "libx264",
            "-tune stillimage",
            "-c:a aac", "-b:a 256k",
            "-pix_fmt", "yuv420p",
            "-shortest",
            mp4
        }
        os.execute(table.concat(ffmpeg_flags, " "))
        table.insert(filenames, mp4_basename)
    end

    local vidlist_fname = outdir .. "/vids.txt"
    local vidlist = io.open(vidlist_fname, "w")

    for _, vid in pairs(filenames) do
        vidlist:write("file '" .. vid  .. "'\n")
    end

    vidlist:close()

    os.execute(table.concat({
        "ffmpeg", "-y", "-f", "concat", "-safe", "0",
        "-i", vidlist_fname,
        "-c copy", outdir .. "/" .. charname .. "_proof.mp4"
    }, " "))
end

local words = {
    {2, 1},
    {3, 1},
    {4, 1},
    {5, 1},
    {6, 1},
    {7, 1},
    {8, 1},
    {1, 2},
    {2, 2},
    {3, 2},
    {4, 2},
    {5, 2},
    {6, 2},
    {7, 2},
    {8, 2},
    {1, 3},
    {2, 3},
}

local wav_files = generate_sounds(words)
local png_files = generate_glyphs(words)

generate_videos(png_files, wav_files, words, "tmp/toni_proof", "toni")
