morpheme = require("morpheme/morpheme")
pprint = require("util/pprint")
tal = require("tal/tal")
path = require("path/path")

m = {
    pitch = {
        {60, 1, 3},
        {62, 1, 3},
        {64, 1, 3},
    }
}

seq = {{m, {1, 1}}}

words = {}

tal.start(words)

morpheme.articulate(path, tal, words, seq)

pprint(words)

lil("gestvmnew gst")
lil("gmemnew mem")
lil("phasor 1.5 0; hold; regset zz 0")

tal.compile_words(words, "mem", "[grab gst]")

lil("gestvmnode [grab gst] [gmemsym [grab mem] pitch] [regget 0]")
lil("mtof zz")
lil("blsaw zz")
lil("butlp zz 300")
lil("mul zz [dblin -6]")

lil("wavout zz test.wav")
lil("computes 10")

lil("unhold [regget 0]")
