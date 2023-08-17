-- the Squad. aka sketching out the lil fellas who will
-- eventually be singing in the trailer

json = require("util/json")
pprint = require("util/pprint")
core = require("util/core")

fp = io.open("avatar/sdfvm_lookup_table.json")
syms = json.decode(fp:read("*all"))
fp:close()

-- pprint(syms)
lilt = core.lilt

lil("bpnew bp 640 480")
gestling_size = 640 / 4

gestling_yoff = (480 // 2) - (gestling_size  // 2)
-- it looks a little better with them raised a little bit
-- maybe the mouth wants to be more y-centered?
gestling_yoff = gestling_yoff - (gestling_size // 8)

for i=1,4 do
    lilt {
        "bpset",
        "[grab bp]", i - 1,
        (i - 1)*gestling_size, gestling_yoff,
        gestling_size, gestling_size
    }
end
lilt {
    "bpset",
    "[grab bp]", 4,
    0, 0, 640, 480
}

lil("bufnew buf 256")
lil("grab buf")
program = pop()
lil("sdfvmnew vm")
lil("grab vm")
vm = pop()

function tokenize(s)
    local sep = lpeg.S(" \t\n")
    local elem = lpeg.C((1 - sep)^0)
    local p = lpeg.Ct(elem * (sep*elem)^0)
    return lpeg.match(p, s)
end

function generate_program(syms, bytebuf)
    local script = {
        "point vec2 0.45 -0.33 add2 scalar 0.37 circle",
        "scalar 0 regset",
        "scalar 0 regget",
        "scalar 0.02 onion",
        "point vec2 0.45 -0.33 add2 scalar 0.1 circle add",
        "gtz",

        "point vec2 -0.45 -0.33 add2 scalar 0.37 circle",
        "scalar 1 regset",
        "scalar 1 regget",
        "scalar 0.02 onion",
        "point vec2 -0.45 -0.33 add2 scalar 0.1 circle add",
        "gtz",

        "add",

        "point scalar 0.75 circle scalar 0.02 onion",
        "scalar 0 regget scalar 1 regget",
        "add",
        "swap subtract",
        "gtz",
        "add",

        "point vec2 0 0.5 add2",
        "scalar 0 uniform scalar 1 uniform",
        "scalar 2 uniform scalar 3 uniform",
        "poly4",
        -- r5: rounded edge amount
        "scalar 5 uniform roundness",
        -- r6: rounded edge amount
        "point vec2 0 0.5 add2",
        "scalar 6 uniform circle",
        -- r4: circleness amount
        "scalar 4 uniform lerp gtz",

        "add"
    }

    local program = tokenize(table.concat(script, "\n"))


    for _,p in pairs(program) do
        if #p == 0 then
            -- ignore
        elseif type(tonumber(p)) == "number" then
            mnobuf.append_float(bytebuf, tonumber(p))
        elseif type(p) == "string" then
            local opcode = syms[p]
            assert(opcode ~= nil, string.format("Invalid opcode: %s", p))
            mnobuf.append(bytebuf, opcode)
        else
            error("can't handle type " .. type(p))
        end
    end
end

function apply_mouth_shape(vm, mouth)
    local scale = 0.6
    sdfvm.uniset_scalar(vm, 4, mouth.circleness)
    sdfvm.uniset_scalar(vm, 5, mouth.roundedge)
    sdfvm.uniset_scalar(vm, 6, mouth.circrad*scale)

    for i=1,4 do
        local p = mouth.points[i]
        sdfvm.uniset_vec2(vm, i-1, p[1]*scale, p[2]*scale)
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

for i=1,4 do
    lilt {
        "bpsdf",
        string.format("[bpget [grab bp] %d]", i-1),
        "[grab vm]",
        "[grab buf]"
    }
end


-- lilt {
--     "bpline", "[bpget [grab bp] 4]",
--     0, 480//2, 640, 480//2, 1
-- }
lil("bppng [grab bp] scratch/squad.png")
