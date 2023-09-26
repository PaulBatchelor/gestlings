local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
local pprint = require("util/pprint")

local vocab = asset:load("vocab/junior/v_junior.b64")
-- local docs = vocab[2]
-- vocab = vocab[1]
local tilemap = asset:load("vocab/junior/t_junior.b64")
local core = require("util/core")
local lilt = core.lilt

local zoom = 4
local symbol_width = (8 + 1) * zoom

function empty(data)
    for _, row in pairs(data) do
        if row > 0 then return false end
    end

    return true
end

function nglyphs(tilemap)
    local n = 0
    for _, tile in pairs(tilemap) do
        if (empty(tile.data) == false) then
            n = n + 1
        end
    end

    return n
end

local squaresz = 4*4 + 3*2
local shape_width = squaresz + 6
local row_width = 8*4
local canvas_height = row_width * nglyphs(tilemap)

lilt{"bpnew", "bp", 240, canvas_height}
lilt {"uf2load", "geneva", "fonts/geneva12.uf2"}
lilt {"bpset", "[grab bp]", 0, 0, 0, 240, canvas_height}

lilt {
    "bpline", "[bpget [grab bp] 0]", 
    symbol_width, 0,
    symbol_width, canvas_height,
    1
}


lilt {
    "bpline", "[bpget [grab bp] 0]", 
    symbol_width + shape_width, 0,
    symbol_width + shape_width, canvas_height,
    1
}

function draw_row(tile, idx)
    local docstr = vocab[idx].doc or ""
    local height = tile.height
    local width = tile.width
    local data = tile.data
    local shape = tile.shape

    local rowoff = row_width * (idx - 1)

    lilt {
        "bpline", "[bpget [grab bp] 0]", 
        0, row_width*idx,
        240, row_width*idx,
        1
    }

    for y=1,height do
        local row = data[y]
        -- local rowstr = ""
        for x=1,width do
            local c = 0
            local bitpos = (x - 1)*2
            local bits = ((row & 1 << bitpos) >> bitpos) & 3
            if bits > 0 then
                c = 1
            else
                c = 0
            end

            lilt {
                "bprectf", "[bpget [grab bp] 0]",
                x*zoom, rowoff+y*zoom, zoom, zoom, c
            }
            -- rowstr = rowstr .. c
        end
        -- print(rowstr)
    end

    lilt {
        "bprect",
        "[bpget [grab bp] 0]",
        symbol_width + 3, rowoff + 3,
        squaresz, squaresz, 1
    }

    local shapestr = ""
    for i = 1,3 do
        local shft = (i-1)*3
        local row = (shape & (7 << shft))>>shft
        local rowstr = ""
        for k=1,3 do
            local c = 0
            if (row & (1 << (k - 1))) > 0 then
                c = 1
                shapestr = shapestr ..  (3 - i)*3 + k
            else
                c = 0
            end

            lilt {
                "bprectf", "[bpget [grab bp] 0]",
                symbol_width + 3 + 3 + (k -1)*6,
                rowoff + 3 + 3 + (i - 1)*6,
                4, 4, c
            }
        end
        -- print(rowstr)
    end

    lilt {
        "uf2txtln",
        "[bpget [grab bp] 0]",
        "[grab geneva]", 
        shape_width+symbol_width+2, rowoff + 2, "\"" .. docstr .. "\""
    }
end

idx = 2
tile = tilemap[idx]

for idx, tile in pairs(tilemap) do
    if empty(tile.data) == false then
        draw_row(tile, idx)
    end
end

lil("bppng [grab bp] res/ref_junior.png")
