uf2 = require("uf2")
symbols = require("symbols")

msgpack = dofile("../util/MessagePack.lua")
base64 = dofile("../util/base64.lua")
asset = dofile("../asset/asset.lua")
asset = asset:new({msgpack=msgpack, base64=base64})

uf2.generate(symbols, "test.uf2.txt")

function generate_symtab(symbols)
    local symtab = {}

    for id, sym in pairs(symbols) do
        symtab[sym.name] = id
    end
    return symtab
end

symtab = generate_symtab(symbols)
asset:save(symtab, "symtab.b64")
