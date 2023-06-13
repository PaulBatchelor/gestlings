warble = require("warble/warble")

msgpack = require("util/MessagePack")
base64 = require("util/base64")
asset = require("asset/asset")
asset = asset:new({msgpack=msgpack, base64=base64})

core = require("util/core")
sigrunes = require("sigrunes/sigrunes")
gest = require("gest/gest")
tal = require("tal/tal")
morpheme = require("morpheme/morpheme")
path = require("path/path")
seq = require("seq/seq")
morpho = require("morpheme/morpho")
mseqlang = require("morpheme/mseq")
sig = require("sig/sig")

pprint = require("util/pprint")

function mkseq(seq, morpho)
    vocab = asset:load("blipsqueak/morphemes.b64")
    words = asset:load("blipsqueak/words.b64")

    SEQ = words.HELLO .. words.IAM .. words.PLEASED .. words.WELCOME
    SEQ = mseqlang.parse(SEQ, vocab)
    return SEQ
end

function create_aligned_path(path, tal, words, mseq, gpath, name)
    gpath_rescaled = path.scale_to_morphseq(gpath, mseq)

    tal.label(words, name)
    path.path(tal, words, gpath_rescaled)
    tal.jump(words, name)
end

function mkconductor(sig, sr, rate)
    local cnd = sig:new()
    sr.node(sr.phasor) {
        rate = 14 / 10
    }
    cnd:hold()

    return cnd
end

function apply_register_macros(patch, patch_data, free, ext)
    -- generate inverse lookup table for registers
    ilookup = {}
    extlookup = {}

    ext = ext or {}

    for k,v in pairs(patch_data.setters) do
        ilookup[v] = k
    end

    for k,v in pairs(ext) do
        extlookup[v] = k
    end

    newpatch = {}

    for _, oldline in pairs(patch) do
        line = {}

        for _, v in pairs(oldline) do
            table.insert(line, v)
        end

        if line[1] == "regget" and type(line[2]) == "table" then
            if line[2].macro == "reg" then
                line[2] = free[line[2].index]
            elseif line[2].macro == "extreg" then
                line[2] = ext[line[2].key]
            end
        elseif line[1] == "regset" and type(line[3]) == "table" then
            if line[3].macro == "reg" then
                line[3] = free[line[3].index]
            end
        elseif line[1] == "regclr" and type(line[2]) == "table" then
            if line[2].macro == "reg" then
                line[2] = free[line[2].index]
            end
        elseif line[1] == "regmrk" and type(line[2]) == "table" then
            if line[2].macro == "reg" then
                line[2] = free[line[2].index]
            end
        end
        table.insert(newpatch, line)
    end

    -- pprint(newpatch)
    return newpatch
end

function sound()
    local lvl = core.liln
    local sr = sigrunes
    local pn = sr.paramnode
    local ln = sr.node
    local cnd = sig:new()
    local gst = gest:new{tal=tal}
    local param = core.paramf
    local words = {}

    gst:create()
    local mseq = mkseq(seq, morpho)

    words = {}
	tal.start(words)

    head = {
        gate = function(words)
            tal.interpolate(words, 0)
        end,
        aspgt = function(words)
            tal.interpolate(words, 0)
        end

    }

    local s16 = seq.seqfun(morpho)

    global_pitch = s16("h1/ k2~ h1/ d h i2~ h4_")
    global_tempo = s16("d1/ f d4 c")

    create_aligned_path(path, tal, words, mseq, global_pitch, "gpitch")
    create_aligned_path(path, tal, words, mseq, global_tempo, "gtempo")

	morpheme.articulate(path, tal, words, mseq, head)

    gst:compile(words)

	gst:swapper()

    cnd = mkconductor(sig, sr, 14/10)

    lines = asset:load("blipsqueak/mechanism.b64")

    ext = {
        cnd = cnd.reg
    }

    -- TODO: dynamically select/mark free registers based
    -- on data contents

    free = {7, 8}
    info = lines.info

    lines = apply_register_macros(lines.patch, info, free, ext)
    for _, l in pairs(lines) do
        if type(l) == "string" then
            error("expected table structure: '" .. l .. "'")
        end

        lil(table.concat(l, " "))
    end

    cnd:unhold()
	gst:done()

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
