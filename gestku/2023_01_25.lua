--[[
goblin waking up from a nap in their cave
-- <@>
dofile("gestku/2023_01_25.lua")
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
#---------#
##-------##
-----------
-###---###-
-----------
--#-----#--
-----------
----#-#----
-----------
-#########-
-#-------#-
-----------
]]
end
-- </@>


-- <@>

function solf(s)
    return gestku.nrt.eval(s, {base=30})
end

function pat(p)
    return {
        pitch = p.pitch or solf("d,1/ r t,,_"),
        timbre = p.timbre or s16("b/ o b_"),
        amp = p.amp or s16("a1/ o4~ a1_"),
        fdbk = p.fdbk or s16("a/ h a_"),
        mod = p.mod or s16("b/ d b d b d_"),
        car = p.car or s16("f/ b"),
        gate =  p.gate or s16("a_"),
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


mel = "d4/ l d,2^"

chit = {
    pitch = solf("d,1/ r t,,_"),
    timbre = s16("f~ b"),
    amp = s16("a4~"),
    fdbk = s16("b"),
    mod = s16("d_"),
    car = s16("b_"),
    gate =  s16("o-"),
    aspgt = s16("a_"),
    gain = s16("o_"),
    ampdur = s16("b_"),
}

grunt = pat {
    pitch = solf("d,1_"),
    timbre = s16("a/ g^ a_"),
    amp = s16("a1/ o4~ a1_"),
    fdbk = s16("a/ l^ a_"),
    mod = s16("b/ d b d b d_"),
    car = s16("d/ b"),
    gate =  s16("a_"),
    aspgt = s16("a_"),
    gain = s16("o_"),
    gdur = s16("a_"),
    ampdur = s16("c_"),
}

vocab = {
    A = clone(grunt),
    B = clone(chit),

    C = clone(chit, {
        pitch = solf("d'1/ r' t,_"),
        fdbk = s16("a~"),
        timbre = s16("h~"),
    }),

    D = clone(chit, {
        pitch = solf("d/ d'"),
        fdbk = s16("a~"),
        timbre = s16("h/ f h f"),
        ampdur = s16("g_"),
        amprel = s16("n_"),
        ampatk = s16("n_"),
    }),

    E = clone(grunt, {
        pitch = solf("d/ r f l, d,"),
        timbre = s16("a/ d^ b f b"),
        mod = s16("b_"),
        car = s16("b_"),
    }),

    S = pat {
        pitch = solf("d1~"),
        timbre = s16("o1~"),
        fdbk = s16("a_"),
        amp = s16("a_"),
        mod = s16("b"),
        car = s16("b"),
        aspgt = s16("o1_"),
        gate = s16("o1_ "),
        gain = s16("a_"),
    },
}
head = {
    gate = function(words)
        gestku.tal.interpolate(words, 0)
    end,
    aspgt = function(words)
        gestku.tal.interpolate(words, 0)
    end

}
--SEQ = "4[A]S"
SEQ = "2[A]8(BBCD)2(SDS)3(BB)S4(BB)S3[E]S5(BBC)2[S]"
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
            dur = param(0.1),
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


    lil("softclip zz 7")
    lil("lowshelf zz 200 8.0 0.5")
    lil("mul zz [dblin -15]")
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
