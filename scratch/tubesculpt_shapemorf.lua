-- produces a "mantra", a looping setting of tract shapes

gest = require("gest/gest")
pprint = require("util/pprint")
tal = require("tal/tal")
path = require("path/path")

lil("shapemorfnew lut shapes/tubesculpt_testshapes.b64")
lil("grab lut")
lut = pop()
-- lut = shapemorf.load("shapes/tubesculpt_testshapes.b64")
lookup = shapemorf.generate_lookup(lut)

for k,v in pairs(lookup) do
    print(k, v)
end

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
test_path = {
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

words = {}

tal.begin(words)
-- pprint(test_path)

tal.label(words, "vowshapes")
path.path(tal, words, test_path, lookup)
tal.jump(words, "vowshapes")
-- pprint(words)

g = gest:new{tal = tal}
g:create()
g:compile(words)

program = {
"tubularnew 20.0 -1",
"regset zz 0",
-- "tabnew [tubularsz [regget 0]]",
-- "regset zz 1",
-- 'tractdrmtab [genvals [tabnew 1] "1 2 1 1 1 4 9 3"] [regget 1]',
-- 
-- "regget 0",
-- "regget 1",
-- "tubulardiams zz zz",

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
"dup",
"wavouts zz zz test.wav",
}

for _, line in pairs(program) do
    lil(line)
end

lil("computes 60")

function lilt(tab)
    lil(table.concat(tab, " "))
end

spacing = 16
square_size = 8
line_width = 0
-- for i=1,#shapes do
--     line_width = line_width + #shapes[i]
-- end

-- line_width =
--     (line_width * square_size) +
--     (#shapes - 1) * (2 * square_size)

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

lil("bppng [grab bp] scratch/tubesculpt_shapemorf.png")
