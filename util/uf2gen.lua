if #arg < 2 then
    error("Usage uf2gen syms.lua out.uf2")
end

uf2 = require("util/uf2")

syms = dofile(arg[1])
outfile = arg[2]
uf2.generate(syms, outfile)
