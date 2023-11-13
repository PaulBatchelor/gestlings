function empty(data)
    for _, row in pairs(data) do
        if row > 0 then return false end
    end

    return true
end

function coordstr(id)
    local y = id // 8
    local x = (id % 8)
    return string.format("(%d, %d)", x, y)
end

return function (p)
    local uf2 = p.uf2
    local tilemap = p.tilemap
    local font = {}
    local shapetab = {}
    local shapetab_keys = {}
    local uf2_filename = p.uf2_filename
    local meta_filename = p.meta_filename
    local keyshapes_filename = p.keyshapes_filename
    local msgpack = p.msgpack
    local asset = p.asset

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
        end
        if shapetab_keys[shapestr] ~= nil then
            error(string.format(
                    "non-unique shape '%d', used by id's %s and %s",
                    shapestr,
                    coordstr(id),
                    coordstr(shapetab_keys[shapestr])))
        end
        shapetab_keys[shapestr] = id
        table.insert(shapetab, {shapestr, id})
        ::skip::
    end

    uf2.generate(font, uf2_filename)
    local fp = io.open(keyshapes_filename, "w")
    fp:write(msgpack.pack(shapetab))
    fp:close()
    asset:save(font, meta_filename)
end
