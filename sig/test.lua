sig = require("sig/sig")

s = sig:new()
b = sig:new()
a = sig:new()

lil("metro 2")
s:hold()

lil("metro 6")
b:hold()
b:unhold()

b:zero()

lil("metro [rline 2 4 2]")
a:hold()

s:get()
lil("env zz 0.001 0.01 0.1")
lil("sine 600 0.3")
lil("mul zz zz")
b:throw(-6)

a:get()
lil("env zz 0.001 0.01 0.1")
lil("sine 700 0.3")
lil("mul zz zz")
b:throw(-6)
lil("add zz zz")

b:get()
lil([[
dup; bigverb zz zz 0.9 10000;
drop;
mul zz [dblin -3];
dcblocker zz
add zz zz
]]
)

a:unhold()
b:unhold()
s:unhold()
lil("wavout zz test.wav; computes 10")
