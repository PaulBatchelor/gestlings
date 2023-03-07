function wtpos_values(name)
    local wtpos = {"wtpos0", "wtpos1", "wtpos2", "wtpos3"}

    for k, v in pairs(wtpos) do
        wtpos[k] = v .. name
    end

    return wtpos
end

function seqnode(cnd, name)
    local ln = gestku.core.liln
    gestku.sr.node(G.gest:node()) {
        name = "seq" .. name,
        conductor = ln(cnd:getstr())
    }
end

function gfmparamnode(cnd, op, param, name)
    local ln = gestku.core.liln
    gestku.sr.node(G.gest:node()) {
        name = param .. op .. name,
        conductor = ln(cnd:getstr())
    }
end

function gmorphfmparam(gst, op, param, sig)
    local cmd = string.format("gmorphfmparam %s %s %s %s",
        gst, op, param, sig)
    lil(cmd)
end

function gmorphfmnew(gst, ftl, wtpos, algo)
    lil("gmorphfmnew " ..  gst:get() ..
        " " .. ftl .. " " ..
        "[" .. gst:gmemsymstr(wtpos[1]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[2]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[3]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[4]) .. "] " ..
        algo)
end
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
