-- WIP
-- construct a morpheme using seq and paths, and map it
-- to actual sound parameters

pp = require("util/pprint")
asset = dofile("asset/asset.lua")
asset = asset:new {
    msgpack = dofile("util/MessagePack.lua"),
    base64 = dofile("util/base64.lua")
}
symtools = require("util/symtools")

symtab = asset:load("seq/test_syms_tab.b64")

local function tcat(dst, src)
    for _,v in pairs(src) do
        table.insert(dst, v)
    end
end

function tokens_to_string(symtab, tk)

    local str = "sym_"

    for _,v in pairs(tk) do
        str = str .. symtab[v]
    end

    return str
end

function generate_tokens(symtab)
    symtools.vars(symtab)()
    local morph_name = {lbrack, parallel, rbrack, rtee, dash}
    local pitch_name = {dash, rtee, rtee}
    local brightness_name = {groundsky, skydash, dashground}
    local tk = {}
    tcat(tk, {morph_begin})
    tcat(tk, morph_name)
    tcat(tk, {morph_break})

    tcat(tk, {morph_line_begin})
    tcat(tk, pitch_name)
    tcat(tk, {morph_define,
            bracket_left,
            zero, zero,
            ratemulstart, zero, one, ratemulend, gliss_medium,
            divider,

            zero, four,
            divider,

            zero, seven,
            divider,

            zero, eleven,
            divider,

            zero, fourteen,
            divider,

            zero, eleven,
            divider,

            zero, seven,
            divider,

            zero, four,

            bracket_right,
        morph_break})

    tcat(tk, {morph_line_begin})
    tcat(tk, brightness_name)
    tcat(tk, {morph_define,
            seq_val0, seq_dur1, seq_linear,
            seq_val16, seq_dur1,
            seq_end,
        morph_break,
        morph_end, morph_break})
    local lookup = {
        name = tokens_to_string(symtab, morph_name),
        pitch = tokens_to_string(symtab, pitch_name),
        brightness = tokens_to_string(symtab, brightness_name)
    }

    return tk, lookup
end

function gfx_setup()
    lil("bpnew bp 320 200")
    lil("bufnew buf 256")
    lil("bpset [grab bp] 0 10 10 300 180")
    lil("uf2load syms seq/test_syms.uf2")
    lil("uf2load chicago fonts/chicago12.uf2")
end

function get_text_buffer()
    lil("grab buf")
    local buf = pop()
    return buf
end

function draw(tokens)
    buf = get_text_buffer()

    bytes = {}
    for _,t in pairs(tokens) do
        table.insert(bytes, symtab[t])
    end

    lil("uf2txtln [bpget [grab bp] 0] [grab chicago] 0 0 'Morpheme Notation Sound Test'")

    line = {}
    mnobuf.clear(buf)
    linepos = 2
    lineheight = 12
    for _,b in pairs(bytes) do
        if b == symtab["morph_break"] then
            mnobuf.append(buf, line)
            lil(string.format(
                "uf2bytes [bpget [grab bp] 0] [grab syms] [grab buf] 0 %d",
                linepos * lineheight))
            linepos = linepos + 1
            mnobuf.clear(buf)
            line = {}
        end
        table.insert(line, b)
    end

    -- lil("bppbm [grab bp]")
end

morpheme_tokens, lookup = generate_tokens(symtab)

gfx_setup()
draw(morpheme_tokens)

chksm="c48701ad34ad33b0e890ec4ed0442734"
rc, msg = pcall(lil, "bpverify [grab bp] " .. chksm)

verbose = os.getenv("VERBOSE")
if rc == false then
    if verbose ~= nil and verbose == "1" then
        error(msg)
    end
    os.exit(1)
end


loadfile("path/grammar.lua")()
path_grammar = generate_path_grammar(symtab)
loadfile("seq/grammar.lua")()
seq_grammar = generate_seq_grammar(symtab)

loadfile("morpheme/grammar.lua")()

local notations = {
    path = path_grammar,
    seq = seq_grammar,
}
morpheme_grammar = generate_morpheme_grammar(symtab, notations)

hexstr = symtools.hexstring(symtab, morpheme_tokens)
-- TODO: we need a way for this tree to support multiple
-- notation systems for gesture paths...
--
-- pat = lpeg.Ct(morpheme_grammar * lpeg.Cg(lpeg.Cc("world"), "hello"))
pat = lpeg.Ct(morpheme_grammar)
t = lpeg.match(pat, hexstr)
-- pp(t[1].attributes[1].path_type)
seq = require("seq/seq")
path = require("path/path")
seqtree = t[1].attributes[2]
-- pp(seq.parse_tree(seqtree.path))
-- pp(seqtree.attribute)
-- pp(lookup)

-- produce morpheme from tree
local m = {}


for _,att in pairs(t[1].attributes) do
    local aname = tokens_to_string(symtab, att.attribute)
    local p = nil

    if att.path_type == "path" then
        p = path.AST_to_data(att.path)
    elseif att.path_type == "seq" then
        p = seq.parse_tree(att.path)
    end
    m[aname] = p
end

-- pp(m)

tal = require("tal/tal")
morpheme = require("morpheme/morpheme")

-- hook up morpheme to gestvm
diagraf = require("diagraf/diagraf")
gest = require("gest/gest")
sigrunes = require("sigrunes/sigrunes")
sig = require("sig/sig")
core = require("util/core")


grf = diagraf.Graph:new{sig=sig}
sr = sigrunes
ng = core.nodegen(diagraf.Node, grf)
pg = core.paramgen(ng)
pn = sr.paramnode
con = grf:connector()
gst = gest:new{tal=tal}
gst:create()

words = {}
tal.begin(words)
mseq = {{m, {1, 2}}}
morpheme.articulate(path, tal, words, mseq)
gst:compile(words)

cnd = ng(sr.phasor) {rate = 2}

pitch = ng(gst:node()) {name = lookup["pitch"]}
con(cnd, pitch.conductor)
mtof = ng(sr.mtof) {}

add1 = ng(sr.add){b=48 + 3}

con(pitch, add1.a)
con(add1, mtof.input)
saw = ng(sr.blsaw){}
con(mtof, saw.freq)
cutoff = ng(sr.scale){min=200, max=2000, input=1}
butlp = ng(sr.butlp){}

brightness = ng(gst:node()) {name = lookup["brightness"]}
con(cnd, brightness.conductor)
mul2 = ng(sr.mul) {b=1.0/16}
con(brightness, mul2.a)
con(mul2, cutoff.input)
con(cutoff, butlp.cutoff)
con(saw, butlp.input)

mul1 = ng(sr.mul){b=0.3}
con(butlp, mul1.a)

l = grf:generate_nodelist()
grf:compute(l)

chksm="be8ffb2455ffd07b1f33b3aa5a9ce0ed"
rc, msg = pcall(lil, "verify " .. chksm)

if rc == false then
    if verbose ~= nil and verbose == "1" then
        error(msg)
    end
    os.exit(1)
end
-- lil("wavout zz test.wav")
-- lil("computes 10")
