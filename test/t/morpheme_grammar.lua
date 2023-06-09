pprint = dofile("util/pprint.lua")
symtools = dofile("util/symtools.lua")
path_grammar = loadfile("path/grammar.lua")
path_grammar()
asset = dofile("asset/asset.lua")
asset = asset:new {
    msgpack = dofile("util/MessagePack.lua"),
    base64 = dofile("util/base64.lua")
}
path = dofile("path/path.lua")
morpheme = dofile("morpheme/morpheme.lua")
morpheme_grammar = loadfile("morpheme/grammar.lua")
morpheme_grammar()

-- simulate symbol table mapping

local morpheme_symtab = {
    morph_sym00 = 1,
    morph_sym01 = 2,
    morph_sym02 = 3,
    morph_sym03 = 4,
    morph_sym04 = 5,
    morph_sym05 = 6,
    morph_sym06 = 7,
    morph_sym07 = 8,
    morph_sym08 = 9,
    morph_sym09 = 10,
    morph_sym10 = 11,
    morph_sym11 = 12,
    morph_sym12 = 13,
    morph_sym13 = 14,
    morph_sym14 = 15,
    morph_sym15 = 16,
    morph_sym16 = 17,
    morph_sym17 = 18,
    morph_sym18 = 19,
    morph_break = 20,
    morph_begin = 21,
    morph_end = 22,
    morph_define = 23,
    morph_line_begin = 24,
}

local symbol2letter = {
    morph_sym00 = "p",
    morph_sym01 = "f",
    morph_sym02 = "th",
    morph_sym03 = "d",
}
 
symtab = asset:load("path/symtab.b64")
symstart = 0

for _,v in pairs(symtab) do
    --if (v > symstart) then symstart = v end
    symstart = symstart + 1
end

for k,v in pairs(morpheme_symtab) do
    symtab[k] = v + symstart
end

symtools.vars(symtab)()

-- syms: test notation , represented as tokens / "symbols"

syms = {
    -- begin the morpheme and give it name
    morph_begin, morph_sym00, morph_sym00, morph_break,

    -- first path in morpheme
    morph_line_begin, morph_sym00, morph_sym01, morph_sym02, morph_sym03, morph_sym03, morph_define,

    bracket_left,
        zero, zero,
        ratemulstart, one, one, ratemulend, linear,
        divider,
        fifteen, fifteen,
        ratemulstart, three, three, ratemulend, step,
    bracket_right, morph_break,

    -- second path in morpheme
    morph_line_begin, morph_sym03, morph_sym03, morph_define,
    bracket_left,
        one, one,
        ratemulstart, nine, nine, ratemulend, gliss_big,
        divider,
        one, one,
        ratemulstart, zero, one, ratemulend, step,
    bracket_right, morph_break,

    morph_end
}
-- convert tokens to hex string values for grammar
str = symtools.hexstring(symtab, syms)

-- morpheme grammar encapsulates path grammar (PEG)
path_grammar = generate_path_grammar(symtab)

local notations = {
    path=path_grammar,
}
grammar = generate_morpheme_grammar(symtab, notations)

-- generate AST from hex string
t = lpeg.match(grammar, str)

-- silly way to produce human-readable names from attribute symbols
-- this most likely won't cause collisions?
-- method: each symbol gets a consonant prefix in a lookup table,
-- a hash based on location is used to determine the vowel (this
-- helps add some deterministic variation)

function djb_hash(str)
    local hash = 5381
    for i = 1, #str do
        hash = ((hash << 5) + hash) + string.byte(str, i)
    end
    return hash
end

function generate_attribute_name(sym, attr)
    local l = ""
    local vow = {"a", "o", "e", "i", "u"}
    local vowpos = 0
    for pos,at in pairs(attr) do
        vowpos = ((vowpos + djb_hash(sym[at])) % #vow) + 1
        l = l .. sym[at] .. vow[vowpos]
    end

    return l
end

-- generate morpheme data from "attributes" key in AST

local m = {}

for _,at in pairs(t.attributes) do
    local atname = generate_attribute_name(symbol2letter, at.attribute)
    local p = path.data_to_path(path.AST_to_data(at.path))
    m[atname] = p
end

local mname = generate_attribute_name(symbol2letter, t.name)

local refname = "papo"
local ref = { 
  dide = { { 
      bhvr = 3,
      dur = { 153 },
      val = 17 
    }, { 
      bhvr = 1,
      dur = { 1 },
      val = 17 
    } },
  pafothidedo = { { 
      bhvr = 0,
      dur = { 17 },
      val = 0 
    }, { 
      bhvr = 1,
      dur = { 51 },
      val = 255 
    } } 
}

function path2str(p)
    local s = ""

    for _,v in pairs(p) do
        s = v.bhvr .. 
            string.format("%x", v.dur[1]) ..
            string.format("%x", v.val)
    end

    return s
end

-- TODO account for morpheme name as well
function morpheme2str(m, name)
    local s = name
    -- first pass: retrieve and sort attributes
    local attr_list = {}
    for attr, _ in pairs(m) do
        table.insert(attr_list, attr)
    end

    table.sort(attr_list)

    for _, attr in pairs(attr_list) do
        s = s .. attr .. path2str(m[attr])
    end
    return s
end

verbose = os.getenv("VERBOSE")
verbose = (verbose ~= nil and verbose == "1")

refstr = morpheme2str(ref, refname)
outstr = morpheme2str(m, mname)

if outstr ~= refstr then
    if verbose then
        print("generated path does not match reference")
        print("ref: " .. refstr)
        print("out: " .. outstr)
    end
    os.exit(1)
end
