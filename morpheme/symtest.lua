uf2 = dofile("../path/uf2.lua")
symbols = require("attribute_symbols")
psymbols = dofile("../path/symbols.lua")
symtools= dofile("../util/symtools.lua")
pp = dofile("../util/pprint.lua")

msgpack = dofile("../util/MessagePack.lua")
base64 = dofile("../util/base64.lua")
asset = dofile("../asset/asset.lua")
asset = asset:new({msgpack=msgpack, base64=base64})

function append_symbols(dst, src)
    local off = 0
    for _,v in pairs(dst) do
        if v.id > off then
            off = v.id
        end
    end

    for k, v in pairs(src) do
        dst[k + off] = src[k]
        dst[k + off].id = src[k].id + off
    end
end

append_symbols(symbols, psymbols)
uf2.generate(symbols, "attrsyms.uf2")
symtab = symtools.symtab(symbols)
symtools.vars(symtab)()
lil("bpnew bp 320 200")
lil("bufnew buf 256")
lil("bpset [grab bp] 0 10 10 300 180")
lil("grab buf")
buf = pop()
lil("uf2load syms attrsyms.uf2")
lil("uf2load chicago ../fonts/chicago12.uf2")

bytes = {}
morph_break = "morph_break"

function tcat(dst, src)
    for _,v in pairs(src) do
        table.insert(dst, v)
    end
end

tokens = {}

tcat(tokens, { morph_begin, lbrack, parallel, rbrack, rtee, dash,
dashground, grounddash, dashsky, skydash, dash, dashsky, skyground,
rhook, morph_break,
})

path1 = {
-- gesture path
bracket_left,
zero, one,
ratemulstart, zero, one, zero, one, ratemulend,
divider,

six, seven,
ratemulstart, eight, seven, zero, three, ratemulend, step,
divider,
eight, nine,
ratemulstart, eight, eight, nine, nine, ratemulend, gliss_big,
divider,

ten, eleven,
ratemulstart, fifteen, eleven, ten, eleven, ratemulend, gliss_medium,
divider,
twelve, thirteen,
ratemulstart, one, two, twelve, thirteen, ratemulend, gliss_small,
divider,
fourteen, fifteen,
bracket_right,

}

path2 = {
-- gesture path
bracket_left,
zero, one,
ratemulstart, zero, one, ratemulend, step,
divider,

zero, two,
divider,
zero, three,
divider,
zero, four,
bracket_right,
}

path3 = {
-- gesture path
bracket_left,
zero, five,
ratemulstart, zero, one, ratemulend, gliss_medium,
divider,

zero, six,
divider,
zero, seven,
divider,
zero, eight,
divider,
zero, nine,
bracket_right,
}

path4 = {
-- gesture path
bracket_left,
zero, ten,
ratemulstart, zero, one, ratemulend, gliss_big,
divider,

zero, eleven,
divider,
zero, twelve,
divider,
zero, thirteen,
divider,
zero, fourteen,
bracket_right,
}

tcat(tokens, {
morph_line_begin,
dash, lbrack, parallel, parallel, ground, morph_define,
})

tcat(tokens, path1)
tcat(tokens, {morph_break})

-- tcat(tokens, {
-- morph_line_begin,
-- skydash, dashsky, sky, skydash, rtee, rbrack, morph_define,
-- })
-- 
-- tcat(tokens, path2)
-- tcat(tokens, {morph_break})
-- 
-- tcat(tokens, {
-- morph_line_begin,
-- rhook, rhook, rhook, groundsky, morph_define,
-- })
-- 
-- tcat(tokens, path3)
-- tcat(tokens, {morph_break})
-- 
-- tcat(tokens, {
-- morph_line_begin,
-- rbrack, dash, lbrack, ltee, morph_define,
-- })
-- 
-- tcat(tokens, path4)
-- tcat(tokens, {morph_break})

tcat(tokens, {morph_end, morph_break})

for _,t in pairs(tokens) do
    table.insert(bytes, symtab[t])
end

line = {}

lil("uf2txtln [bpget [grab bp] 0] [grab chicago] 0 0 'Morpheme Notation Test'")

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


-- attempt to parse grammar
path_grammar = loadfile("../path/grammar.lua")
path_grammar()
path_grammar = generate_path_grammar(symtab)

morpheme_grammar = loadfile("../morpheme/grammar.lua")
morpheme_grammar()

grammar = generate_morpheme_grammar(symtab, path_grammar)

hexstr = symtools.hexstring(symtab, tokens)
-- t = lpeg.match(lpeg.Ct(path_grammar), hexstr)
t = lpeg.match(lpeg.Ct(grammar), hexstr)
pp(t)
