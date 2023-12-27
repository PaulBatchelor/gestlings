Eye = {}

local Cyclops = {}

function Cyclops:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Eye.cyclops(o)
    return Cyclops:new(o)
end

function Cyclops:generate(offx, offy)
    offx = offx or 0.0
    offy = offy or 0.0

    -- pupil coordinates in radial coordinates
    -- (angle (-1, 1), clockwise), (0-1))
    local pupil_angle = 0
    local pupil_radius = 0.9

    local theta = (2 * math.pi * pupil_angle) + math.pi
    local radius = pupil_radius * 0.23
    local pscale_x = 0.25
    local pscale_y = 0.15
    local pupil_x = pscale_x * pupil_radius * math.cos(theta)
    local pupil_y = pscale_y * pupil_radius * math.sin(theta)
    local pupil_scale = 1.0
    local shader = {
        -- eyeball
        "point",
        "vec2", offx, offy, "add2",
        "vec2", 0.35, 0.25, "ellipse",
        "scalar 0 regset",

        -- pupil 
        "point",
        "vec2", offx + pupil_x, offy + pupil_y, "add2",
        "scalar", 0.1*pupil_scale, "circle",
        "scalar", -1, "mul",
        "scalar", 0, "regget",
        "subtract",

        "scalar 0 regget",
        "scalar", 0.01, "onion",
        "union",

        "gtz",
    }

    return shader
end

return Eye
