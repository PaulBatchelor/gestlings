Avatar = {}

function Avatar.mkavatar(sdfdraw, vm, syms, name, id, bufsize, lilt)
    local singer = {
    }

    singer.id = id

    singer.renderer = sdfdraw.mkrenderer(syms, singer.bufname, bufsize, lilt)
    singer.lilt = lilt
    return function(program)
        singer.renderer:generate_bytecode(program)
        return singer
    end
end

local function lerp(curval, target, speed)
    local newval = curval + ((target - curval) * speed)
    return newval
end

function Avatar.mkbouncer()
    local bouncer = {}
    bouncer.rate_target = 1.3
    bouncer.rate_cur = bouncer.rate_target
    bouncer.rate_lerp = 0.2
    bouncer.amp_target = 0.06
    bouncer.amp_cur = bouncer.amp_target
    bouncer.amp_lerp = 0.2
    bouncer.lastphs = 0.0

    bouncer.update = function(b)
        b.rate_cur = lerp(b.rate_cur, b.rate_target, b.rate_lerp)
        b.amp_cur = lerp(b.amp_cur, b.amp_target, b.amp_lerp)
    end

    bouncer.set_rate = function(b, val)
        b.rate_target = val
    end

    bouncer.set_amp = function(b, val)
        b.amp_target = val
    end

    bouncer.reset = function(b, rate, amp)
        b.amp_cur = amp
        b.rate_cur = rate
        b.amp_target = b.amp_cur
        b.rate_target = b.rate_cur
        b.lastphs = 0.0
    end

    return bouncer
end

function Avatar.draw(vm, singer, mouth_x, mouth_y, dims, framepos)
    -- local mouth = singer.open
    local m1 = nil
    local m2 = nil
    local mouth = nil
    local lilt = singer.lilt

    local mouthshapes = singer.mouthshapes
    local mouthvals = singer.mouthidx
    local apply_shape = false

    -- mouth = singer.mouthshapes.rest
    if mouth_x ~= nil then
        local cur, nxt, pos = gestvm_last_values(mouth_x)
        -- print(cur, nxt)
        m1 = mouthvals[cur]
        m2 = mouthvals[nxt]
        mouth = singer.mouth_controller:interp(m1, m2, pos)
        apply_shape = true
    end

    if mouth_y ~= nil then
        local cur, nxt, pos = gestvm_last_values(mouth_y)
        cur = cur / 0xFF
        nxt = nxt / 0xFF
        pos = (1 - pos)*cur + pos*nxt
        mouth = singer.mouth_controller:interp(mouthshapes.rest, mouth, pos)
        apply_shape = true
    end

    if apply_shape then
        singer.mouth_controller:apply_shape(vm, mouth)
    end

    if dims ~= nil then
        local bouncer = singer.bouncer
        local lastphs = bouncer.lastphs or 0

        local bounce_rate = bouncer.rate_cur or 1.3
        local bounce_amp = bouncer.amp_cur or 0.06
        --local phasor = (framepos/(60 * bounce_rate))
        local phasor = (lastphs + (bounce_rate/60)) % 1.0
        lfo = math.sin(2*math.pi * phasor)*bounce_amp
        bouncer.lastphs = phasor
        sdfvm.bias(vm, 0, lfo)
        lilt {
            "bpset",
            "[grab bp]", 1,
            dims[1], dims[2],
            dims[3], dims[4]
            -- avatar_padding, avatar_padding,
            -- 240 - 2*avatar_padding,
            -- (320 - 60) - 2*avatar_padding
        }
    end

    singer.renderer:draw(
        string.format("[bpget [grab bp] %d]", singer.id),
        "[grab vm]"
    )
end

function Avatar.setup(lilt)
    local window_padding = 4
    local avatar_padding = window_padding + 8

    -- avatar
    local avatar_dims = {
        avatar_padding, avatar_padding,
        240 - 2*avatar_padding,
        (320 - 60) - 2*avatar_padding
    }

    -- set up drawing region for avatar
    lilt {
        "bpset",
        "[grab bp]", 1,
        avatar_dims[1], avatar_dims[2],
        avatar_dims[3], avatar_dims[4]
    }

    return avatar_dims
end

return Avatar
