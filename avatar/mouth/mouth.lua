Mouth = {}

local SquareCirc = {}
function SquareCirc:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function SquareCirc:generate(scale, mouth_xscale, mouth_yscale, offset)
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

function SquareCirc:apply_shape(vm, shape)
    local scale = 0.6
    sdfvm.uniset_scalar(vm, 4, shape.circleness)
    sdfvm.uniset_scalar(vm, 5, shape.roundedge)
    sdfvm.uniset_scalar(vm, 6, shape.circrad*scale)

    for i=1,4 do
        local p = shape.points[i]
        sdfvm.uniset_vec2(vm, i-1, p[1]*scale, p[2]*scale)
    end
end

function Mouth.squarecirc(o)
    return SquareCirc:new(o)
end

return Mouth
