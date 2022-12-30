tal = require("tal/tal")
path = require("path/path")
morpheme = require("morpheme/morpheme")
pprint = require("util/pprint")
morpho = require("morpheme/morpho")

append = morpheme.appender(path)

seq = require("seq/seq")

s16 = seq.seqfun(morpho)
