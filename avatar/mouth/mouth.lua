Mouth = {}

function Mouth.squarecirc(scale, mouth_xscale, mouth_yscale, offset)
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

return Mouth
