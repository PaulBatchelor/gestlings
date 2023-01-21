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
lil("regset zz 0; regmrk 0")

g = diagraf.Graph:new{sig=sig}

ng  = core.nodegen(diagraf.Node, g)
pg  = core.paramgen(ng)
con = g:connector()
prmf = core.paramf

p = {
    freq = lf("rline 200 400 1")
}

freq = pg(p.freq or prmf(330))

-- sr.lilnode_debug(true)
fm = ng(sr.fmpair) {
    tab = plf("regget 0"),
    mi = 1.5,
    car = 1.0,
    mod = 1.0,
    fdbk = 0.4,
}

scaler = ng(sr.scale)

mul = ng(sr.mul)
nz = ng(sr.noise)()
lpf = ng(sr.butlp)()
hpf = ng(sr.buthp){cutoff=300}
con(nz, hpf.input)
con(hpf, lpf.input)
freqmul = mul{b = 2.0}
con(freq, freqmul.a)
con(freqmul, lpf.cutoff)

envar = ng(sr.envar)

cf = ng(sr.crossfade) {
    pos = 0.5
}

cfenv = envar {
    gate = plf("metro 10; tgate zz 0.01"),
    atk = 0.03,
    rel = 0.01,
}
sclcf = scaler {
    min = 0.0,
    max = 1.0
}
con(cfenv, sclcf.input)
con(sclcf, cf.pos)


con(fm, cf.a)
con(lpf, cf.b)

osc = cf

con(freq, fm.freq)

sclamp = scaler {
    min = 0.0,
    max = 1.0
}


ampenv = envar {
    gate = plf("metro 1.5; tgate zz 0.01"),
    atk = 0.003,
    rel = 0.9,
}

con(ampenv, sclamp.input)

ascl_mul = mul()
con(osc, ascl_mul.a)
con(sclamp, ascl_mul.b)
g:dot("warble.dot")
l = g:generate_nodelist()

g:compute(l)

lil("mul zz 0.2; wavout zz test.wav")
lil("computes 10")
