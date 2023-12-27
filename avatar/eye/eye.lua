Eye = {}

local Cyclops = {}

local cyclops_states = {
    center = {
        pupil_angle = 0,
        pupil_radius = 0.0,
    },
    east = {
        pupil_angle = 0,
        pupil_radius = 0.9,
    },
    west = {
        pupil_angle = 0.5,
        pupil_radius = 0.9,
    },
    north= {
        pupil_angle = 0.25,
        pupil_radius = 0.9,
    },
    south = {
        pupil_angle = -0.25,
        pupil_radius = 0.9,
    },
    southwest = {
        pupil_angle = 0.625,
        pupil_radius = 0.9,
    },
    northwest = {
        pupil_angle = -0.625,
        pupil_radius = 0.9,
    },
    northeast = {
        pupil_angle = 0.125,
        pupil_radius = 0.9,
    },
    southeast = {
        pupil_angle = -0.125,
        pupil_radius = 0.9,
    },
}    

function Cyclops:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.params = {
        pupil_x = 0,
        pupil_y = 0.0,
        pupil_scale = 1.0
    }

    o.target = {
        pupil_x = 0,
        pupil_y = 0.0,
        pupil_scale = 1.0
    }

    o.speed = 0.1

    o.uniforms = {
        pupil_coords = 7,
        pupil_scale = 8
    }

    return o
end

function Eye.cyclops(o)
    return Cyclops:new(o)
end

function pupil_polar_to_xy(pupil_angle, pupil_radius)
    local theta = (2 * math.pi * pupil_angle) + math.pi
    local radius = pupil_radius * 0.23
    local pscale_x = 0.25
    local pscale_y = 0.15
    local pupil_x = pscale_x * pupil_radius * math.cos(theta)
    local pupil_y = pscale_y * pupil_radius * math.sin(theta)

    return pupil_x, pupil_y
end

function Cyclops:generate(offx, offy)
    offx = offx or 0.0
    offy = offy or 0.0

    -- pupil coordinates in radial coordinates
    -- (angle (-1, 1), clockwise), (0-1))
    local pupil_angle = 0.0
    local pupil_radius = 1.0

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
        "vec2", offx, offy, "add2",
        "scalar", self.uniforms.pupil_coords, "uniform", "add2",
        "scalar", 0.1, "circle",
        -- "scalar", 0.1,
        -- "scalar", self.uniforms.pupil_scale, "uniform", "mul",
        -- "circle",
        "scalar", -1, "mul",
        "scalar", 0, "regget",
        "subtract",

        "scalar 0 regget",
        "scalar", 0.01, "onion",
        "union",

        "gtz",
    }

    -- Debugging work, copying what is above, to what is
    -- down here to trace where the program crashes
    shader = {
        "point",
        "vec2", offx, offy, "add2",
        "vec2", 0.35, 0.25, "ellipse",
        "scalar 0 regset",

        "point",
        "vec2", offx, offy, "add2",
        "scalar", self.uniforms.pupil_coords, "uniform", "add2",
        "scalar", 0.1, "circle",

        -- TODO: why does this cause problems?
        -- "scalar", -1, "mul",
        -- "scalar", 0, "regget",
        -- "subtract",

        "scalar", 0, "regget",
        "scalar", 0.01, "onion",
        "union",
        "gtz",
    }

    return shader
end

function Cyclops:name()
    return "cyclops"
end

local function lerp(curval, target, speed)
    local newval = curval + ((target - curval) * speed)
    return newval
end

function Cyclops:update(vm)
    local cur = self.params
    local tar = self.target
    local uni = self.uniforms
    local speed = self.speed

    for k,_ in pairs(cur) do
        cur[k] = lerp(cur[k], tar[k], speed)
    end

    sdfvm.uniset_scalar(vm, uni.pupil_scale, cur.pupil_scale)
    sdfvm.uniset_vec2(vm, uni.pupil_coords, cur.pupil_x, cur.pupil_y)
end

function Cyclops:apply_state(state)
    local tar = self.target
    local cur = self.params
    local speed = self.speed

    local angle = nil
    local radius = nil

    for k,v in pairs(state) do
        if k == "pupil_angle" then
            angle = v
        elseif k == "pupil_radius" then
            radius = v
        else
            tar[k] = v
            if self.speed == 0 then
                cur[k] = v
            end
        end
    end

    if angle ~= nil and radius ~= nil then
        -- convert retrieved polar coordinates to
        -- cartesian coordinates
        local pupil_x, pupil_y = pupil_polar_to_xy(angle, radius)

        tar.pupil_x = pupil_x
        tar.pupil_y = pupil_y

        if speed == 0 then
            cur.pupil_x = pupil_x
            cur.pupil_y = pupil_y
        end
    end
end

function Cyclops:apply(state_names)
    for _,v in pairs(state_names) do
        self.apply_state(self, cyclops_states[v])
    end
end

function Cyclops:lerp_speed(speed)
    self.speed = speed
end

function Eye.name_to_eye(name)
    if name == "cyclops" then
        return Eye:cyclops()
    else
        error("could not find eye type: " .. name)
    end
end

return Eye
