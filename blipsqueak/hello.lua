pprint = require("util/pprint")

function resolve(seq, lookup)
    local o = {}

    for _, v in pairs(seq) do
        table.insert(o, {lookup[v[1]], v[2]})
    end

    return o
end

function mcat(tab)
    local o = {}

    for _,w in pairs(tab) do
        for _,m in pairs(w) do
            table.insert(o, m)
        end
    end

    return o
end

function mkseq(phrase)
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

function load_component(comp, top_path, name, filepath)
    if comp[name] == nil then
        comp[name] = dofile(top_path .. filepath .. ".lua")
        return true
    end

    return false
end

function load_blipsqueak_components(comp, top_path)
    top_path = top_path or ""
    comp = comp or {}

    load_component(comp, top_path, "core", "util/core")
    load_component(comp, top_path, "sigrunes", "sigrunes/sigrunes")
    load_component(comp, top_path, "gest", "gest/gest")
    load_component(comp, top_path, "morpheme", "morpheme/morpheme")
    load_component(comp, top_path, "path", "path/path")
    load_component(comp, top_path, "seq", "seq/seq")
    load_component(comp, top_path, "morpho", "morpheme/morpho")
    load_component(comp, top_path, "tal", "tal/tal")
    load_component(comp, top_path, "sig", "sig/sig")
    load_component(comp, top_path, "warble", "warble/warble")
    load_component(comp, top_path, "msgpack", "util/MessagePack")
    load_component(comp, top_path, "base64", "util/base64")
    local loaded = load_component(comp, top_path, "asset", "asset/asset")

    if loaded then
        comp.asset = comp.asset:new {
            msgpack = comp.msgpack,
            base64 = comp.base64
        }
    end

    return comp
end

function blipsqueak_components(o)
    local comp = {}
    o = o or {}
    comp.sigrunes = o.sigrunes or sigrunes
    assert(comp.sigrunes ~= nil, "sigrunes not found")
    comp.core = o.core or core
    assert(comp.core ~= nil, "core not found")
    comp.tal = o.tal or tal
    assert(comp.tal ~= nil, "tal not found")
    comp.gest = o.gest or gest
    assert(comp.gest ~= nil, "gest not found")
    comp.asset = o.asset or asset
    assert(comp.asset ~= nil, "asset not found")
    comp.morpho = o.morpho or morpho
    assert(comp.morpho ~= nil, "morpho not found")
    comp.seq = o.seq or seq
    assert(comp.seq ~= nil, "seq not found")
    comp.sig = o.sig or sig
    assert(comp.sig ~= nil, "sig not found")
    comp.path = o.path or path
    assert(comp.path ~= nil, "path not found")
    comp.warble = o.warble or warble 
    assert(comp.warble ~= nil, "warble not found")
    comp.morpheme = o.morpheme or morpheme
    assert(comp.morpheme ~= nil, "morpheme not found")
    comp.msgpack = o.msgpack or msgpack
    assert(comp.msgpack ~= nil, "msgpack not found")
    comp.base64 = o.base64 or base64
    assert(comp.msgpack ~= nil, "base64 not found")
    comp.asset = o.asset or asset
    assert(comp.msgpack ~= nil, "asset not found")

    return comp
end

function blipsqueak_speak(comp, phrase, pitchseq, temposeq)
    local lvl = comp.core.liln
    local sr = comp.sigrunes
    local pn = sr.paramnode
    local ln = sr.node
    local cnd = comp.sig:new()
    local gst = comp.gest:new{tal=comp.tal}
    local param = comp.core.paramf
    local words = {}

    gst:create()

    vocab = comp.asset:load("blipsqueak/morphemes.b64")
    words = comp.asset:load("blipsqueak/words.b64")

    phrase_morphs = {}

    for _, wrd in pairs(phrase) do
        table.insert(phrase_morphs, words[wrd])
    end

    SEQ = mcat(phrase_morphs)
    mseq = resolve(SEQ, vocab)

    words = {}
	comp.tal.start(words)

    head = {
        gate = function(words)
            comp.tal.interpolate(words, 0)
        end,
        aspgt = function(words)
            comp.tal.interpolate(words, 0)
        end

    }

    local s16 = comp.seq.seqfun(comp.morpho)

    global_pitch = s16(pitchseq)
    global_tempo = s16(temposeq)

    create_aligned_path(comp.path, comp.tal, words, mseq, global_pitch, "gpitch")
    create_aligned_path(comp.path, comp.tal, words, mseq, global_tempo, "gtempo")

	comp.morpheme.articulate(comp.path, comp.tal, words, mseq, head)

    gst:compile(words)

	gst:swapper()

    cnd = mkconductor(comp.sig, sr, 14/10)

    lines = comp.asset:load("blipsqueak/mechanism.b64")

    ext = {
        cnd = cnd.reg
    }

    info = lines.info

    -- dynamically select/mark free registers based on number
    -- of setters
    free = {}

    for _=1,#info.setters do
        lil("param [regnxt 0]")
        local r = pop()
        lil("regmrk " .. r)
        table.insert(free, r)
    end

    lines = comp.core.apply_register_macros(lines.patch, info, free, ext)
    for _, l in pairs(lines) do
        if type(l) == "string" then
            error("expected table structure: '" .. l .. "'")
        end

        lil(table.concat(l, " "))
    end

    cnd:unhold()
	gst:done()
end

function sound()
    comp = blipsqueak_components(load_blipsqueak_components())
    phrase = {"HELLO", "IAM", "PLEASED", "WELCOME"}
    pitchseq = "h1/ k2~ h1/ d h i2~ h4_"
    temposeq = "d1/ f d4 c"
    blipsqueak_speak(comp, phrase, pitchseq, temposeq)
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
