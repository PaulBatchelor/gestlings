local asset = require("asset/asset")
msgpack = require("util/MessagePack")
asset = asset:new{
    msgpack = msgpack,
    base64 = require("util/base64")
}
pprint = require("util/pprint")

junior = {}

function genphrasebook(phrasenames_fname, symbols_fname, notation)
    fp = io.open(phrasenames_fname)

    assert(fp ~= nil, "Could not open file:" .. phrasenames_fname)
    local phrasenames = {}
    for l in fp:lines() do
        if string.match(l, "^#") == nil then
            table.insert(phrasenames, l)
        end
    end
    fp:close()

    local symbols = asset:load(symbols_fname)
    local verses = {}
    local vr = {}

    for _, sym in pairs(symbols) do
        if sym == 0 then
            table.insert(verses, vr)
            -- pprint(vr)
            vr = {}
        else
            table.insert(vr, sym)
        end
    end

    assert(#verses == #phrasenames,
        string.format("verse (%d)/phrasename (%d) mismatch",
            #verses, #phrasenames))

    phrases = {}

    for idx, name in pairs(phrasenames) do
        phrases[name] = verses[idx]
    end

    local phrasebook = {}

    phrasebook.phrases = phrases
    phrasebook.notation = notation
    return phrasebook
end

junior.phrasebook = {}
junior.phrasebook.default =
    genphrasebook("vocab/junior/pb_junior.txt",
        "vocab/junior/p_junior.b64",
        "simple")
junior.phrasebook.mushroom_poem =
    genphrasebook("vocab/junior/pb_junior_verses.txt",
        "vocab/junior/p_junior_verses.b64",
        "poetic")

junior.vocab = asset:load("vocab/junior/v_junior.b64")
junior.tilemap = asset:load("vocab/junior/t_junior.b64")
junior.uf2 = "fonts/junior.uf2"
junior.shapelut = asset:load("shapes/l_junior.b64")
junior.shapes = "shapes/junior.b64"
junior.physiology = "physiology/phys_junior.lua"
junior.name = "junior"

asset:save(junior, "characters/junior.b64")
