function sound()
    local bs = require("blipsqueak/blipsqueak")
    comp = bs.components(bs.load_components())
    bs.load_data(comp)
    phrase = {"HELLO", "IAM", "PLEASED", "WELCOME"}
    pitchseq = "h1/ k2~ h1/ d h i2~ h4_"
    temposeq = "d1/ f d4 c"
    bs.speak(comp, phrase, pitchseq, temposeq)
    lil("mul zz [dblin -6]")
    lil([[
dup; dup;
bigverb zz zz 0.8 8000
drop;
dcblocker zz
mul zz [dblin -20];
add zz zz
    ]])
end

sound()
lil("wavout zz test.wav")
lil("computes 10")
