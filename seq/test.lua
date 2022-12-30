tal = require("tal/tal")
path = require("path/path")
morpheme = require("morpheme/morpheme")
pprint = require("util/pprint")
morpho = require("morpheme/morpho")
seq = require("seq/seq")
gest = require("gest/gest")

s16 = seq.seqfun(morpho)
gate = seq.gatefun(morpho)

A = {
    seq = s16("a/ d_ f^ o2~"),
    gate = gate("o2_ o1 c o2 o4"),
}

mseq = {
    {A, {1, 3}}
}

words = {}

g = gest:new {
    conductor = "[regget 0]"
}

g:create()
tal.start(words)
morpheme.articulate(path, tal, words, mseq)

g:compile(words)

lil("phasor 1 0; hold zz; regset zz 0")
g:swapper()
g:node("seq")

lil(string.format("mul zz %g", 1.0 / 16))
lil("scale zz 48 70")
lil("mtof zz")
lil("blsaw zz; butlp zz 500; mul zz 0.3")
g:node("gate")
lil("envar zz 0.008 0.03")
lil("mul zz zz")
lil("gldone [grab glive]")
lil("wavout zz test.wav")
lil("computes 10")
