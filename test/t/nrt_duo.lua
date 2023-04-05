morpheme = require("morpheme/morpheme")

pprint = require("util/pprint")
tal = require("tal/tal")
gest = require("gest/gest")
path = require("path/path")
nrt = require("nrt/nrt")
sr = require("sigrunes/sigrunes")
verify = require("test/verify")

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

sr.node(g:node()) {
    name="seq"
}
lil("mtof zz")
lil("blsaw zz; butlp zz 500; mul zz 0.3")

sr.node(g:node()){
    name="seq2"
}
lil("mtof zz")
lil("blsaw zz; butlp zz 500; mul zz 0.3")
lil("add zz zz")

lil("unhold [regget 0]")

chksm = "043867aee329854be2e8dd72ce12aad2"

verify.verify(chksm)
