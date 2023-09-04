antik = require("scratch/antik_1_syms")
uf2 = require("util/uf2")

uf2.generate(antik, "scratch/antik.uf2")

lil("bpnew bp 256 256")
lil("uf2load antik scratch/antik.uf2")
lil("bpset [grab bp] 0 0 0 256 256")
lil("uf2txtln [bpget [grab bp] 0] [grab antik] 0 0 'hello there!'")
lil("bppng [grab bp] scratch/c64parse.png")
