gest = require("gest/gest")
pprint = require("util/pprint")
tal = require("tal/tal")
path = require("path/path")
json = require("util/json")

lil("shapemorfnew lut shapes/tubesculpt_testshapes.b64")
lil("grab lut")
lut = pop()
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

mantra = {
    -- 1, 2, {1, 2}, 3, 4, {3, 4}, 5, 6, {5, 6}
    1, 2, {1, 2}, {1, 4},
    3, 4, {3, 4}, {5, 4},
    5, 6, {5, 6}, {1, 6},
}

function mantra_to_path(mantra, shapes)
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local vt = path.vertex
    local mantra_path = {}
    local mantra_indices = {}
    local dur = {1, 1}

    for _,m in pairs(mantra) do
        if type(m) == "table" then
            table.insert(mantra_path, vt{shapes[m[1]], dur, lin})
            table.insert(mantra_path, vt{shapes[m[2]], dur, gl})

            table.insert(mantra_indices, vt{m[1], dur, lin})
            table.insert(mantra_indices, vt{m[2], dur, gl})

        else
            table.insert(mantra_path, vt{shapes[m], dur, gm})

            -- TODO: how to use the lookup table instead?
            table.insert(mantra_indices, vt{m, dur, gm})
        end
    end

    return mantra_path, mantra_indices
end

vt = path.vertex
test_path, path_indices = mantra_to_path(mantra, shapes)

words = {}

tal.begin(words)
-- pprint(test_path)

tal.label(words, "vowshapes")
path.path(tal, words, test_path, lookup)
tal.jump(words, "vowshapes")
tal.label(words, "vowindices")
path.path(tal, words, path_indices, lookup)
tal.jump(words, "vowindices")
-- pprint(words)

g = gest:new{tal = tal}
g:create()
g:compile(words)

signal_setup = {
    "blkset 49",
    "tubularnew 20.0 -1",
    "regset zz 0",

    "expmap [flipper [phasor 0.05 0]] 3",
    "hold zz",
    "regset zz 2",
    "phasor [scale [regget 2] 1 8] 0",
    "hold zz",
    "regset zz 1"
}

shapemorf_gesture = {
    table.concat({
        -- gvm, lut, tubular, program , conductor
        "shapemorf",
        g:get(),
        "[grab lut]",
        "[regget 0]",
        "[" .. g:gmemsymstr("vowshapes") .. "]",
        "[regget 1]"
    }, " "),
}

indice_gesture = {
    table.concat({
        -- gvm, lut, tubular, program , conductor
        "gestvmnode",
        g:get(),
        "[" .. g:gmemsymstr("vowindices") .. "]",
        "[regget 1]"
    }, " "),
}

program = {
    "regget 0",
    "param 30",
    "jitseg 0.3 -0.3 0.5 2 1",
    -- "jitseg 10.3 -2.3 0.5 2 1",
    "add zz zz",
    "scale [regget 2] -2 19",
    "add zz zz",
    "mtof zz",
    -- "param 0.3",
    "scale [regget 2] 0.2 0.7",
    "param 0.1",
    "param 0.0",
    "glot zz zz zz zz",
    "tubular zz zz zz",
    "butlp zz 3000", "mul zz [dblin [scale [regget 2] -3 -8]]",
    "dup", "dup",
    "bigverb zz zz [scale [regget 2] 0.9 0.97] 10000",
    "drop", "dcblocker zz", "mul zz [dblin [scale [regget 2] -16 -13]]",
    "add zz zz",
    "mul zz [dblin -2]",

    -- delay by some frames for latency compensation
    -- this is tuned by ear/eye, but I'm sure there's
    -- an actual value
    table.concat({
        "vardelay", "zz", 0, 4.0/60.0, 1.0
    }, " "),

    "dup",
    "wavouts zz zz tmp/mouthsounds.wav",
    "unhold [regget 2]",
    "unhold [regget 1]"
}

function compile_lil_lines(lines)
    for _, line in pairs(lines) do
        lil(line)
    end
end

compile_lil_lines(signal_setup)
compile_lil_lines(shapemorf_gesture)
compile_lil_lines(indice_gesture)
lil("gestvmlast " .. g:get())
indice_gesture_node = pop()
compile_lil_lines(program)

-- for _, line in pairs(program) do
--     lil(line)
-- end


fp = io.open("avatar/sdfvm_lookup_table.json")
syms = json.decode(fp:read("*all"))
fp:close()

lil("bpnew bp 256 256")
lil("gfxnew gfx 256 256")
lil("bpset [grab bp] 0 0 0 256 256")
lil("bufnew buf 256")
lil("grab buf")
program = pop()
lil("sdfvmnew vm")
lil("grab vm")
vm = pop()

