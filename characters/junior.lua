local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
pprint = require("util/pprint")

junior = {}

fp = io.open("vocab/junior/pb_junior.txt")

local phrasenames = {}
for l in fp:lines() do
    table.insert(phrasenames, l)
end
fp:close()

local symbols = asset:load("vocab/junior/p_junior.b64")
local verses = {}
local vr = {}

for _, sym in pairs(symbols) do
    if sym == 0 then
        table.insert(verses, vr)
        vr = {}
    else
        table.insert(vr, sym)
    end
end

assert(#verses == #phrasenames)

phrasebook = {}

for idx, name in pairs(phrasenames) do
    phrasebook[name] = verses[idx]
end

junior.phrasebook = phrasebook

junior.vocab = asset:load("vocab/junior/v_junior.b64")
junior.docs = junior.vocab[2]
junior.vocab = junior.vocab[1]
junior.tilemap = asset:load("vocab/junior/t_junior.b64")
junior.uf2 = "fonts/junior.uf2"

asset:save(junior, "characters/junior.b64")
