msgpack = require("util/MessagePack")
base64 = require("util/base64")
asset = require("asset/asset")
asset = asset:new({msgpack=msgpack, base64=base64})
symtools = require("util/symtools")
seq_grammar = loadfile("seq/grammar.lua")
seq_grammar()
seq = require("seq/seq")

symtab = asset:load("seq/test_syms_tab.b64")
symtools.vars(symtab)()
tokens = {
    seq_val8, seq_dur1, seq_dur2, seq_linear,
    seq_val1, seq_dur2,
    seq_val9, seq_dur3, seq_step,
    seq_val15, seq_dur4,
    seq_val11, seq_dur5,
    seq_val3, seq_dur6, seq_linear,
    seq_val4, seq_dur7,
    seq_val10, seq_dur8, seq_gliss_small,
    seq_val16, seq_dur1,
    seq_val8, seq_dur8, seq_gliss_big,
    seq_val0,
    seq_val3,
    seq_val5, seq_gliss_big,
    seq_end
}
    
linear = 0
step = 1
gliss_medium = 2
gliss_big = 3
gliss_small = 4

expected = {
    8, 10, linear,
    1, 2, linear,
    9, 3, step,
    15, 4, step,
    11, 5, step,
    3, 6, linear,
    4, 7, linear,
    10, 8, gliss_small,
    16, 1, gliss_small,
    8, 8, gliss_big,
    0, 8, gliss_big,
    3, 8, gliss_big,
    5, 8, gliss_big,
}

grammar = generate_seq_grammar(symtab)

hexstr = symtools.hexstring(symtab, tokens)
t = lpeg.match(lpeg.Ct(grammar), hexstr)
gpath = seq.parse_tree(t)

generated = {}

for _, v in pairs(gpath) do
    table.insert(generated, v[1])
    table.insert(generated, v[2])
    table.insert(generated, v[3])
end

expected = table.concat(expected, " ")
generated = table.concat(generated, " ")

verbose = os.getenv("VERBOSE")

if expected ~= generated then
    if verbose ~= nil and verbose == "1" then
        print("different results generated:")
        print(expected)
        print(generated)
    end
    os.exit(1)
end
