symtools = require("util/symtools")
seq_symbols = require("seq/symbols")
path_symbols = require("path/symbols")
morpheme_symbols = require("morpheme/symbols")

function tabcount(tab)
    local cnt = 0
    for _,_ in pairs(tab) do cnt = cnt + 1 end
    return cnt
end

individual_sum = (#seq_symbols + #path_symbols)
-- individual_sum = (tabcount(seq_symbols) + tabcount(path_symbols))
symbols = seq_symbols
symtools.append_symbols(symbols, path_symbols)

nsymbols = tabcount(symbols)

verbose = os.getenv("VERBOSE")

if nsymbols ~= individual_sum then
    if verbose ~= nil and verbose == "1" then
        error(
            string.format(
                "symbol table sizes do not match: "..
                "%d (nsymbols) vs %d (individual)",
                nsymbols, individual_sum))
    else
        os.exit(1)
    end
end
