uf2 = require("util/uf2")
msgpack = require("util/MessagePack")
base64 = require("util/base64")
asset = require("asset/asset")
asset = asset:new({msgpack=msgpack, base64=base64})
symtools = require("util/symtools")

seq_symbols = require("seq/symbols")
path_symbols = require("path/symbols")
morpheme_symbols = require("morpheme/symbols")

symbols = seq_symbols
symtools.append_symbols(symbols, path_symbols)
symtools.append_symbols(symbols, morpheme_symbols)

uf2.generate(symbols, "seq/test_syms.uf2")

symtab = symtools.symtab(symbols)
tmp = symtools.symtab(path_symbols)
asset:save(symtab, "seq/test_syms_tab.b64")