lil("grab gfx")
lil("dup")
lil("gfxopen tmp/mouthsounds.h264")

lil("gfxclrset 1 1.0 1.0 1.0")
lil("gfxclrset 0 0.0 0.0 0.0")
lil("drop")
function generate_program(syms, program)
   mnobuf.append(program, syms.point)

   for i=1,4 do
       mnobuf.append(program, syms.scalar)
       mnobuf.append_float(program, i - 1)
       mnobuf.append(program, syms.register)
   end

   mnobuf.append(program, syms.poly4)

   -- r5: rounded edge amount
   mnobuf.append(program, syms.scalar);
   mnobuf.append_float(program, 5)
   mnobuf.append(program, syms.register);

   mnobuf.append(program, syms.roundness)
   mnobuf.append(program, syms.point)

   -- r6: circle radius
   mnobuf.append(program, syms.scalar);
   mnobuf.append_float(program, 6)
   mnobuf.append(program, syms.register);

   mnobuf.append(program, syms.circle);

   -- r4: circleness amount
   mnobuf.append(program, syms.scalar);
   mnobuf.append_float(program, 4)
   mnobuf.append(program, syms.register);

   mnobuf.append(program, syms.lerp);
   mnobuf.append(program, syms.gtz);
end
generate_program(syms, program)
mouth1 = {
    circleness = 0.1,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-0.5, 0.5},
        {-0.1, -0.5},
        {0.1, -0.5},
        {0.5, 0.5},
    }
}

mouth2 = {
    circleness = 0.1,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-0.1, 0.5},
        {-0.5, -0.5},
        {0.5, -0.5},
        {0.1, 0.5},
    }
}

mouth1b = {
    circleness = 0.8,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-0.5, 0.5},
        {-0.1, -0.5},
        {0.1, -0.5},
        {0.5, 0.5},
    }
}

mouth2b = {
    circleness = 0.8,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-0.1, 0.5},
        {-0.5, -0.5},
        {0.5, -0.5},
        {0.1, 0.5},
    }
}

mouth3 = {
    circleness = 0.0,
    roundedge = 0.08,
    circrad = 0.7,
    points = {
        {-0.5, 0.02},
        {-0.5, -0.02},
        {0.5, -0.02},
        {0.5, 0.02},
    }
}

mouth3b = {
    circleness = 0.1,
    roundedge = 0.08,
    circrad = 0.7,
    points = {
        {-0.5, 0.02},
        {-0.5, -0.02},
        {0.5, -0.02},
        {0.5, 0.02},
    }
}

mouth4 = {
    circleness = 0.0,
    roundedge = 0.08,
    circrad = 0.7,
    points = {
        {-0.2, 0.6},
        {-0.02, -0.6},
        {0.02, -0.6},
        {0.2, 0.6},
    }
}

mouth4b = {
    circleness = 0.3,
    roundedge = 0.08,
    circrad = 0.7,
    points = {
        {-0.2, 0.6},
        {-0.02, -0.6},
        {0.02, -0.6},
        {0.2, 0.6},
    }
}

mouth5 = {
    circleness = 0.9,
    roundedge = 0.08,
    circrad = 0.4,
    points = {
        {-0.5, 0.5},
        {-0.1, -0.5},
        {0.1, -0.5},
        {0.5, 0.5},
    }
}

mouth1c = {
    circleness = 0.0,
    roundedge = 0.0,
    circrad = 0.7,
    points = {
        {-0.5, 0.5},
        {-0.1, -0.5},
        {0.1, -0.5},
        {0.5, 0.5},
    }
}

mouth2c = {
    circleness = 0.0,
    roundedge = 0.0,
    circrad = 0.7,
    points = {
        {-0.1, 0.5},
        {-0.5, -0.5},
        {0.5, -0.5},
        {0.1, 0.5},
    }
}

mouth6 = {
    circleness = 0.0,
    roundedge = 0.0,
    circrad = 0.7,
    points = {
        {-0.7, 0.7},
        {-0.4, -0.4},
        {0.4, -0.5},
        {0.5, 0.5},
    }
}

shearx = 0.2
mouth7 = {
    circleness = 0.1,
    roundedge = 0.05,
    circrad = 0.7,
    points = {
        {-0.3 + shearx, 0.5},
        {-0.3 - shearx, -0.5},
        {0.3 - shearx, -0.5},
        {0.3 + shearx, 0.5},
    }
}

