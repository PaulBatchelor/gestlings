uf2 = dofile("../path/uf2.lua")
symbols = require("attribute_symbols")
symtools= dofile("../util/symtools.lua")

msgpack = dofile("../util/MessagePack.lua")
base64 = dofile("../util/base64.lua")

uf2.generate(symbols, "attrsyms.uf2")

symtab = symtools.symtab(symbols)
symtools.vars(symtab)()

lil("bpnew bp 320 200")
lil("bufnew buf 256")
lil("bpset [grab bp] 0 10 10 300 180")
lil("grab buf")
buf = pop()
lil("uf2load syms attrsyms.uf2")

bytes = {}
endline = "endline"

tokens = { morph_begin, lbrack, parallel, rbrack, rtee, dash,
dashground, grounddash, dashsky, skydash, dash, dashsky, skyground,
rhook, endline,

morph_line_begin,
dash, lbrack, parallel, parallel, ground, morph_define,
endline,

morph_line_begin,
skydash, dashsky, sky, skydash, rtee, rbrack, morph_define,
endline,

morph_end, endline,

morph_begin, endline
}

for _,t in pairs(tokens) do
    if t == "endline" then
        table.insert(bytes, 0x00)
    else
        table.insert(bytes, symtab[t])
    end
end

line = {}

mnobuf.clear(buf)
linepos = 0
lineheight = 12
for _,b in pairs(bytes) do
    if b == 0x00 then
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

lil("bppbm [grab bp]")
