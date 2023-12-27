Mouth = {}

local Squirc = {}

function Squirc:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function Squirc:generate(scale, mouth_xscale, mouth_yscale, offset)
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

function Squirc:interp(m1, m2, pos)
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

function Squirc:apply_shape(vm, shape, scale)
    scale = scale or 0.6
    sdfvm.uniset_scalar(vm, 4, shape.circleness)
    sdfvm.uniset_scalar(vm, 5, shape.roundedge)
    sdfvm.uniset_scalar(vm, 6, scale*shape.circrad)

    for i=1,4 do
        local p = shape.points[i]
        sdfvm.uniset_vec2(vm, i-1, scale*p[1], scale*p[2])
    end
end

function Squirc:new_shape()

end

function Squirc:name()
    return "squirc"
end

function Squirc:load_shapes(asset, filename)
    filename = filename or "avatar/mouth/mouthshapes1.b64"
    local mouthshapes = asset:load(filename)
    return mouthshapes
end

function Mouth.squirc(o)
    local sqc = Squirc:new(o)
    sqc.mouth = Mouth
    return sqc
end

function Mouth.mkmouthtab(mouthshapes)
    local lut = {}
    for _, mth in pairs(mouthshapes) do
        lut[mth.name] = mth.shape
    end

    return lut
end

function Mouth.mkmouthlut(mouthshapes)
    local lut = {}

    for idx, mth in pairs(mouthshapes) do
        lut[mth.name] = idx
    end

    return lut
end

function Mouth.mkmouthidx(mouthshapes)
    local lut = {}

    for idx, mth in pairs(mouthshapes) do
        lut[idx] = mth.shape
    end

    return lut
end

function Mouth.name_to_mouth(name)
    if name == "squirc" then
        return Mouth:squirc()
    else
        error("could not find mouth type: " .. name)
    end
    return nil
end

return Mouth
