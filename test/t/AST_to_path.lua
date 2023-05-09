msgpack = dofile("util/MessagePack.lua")
base64 = dofile("util/base64.lua")
asset = dofile("asset/asset.lua")
symtools = dofile("util/symtools.lua")
asset = asset:new({msgpack=msgpack, base64=base64})
pprint = dofile("util/pprint.lua")
path = dofile("path/path.lua")

-- make sure this is generated beforehand
symtab = asset:load("path/symtab.b64")

grammar = loadfile("path/grammar.lua")
grammar()
grammar = generate_path_grammar(symtab)

symtools.vars(symtab)()

tokens = {
bracket_left,
zero, zero,
ratemulstart, one, one, ratemulend, linear,
divider,
fifteen, fifteen,
ratemulstart, three, three, ratemulend, step,
divider,
zero, one,
ratemulstart, two, three, four, five, ratemulend, step,
bracket_right
}

local hexstr = symtools.hexstring(symtab, tokens)
local ast = lpeg.match(lpeg.Ct(grammar), hexstr)
local gpath = path.AST_to_path(ast)

local ref = {
    {0x00, {0x11}, 0},
    {0xff, {0x33}, 1},
    {0x01, {0x23, 0x45}, 1},
}

function path2str(p)
    local s = ""

    for _, vx in pairs(p) do
        s = s .. string.format("[%d:", vx[1])
        if #vx[2] == 1 then
            s = s .. string.format("%d:", vx[2][1])
        elseif #vx[2] == 2 then
            s = s .. string.format("%d,%d:", vx[2][1], vx[2][2])
        end
        s = s .. string.format("%d]", vx[3])
    end

    return s
end

verbose = os.getenv("VERBOSE")
verbose = (verbose ~= nil and verbose == "1")

outstr = path2str(gpath)
refstr = path2str(ref)

if outstr ~= refstr then
    if verbose then
        print("generated path does not match reference")
        print("ref: " .. refstr)
        print("out: " .. outstr)
    end
    os.exit(1)
end
