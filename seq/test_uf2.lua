uf2 = require("path/uf2")
msgpack = require("util/MessagePack")
base64 = require("util/base64")
asset = require("asset/asset")
asset = asset:new({msgpack=msgpack, base64=base64})
symtools = require("util/symtools")

seq_symbols = require("seq/symbols")
-- psymbols = require("path/symbols")

-- function append_symbols(dst, src)
--     local off = 0
--     for _,v in pairs(dst) do
--         if v.id > off then
--             off = v.id
--         end
--     end
-- 
--     for k, v in pairs(src) do
--         dst[k + off] = src[k]
--         dst[k + off].id = src[k].id + off
--     end
-- end
-- 
-- append_symbols(symbols, psymbols)
symtab = symtools.symtab(seq_symbols)

uf2.generate(seq_symbols, "seq/test_syms.uf2")

symtab = symtools.symtab(seq_symbols)
asset:save(symtab, "seq/test_syms_tab.b64")
