--[[
WIP.

-- <@>
dofile("gestku/2023_02_17.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
pprint = require("util/pprint")
-- </@>

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
    G:start()
    local b = gestku.gest.behavior
    local gm = b.gliss_medium
    local lin = b.linear

    local M = {
        seq = gestku.nrt.eval("d4 r m f s f m2", {base=58}),
        wtpos1 = {
            {0, 1, gm},
            {0, 1, gm},
            {0, 1, gm},
            {1, 1, gm},
            {2, 1, gm},
            {3, 1, gm},
            {4, 2, lin},
        }
    }

    G:articulate({{M, {1,4}}})

    tal_code = [[
%VAL { #26 DEO BRK }
%NUM { #24 DEO }
%DEN { #25 DEO }
%BHV { #27 DEO }

( @wtpos1
#00 VAL #01 NUM #01 DEN #00 BHV
#01 VAL #01 NUM #01 DEN #00 BHV
#02 VAL #01 NUM #01 DEN #00 BHV
#03 VAL #01 NUM #01 DEN #00 BHV
#04 VAL #01 NUM #01 DEN #00 BHV
;wtpos1 JMP2 )

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
]]

    G:compile_words_and_tal(tal_code)
end
-- </@>

-- <@>
function G:sound()
    local gst = G.gest
    articulate()
    gst:swapper()
lil([[hold [phasor 1 0]; regset zz 1]])
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

gestku.sr.node(G.gest:node()) {
    name = "seq",
    conductor = gestku.core.liln("regget 1")
}

lil([[
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
gmorphfmparam [regget 0] 3 modamt 1

gmorphfm [regget 0] [regget 1] [regget 2]

mul zz 0.6

]])

lil([[
dup; dup
bigverb zz zz 0.6 4000
drop
mul zz [dblin -10]
dcblocker zz
add zz zz

tenv [tick] 0.1 9 1
mul zz zz

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
