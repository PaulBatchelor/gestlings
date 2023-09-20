local asset = require("asset/asset")
local msgpack = require("util/MessagePack")
asset = asset:new {
    msgpack = msgpack,
    base64 = require("util/base64")
}
local pprint = require("util/pprint")

local uf2 = require("util/uf2")

function empty(data)
    for _, row in pairs(data) do
        if row > 0 then return false end
    end

    return true
end

function main()
    local tilemap = asset:load("vocab/junior/t_junior.b64")

    local font = {}
    local shapetab = {}

    for id,tile in pairs(tilemap) do
        local data = tile.data
        local width = tile.width

        if empty(data) then goto skip end

        bits = {}
        for _,row in pairs(data) do

            local rowstr = ""
            for i = 1, width do
                local shft = (i - 1)*2
                local bits = ((row & (1<<shft))>>shft) & 3
                local c = "0"

                if bits > 0 then
                    c = "#"
                else
                    c = "-"
                end

                rowstr = rowstr .. c
            end
            table.insert(bits, rowstr)
        end

        local glyph =  {
            id = id,
            bits = bits,
            width = width
        }

        -- table.insert(font, glyph)
        -- id values are not necessarily continguous
        -- 0 is reserved, so start at 1 (lua starts at 1 anyways)
        font[id] = glyph

        local shape = tile.shape

        local shapestr = ""
        for i = 1,3 do
            local shft = (i-1)*3
            local row = (shape & (7 << shft))>>shft
            local rowstr = ""
            for k=1,3 do
                local c = "0"
                if (row & (1 << (k - 1))) > 0 then
                    c = "#"
                    shapestr = shapestr ..  (3 - i)*3 + k
                else
                    c = "-"
                end
                rowstr = rowstr .. c
            end
            -- print(rowstr)
        end
        -- print(shapestr)
        -- print()
        -- print(shapestr, id)
        table.insert(shapetab, {shapestr, id})
        ::skip::
    end

    uf2.generate(font, "fonts/junior.uf2")
    local fp = io.open("vocab/junior/k_junior.bin", "w")
    fp:write(msgpack.pack(shapetab))
    fp:close()
    asset:save(font, "vocab/junior/f_junior.b64")
end

main()
