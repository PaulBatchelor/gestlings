sig = require("sig/sig")

s = sig:new()
b = sig:new()
a = sig:new()

lil("metro 2")
s:hold()

lil("metro 6")
b:hold()
b:unhold()

lil("metro [rline 2 4 2]")
a:hold()

s:get()
lil("env zz 0.001 0.01 0.1")
lil("sine 600 0.3")
lil("mul zz zz")

a:get()
lil("env zz 0.001 0.01 0.1")
lil("sine 700 0.3")
lil("mul zz zz")
lil("add zz zz")

lil("wavout zz test.wav; computes 10")
