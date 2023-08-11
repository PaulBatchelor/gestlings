-- Testing out a DSL that will make it easier to generate
-- programs

json = require("util/json")
pprint = require("util/pprint")

fp = io.open("avatar/sdfvm_lookup_table.json")
syms = json.decode(fp:read("*all"))
fp:close()

-- pprint(syms)

lil("bpnew bp 256 256")
lil("bpset [grab bp] 0 0 0 256 256")
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
        "point",
        "scalar 0 register scalar 1 register",
        "scalar 2 register scalar 3 register",
        "poly4",
        -- r5: rounded edge amount
        "scalar 5 register roundness",
        -- r6: rounded edge amount
        "point scalar 6 register circle",
        -- r4: circleness amount
        "scalar 4 register lerp gtz"
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

lil("bpsdf [bpget [grab bp] 0] [grab vm] [grab buf]")
lil("bppng [grab bp] scratch/sdfvm_lang.png")
