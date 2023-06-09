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

function generate_tokens(symtab)
    symtools.vars(symtab)()

    local tk = {
        morph_begin,
            lbrack, parallel, rbrack, rtee, dash,
        morph_break,

        morph_line_begin,
        dash, rtee, rtee, morph_define,
            bracket_left,
            zero, zero,
            ratemulstart, zero, one, ratemulend, gliss_medium,
            divider,

            zero, four,
            divider,

            zero, seven,
            divider,

            zero, eleven,

            bracket_right,
        morph_break,

        -- morph_line_begin,
        -- groundsky, skydash, dashground, morph_define,
        --     seq_val0, seq_dur1, seq_linear,
        --     seq_val16, seq_dur2,
        --     seq_val0, seq_dur2,
        --     seq_val16, seq_dur1,
        --     seq_end,
        -- morph_break,

        morph_end, morph_break
    }
    return tk
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

    -- lil("uf2txtln [bpget [grab bp] 0] [grab chicago] 0 0 'Morpheme Notation Test'")

    line = {}
    mnobuf.clear(buf)
    linepos = 0
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

    lil("bppbm [grab bp]")
end

morpheme_tokens = generate_tokens(symtab)

gfx_setup()
-- draw(morpheme_tokens)

loadfile("path/grammar.lua")()
print(symtab["gliss_medium"])
-- path_grammar = generate_path_grammar(symtab)

-- morpheme_grammar = loadfile("morpheme/grammar.lua")
-- morpheme_grammar()
-- 
-- grammar = generate_morpheme_grammar(symtab, path_grammar)
-- 
-- -- pp(tokens)
-- hexstr = symtools.hexstring(symtab, tokens)
-- -- pp(hexstr)
-- -- t = lpeg.match(lpeg.Ct(path_grammar), hexstr)
-- t = lpeg.match(lpeg.Ct(grammar), hexstr)
-- pp(t)
