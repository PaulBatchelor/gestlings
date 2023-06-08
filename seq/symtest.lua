uf2 = dofile("../path/uf2.lua")
symtools= dofile("../util/symtools.lua")
pp = dofile("../util/pprint.lua")

msgpack = dofile("../util/MessagePack.lua")
base64 = dofile("../util/base64.lua")
asset = dofile("../asset/asset.lua")
asset = asset:new({msgpack=msgpack, base64=base64})

symtab = asset:load("test_syms_tab.b64")
symtools.vars(symtab)()
lil("bpnew bp 320 200")
lil("bufnew buf 256")
margin = 50
lil(string.format("bpset [grab bp] 0 %d %d %d %d",
    margin, margin, 320 - 2*margin, 200 - 2*margin))
lil("grab buf")
buf = pop()
lil("uf2load syms test_syms.uf2")
lil("uf2load chicago ../fonts/chicago12.uf2")

-- lil("bpoutline [bpget [grab bp] 0] 1")

bytes = {}

function tcat(dst, src)
    for _,v in pairs(src) do
        table.insert(dst, v)
    end
end

tokens = {
    seq_val8, seq_dur1, seq_dur2, seq_linear,
    seq_val1, seq_dur2,
    seq_val9, seq_dur3, seq_step,
    seq_val15, seq_dur4,
    seq_val11, seq_dur5,
    seq_val3, seq_dur6, seq_linear,
    seq_val4, seq_dur7,
    seq_val10, seq_dur8, seq_gliss_small,
    seq_val16, seq_dur1,
    seq_val8, seq_dur8, seq_gliss_big,
    seq_val0,
    seq_val3,
    seq_val5, seq_gliss_big,
    seq_end
}

for _,t in pairs(tokens) do
    table.insert(bytes, symtab[t])
end

line = {}

lil("uf2txtln [bpget [grab bp] 0] [grab chicago] 0 0 'Seq Notation Test'")

mnobuf.clear(buf)
linepos = 2
lineheight = 12
for _,b in pairs(bytes) do
    if b == symtab["seq_end"] then
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


-- -- attempt to parse grammar
-- path_grammar = loadfile("../path/grammar.lua")
-- path_grammar()
-- path_grammar = generate_path_grammar(symtab)
-- 
seq_grammar = loadfile("grammar.lua")
seq_grammar()
-- 
grammar = generate_seq_grammar(symtab)
-- 
-- -- pp(tokens)
-- -- pp(hexstr)
-- -- t = lpeg.match(lpeg.Ct(path_grammar), hexstr)

function seq_parse_tree(tree)
    local btab = {
        linear = 0,
        step = 1,
        gliss_medium = 2,
        gliss_big = 3,
        gliss_small = 4,
    }

    local behavior = btab["linear"]
    local dur = 1

    local gpath = {}

    for _,leaf in pairs(t) do
        local v = {}

        if leaf.value == nil then
            error("leaf value is nil")
        end

        if leaf.behavior ~= nil then
            behavior = btab[leaf.behavior]
        end

        if leaf.dur ~= nil then
            local r = 0
            for _, digit in pairs(leaf.dur) do
                r = r * 8 + tonumber(digit)
            end
            dur = r
        end

        v[1] = tonumber(leaf.value)
        v[2] = dur
        v[3] = behavior
        table.insert(gpath, v)
    end

    return gpath
end

path = dofile("../path/path.lua")
hexstr = symtools.hexstring(symtab, tokens)
t = lpeg.match(lpeg.Ct(grammar), hexstr)
gpath = seq_parse_tree(t)

-- tal = dofile("../tal/tal.lua")
-- words = {}

-- tal.begin(words)
-- path.path(tal, words, gpath)
-- pp(words)

morpho = dofile("../morpheme/morpho.lua")
pp(gpath)
