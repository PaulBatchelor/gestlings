core = require("util/core")
sr = require("sigrunes/sigrunes")
diagraf = require("diagraf/diagraf")
pprint = require("util/pprint")
sig = require("sig/sig")

nd = sr.node
ln = core.liln
lf = core.lilf
plf = core.plilf

lil("gensine [tabnew 8192]")
lil("param [regnxt 0]")
tab = pop()
lil(string.format("regset zz %d; regmrk %d", tab, tab))
sintab = plf(string.format("regget %d", tab))

g = diagraf.Graph:new{sig=sig}

ng  = core.nodegen(diagraf.Node, g)
pg  = core.paramgen(ng)
con = g:connector()
prmf = core.paramf

p = {
    pitch = lf("rline 60 67 1"),
    mi = lf("rline 0 2 2.3"),
    car = prmf(1),
    mod = prmf(3),
    fdbk = lf("rline 0 0.7 4"),

    asp = {
        val = lf("rline 0 0.3 0.1"),
        gate = lf("metro 10; tgate zz 0.01"),
        atk = lf("rline 0.001 0.1 1"),
        rel = lf("rline 0.001 0.1 1"),
    },

    amp = {
        val = lf("rline 0 0.1 0.2"),
        gate = lf("metro 1; tgate zz 0.2"),
        atk = lf("rline 0.001 0.1 1"),
        rel = lf("rline 0.1 0.9 3"),
    },

    vib = {
        rate = lf("rline 5 9 0.99"),
        depth = lf("rline 0.1 0.9 0.33"),
    }
}

local pitch = pg(p.pitch or prmf(60), "pitch")
local amp = pg(p.amp.val or prmf(1), "amp")
local mi = pg(p.mi or prmf(1), "mod index")
local car = pg(p.car or prmf(1), "car")
local mod = pg(p.mod or prmf(1), "mod")
local fdbk = pg(p.fdbk or prmf(0), "feedback")
local asp = pg(p.asp.val or prmf(0), "aspiration")
local asp_gt = pg(p.asp.gate or prmf(0), "aspiration gate")
local asp_atk = pg(p.asp.atk or prmf(0.1), "aspiration attack")
local asp_rel = pg(p.asp.rel or prmf(0.1), "aspiration release")
local a_gt = pg(p.amp.gate or prmf(0), "amp gate")
local a_atk = pg(p.amp.atk or prmf(0.1), "amp attack")
local a_rel = pg(p.amp.rel or prmf(0.1), "amp release")
local vib_rate = pg(p.vib.rate or prmf(6), "vibrato rate")
local vib_depth = pg(p.vib.depth or prmf(0.2), "vibrato depth")

-- sr.lilnode_debug(true)
local fm = ng(sr.fmpair) {tab = sintab}

con(mi, fm.mi)
con(car, fm.car)
con(mod, fm.mod)
con(fdbk, fm.fdbk)

local scaler = ng(sr.scale)

local mul = ng(sr.mul)
local add = ng(sr.add)
local nz = ng(sr.noise)()
local lpf = ng(sr.butlp)()
local hpf = ng(sr.buthp){cutoff=300}
con(nz, hpf.input)
con(hpf, lpf.input)
local freqmul = add{b = 12.0}
con(pitch, freqmul.a)
local mtof = ng(sr.mtof)
local lpf_freq = mtof()
con(freqmul, lpf_freq.input)
con(lpf_freq, lpf.cutoff)

local envar = ng(sr.envar)

local cf = ng(sr.crossfade) {}

local cfenv = envar {}

local sclcf = scaler {max = 1.0}

con(asp_rel, cfenv.rel)
con(asp_atk, cfenv.atk)
con(asp_gt, cfenv.gate)
con(asp, sclcf.min)
con(cfenv, sclcf.input)
con(sclcf, cf.pos)

con(fm, cf.a)
con(lpf, cf.b)

local generator = cf

lfo = ng(sr.osc) {
    -- freq = 6,
    -- amp = 0.5,
    tab = sintab
}

con(vib_rate, lfo.freq)
con(vib_depth, lfo.amp)

vib = add()
fm_freq = mtof()
con(pitch, vib.a)
con(lfo, vib.b)
con(vib, fm_freq.input)
con(fm_freq, fm.freq)

sclamp = scaler {
    max = 1.0
}

con(amp, sclamp.min)

ampenv = envar {}

con(a_atk, ampenv.atk)
con(a_rel, ampenv.rel)

con(a_gt, ampenv.gate)
con(ampenv, sclamp.input)

local ascl_mul = mul()
con(generator, ascl_mul.a)
con(sclamp, ascl_mul.b)
g:dot("warble.dot")
l = g:generate_nodelist()

g:compute(l)
lil(string.format("regclr %d", tab))

lil("mul zz 0.2; wavout zz test.wav")
lil("computes 10")
