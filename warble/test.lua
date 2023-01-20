core = require("util/core")
sr = require("sigrunes/sigrunes")

ln = sr.lilnode
lvl = core.liln

lil("gensine [tabnew 8192]")
lil("regset zz 0; regmrk 0")

-- sr.lilnode_debug(true)
ln(sr.fmpair) {
    tab = lvl("regget 0")
}

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

lil("mul zz 0.2; wavout zz test.wav")
lil("computes 10")
