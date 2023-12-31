-- function generate_morpheme_grammar(symtab, pathgram)
function generate_morpheme_grammar(symtab, notations)
    local Space = lpeg.S(" \n\t")^0
    local MorphSymbols = nil

    -- when making the grammar, it was much easier to use
    -- generic names. when making the notation system,
    -- it was much easier to use human-readable names.
    -- this look up table was created after the fact to
    -- translate generic names to the symbols they ended
    -- up being.

    local name_to_msym = {
        morph_sym00 = "lbrack",
        morph_sym01 = "rbrack",
        morph_sym02 = "ltee",
        morph_sym03 = "rtee",
        morph_sym04 = "dash",
        morph_sym05 = "parallel",
        morph_sym06 = "lhook",
        morph_sym07 = "rhook",
        morph_sym08 = "sky",
        morph_sym09 = "ground",
        morph_sym10 = "dashground",
        morph_sym11 = "grounddash",
        morph_sym12 = "dashsky",
        morph_sym13 = "skydash",
        morph_sym14 = "groundsky",
        morph_sym15 = "morph_begin",
        morph_sym16 = "morph_line_begin",
        morph_sym17 = "morph_end",
    }

    hexpat = function(msym)
        local num = symtab[msym]
        if num == nil then
            error("symbol " .. msym .. " returns nil value")
        end
        return lpeg.P(string.format("%02x", num))
    end

    for i = 1,18 do
        local msym = string.format("morph_sym%02d", i - 1)
        local symnum = symtab[msym]
        if symnum ~= nil then
            if MorphSymbols == nil then
                MorphSymbols = hexpat(msym) / msym
            else
                MorphSymbols = MorphSymbols + hexpat(msym) / msym
            end
        else
            -- try using the lookup table
            local new_msym = name_to_msym[msym]
            symnum = symtab[new_msym]
            if symnum == nil then
                error("Can't find symbol '" .. msym .. "'")
            end

            if MorphSymbols == nil then
                MorphSymbols = hexpat(new_msym) / new_msym
            else
                MorphSymbols = MorphSymbols + hexpat(new_msym) / new_msym
            end
        end
    end
    local MorphVals = Space * MorphSymbols * Space
    local LineBegin = hexpat("morph_line_begin") * Space
    local Define = Space * hexpat("morph_define") * Space
    local MorphAttrName = lpeg.Cg(lpeg.Ct(MorphVals^1) * Define, "attribute")

    -- local notations = {
    --     path=pathgram,
    -- }

    local GesturePath = nil

    for name, gram in pairs(notations) do
        local p =
            lpeg.Cg(lpeg.Ct(gram), "path") *
            lpeg.Cg(lpeg.Cc(name), "path_type")
        if GesturePath == nil then
            GesturePath = p
        else
            GesturePath = GesturePath + p
        end
    end

    local MorphPath =
        lpeg.Ct(LineBegin^0 *
            MorphAttrName *
            GesturePath)

    local MorphBegin = hexpat("morph_begin")
    local MorphEnd = hexpat("morph_end")
    local MorphBreak = hexpat("morph_break")
    local cg = lpeg.Cg
    local ct = lpeg.Ct
    local MorphHeader =
        MorphBegin * Space * cg(ct(MorphVals^1), "name") * MorphBreak * Space
    local MorphAttributes = 
        cg(ct((MorphPath*MorphBreak*Space)^0), "attributes")
    local Morpheme = ct(MorphHeader * MorphAttributes * MorphEnd)
    return Morpheme
    --return ct(MorphPath)
end
