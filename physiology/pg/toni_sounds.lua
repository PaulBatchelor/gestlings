--[[
-- <@>
dofile("physiology/pg/toni_sounds.lua")
-- </@>
--]]

core = require("util/core")
rt = require("util/rt")
lilt = core.lilt
lilts = core.lilts
sig = require("sig/sig")
zz = "zz"

function setup()
end

-- <@>
function patch(phystoni)
    local pt = phystoni.create {
        sig = sig,
    }

    -- set up tract filter, use fixed shape for testing
    local tubular = pt.tubular
    local shape = {
        0.1, 0.1, 0.1, 0.1, 0.1, 0.4, 0.3, 0.9
    }

    phystoni.fixed_tube_shape(sig, tubular, shape)

    -- create excitation signal
    local pitch, trig, gate = phystoni.tempwhistlesigs()

    phystoni.excitation(sig, core, pitch, trig, gate)
    pitch:unhold()
    trig:unhold()

    local exc = sig:new()
    exc:hold()

    -- process excitation with tract filter
    phystoni.filter(tubular, exc)
    exc:unhold()
    phystoni.gate(gate)
    gate:unhold()
    phystoni.postprocess()
    phystoni.clean(pt)
end
-- </@>
-- [[
-- <@>
lil("unholdall")
-- </@>
-- ]]

-- lilt {"wavout", zz, "tmp/test.wav"}

-- lil("computes 10")
setup()
rt.setup()

-- <@>
function run()
    local phystoni = dofile("physiology/phys_toni.lua")
    patch(phystoni)
    rt.out()
end
-- </@>
