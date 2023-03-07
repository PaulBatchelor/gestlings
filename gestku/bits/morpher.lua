function gfmgestparam(cnd, op, param, name)
    local sig = gestku.sig

    gfmparamnode(cnd, op, param, name)
    tmp = sig:new()
    tmp:hold()
    tmpstr = "[" .. tmp:getstr()  .. "]"
    gmorphfmparam(gfmstr, op, param, tmpstr)
    tmp:unhold()
end
function morpher(cnd, name)
    local gst = G.gest
    local sig = gestku.sig
    local core = G.core
    gmorphfmnew(gst,
        "[grab ftl]",
        wtpos_values(name),
        0)

    gfm = core.reserve()

    seqnode(cnd, name)

    lil([[
sine 6 0.07
add zz zz
mtof zz]])

    local pitch = sig:new()
    pitch:hold()

    gfmstr = "[" .. core.reggetstr(gfm) .. "]"

    for i=0,3 do
        gfmgestparam(cnd, i, "frqmul", name)
        gfmgestparam(cnd, i, "fdbk", name)
        gfmgestparam(cnd, i, "modamt", name)
    end

    lil(string.format("gmorphfm %s %s %s",
        gfmstr,
        "[" .. cnd:getstr() .. "]",
        "[" .. pitch:getstr() .. "]"))
    pitch:unhold()
    core.liberate(gfm)
end

return morpher
