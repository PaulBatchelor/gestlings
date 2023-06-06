-- pprint = dofile("../util/pprint.lua")
-- symtools = dofile("../util/symtools.lua")
-- path_grammar = loadfile("../path/grammar.lua")
-- path_grammar()
-- asset = dofile("../asset/asset.lua")
-- asset = asset:new {
--     msgpack = dofile("../util/MessagePack.lua"),
--     base64 = dofile("../util/base64.lua")
-- }
-- path = dofile("../path/path.lua")
-- morpheme = dofile("../morpheme/morpheme.lua")

function generate_morpheme_grammar(symtab, pathgram)
    local Space = lpeg.S(" \n\t")^0
    local MorphSymbols = nil

    hexpat = function(msym)
        return lpeg.P(string.format("%02x", symtab[msym]))
    end

    for i = 1,16 do
        local msym = string.format("morph_sym%02d", i - 1)
        local symnum = symtab[msym]
        if symnum ~= nil then
            if MorphSymbols == nil then
                MorphSymbols = hexpat(msym) / msym
            else
                MorphSymbols = MorphSymbols + hexpat(msym) / msym
            end
        end
    end
    local MorphVals = Space * MorphSymbols * Space
    local LineBegin = hexpat("morph_line_begin") * Space
    local Define = hexpat("morph_define") * Space
    local MorphPath = lpeg.Ct(LineBegin^0*lpeg.Cg(lpeg.Ct(MorphVals^1) * Define, "attribute") *
        lpeg.Cg(lpeg.Ct(pathgram), "path")
        )
    local MorphBegin = hexpat("morph_begin")
    local MorphEnd = hexpat("morph_end")
    local MorphBreak = hexpat("morph_break")
    local cg = lpeg.Cg
    local ct = lpeg.Ct
    local Morpheme =
        ct(MorphBegin * Space * cg(MorphVals^1, "name") * MorphBreak * Space *
            cg(ct((MorphPath*MorphBreak*Space)^0), "attributes") * MorphEnd)
    return Morpheme
end
