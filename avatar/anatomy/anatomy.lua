anatomy = {}

function anatomy.new(p)
    p = p or {}
    local avatar_name = "avatar"
    local syms = p.syms
    local vm = p.vm
    local sdfdraw = p.sdfdraw
    local avatar = p.avatar
    local lilt = p.lilt
    local shader = p.shader
    local asset = p.asset
    local mouth_controller = p.mouth_controller
    local eye_controller = p.eye_controller
    local mouth_scale = p.mouth_scale

    assert(syms ~= nil, "Symbol table must be loaded")
    assert(vm ~= nil, "sdfvm instance not supplied")
    assert(sdfdraw ~= nil, "sdfdraw component not found")
    assert(avatar ~= nil, "avatar component not found")
    assert(lilt ~= nil, "lilt function not supplied")
    assert(shader ~= nil, "shader program not supplied")
    assert(asset ~= nil, "asset component not found")
    assert(mouth_controller ~= nil, "mouth controller not supplied")

    local an = {}

    an.modules = {}

    an.avatar_name = avatar_name
    an.sdfdraw = sdfdraw
    an.lilt = lilt
    an.avatar = avatar
    an.vm = vm
    an.shader = shader
    an.mouth_controller = mouth_controller
    an.asset = asset
    an.syms = syms
    an.eye_controller = eye_controller
    an.mouth_scale = mouth_scale

    return an
end

function anatomy.generate_avatar(an)
    local id = 1
    local asset = an.asset
    local avatar = an.avatar
    local mc = an.mouth_controller
    local mouth = mc.mouth
    local mouthshapes = mc:load_shapes(asset)
    local shader_size = 1024
    local av = avatar.mkavatar(an.sdfdraw,
        an.vm,
        an.syms,
        an.avatar,
        id, shader_size, an.lilt)(an.shader)

    av.mouthshapes = mouth.mkmouthtab(mouthshapes)
    av.mouthlut = mouth.mkmouthlut(mouthshapes)
    av.mouthidx = mouth.mkmouthidx(mouthshapes)
    av.mouth_controller = mc
    an.avatar_controller = av
    av.bouncer = avatar.mkbouncer()

    return av
end

function anatomy.apply_shape(an, shape_name, scale)
    local av = an.avatar_controller
    local ms = av.mouthshapes
    local mc = an.mouth_controller

    assert(ms[shape_name] ~= nil,
        "Could not find mouth shape: " .. shape_name)
    mc:apply_shape(vm, ms[shape_name], an.mouth_scale)
end

function anatomy.draw(an, mouth_x, mouth_y, dims, framepos)
    local avatar = an.avatar
    local vm = an.vm
    local av = an.avatar_controller
    local ec = an.eye_controller

    if ec ~= nil then
        ec:update(vm)
    end

    avatar.draw(vm, av, mouth_x, mouth_y, dims, framepos, an.mouth_scale)
end

function anatomy.update_bounce(an)
    local av = an.avatar_controller
    av.bouncer.update(av.bouncer)
end

function anatomy.bouncereset(an)
    local av = an.avatar_controller
    av.bouncer.reset(av.bouncer)
end

return anatomy
