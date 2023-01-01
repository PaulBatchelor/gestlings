whistle = require("whistle/whistle")
core = require("util/core")
sig = require("sig/sig")

whistle.osc {
    freq = lilf("rline 70 80 10"),
    timbre = paramf(0.5),
    amp = paramf(0.5),
    sig = sig,
    core = core
}

lil("wavout zz test.wav")
lil("computes 6")
