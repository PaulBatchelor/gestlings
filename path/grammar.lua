Grammar = {}

function Grammar.generate(symtab)
    local Space = lpeg.S(" \n\t")^0
    local LBrack = lpeg.P(string.format("%02x", symtab["bracket_left"]))
    local RBrack = lpeg.P(string.format("%02x", symtab["bracket_right"]))
    local One = lpeg.P(string.format("%02x", symtab["one"]))
    local Two = lpeg.P(string.format("%02x", symtab["two"]))
    local Three = lpeg.P(string.format("%02x", symtab["three"]))
    local Four = lpeg.P(string.format("%02x", symtab["four"]))
    local Five = lpeg.P(string.format("%02x", symtab["five"]))
    local Six = lpeg.P(string.format("%02x", symtab["six"]))
    local Seven = lpeg.P(string.format("%02x", symtab["seven"]))
    local Eight = lpeg.P(string.format("%02x", symtab["eight"]))
    local Nine = lpeg.P(string.format("%02x", symtab["nine"]))
    local Ten = lpeg.P(string.format("%02x", symtab["ten"]))
    local Eleven = lpeg.P(string.format("%02x", symtab["eleven"]))
    local Twelve = lpeg.P(string.format("%02x", symtab["twelve"]))
    local Thirteen = lpeg.P(string.format("%02x", symtab["thirteen"]))
    local Fourteen = lpeg.P(string.format("%02x", symtab["fourteen"]))
    local Fifteen = lpeg.P(string.format("%02x", symtab["fifteen"]))
    local Zero = lpeg.P(string.format("%02x", symtab["zero"]))
    local RateMulStart = lpeg.P(string.format("%02x", symtab["ratemulstart"]))
    local RateMulEnd = lpeg.P(string.format("%02x", symtab["ratemulend"]))
    local Divider = lpeg.P(string.format("%02x", symtab["divider"]))
    local Linear = lpeg.P(string.format("%02x", symtab["linear"]))
    local Step = lpeg.P(string.format("%02x", symtab["step"]))
    local GlissBig = lpeg.P(string.format("%02x", symtab["gliss_big"]))
    local GlissMedium = lpeg.P(string.format("%02x", symtab["gliss_medium"]))
    local GlissSmall = lpeg.P(string.format("%02x", symtab["gliss_small"]))

    local Symbol = LBrack + RBrack + One + Two + Three + Four
    local Number =
        Zero / "0" +
        One / "1" +
        Two / "2" +
        Three / "3" +
        Four / "4" +
        Five / "5" +
        Six / "6" +
        Seven / "7" +
        Eight / "8" +
        Nine / "9" +
        Ten / "a" +
        Eleven / "b" +
        Twelve / "c" +
        Thirteen / "d" +
        Fourteen / "e" +
        Fifteen / "f"
    local Behavior = Space * (
        Linear / "linear" +
        Step / "step" +
        GlissBig / "gliss_large" +
        GlissMedium / "gliss_medium" +
        GlissSmall / "gliss_small"
        ) * Space
    local Nibble = Space * Number * Space
    local Div = (Space * Divider * Space)^0
    local Hex = Div * lpeg.Ct(Nibble*Nibble) * Div
    local RateMul = RateMulStart * Hex * Div * Hex * RateMulEnd
    local Value = lpeg.Ct(lpeg.Cg(Hex, "value") *
                    lpeg.Cg(lpeg.Ct(RateMul), "ratemul")^0 *
                    lpeg.Cg(Behavior, "behavior")^0
                    )

    local Path = LBrack * (Value)^0 * RBrack * Space
    return Path
end

return Grammar