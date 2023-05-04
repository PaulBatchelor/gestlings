-- path_grammar = dofile("grammar.lua")
msgpack = dofile("util/MessagePack.lua")
base64 = dofile("util/base64.lua")
asset = dofile("asset/asset.lua")
asset = asset:new({msgpack=msgpack, base64=base64})
generate_grammar = dofile("path/grammar.out")

function parse(Lines, hexstr)
    behaviors = {
        linear = 0,
        step = 1,
        gliss_medium = 2,
        gliss_large = 3,
        gliss_small = 4,
    }

    local t = lpeg.match(Lines, hexstr)

    local ratemul = {1, 1}
    local behavior = behaviors["linear"]
    local gpath = {}

    for _,v in pairs(t[2]) do
        local val = tonumber("0x" .. v.value[1] .. v.value[2])
        if v.behavior ~= nil then
            behavior = behaviors[v.behavior]
        end

        if v.ratemul ~= nil then
            local num, den
            num = v.ratemul[1]
            num = tonumber("0x" .. num[1] .. num[2])
            den = v.ratemul[2]
            den = tonumber("0x" .. den[1] .. den[2])
            ratemul = {num, den}
        end
        local vertex = {
            val,
            ratemul,
            behavior
        }
        table.insert(gpath, vertex)
    end
    return gpath
end

symtab = asset:load("path/symtab.b64")
-- Path = path_grammar.generate(symtab)
fp = io.open("path/notation.hex")
hexstr = fp:read("*all")
fp:close()

Grammar = generate_grammar(symtab)

gpath = parse(Grammar, hexstr)
asset:save(gpath, "path/path.b64")
