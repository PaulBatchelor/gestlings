whistle = require("whistle/whistle")
core = require("util/core")
sig = require("sig/sig")
diagraf = require("diagraf/diagraf")
sigrunes = require("sigrunes/sigrunes")

whistle.osc {
    freq = lilf("rline 70 80 10"),
    timbre = paramf(0),
    amp = paramf(0.5),
    sig = sig,
    core = core,
    diagraf = diagraf,
    sigrunes = sigrunes
}

lil("wavout zz test.wav")
lil("computes 6")
