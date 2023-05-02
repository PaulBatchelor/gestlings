return function(symtab)
    pathgram = generate_path_grammar(symtab)
    local Space = lpeg.S(" \n\t")^0
    local Null = lpeg.P("00")
    local Line = pathgram * Null * Space
    Line = lpeg.Ct(Line)
    local Lines = lpeg.Ct(Line^0)
    return Lines
end
