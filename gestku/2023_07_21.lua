--[[
mantra. (adapted from scratch/tubesculpt_shapemorf.lua)

Note: this was not live coded. It was originally
created as proof-of-concept, but then I got carried away
and started making a score for it, which had great gestku
energy.
-- <@>
dofile("gestku/2023_04_22.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
-- </@>
-- <@>
gestku = require("gestku/gestku")
warble = require("warble/warble")

s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)
G = gestku:new()

-- Not actually using this
function G.symbol()
    return ""
end

function G:init()
    lil("shapemorfnew lut shapes/tubesculpt_testshapes.b64")
    lil("grab lut")
    local lut = pop()
    -- lut = shapemorf.load("shapes/tubesculpt_testshapes.b64")
    self.lookup = shapemorf.generate_lookup(lut)
    local gest = G.gest
    local path = G.path
    gm = gest.behavior.gliss_medium
    gl = gest.behavior.gliss
    lin = gest.behavior.linear

    shapes = {
        "2b1d8a",
        "4e8a8e",
        "83ae8a",
        "172828",
        "54f27d",
        "8abe8d",
    }
    vt = path.vertex
    self.test_path = {
        vt{shapes[1], {1, 1}, gm},
        vt{shapes[2], {1, 1}, gm},
        vt{shapes[1], {1, 1}, lin},
        vt{shapes[2], {1, 1}, gl},

        vt{shapes[3], {1, 1}, gm},
        vt{shapes[4], {1, 1}, gm},
        vt{shapes[3], {1, 1}, lin},
        vt{shapes[4], {1, 1}, gl},

        vt{shapes[5], {1, 1}, gm},
        vt{shapes[6], {1, 1}, gm},
        vt{shapes[5], {1, 1}, lin},
        vt{shapes[6], {1, 1}, gl}
    }
    self.shapes = shapes
end

function lilt(tab)
    lil(table.concat(tab, " "))
end

-- override draw function
function G:draw(filename)
    spacing = 16
    square_size = 8
    line_width = 0
    local shapes = self.shapes

    line_height =
        4*#shapes*square_size +
        (#shapes - 1) * (2 * square_size) + spacing*2

        print(line_height)
    -- characters happen to be all fixed width of 6 tiles
    line_width = 6*square_size + spacing*2

    canvas_width = 240
    canvas_height = 320

    lilt{"bpnew", "bp", canvas_width, canvas_height}
    lilt{"bpset",
        "[grab bp]", 0,
        spacing + (canvas_width - line_width)//2,
        spacing + (canvas_height - line_height)//2,
        line_width - spacing,
        line_height - spacing}
    lilt{"bpset", "[grab bp]", 1, 0, 0, canvas_width, canvas_height}

    -- lilt{"bpline", "[bpget [grab bp] 1]",
    -- canvas_width // 2, 0, canvas_width//2, canvas_height, 1}

    function draw_shape(shp, square_size, yoff)
        for c=1,#shp do
            col=string.byte(shp, c)
            col=tonumber(string.char(col), 16)
            for row=1,4 do
                local s = col & (1 << (row -1))
                if (s > 0) then
                    lil(table.concat({
                        "bprectf",
                        "[bpget [grab bp] 0]",
                        (c - 1)*square_size, (row - 1)*square_size+yoff,
                        square_size, square_size, 1
                    }, " "))
                end
            end
        end
    end

    xoff = 0
    for i=1,#shapes do
        draw_shape(shapes[i], square_size, xoff)
        xoff=xoff + 6*square_size
    end

    lil("bppbm [grab bp] " .. filename .. ".pbm")
    return true
end

function G:sound()
    local g = G.gest
    program = {
    "tubularnew 20.0 -1",
    "regset zz 0",

    table.concat({
        -- gvm, lut, tubular, program , conductor
        "shapemorf",
        g:get(),
        "[grab lut]",
        "[regget 0]",
        "[" .. g:gmemsymstr("vowshapes") .. "]",
        "[phasor [scale [expmap [flipper [phasor 0.05 0]] 3] 1 10] 0]"
    }, " "),

    "regget 0",
    "param 30",
    "jitseg 0.3 -0.3 0.5 2 1",
    "add zz zz",
    "mtof zz",
    "param 0.3",
    "param 0.1",
    "param 0.0",
    "glot zz zz zz zz",
    "tubular zz zz zz",
    "butlp zz 3000", "mul zz [dblin -3]",
    "dup", "dup",
    "bigverb zz zz 0.9 10000",
    "drop", "dcblocker zz", "mul zz [dblin -16]",
    "add zz zz",
    }
    local path = G.path
    local tal = G.tal
    G:start()
    tal.label(G.words, "vowshapes")
    path.path(tal, G.words, G.test_path, G.lookup)
    tal.jump(G.words, "vowshapes")
    G:compile()

    for _, line in pairs(program) do
        lil(line)
    end
end

function run()
    G:sound()
    lil("out")
end

function G.patch()
    G:setup()
    G:sound()
end

return G
-- </@>
