Symtools = {}

function Symtools.vars(symtab)
    local evalstr = ""
    for k,_ in pairs(symtab) do
        evalstr= evalstr .. string.format("%s=%q", k, k)
    end
    return load(evalstr)
end

function Symtools.hexstring(symtab, line)
    local s = {}
    for _,c in pairs(line) do
        table.insert(s, string.format("%02x", symtab[c]))
    end
    local hexstr = table.concat(s, " ") .. "\n"
    return hexstr
end

function Symtools.symtab(symbols)
    local symtab = {}

    for id, sym in pairs(symbols) do
        symtab[sym.name] = id
    end
    return symtab
end


return Symtools
