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
        "point scalar 0.8 circle scalar 0.02 onion",
        "point scalar 0.2 circle add",
        "gtz",

        "point vec2 -0.7 0.7 add2 scalar 1.5 circle scalar 0.02 onion",
        -- I'm duplicated the primitive made before
        -- this could probably be more cleverly done
        "point scalar 0.8 circle swap subtract",
        "gtz",
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

generate_program(syms, program)

lil("bpsdf [bpget [grab bp] 0] [grab vm] [grab buf]")
lil("bppng [grab bp] scratch/eyeball.png")
