core = require("util/core")
sr = require("sigrunes/sigrunes")
diagraf = require("diagraf/diagraf")
pprint = require("util/pprint")
sig = require("sig/sig")
warble = require("warble/warble")

nd = sr.node
ln = core.liln
lf = core.lilf
plf = core.plilf
prmf = core.paramf

local g = warble.graph {
    sr = sr,
    diagraf = diagraf,
    sig = sig,
    core = core,

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

l = g:generate_nodelist()
g:compute(l)

lil("mul zz 0.2")

chksm = "8f8a56821de869cd887886421288d4b4"
rc, msg = pcall(lil, "verify " .. chksm)

verbose = os.getenv("VERBOSE")
if rc == false then
    if verbose ~= nil and verbose == "1" then
        print(msg)
    end
    os.exit(1)
else
    os.exit(0)
end


