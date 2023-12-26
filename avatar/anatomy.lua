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

    return an
end

function anatomy.generate_avatar(an)
    local id = 1
    local asset = an.asset
    local avatar = an.avatar
    local mc = an.mouth_controller
    local mouth = mc.mouth
    local mouthshapes = mc:load_shapes(asset)

    local av = avatar.mkavatar(an.sdfdraw,
        an.vm,
        an.syms,
        an.avatar,
        id, 512, an.lilt)(an.shader)

    av.mouthshapes = mouth.mkmouthtab(mouthshapes)
    av.mouthlut = mouth.mkmouthlut(mouthshapes)
    av.mouthidx = mouth.mkmouthidx(mouthshapes)
    av.mouth_controller = mc
    an.avatar_controller = av
    return av
end

function anatomy.apply_shape(an, shape_name, scale)
    scale = scale or 0.5
    local av = an.avatar_controller
    local ms = av.mouthshapes
    local mc = an.mouth_controller

    assert(ms[shape_name] ~= nil,
        "Could not find mouth shape: " .. shape_name)
    mc:apply_shape(vm, ms[shape_name], 0.5)
end

function anatomy.draw(an)
    local avatar = an.avatar
    local vm = an.vm
    local av = an.avatar_controller
    avatar.draw(vm, av)
end

return anatomy
