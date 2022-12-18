pprint = require("util/pprint")

local L = {}

Space = lpeg.S(" \n\t")^0
Duration = lpeg.Cg(lpeg.R("09")^1, "duration")
Value = lpeg.Cg(lpeg.R("az","AZ")^1, "value")
Behavior = lpeg.Cg(lpeg.S("~^/_"), "behavior")

local Exp, S =
    lpeg.V"Exp", lpeg.V"S"

local G = lpeg.P{
    Exp,
    Exp = lpeg.Ct(S*S^0);
    S = lpeg.Ct(Value * Duration^0 * Behavior^0) * Space
}


function parse(t, vals)
    local bhvr = 2
    local dur = 1
    local out = {}

    for _,x in pairs(t) do
        if x.behavior == "~" then
            bhvr = 2
        elseif x.behavior == "^" then
            bhvr = 3
        elseif x.behavior == "/" then
            bhvr = 0
        elseif x.behavior == "_" then
            bhvr = 1
        end

        if x.duration ~= nil then
            dur = x.duration
        end

        if vals[x.value] == nil then
            error("Unknown value: " .. x.value)
        end

        local row = {vals[x.value], dur, bhvr}

        table.insert(out, row)
    end
    return out
end

function L.eval(str, vals)
    local t = lpeg.match(G, str)

    if t == nil then
        error("syntax error: '" .. str .. "'")
    end

    return parse(t, vals)
end

return L
