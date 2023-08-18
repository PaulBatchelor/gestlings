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

function tokenize(s)
    local sep = lpeg.S(" \t\n")
    local elem = lpeg.C((1 - sep)^0)
    local p = lpeg.Ct(elem * (sep*elem)^0)
    return lpeg.match(p, s)
end

function generate_bytecode(script, bytebuf)

    input_script = {}

    for _,line in pairs(script) do
        if (type(line) == "table") then
            table.insert(input_script, table.concat(line, " "))
        else
            table.insert(input_script, line)
        end
    end

    local program = tokenize(table.concat(input_script, "\n"))

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

function setup()
    lil("bpnew bp 640 480")
    gestling_width = 640 / 2
    gestling_height = 480 / 2

    gestling_yoff = (480 // 2) - (gestling_height // 2)
    -- it looks a little better with them raised a little bit
    -- maybe the mouth wants to be more y-centered?
    gestling_yoff = gestling_yoff - (gestling_width // 8)

    local gw = gestling_width
    local gh = gestling_height
    local dims = {
        {0, 0, gw, gh},
        {gw, 0, gw, gh},
        {0, gh, gw, gh},
        {gw, gh, gw, gh},
    }

    for i=1,4 do
        lilt {
            "bpset",
            "[grab bp]", i - 1,
            dims[i][1], dims[i][2],
            dims[i][3], dims[i][4]
        }
    end
    lilt {
        "bpset",
        "[grab bp]", 4,
        0, 0, 640, 480
    }
end

function draw(vm, singer)
    local mouth = singer.rest
    apply_mouth_shape(vm, mouth)
    lilt {
        "bpsdf",
        string.format("[bpget [grab bp] %d]", singer.id),
        "[grab vm]",
        "[grab " .. singer.bufname .. "]"
    }
end

function mksinger(vm, name, id, bufsize)
    local singer = {
    }

    bufsize = bufsize or 256
    singer.bufname = name
    lilt {"bufnew", singer.bufname, bufsize}
    lilt {"grab", singer.bufname}
    singer.bytebuf = pop()
    singer.id = id

    return function(program)
        generate_bytecode(program, singer.bytebuf)
        return singer
    end
end

setup()
lil("sdfvmnew vm")
lil("grab vm")
vm = pop()

function mkmouth(scale, mouth_xscale, mouth_yscale, offset)
    local offx = offset[1]
    local offy = offset[2]
    local m = {
        "point",
        "vec2", offx*scale, offy*scale, "add2",
        "scalar", 0, "uniform",
        "vec2", scale*mouth_xscale, scale*mouth_yscale, "mul2",
        "scalar", 1, "uniform",
        "vec2", scale*mouth_xscale, scale*mouth_yscale, "mul2",
        "scalar", 2, "uniform",
        "vec2", scale*mouth_xscale, scale*mouth_yscale, "mul2",
        "scalar", 3, "uniform",
        "vec2", scale*mouth_xscale, scale*mouth_yscale, "mul2",
        "poly4",

        "scalar", 5, "uniform",
        "scalar", scale, "mul",
        "roundness",
        "point",
        "vec2", offx*scale, offy*scale,
        "add2",
        "scalar", 6, "uniform", "circle",
        "scalar", 4, "uniform", "lerp",

        "gtz",
    }

    return m
end

function mktrixie(vm, id)
    local scale = 0.6

    return mksinger(vm, "trixie", id, 512) {
        {
            "point",
            "vec2", 0.45*scale, -0.33*scale, "add2",
            "scalar", 0.4*scale, "circle"
        },
        "scalar 0 regset",
        "scalar 0 regget",
        {"scalar", 0.02*scale, "onion"},
        {
            "point",
            "vec2", 0.45*scale, -0.33*scale, "add2",
            "scalar", 0.15*scale, "circle",
            "add"
        },
        "gtz",

        {
            "point",
            "vec2", -0.45*scale, -0.33*scale, "add2",
            "scalar", 0.4*scale, "circle"
        },
        "scalar 1 regset",
        "scalar 1 regget",
        {"scalar", 0.02*scale, "onion"},
        {
            "point",
            "vec2", -0.45*scale, -0.33*scale, "add2",
            "scalar", 0.15*scale, "circle",
            "add"
        },
        "gtz",

        "add",

        "point",
        {"vec2", 0.65*scale, 0.5*scale, "ellipse"},
        {"scalar", 0.02*scale, "onion"},
        "scalar 0 regget scalar 1 regget",
        "add",
        "swap subtract",
        "add",

        mkmouth(scale, 0.8, 0.05, {0, 0.3}),

        "add",
        -- "point vec2 0.75 0.6 ellipse gtz",
        "gtz",
    }
end

function poly4(points, scale)
    local shape = {}

    for i =1,4 do
        table.insert(shape, "vec2")
        table.insert(shape, points[i][1]*scale)
        table.insert(shape, points[i][2]*scale)
    end

    table.insert(shape, "poly4")
    return shape
end

function mkdiamond(vm, id)
    local scale = 0.6
    return mksinger(vm, "diamond", id) {
        {
            "point",
            "vec2", 1.0*scale, -0.2*scale, "add2",
            "scalar", 0.2*scale, "circle"
        },
        {"scalar", 0.02*scale, "onion"},
        {
            "point",
            "vec2", 1.0*scale, -0.2*scale, "add2",
            "scalar", 0.08*scale, "circle",
            "add"
        },
        "gtz",

        {
            "point",
            "vec2", -1.0*scale, -0.2*scale, "add2",
            "scalar", 0.2*scale, "circle"
        },
        {"scalar", 0.02*scale, "onion"},
        {
            "point",
            "vec2", -1.0*scale, -0.2*scale, "add2",
            "scalar", 0.08*scale, "circle",
            "add"
        },
        "gtz add",

        -- {"point", "vec2", 1.5*scale, 1.4*scale, "ellipse"},

        "point",
        poly4({
            {-0.9, 1.0},
            {-1.0, -1.0},
            {1.0, -1.0},
            {0.9, 1.0}
        }, scale),
        {"scalar", 0.5*scale, "roundness"},
        --{"point", "vec2", 0.0, -0.5*scale, "add2", "scalar", 0.5*scale, "circle"},
        -- {"scalar", 0.01*scale, "union_smooth"},
        {"scalar", 0.02*scale, "onion", "gtz", "add"},
        mkmouth(scale, 3.5, 0.9, {0, 0.7}), "add"
    }
end

function mkbubbles(vm, id)
    local scale = 0.6
    return mksinger(vm, "bubbles", id) {
        {
            "point",
            "vec2", 0.0, 0.4*scale, "add2",
            "vec2",
            1.2*scale, 0.7*scale,
            "ellipse"
        },
        {
            "point",
            "vec2", 0.0, -0.5*scale, "add2",
            "scalar", 0.5*scale,
            "circle",
        },
        {
            "scalar", 0.8*scale,
            "union_smooth"
        },
        {"scalar", 0.02*scale, "onion", "gtz"},

        {
            "point",
            "vec2", 0.0*scale, -0.33*scale, "add2",
            "scalar", 0.5*scale, "circle"
        },
        {"scalar", 0.02*scale, "onion"},
        {
            "point",
            "vec2", 0.0*scale, -0.33*scale, "add2",
            "scalar", 0.3*scale, "circle",
            "add"
        },
        "gtz",
        "add",
        mkmouth(scale, 0.8, 0.3, {0, 0.7}), "add"
    }
end

function mkcarl(vm, id)
    local scale = 0.6
    return mksinger(vm, "carl", id) {
        {
            "point",
            "vec2",
            0.4*scale, 1.5*scale,
            "ellipse"
        },
        {"scalar", 0.02*scale, "onion", "gtz"},

        {
            "point",
            "vec2", 0.15*scale, -0.2*scale, "add2",
            "scalar", 0.08*scale, "circle",
            "gtz add",
            "point",
            "vec2", -0.15*scale, -0.2*scale, "add2",
            "scalar", 0.08*scale, "circle",
            "gtz add"
        },

        mkmouth(scale, 1.8, 0.8, {0, 0.7}),

        "add",
    }
end


trixie = mktrixie(vm, 3)
trixie.open = {
    circleness = 0.7,
    roundedge = 0.1,
    circrad = 0.35,
    points = {
        {-0.4, 0.4},
        {-0.05, -0.4},
        {0.05, -0.4},
        {0.4, 0.4},
    }
}
trixie.close = {
    circleness = 0.7,
    roundedge = 0.1,
    circrad = 0.1,
    points = {
        {-0.4, 0.4},
        {-0.05, -0.4},
        {0.05, -0.4},
        {0.4, 0.4},
    }
}
trixie.rest = {
    circleness = 0.1,
    roundedge = 0.03,
    circrad = 0.1,
    points = {
        {-0.8, 0.1},
        {-0.8, -0.1},
        {0.8, -0.1},
        {0.8, 0.1},
    }
}

diamond = mkdiamond(vm, 0)
diamond.open = {
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
diamond.close = {
    circleness = 0.1,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-0.4, 0.5},
        {-0.1, 0.5},
        {0.1, 0.5},
        {0.4, 0.5},
    }
}
diamond.rest = {
    circleness = 0.05,
    roundedge = 0.01,
    circrad = 0.7,
    points = {
        {-0.8, 0.1},
        {-0.8, 0.1},
        {0.8, 0.1},
        {0.8, 0.1},
    }
}

bubbles = mkbubbles(vm, 1)
bubbles.open = {
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
bubbles.close = {
    circleness = 0.1,
    roundedge = 0.1,
    circrad = 0.7,
    points = {
        {-1.5, 0.5},
        {-0.1, 0.5},
        {0.1, 0.5},
        {1.5, 0.5},
    }
}
bubbles.rest = {
    circleness = 0.01,
    roundedge = 0.05,
    circrad = 0.7,
    points = {
        {-1.5, 0.2},
        {-0.1, 0.2},
        {0.1, 0.2},
        {1.5, 0.2},
    }
}

carl = mkcarl(vm, 2)
carl.open = {
    circleness = 0.05,
    roundedge = 0.01,
    circrad = 0.7,
    points = {
        {-0.5, 0.5},
        {-0.1, -0.5},
        {0.1, -0.5},
        {0.5, 0.5},
    }
}
carl.close = {
    circleness = 0.05,
    roundedge = 0.01,
    circrad = 0.7,
    points = {
        {-0.8, 0.5},
        {-0.1, 0.3},
        {0.1, 0.3},
        {0.8, 0.5},
    }
}
carl.rest = {
    circleness = 0.05,
    roundedge = 0.01,
    circrad = 0.7,
    points = {
        {-0.2, 0.1},
        {-0.2, 0.1},
        {0.2, 0.1},
        {0.2, 0.1},
    }
}

draw(vm, trixie)
draw(vm, diamond)
draw(vm, bubbles)
draw(vm, carl)

lil("bppng [grab bp] scratch/squad.png")
