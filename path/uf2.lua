local uf2 = {}

function bits_to_bytes(bits)
    on = string.byte("#")
    off = string.byte("-")
    block = {}

    for i = 1,32 do
        block[i] = 0x00
    end

    for pos,row in pairs(bits) do
        rowlen = #row

        if rowlen > 16 then
            rowlen = 16
        end

        for x = 1,rowlen do
            c = string.byte(row, x)
            y = pos

            bytepos = y
            bitpos = x - 1
            if x > 8 then
                bytepos = bytepos + 16
                bitpos = bitpos - 8
            end

            byte = block[bytepos]

            if c == on then
                byte = byte | (1 << (7 - bitpos))
            elseif c == off then
                byte = byte & ~(1 << (7 - bitpos))
            end

            block[bytepos] = byte
        end
    end

    return block
end

function bytes_to_str(bytes)
    local s = ""
    for _, b in pairs(bytes) do
        s = s .. string.format("%02x", b)
    end

    return s
end


function uf2.generate(font, filename)
    local widths = {}

    for id,f in pairs(font) do
        widths[id] = f.width
    end

    local wstr = ""
    for i = 0,255 do
        if (widths[i] ~= nil) then
            wstr = wstr .. string.format("%02x", widths[i])
        else
            wstr = wstr .. "00"
        end
    end

    local emptyglyph = ""
    for i = 1, 32 do
        emptyglyph = emptyglyph .. "00"
    end
    local glyphs = ""
    for i = 0, 255 do
        local glystr = ""
        if font[i] ~= nil then
            local fbits = font[i].bits
            local fbytes = bits_to_bytes(fbits)
            glystr = bytes_to_str(fbytes)
        else
            glystr = emptyglyph
        end
        glyphs = glyphs .. glystr .. "\n"
    end

    local i = 1
    local bytes = {}
    wstr = wstr .. " " .. glyphs
    while true do
        local m = wstr:match("([0-9a-fA-F][0-9a-fA-F]%s?)", i)
        if not m then break end
        i = i + #m
        table.insert(bytes, string.char(tonumber(m, 16)))
    end

    local f = io.open(filename, "wb")
    f:write(table.concat(bytes))
    f:close()
end

return uf2
