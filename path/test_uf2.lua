-- top-level file to generate uf2/symtab for path
-- mainly used of testing purposes (still working out the system)

uf2 = require("path/uf2")
symbols = require("path/symbols")

msgpack = require("util/MessagePack")
base64 = require("util/base64")
asset = require("asset/asset")
asset = asset:new({msgpack=msgpack, base64=base64})
symtools = require("util/symtools")

uf2.generate(symbols, "path/test.uf2.hex")

symtab = symtools.symtab(symbols)
asset:save(symtab, "path/symtab.b64")
