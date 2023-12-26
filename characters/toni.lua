-- TODO build re-usable abstraction

local asset = require("asset/asset")
msgpack = require("util/MessagePack")
asset = asset:new {
    msgpack = msgpack,
    base64 = require("util/base64")
}
pprint = require("util/pprint")

toni = {}

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

toni.phrasebook = {}
toni.phrasebook.default =
    genphrasebook("vocab/toni/pb_toni.txt",
        "vocab/toni/p_toni.b64",
        "poetic")

toni.vocab = asset:load("vocab/toni/v_toni.b64")
toni.tilemap = asset:load("vocab/toni/t_toni.b64")
toni.uf2 = "fonts/toni.uf2"
-- TODO
toni.shapelut = asset:load("shapes/l_toni.b64")
toni.shapes = "shapes/s_toni.b64"
toni.physiology = "physiology/phys_toni.lua"
toni.name = "toni"
toni.keyshapes = "vocab/toni/k_toni.bin"
toni.anatomy = asset:load("avatar/anatomy/a_toni.b64")

asset:save(toni, "characters/toni.b64")
