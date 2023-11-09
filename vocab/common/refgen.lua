refgen = {}

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

-- TODO: re-organize
function draw_lines(glyphs_left,
                    rows_per_page,
                    row_width,
                    table_width,
                    symbol_width,
                    shape_width,
                    lilt)
    local line_height = rows_per_page * row_width

    if glyphs_left < rows_per_page then
        line_height = glyphs_left * row_width
    end

    -- bounding box
    lilt {
        "bpline", "[bpget [grab bp] 0]",
        0, 0,
        0, line_height,
        1
    }

    lilt {
        "bpline", "[bpget [grab bp] 0]",
        table_width - 1, 0,
        table_width - 1, line_height,
        1
    }

    lilt {
        "bpline", "[bpget [grab bp] 0]",
        0, 0,
        table_width, 0,
        1
    }

    lilt {
        "bpline", "[bpget [grab bp] 0]",
        0, line_height - 1,
        table_width, line_height - 1,
        1
    }

    -- column lines

    lilt {
        "bpline", "[bpget [grab bp] 0]",
        symbol_width, 0,
        symbol_width, line_height,
        1
    }

    lilt {
        "bpline", "[bpget [grab bp] 0]",
        symbol_width + shape_width, 0,
        symbol_width + shape_width, line_height,
        1
    }

end

function draw_row(vocab, tile, idx, rowpos, row_width, zoom, symbol_width, squaresz, shape_width, lilt)
    local docstr = vocab[idx].doc or ""
    local height = tile.height
    local width = tile.width
    local data = tile.data
    local shape = tile.shape

    local rowoff = row_width * (rowpos - 1)

    -- note: subtracting one because it lines up
    -- with the bounding box drawn in draw_lines()
    local ypos = row_width * rowpos - 1

    lilt {
        "bpline", "[bpget [grab bp] 0]", 
        0, ypos,
        240, ypos,
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

function pngname(name, pgnum)
    return string.format("res/ref_%s_%02d.png", name, pgnum)
end

function refgen.generate(p)
    local name = p.name
    local vocab = p.vocab
    local tilemap = p.tilemap
    local zoom = 4
    local symbol_width = (8 + 1) * zoom
    local lilt = p.lilt

    local squaresz = 4*4 + 3*2
    local shape_width = squaresz + 6
    local row_width = 8*4
    local canvas_height = row_width * nglyphs(tilemap)
    local a5dims = {420, 595}

    local table_width = 240
    canvas_height = a5dims[2]
    canvas_width = a5dims[1]
    local rows_per_page = (canvas_height  // row_width)
    local table_height =  rows_per_page * row_width
    lilt{"bpnew", "bp", a5dims[1], canvas_height}
    lilt {"uf2load", "geneva", "fonts/geneva12.uf2"}

    cx = (canvas_width - table_width) // 2
    cy = (canvas_height - table_height) // 2
    lilt {"bpset", "[grab bp]", 0, cx, cy, table_width, table_height}


    pagenum = 1
    rowpos = 1

    glyphs_left = nglyphs(tilemap)

    draw_lines(glyphs_left, rows_per_page, row_width, table_width, symbol_width, shape_width, lilt)
    for idx, tile in pairs(tilemap) do
        if rowpos > rows_per_page then
            print("writing page " .. pagenum)
            lilt {
                "bppng",
                "[grab bp]",
                pngname(name, pagenum)
            }
            lilt {"bpfill", "[bpget [grab bp] 0]", 0}
            draw_lines(glyphs_left, rows_per_page, row_width, table_width, symbol_width, shape_width, lilt)
            rowpos = 1
            pagenum = pagenum + 1
        end
        if empty(tile.data) == false then
            draw_row(vocab, tile, idx, rowpos, row_width, zoom, symbol_width, squaresz, shape_width, lilt)
            rowpos = rowpos + 1
            glyphs_left = glyphs_left - 1
        end
    end

    if rowpos > 1 then
        print("writing page " .. pagenum)
        lilt {
            "bppng",
            "[grab bp]",
            pngname(name, pagenum)
        }
    end
end

return refgen
