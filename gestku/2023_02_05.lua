--[[
down in the muck
-- <@>
dofile("gestku/2023_02_05.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
gestku = require("gestku/gestku")
G = gestku:new()

function G.symbol()
    return [[
-----------
-###-#-###-
-----#-----
-###-#-###-
-----#-----
-###-#-###-
-----#-----
-###-#-###-
-----------
]]
end
-- </@>

-- <@>
function G:sound()
lil([[
sine 0.2 1
hold zz
regset zz 0

sine [rline 4 12 1] 1
hold zz
regset zz 1

gensinesum [tabnew 8192] "1 1 1 1 0 0 0.1 0.1" 1
gensinesum [tabnew 8192] "1 1 0 0.5 0 0.2" 1
oscmorph zz zz \
[mtof [smoother [add 27 [mul [tog [metro [expr 1 / 4 ] ] ] 3] ] [param 0.1] ] ] \
[biscale [regget 1] 0 1] \
[biscale [regget 0] 0.1 1.9]
mul zz 2.5

gensinesum [tabnew 8192] "1 1 1 1 0 0 0.1 0.1" 1
gensinesum [tabnew 8192] "1 1 0 0.5 0 0.2" 1
oscmorph zz zz \
[mtof 46] \
[biscale [regget 1] 0 1] \
[biscale [regget 0] 0.1 1.0]
mul zz [rline 0.1 0.2 0.1]
mul zz 4.5

add zz zz
softclip zz 3.5
valp1 zz 1000

dup
vardelay zz 0.9 0.2 2.0
buthp zz 2000
mul zz [dblin 8]
add zz zz

unhold [regget 0]
unhold [regget 1]
]])
end
-- </@>

function run()
    G:run()
end

return G
-- </@>
