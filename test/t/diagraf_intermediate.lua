diagraf = require("diagraf/diagraf")
sigrunes = require("sigrunes/sigrunes")
core = require("util/core")
pprint = require("util/pprint")

local g = diagraf.Graph:new{sig=sig}
local ng = core.nodegen(diagraf.Node, g)
local pg = core.paramgen(ng)
local con = g:connector()

sr = sigrunes

sine = ng(sr.sine) {freq = 440, amp = 0.5}
wavout = ng(sr.wavout) {file="test.wav"}

con(sine, wavout.input)

l = g:generate_nodelist()

-- g:compute(l)
lines = g:intermediate(l)

gen = ""

for _,ln in pairs(lines) do
    if type(ln) ~= "table" then
        error("expected table structure, got '" .. ln)
    end
    gen = gen .. table.concat(ln)
end


ref = "param440param0.5sinezzzzwavoutzztest.wav"

verbose = os.getenv("VERBOSE")

if ref ~= gen then
    if verbose ~= nil and verbose == "1" then
        print("different results generated:")
        print(ref)
        print(gen)
    end
    os.exit(1)
end
