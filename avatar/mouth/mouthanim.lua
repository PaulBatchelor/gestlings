json = require("util/json")
pprint = require("util/pprint")

os.execute("mkdir -p tmp res")
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
lil("gfxopen tmp/mouthanim.h264")

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

function apply_mouth_shape(vm, mouth)
    sdfvm.regset_scalar(vm, 4, mouth.circleness)
    sdfvm.regset_scalar(vm, 5, mouth.roundedge)
    sdfvm.regset_scalar(vm, 6, mouth.circrad)

    for i=1,4 do
        local p = mouth.points[i]
        sdfvm.regset_vec2(vm, i-1, p[1], p[2])
    end
end

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
    circleness = 1.0,
    roundedge = 0.08,
    circrad = 0.2,
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
    mouth1, mouth2, mouth1b, mouth2b,
    mouth3, mouth3b, mouth4, mouth4b,
    mouth5, mouth1c, mouth2c, mouth6,
    mouth7, mouth7b, mouth2d, mouth1d
}

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

generate_program(syms, program)

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
    local m1 = mouths[fs.current_mouth]
    local m2 = mouths[fs.next_mouth]
    local ms = mouth_interp(m1, m2, gliss(fs.pos))
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
    current_mouth = 1
}

for i = 1, 600  do
    frame_state.framenum = i
    frame(frame_state)
    frame_state.pos = frame_state.pos + (1/60)*2
    if frame_state.pos > 1 then
        frame_state.pos = frame_state.pos - 1
        frame_state.current_mouth = frame_state.next_mouth
        frame_state.next_mouth = (frame_state.next_mouth + 1)
        if frame_state.next_mouth > #mouths then
            frame_state.next_mouth = 1
        end
        print(frame_state.next_mouth, frame_state.current_mouth)
    end
end

lil([[
grab gfx
gfxclose
gfxmp4 tmp/mouthanim.h264 tmp/mouthanim.mp4
]])
os.execute("ffmpeg -y -i tmp/mouthanim.mp4 -pix_fmt yuv420p res/mouthanim.mp4")
-- lil("bppng [grab bp] res/sdfvm_mouth.png")
