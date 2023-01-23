
--[[
Goblin Vocal Warm-ups
-- <@>
dofile("gestku/2023_01_23.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
-- </@>
-- <@>
gestku = require("gestku/gestku")
warble = require("warble/warble")

s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)
G = gestku:new()

function G.symbol()
    return [[
-----------
#---------#
#--#---#--#
##-------##
----#-#----
----#-#----
-----------
--#######--
--#-----#--
-----------
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=56})
end


function pat(p)
    mel = "d4/ l d,2^"
    return {
        pitch = p.pitch or solf(mel),
        timbre = p.timbre or s16("a1/ o^"),
        amp = p.amp or s16("a1_"),
        fdbk = p.fdbk or s16("o a1"),
        gate = p.gate or s16("o6- o o o o o o4 o o o"),
        mod = p.mod or s16("b"),
        car = p.car or s16("b"),
    }
end

vocab = {
    A = pat {
        pitch = solf("d4/ l d,2^"),
        timbre = s16("a1/ o^"),
        amp = s16("a7_ a~"),
        fdbk = s16("o a1"),
        gate = s16("o6- o o o o o o4 o o o"),
        mod = s16("b"),
        car = s16("b"),
    },

    B = pat {
        pitch = solf("d,,/ s,, d,,,~"),
        amp = s16("a1/ o5^ o"),
        gate = s16("a1_"),
        timbre = s16("b/ o c^"),
        fdbk = s16("o^"),
        mod = s16("d/ b~"),
        car = s16("b^ f"),
    },

    C = pat {
        pitch = solf("l,,,~"),
        amp = s16("o^"),
        gate = s16("a1_"),
        timbre = s16("o"),
        fdbk = s16("g^"),
        mod = s16("d/ b"),
        car = s16("c/"),
    },

    D = pat {
        pitch = solf("d,,/ r,,/ d,,~"),
        amp = s16("o^"),
        gate = s16("a1_"),
        timbre = s16("h/ o^"),
        fdbk = s16("c^"),
        mod = s16("c/ d~"),
        car = s16("b_"),
    },

    E = pat {
        pitch = solf("D/ D'^"),
        timbre = s16("a1/ b~"),
        amp = s16("a7_ a~"),
        fdbk = s16("o a1"),
        gate = s16("o1 o o o o2 o o3 o o4 o o2 o1 o o"),
        mod = s16("b"),
        car = s16("b"),
    },

    F = pat {
        pitch = solf("d,,,1/ d,,4/ r,,+4^"),
        amp = s16("o3~ o1"),
        gate = s16("a1_"),
        timbre = s16("o"),
        fdbk = s16("g^ o~"),
        mod = s16("b"),
        car = s16("b/ c~"),
    },

    S = {
        pitch = solf("d,1^"),
        timbre = s16("d2/o1"),
        fdbk = s16("a^"),
        amp = s16("a3 a~"),
        gate = s16("a_"),
        mod = s16("b~"),
        car = s16("b~"),
    },
}
SEQ = "A4(BB)S2(B)CDS2[ECF]2[S]"
SEQ = gestku.mseq.parse(SEQ, vocab)

head = {
    gate = function(words)
        gestku.tal.interpolate(words, 0)
    end

}

-- </@>

-- <@>
function G:sound()
    local lvl = gestku.core.liln
    local sr = gestku.sr
    local pn = sr.paramnode
    local ln = sr.node
    local sig = gestku.sig
    local cnd = sig:new()
    local gst = G.gest
    local param = gestku.core.paramf

    ln(sr.phasor) {
        rate = 13 / 10
    }

    cnd:hold()

    local seq = SEQ

    G:start()
    G:articulate(seq, head)
    G:compile()

	gst:swapper()

    fg = pn(gst:node()) {
        name = "pitch",
        conductor = lvl(cnd:getstr())
    }

    tg = gest16(gst, "timbre", cnd, 0.3, 4.8)
    vdepth  = gest16(gst, "timbre", cnd, 0.0, 0.4)
    vrate = gest16(gst, "timbre", cnd, 6, 7)

    ag = gest16(gst, "amp", cnd, 0, 0.8)

    fdbk = gest16(gst, "fdbk", cnd, 0, 0.5)

    gate = gest16(gst, "gate", cnd, 0, 1)

    mod = pn(gst:node()) {
        name = "mod",
        conductor = lvl(cnd:getstr())
    }

    car = pn(gst:node()) {
        name = "car",
        conductor = lvl(cnd:getstr())
    }

    local g = warble.graph {
        pitch = fg,
        mi = tg,
        fdbk = fdbk,
        amp = {
            val = ag,
            gate = gate,
            dur = param(0.005),
            atk = param(0.005),
            rel = param(0.01),
        },
        mod = mod,
        car = car,
        diagraf = gestku.diagraf,
        sr = sr,
        sig = sig,
        core = gestku.core,

        vib = {
            rate = vrate,
            depth = param(0.0),
        }
    }

	l = g:generate_nodelist()
	g:compute(l)

	gst:done()
    cnd:unhold()

    lil("mul zz [dblin -10]")
    lil([[
dup;
dup;
bigverb zz zz 0.6 4000
drop;
dcblocker zz
mul zz [dblin -15];
add zz zz
    ]])


    lil("tgate [tick] 10; smoother zz 0.01; mul zz zz")
end

function run()
    G:sound()
    lil("out")
end

function G.patch()
    G:setup()
    G:sound()
end

return G
-- </@>
