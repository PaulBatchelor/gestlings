--[[
goblin deciding what to order for lunch
-- <@>
dofile("gestku/2023_01_26.lua")
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
#-------#
#-#####-#
#-------#
##-#-#-##
#-------#
#-#-----#
---#-----
----#----
---------
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=50})
end

function pat(p)
    return {
        pitch = p.pitch or solf("r t,,_"),
        timbre = p.timbre or s16("b/ o b_"),
        amp = p.amp or s16("a1/ o4~ a1_"),
        fdbk = p.fdbk or s16("a/ h a_"),
        mod = p.mod or s16("b/ d b d b d_"),
        car = p.car or s16("f/ b"),
        gate =  p.gate or s16("a_"),
        aspdur = p.aspdur or s16("h_"),
        aspgt = p.aspgt or s16("a_"),
        gain = p.gain or s16("o_"),
        gdur = p.gdur or s16("a_"),
        ampdur = p.ampdur or s16("c_"),
        ampatk = p.atk or s16("c_"),
        amprel = p.rel or s16("c_"),
    }
end

function clone(M, p)
    local o = {}
    p = p or {}

    for k,v in pairs(M) do
        o[k] = p[k] or v
    end

    return o
end

sigh = pat {
    pitch = solf("d'2/ d4~"),
    timbre = s16("d~"),
    amp = s16("a1/ o4~ a1_"),
    fdbk = s16("b_"),
    mod = s16("b_"),
    car = s16("b_"),
    gate =  s16("a_"),
    aspgt = s16("o-"),
    aspdur = s16("k_"),
    gdur = s16("a_"),
    gain = s16("o_"),
    ampdur = s16("c_"),
}

muttering = clone(sigh, {
    pitch = solf("s4/ d r d s s, d2~"),
    timbre = s16("b/ f~"),
    aspgt = s16("a_"),
})

vocab = {
    A = clone(sigh),
    B = clone(muttering),
    C = clone(muttering, {
        pitch = solf("l1^ d4/ r l, r~ l,/ d s"),
		aspgt = s16("a_ a_ o- o- o-"),
		aspdur = s16("a_"),
    }),
    D = clone(sigh, {
        pitch = solf("l/ l,~"),
		aspdur = s16("g_"),
    }),

    S = clone(sigh, {
        gain = s16("a_")
    })
}

head = {
    gate = function(words)
        gestku.tal.interpolate(words, 0)
    end,
    aspgt = function(words)
        gestku.tal.interpolate(words, 0)
    end

}
SEQ = "2[ASBS]CSS2[D]S"
SEQ = gestku.mseq.parse(SEQ, vocab)

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

    tg = gest16(gst, "timbre", cnd, 0.0, 10)
    vdepth  = gest16(gst, "timbre", cnd, 0.0, 0.4)
    vrate = gest16(gst, "timbre", cnd, 6, 7)

    ag = gest16(gst, "amp", cnd, 0, 0.8)

    fdbk = gest16(gst, "fdbk", cnd, 0, 0.9)

    gate = gest16(gst, "gate", cnd, 0, 1)

    ampdur = gest16(gst, "ampdur", cnd, 0.003, 0.6)
    aspdur = gest16(gst, "aspdur", cnd, 0.003, 0.6)

    aspgt = gest16(gst, "aspgt", cnd, 0, 1)

    mod = pn(gst:node()) {
        name = "mod",
        conductor = lvl(cnd:getstr())
    }

    car = pn(gst:node()) {
        name = "car",
        conductor = lvl(cnd:getstr())
    }

    ampatk = gest16(gst, "ampatk", cnd, 0.003, 0.3)
    amprel = gest16(gst, "amprel", cnd, 0.003, 0.3)

    local g = warble.graph {
        pitch = fg,
        mi = tg,
        fdbk = fdbk,
        amp = {
            val = ag,
            gate = gate,
            dur = ampdur,
            atk = ampatk,
            rel = amprel,
        },
        mod = mod,
        car = car,
        diagraf = gestku.diagraf,
        sr = sr,
        sig = sig,
        core = gestku.core,

        vib = {
            rate = vrate,
            depth = param(0),
        },

        asp = {
            gate = aspgt,
            dur = aspdur,
            atk = param(0.01),
            rel = param(0.3),
            val = param(0.0),
            gain = param(2.5),
            bw = param(150),
            freq = param(400),
        },
    }

	l = g:generate_nodelist()
	g:compute(l)

    ln(sr.smoother) {
        input = gest16(gst, "gain", cnd, 0, 0.5),
        smooth = 0.008,
    }

    lil("mul zz zz")

	gst:done()
    cnd:unhold()


    -- lil("softclip zz 7")
    -- lil("lowshelf zz 200 8.0 0.5")
    lil("mul zz [dblin -6]")
    lil([[
dup; dup;
bigverb zz zz 0.85 8000
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
