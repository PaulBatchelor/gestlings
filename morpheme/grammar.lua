pprint = dofile("../util/pprint.lua")
symtools = dofile("../util/symtools.lua")
path_grammar = loadfile("../path/grammar.lua")
path_grammar()
asset = dofile("../asset/asset.lua")
asset = asset:new {
    msgpack = dofile("../util/MessagePack.lua"),
    base64 = dofile("../util/base64.lua")
}

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
    local Define = hexpat("morph_define") * Space
    local MorphPath = lpeg.Ct(lpeg.Cg(lpeg.Ct(MorphVals^1) * Define, "attribute") *
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

local morpheme_symtab = {
    morph_sym00 = 1,
    morph_sym01 = 2,
    morph_sym02 = 3,
    morph_sym03 = 4,
    morph_break = 5,
    morph_begin = 6,
    morph_end = 7,
    morph_define = 8,
}

symtab = asset:load("../path/symtab.b64")
symstart = 0

for _,_ in pairs(symtab) do
    symstart = symstart + 1
end

for k,v in pairs(morpheme_symtab) do
    symtab[k] = v + symstart
end

symtools.vars(symtab)()

syms = {
    morph_begin, morph_sym00, morph_sym00, morph_break,

    morph_sym00, morph_sym01, morph_sym02, morph_sym03, morph_sym03, morph_define,

    bracket_left,
        zero, zero,
        ratemulstart, one, one, ratemulend, linear,
        divider,
        fifteen, fifteen,
        ratemulstart, three, three, ratemulend, step,
    bracket_right, morph_break,

    morph_sym03, morph_sym03, morph_define,
    bracket_left,
        one, one,
        ratemulstart, nine, nine, ratemulend, gliss_big,
        divider,
        one, one,
        ratemulstart, zero, one, ratemulend, step,
    bracket_right, morph_break,

    morph_end
}
-- print(bracket_left)
-- pprint(symtab)
str = symtools.hexstring(symtab, syms)
-- print(str)
path_grammar = generate_path_grammar(symtab)
grammar = generate_morpheme_grammar(symtab, path_grammar)
t = lpeg.match(grammar, str)
-- t = lpeg.match(path_grammar, str)

pprint(t)
