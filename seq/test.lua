tal = require("tal/tal")
path = require("path/path")
morpheme = require("morpheme/morpheme")
pprint = require("util/pprint")
morpho = require("morpheme/morpho")
seq = require("seq/seq")

s16 = seq.seqfun(morpho)

function gestvmnode(glive, membuf, program, conductor)
    lil(string.format(
        "gestvmnode %s [gmemsym [grab %s] %s] %s",
        glive, membuf, program, conductor))

end

A = {
    seq= s16("a/ d_ f o2~"),
}

mseq = {
    {A, {1, 3}}
}

words = {}

tal.membuf("mem")
lil("glnew glive")
tal.start(words)

morpheme.articulate(path, tal, words, mseq)

tal.compile_words(words, "mem", "[glget [grab glive]]")


lil("phasor 1 0; hold zz; regset zz 0")
lil("glswapper [grab glive]")
gestvmnode("[glget [grab glive]]",
    "mem", "seq", "[regget 0]")

lil(string.format("mul zz %g", 1.0 / 16))
-- lil("param 0.5")
lil("scale zz 48 70")
lil("mtof zz")
lil("blsaw zz; butlp zz 500; mul zz 0.3")
lil("gldone [grab glive]")
lil("wavout zz test.wav")
lil("computes 10")
