-- "^[drmfsltDRMFSLT][+\-\=]?[,']*(?:[1-9][0-9]?[.]?)?$"

morpheme = require("morpheme/morpheme")

pprint = require("util/pprint")
tal = require("tal/tal")
gest = require("gest/gest")
path = require("path/path")
nrt = require("nrt/nrt")

eval = NRT.eval

A = {
    seq = eval("d4.~r8mslR16D", {base=60}),
    seq2 = eval("d8.^s,~f,s,m,8l,", {base=48}),
}

S = {
    {A, {1, 4}},
}

g = gest:new({tal = tal, conductor="[regget 0]"})

words = {}

tal.start(words)

g:create()
morpheme.articulate(path, tal, words, S)
g:compile(words)

lil("phasor 2 0; hold zz; regset zz 0")
g:swapper()
g:node_old("seq")
lil("mtof zz")
lil("blsaw zz; butlp zz 500; mul zz 0.3")

g:node_old("seq2")
lil("mtof zz")
lil("blsaw zz; butlp zz 500; mul zz 0.3")
lil("add zz zz")

lil("wavout zz test.wav")
lil("unhold [regget 0]")
lil("computes 10")
