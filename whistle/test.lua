whistle = require("whistle/whistle")
core = require("util/core")
sig = require("sig/sig")
diagraf = require("diagraf/diagraf")
sigrunes = require("sigrunes/sigrunes")

lvl = core.liln

pulses = lvl([[
metro [rline 1 8 1]
tgate zz 0.08
env zz 0.004 0.001 0.01
]])

local g = whistle.graph {
    freq = lvl("rline 70 80 10"),
    timbre = lvl("rline 0 1 3"),
    amp = pulses,
    sig = sig,
    core = core,
    diagraf = diagraf,
    sigrunes = sigrunes
}

l = g:generate_nodelist()
g:dot("whistle.dot")
g:compute(l)

lil("dup; wavouts zz zz test.wav")
lil("computes 12")
