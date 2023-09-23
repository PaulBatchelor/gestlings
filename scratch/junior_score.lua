descript = require("descript/descript")

pprint = require("util/pprint")
local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
core = require("util/core")
local lilts = core.lilts

function new_block(state)
    local curblock = {}
    curblock.nphrases = -1
    curblock.phrases = {}
    curblock.lines = {}
    curblock.scale = state.scale
    curblock.font = state.font
    return curblock
end

function remove_tags(line)
    local new_line = ""
    local ignore = false
    local tagcontents = ""

    for i=1,#line do
        local c = string.byte(line, i)
        c = string.char(c)

        if c == "<" then
            ignore = true
            tagcontents = ""
        end

        if ignore == false then
            new_line = new_line .. c
        else
            if c ~= "<" and c ~= ">" then
                tagcontents = tagcontents .. c
            end
        end

        if c == ">" then
            ignore = false
            if string.match(tagcontents, "^BACKSPACE") ~= nil then
                local cmd = core.split(tagcontents, " ")
                new_line = string.sub(new_line, 1, #new_line - tonumber(cmd[2]))
            end
        end
    end

    return new_line
end

function draw_block(blk, buf, phrasebook, ypos, drawit)
    local glyphzoom = 2
    local glyphheight = 6
    local glyphspace = 1*glyphzoom
    local lineheight = 12

    for pos,line in pairs(blk.lines) do
        if drawit == true then
            lilts {
                {
                    "uf2txtln",
                    "[bpget [grab bp] 0]",
                    "[grab " .. blk.font .. "]",
                    0, ypos, "\"" .. remove_tags(line) .. "\"",
                    blk.scale
                }
            }
        end
        ypos = ypos + lineheight*blk.scale
    end

    -- linebreak to separate symbols/text
    ypos = ypos + lineheight

    for idx,phrase in pairs(blk.phrases) do
        if drawit == true then
            mnobuf.clear(buf)
            for _,c in pairs(phrasebook[phrase[1]]) do
                mnobuf.append(buf, c)
            end

            lilts {
                {
                    "uf2bytes",
                    "[bpget [grab bp] 0]",
                    "[grab symbols]",
                    "[grab buf]",
                    0, ypos, glyphzoom
                }
            }
        end
        ypos = ypos + (glyphzoom*glyphheight + glyphspace)
    end
    ypos = ypos + lineheight 
    return ypos
end

function draw_blocks(phrasebook, blocks, buf, drawit)
    local ypos = 0

    for _,blk in pairs(blocks) do
        ypos = draw_block(blk, buf, phrasebook, ypos, drawit)
    end

    return ypos
end

function main()
    fp = io.open("dialogue/junior.txt")
    script = fp:read("*all")
    fp:close()
    local blocks = {}
    local character = "???"

    dialogue = descript.parse(script)

    -- local curblock = {}
    -- curblock.nphrases = -1
    -- curblock.phrases = {}
    -- curblock.lines = {}
    local state = {
        font = "chicago",
        scale = 1
    }
    local curblock = new_block(state)
    for _, chunk in pairs(dialogue) do
        cmd = core.split(chunk[1], " ")
        if cmd[1] == "block" then
            local lines = {}
            for i=2,#chunk do
                table.insert(lines, chunk[i])
            end
            curblock.lines = lines
            table.insert(blocks, curblock)
            curblock = new_block(state)
            -- curblock = {}
            -- curblock.nphrases = -1
            -- curblock.phrases = {}
            -- curblock.lines = {}
        elseif cmd[1] == "nphrases" then
            curblock.nphrases = tonumber(cmd[2])
        elseif cmd[1] == "phrase" then
            table.insert(curblock.phrases, {cmd[2], cmd[3]})
        elseif cmd[1] == "character" then
            character = cmd[2]
        elseif cmd[1] == "font" then
            curblock.font = cmd[2]
            state.font = cmd[2]
        elseif cmd[1] == "scale" then
            curblock.scale = tonumber(cmd[2])
            state.scale = curblock.scale
        end
    end

    local padding = 8
    local width = 240 + 2*padding
    local height = 320 + 2*padding
    local fmt = string.format
    local cdat = asset:load(fmt("characters/%s.b64", character))
    local phrasebook = cdat.phrasebook

    -- local blk = blocks[1]

    -- for k,_ in pairs(cdat) do print(k) end

    lilts {
        {"bufnew", "buf", 128},
    }

    --local ypos = 0
    -- ypos = draw_block(blk, buf, phrasebook, ypos, false)
    height = draw_blocks(phrasebook, blocks, buf, false)
    height = height + 2*padding


    lilts {
        {"bpnew", "bp", width, height},
        {"bpset", "[grab bp]", 0, padding, padding, width, height},
        {"uf2load", "fountain", "fonts/fountain.uf2"},
        {"uf2load", "fountain_joined", "fonts/fountain_joined.uf2"},
        {"uf2load", "chicago", "fonts/chicago12.uf2"},
        {"uf2load", "symbols", cdat.uf2},
        {"uf2load", "protorunes", "fonts/protorunes.uf2"},
    }

    lil("grab buf")
    buf = pop()

    ypos = 0
    draw_blocks(phrasebook, blocks, buf, true)
    --draw_block(blk, buf, phrasebook, ypos, true)

    lilts {
        {"bppng", "[grab bp]", "scratch/junior_score.png"}
    }
end

main()
