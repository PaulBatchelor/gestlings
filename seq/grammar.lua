function generate_seq_grammar(symtab)
    local Space = lpeg.S(" \n\t")^0
    local hexpat = function(msym)
        local num = symtab[msym]
        if num == nil then
            error("symbol " .. msym .. " returns nil value")
        end
        return lpeg.P(string.format("%02x", num))
    end

    local Value = nil

    for i=1,17 do
        local strval = string.format("seq_val%d", i - 1)
        local p = hexpat(strval) / tostring(i - 1)

        if Value == nil then
            Value = p
        else
            Value = Value + p
        end
    end

    local Dur = nil
    for i=1,8 do
        local strval = string.format("seq_dur%d", i)
        local p = hexpat(strval) / tostring(i)

        if Dur == nil then
            Dur = p
        else
            Dur = Dur + p
        end
    end

    local Behavior =
        hexpat("seq_linear") / "linear" +
        hexpat("seq_step") / "step" +
        hexpat("seq_gliss_big") / "gliss_big" +
        hexpat("seq_gliss_medium") / "gliss_medium" +
        hexpat("seq_gliss_small") / "gliss_small"

    local cg = lpeg.Cg
    local ct = lpeg.Ct
    local SeqValue = cg(Space * Value * Space, "value")
    local SeqDur = cg(ct((Space * Dur * Space)^1), "dur")^0
    local SeqBehavior= cg(Space * Behavior * Space, "behavior")^0
    local SeqUnit = ct(SeqValue * SeqDur * SeqBehavior)
    local SeqEnd = Space * hexpat("seq_end") * Space

    return (SeqUnit^1) * SeqEnd
    -- local name_to_msym = {
    --     morph_sym00 = "lbrack",
    --     morph_sym01 = "rbrack",
    --     morph_sym02 = "ltee",
    --     morph_sym03 = "rtee",
    --     morph_sym04 = "dash",
    --     morph_sym05 = "parallel",
    --     morph_sym06 = "lhook",
    --     morph_sym07 = "rhook",
    --     morph_sym08 = "sky",
    --     morph_sym09 = "ground",
    --     morph_sym10 = "dashground",
    --     morph_sym11 = "grounddash",
    --     morph_sym12 = "dashsky",
    --     morph_sym13 = "skydash",
    --     morph_sym14 = "groundsky",
    --     morph_sym15 = "morph_begin",
    --     morph_sym16 = "morph_line_begin",
    --     morph_sym17 = "morph_end",
    -- }


    -- for i = 1,18 do
    --     local msym = string.format("morph_sym%02d", i - 1)
    --     local symnum = symtab[msym]
    --     if symnum ~= nil then
    --         if MorphSymbols == nil then
    --             MorphSymbols = hexpat(msym) / msym
    --         else
    --             MorphSymbols = MorphSymbols + hexpat(msym) / msym
    --         end
    --     else
    --         -- try using the lookup table
    --         local new_msym = name_to_msym[msym]
    --         symnum = symtab[new_msym]
    --         if symnum == nil then
    --             error("Can't find symbol '" .. msym .. "'")
    --         end

    --         if MorphSymbols == nil then
    --             MorphSymbols = hexpat(new_msym) / new_msym
    --         else
    --             MorphSymbols = MorphSymbols + hexpat(new_msym) / new_msym
    --         end
    --     end
    -- end
    -- local MorphVals = Space * MorphSymbols * Space
    -- local LineBegin = hexpat("morph_line_begin") * Space
    -- local Define = Space * hexpat("morph_define") * Space
    -- local MorphAttrName = lpeg.Cg(lpeg.Ct(MorphVals^1) * Define, "attribute") 
    -- local GesturePath = lpeg.Cg(lpeg.Ct(pathgram), "path")
    -- local MorphPath = lpeg.Ct(LineBegin^0 * MorphAttrName * GesturePath)

    -- local MorphBegin = hexpat("morph_begin")
    -- local MorphEnd = hexpat("morph_end")
    -- local MorphBreak = hexpat("morph_break")
    -- local cg = lpeg.Cg
    -- local ct = lpeg.Ct
    -- local MorphHeader =
    --     MorphBegin * Space * cg(ct(MorphVals^1), "name") * MorphBreak * Space
    -- local MorphAttributes = 
    --     cg(ct((MorphPath*MorphBreak*Space)^0), "attributes")
    -- local Morpheme = ct(MorphHeader * MorphAttributes * MorphEnd)
    -- return Morpheme
    -- --return ct(MorphPath)
end
