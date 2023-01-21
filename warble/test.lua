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
    pitch = lf("rline 60 67 1")
}

pitch = pg(p.pitch or prmf(60))

-- sr.lilnode_debug(true)
fm = ng(sr.fmpair) {
    --tab = plf("regget 0"),
    tab = sintab,
    mi = 1.5,
    car = 1.0,
    mod = 1.0,
    fdbk = 0.4,
}

scaler = ng(sr.scale)

mul = ng(sr.mul)
add = ng(sr.add)
nz = ng(sr.noise)()
lpf = ng(sr.butlp)()
hpf = ng(sr.buthp){cutoff=300}
con(nz, hpf.input)
con(hpf, lpf.input)
freqmul = add{b = 12.0}
con(pitch, freqmul.a)
mtof = ng(sr.mtof)
lpf_freq = mtof()
con(freqmul, lpf_freq.input)
con(lpf_freq, lpf.cutoff)

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

generator = cf

lfo = ng(sr.osc) {
    freq = 6,
    amp = 0.5,
    tab = sintab
}

vib = add()
fm_freq = mtof()
con(pitch, vib.a)
con(lfo, vib.b)
con(vib, fm_freq.input)
con(fm_freq, fm.freq)

sclamp = scaler {
    min = 0.0,
    max = 1.0
}

ampenv = envar {
    gate = plf("metro 1; tgate zz 0.2"),
    atk = 0.03,
    rel = 0.9,
}

con(ampenv, sclamp.input)

ascl_mul = mul()
con(generator, ascl_mul.a)
con(sclamp, ascl_mul.b)
-- g:dot("warble.dot")
l = g:generate_nodelist()

g:compute(l)
lil(string.format("regclr %d", tab))

lil("mul zz 0.2; wavout zz test.wav")
lil("computes 10")
