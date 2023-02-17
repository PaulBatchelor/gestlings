--[[
noodling with metal

-- <@>
dofile("gestku/2023_02_15.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
gestku = require("gestku/gestku")
G = gestku:new()

function G.symbol()
    return [[
---------
----#----
---###---
----#----
---------
----#----
---------
----#----
---------
----#----
--#####--
---------
]]
end
-- </@>

-- <@>
function G:init()
lil("opendb db /home/paul/proj/smp/a.db")
    lil([[ftlnew ftl
grab ftl
gensine [tabnew 8192 wt4]
ftladd zz
crtwavk [grab db] wt1 gkkfjirki
grab wt1
ftladd zz
crtwavk [grab db] wt2 gphqwqork
grab wt2
ftladd zz
crtwavk [grab db] wt3 ghirdoqwr
grab wt3
ftladd zz
gensinesum [tabnew 8192 wt5] "1 0 1 0 1 0 1 0 1" 1
ftladd zz
drop
]])

end
-- </@>
-- <@>
function articulate()
    G:compile_tal([[
|0100

%VAL { #26 DEO BRK }
%NUM { #24 DEO }
%DEN { #25 DEO }
%BHV { #27 DEO }

@wtpos1
#00 VAL #01 NUM #01 DEN #00 BHV
#01 VAL #01 NUM #01 DEN #00 BHV
#02 VAL #01 NUM #01 DEN #00 BHV
#03 VAL #01 NUM #01 DEN #00 BHV
#04 VAL #01 NUM #01 DEN #00 BHV
;wtpos1 JMP2

@wtpos2
#00 #26 DEO BRK
#01 #24 DEO
#01 #25 DEO
#00 #27 DEO
;wtpos2 JMP2

@wtpos3
#00 #26 DEO BRK
#01 #24 DEO
#01 #25 DEO
#00 #27 DEO
;wtpos3 JMP2

@wtpos4
#00 #26 DEO BRK
#01 #24 DEO
#01 #25 DEO
#00 #27 DEO
;wtpos4 JMP2
]])
end
-- </@>

-- <@>
function G:sound()
    --G:start()
    local gst = G.gest
    articulate()
    --G:compile()

    gst:swapper()
lil([[hold [phasor [rline 0.3 2 1] 0]; regset zz 1]])
membuf = "[grab " .. G.gest.bufname .. "]"
lil(string.format([[
gmorphfmnew %s [grab ftl] \
[gmemsym %s wtpos4] \
[gmemsym %s wtpos3] \
[gmemsym %s wtpos2] \
[gmemsym %s wtpos1] \
0

regset zz 0
]], gst:get(), membuf, membuf, membuf, membuf))

lil([[
# breath signal for phrasing

metro 2
tdiv zz 8 0
tgate zz 2
hold zz
regset zz 4

# random phrase line

rline 0 1 2
hold zz
regset zz 3

genvals [tabnew 1] "-3 -1 0 2 4 7 11 12"
regget 3
tseq [genvals [tabnew 1] "0.25 0.3750 0.25 0.625 0.25 0.75 0.25"] \
    [thresh [regget 4] 0.5 0] \
    [param 0]
swap
crossfade zz zz [regget 4]

phasor [scale [regget 3] 12 2] 0

scale [expmap [regget 3] 1] 0.7 0.3
qgliss zz zz zz zz

add zz 43
mtof zz
hold zz
regset zz 2

]])

lil([[
gmorphfmparam [regget 0] 0 frqmul 8
gmorphfmparam [regget 0] 0 fdbk 0
gmorphfmparam [regget 0] 0 modamt 0

gmorphfmparam [regget 0] 1 frqmul 4
gmorphfmparam [regget 0] 1 fdbk 0
gmorphfmparam [regget 0] 1 modamt 1

gmorphfmparam [regget 0] 2 frqmul 3
gmorphfmparam [regget 0] 2 fdbk 0
gmorphfmparam [regget 0] 2 modamt 1

gmorphfmparam [regget 0] 3 frqmul 1
gmorphfmparam [regget 0] 3 fdbk 0
gmorphfmparam [regget 0] 3 modamt [regget 3]

gmorphfm [regget 0] [regget 1] [regget 2]

mul zz 0.6
regget 4
adsr zz 1 0.1 0.9 0.5
scale zz 100 8000
butlp zz zz

regget 4
adsr zz 0.5 0.1 0.9 1.0

mul zz zz

]])

lil([[
dup; dup
bigverb zz zz 0.97 4000
drop
mul zz [dblin -30]
dcblocker zz
add zz zz

tenv [tick] 0.1 9 1
mul zz zz

unhold [regget 3]
unhold [regget 4]
unhold [regget 2]
unhold [regget 1]
]])
    gst:done()
end
-- </@>

function run()
    G:run()
end

return G
-- </@>