shearx = 0.5
mouth7b = {
    circleness = 0.0,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-0.3 - shearx, 0.5},
        {-0.3 + shearx, -0.5},
        {0.3 + shearx, -0.5},
        {0.3 - shearx, 0.5},
    }
}

mouth2d = {
    circleness = 0.1,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-0.1, 0.5},
        {-0.8, 0.3},
        {0.8, 0.3},
        {0.1, 0.5},
    }
}

mouth1d = {
    circleness = 0.1,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-0.8, 0.5},
        {-0.1, 0.3},
        {0.1, 0.3},
        {0.8, 0.5},
    }
}


mouths = {
    -- mouth1, mouth2, mouth1b, mouth2b,
    -- mouth3, mouth3b, mouth4, mouth4b,
    -- mouth5, mouth1c, mouth2c, mouth6,
    -- mouth7, mouth7b, mouth2d, mouth1d
     
     mouth1, mouth4b, mouth7, mouth1c,
     mouth5, mouth1d, mouth4, mouth4b,
     mouth5, mouth1c, mouth2c, mouth6,
     mouth7, mouth7b, mouth2d, mouth1d
}

function apply_mouth_shape(vm, mouth)
    sdfvm.regset_scalar(vm, 4, mouth.circleness)
    sdfvm.regset_scalar(vm, 5, mouth.roundedge)
    sdfvm.regset_scalar(vm, 6, mouth.circrad)

    for i=1,4 do
        local p = mouth.points[i]
        sdfvm.regset_vec2(vm, i-1, p[1], p[2])
    end
end
function mouth_interp(m1, m2, pos)
    local newmouth = {}

    newmouth.circleness =
        pos*m2.circleness +
        (1 - pos)*m1.circleness

    newmouth.roundedge =
        pos*m2.roundedge +
        (1 - pos)*m1.roundedge

    newmouth.circrad =
        pos*m2.circrad +
        (1 - pos)*m1.circrad

    newmouth.points = {}
    for i=1,4 do
        newmouth.points[i] = {}
        newmouth.points[i][1] =
            pos*m2.points[i][1] +
            (1 - pos)*m1.points[i][1]
        newmouth.points[i][2] =
            pos*m2.points[i][2] +
            (1 - pos)*m1.points[i][2]
    end

    return newmouth
end
function gliss(a)
    if (a < 0.5) then
        a = 0
    else
        a = a - 0.5
        if (a < 0) then a  = 0 end
        a = a / 0.5
        a = a * a * a
    end

    return a
end
function frame(fs)
    framenum = fs.framenum
    if (framenum % 60 == 0) then
        print(framenum)
    end
    lil("compute 15")
    local current_mouth, next_mouth, pos = gestvm_last_values(fs.gvm)
    -- print(current_mouth, next_mouth, pos)
    local m1 = mouths[current_mouth]
    local m2 = mouths[next_mouth]
    --local m2 = mouths[current_mouth]
    local ms = mouth_interp(m1, m2, gliss(pos))
    apply_mouth_shape(vm, ms)
    lil("bpfill [bpget [grab bp] 0] 0")
    lil("grab gfx")
    lil("gfxfill 1")
    lil("bpsdf [bpget [grab bp] 0] [grab vm] [grab buf]")
    lil("dup")
    lil("bptr [grab bp] 0 0 256 256 0 0 0")
    lil("dup; gfxtransfer; gfxappend")
end
frame_state = {
    pos = 0,
    framenum = 0,
    next_mouth = 2,
    current_mouth = 1,
    gvm = indice_gesture_node
}
for i = 1, 60*30 do
    frame_state.framenum = i
    frame(frame_state)
    -- frame_state.pos = frame_state.pos + (1/60)*2
    -- if frame_state.pos > 1 then
    --     frame_state.pos = frame_state.pos - 1
    --     frame_state.current_mouth = frame_state.next_mouth
    --     frame_state.next_mouth = (frame_state.next_mouth + 1)
    --     if frame_state.next_mouth > #mouths then
    --         frame_state.next_mouth = 1
    --     end
    --     print(frame_state.next_mouth, frame_state.current_mouth)
    -- end
end
lil([[
grab gfx
gfxclose
gfxmp4 tmp/mouthsounds.h264 tmp/mouthsounds.mp4
]])
--os.execute("ffmpeg -y -i tmp/mouthsounds.mp4 -pix_fmt yuv420p res/mouthsounds.mp4")
os.execute("ffmpeg -y -i tmp/mouthsounds.mp4 -i tmp/mouthsounds.wav -pix_fmt yuv420p -acodec aac res/mouthsounds.mp4")
