core = require("util/core")
sr = require("sigrunes/sigrunes")
diagraf = require("diagraf/diagraf")

nd = sr.node
ln = core.liln
lf = core.lilf
plf = core.plilf

lil("gensine [tabnew 8192]")
lil("regset zz 0; regmrk 0")

g = diagraf.Graph:new()

ng  = core.nodegen(diagraf.Node, g)
pg  = core.paramgen(ng)
con = g:connector()

-- sr.lilnode_debug(true)
fm = ng(sr.fmpair) {
    tab = plf("regget 0"),
    freq = 330,
    mi = 1.5,
    car = 1.0,
    mod = 3.0,
    fdbk = 0.4,
}

tab = ln("regget 0")

-- lil("mul zz 0.2")
-- lil([[
-- regget 0
-- param 440
-- param 1
-- param 1
-- param 1
-- param 0
-- fmpair zz zz zz zz zz zz
-- mul zz 0.2
-- ]])

l = g:generate_nodelist()
pprint = require("util/pprint")

pprint(tab)
g:compute(l)
lil("mul zz 0.2; wavout zz test.wav")
lil("computes 10")
