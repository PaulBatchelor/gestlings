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

generate_program(syms, program)
apply_mouth_shape(vm, mouth1)

function frame(framenum)
    if (framenum % 60 == 0) then
        print(framenum)
    end
    lil("bpfill [bpget [grab bp] 0] 0")
    lil("grab gfx")
    lil("gfxfill 1")
    lil("bpsdf [bpget [grab bp] 0] [grab vm] [grab buf]")
    lil("dup")
    lil("bptr [grab bp] 0 0 256 256 0 0 0")
    lil("dup; gfxtransfer; gfxappend")
end

for i = 1, 300  do
    frame(i)
end

lil([[
grab gfx
gfxclose
gfxmp4 tmp/mouthanim.h264 res/mouthanim.mp4
]])
-- lil("bppng [grab bp] res/sdfvm_mouth.png")
