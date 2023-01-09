diagraf = require("diagraf/diagraf")
pprint = require("util/pprint")
-- nodes = require("diagraf/nodes")
sigrunes = require("sigrunes/sigrunes")
sig = require("sig/sig")

g = diagraf.Graph:new{debug=true, sig=sig}

n = {}
sigrunes.nodes(diagraf.Node, g, n)

s1 = n.blsaw()
lfo = n.sine{freq=1.23, amp=1}
lfo:label("LFO generator")
gain = n.mul{b=0.5}
lpf = n.butlp{cutoff=300}

con = g:connector()

bias = n.biscale{min=200, max=500}
con(lfo, bias.input)
con(bias, s1.freq)
con(s1, gain.a)

lpf_lfo = n.biscale{min=321, max=1234}
con(lfo, lpf_lfo.input)
con(lpf_lfo, lpf.cutoff)

con(gain, lpf.input)

out = lpf
con(out, n.wavout().input)

-- add an envelope
met = n.metro{rate = 2}
env = n.env{}
con(met, env.trig)
env_scaled = n.mul{b=0.5}
con(env, env_scaled.a)
con(env_scaled, gain.b)

g:process()
l = topsort(g.edges)
g:nsort_rec(l, g.nodes[l[#l]], #l)
g:setters_to_first_getters(l)
g:nsort_rec(l, g.nodes[l[#l]], #l)
g:postprocess(l)
g:dot("diagraf_test.dot")
