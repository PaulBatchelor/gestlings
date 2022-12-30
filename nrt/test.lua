-- "^[drmfsltDRMFSLT][+\-\=]?[,']*(?:[1-9][0-9]?[.]?)?$"

morpheme = require("morpheme/morpheme")

pprint = require("util/pprint")
tal = require("tal/tal")
gest = require("gest/gest")
path = require("path/path")

Oct = lpeg.S(",'")^0
Solf = lpeg.S("drmfsltDRMFSLT")
Acc = lpeg.S("+-=")^0
Dot = lpeg.P(".")^0
Rhythm = lpeg.Ct(lpeg.Cg(lpeg.R("09")^1, "dur") *
    lpeg.Cg(Dot, "dot"))^0

Behavior = lpeg.S("~^/_")^0

Space = lpeg.S(" \n\t")^0

Note = lpeg.Ct(lpeg.Cg(Solf, "solf") *
    lpeg.Cg(Oct, "oct") *
    lpeg.Cg(Acc, "acc") *
    lpeg.Cg(Rhythm, "rhythm") *
    lpeg.Cg(Behavior, "behavior"))

Notes = lpeg.Ct((Note * Space)^0)

solfvals = {
    d = 0,
    r = 2,
    m = 4,
    f = 5,
    s = 7,
    l = 9,
    t = 11,
    D = 12,
    R = 14,
    M = 16,
    F = 17,
    S = 19,
    L = 21,
    T = 23,
}


function eval(str, cfg)
    cfg = cfg or {}
    local t = lpeg.match(Notes, str)

    if #t == 0 then
        error("Couldn't parse string: " .. str)
    end

    -- pulses per quarter note
    local ppq = cfg.ppq or 12

    -- pulses per bar (4 beats per bar)
    local ppb = 4 * ppq

    local dur = ppq

    local out = {}

    local base = cfg.base or 60
    local bhvr = 2

    for _, nt in pairs(t) do
        local val = solfvals[nt.solf]

        if nt.oct ~= '' then
            local oct = {}
            nt.oct:gsub(".", 
                function(c) table.insert(oct, c) end)
            for _, o in pairs(oct) do
                if o == "'" then
                    val = val + 12
                elseif o == "," then
                    val = val - 12
                end
            end
        end

        if nt.acc ~= '' then
            if nt.acc == "-" then
                val = val - 1
            elseif nt.acc == "+" then
                val = val + 1
            end
        end

        if nt.rhythm.dur ~= nil then
            dur = ppb / nt.rhythm.dur

            -- TODO: handle more than one dot
            if nt.rhythm.dot ~= "" then
                dur = dur + dur / 2
            end
        end

        if nt.behavior == "~" then
            bhvr = 2
        elseif nt.behavior == "^" then
            bhvr = 3
        elseif nt.behavior == "/" then
            bhvr = 0
        elseif nt.behavior == "_" then
            bhvr = 1
        end

        val = val + base

        table.insert(out, {val, dur, bhvr})
    end

    return out
end

A = {
    seq = eval("d4.~r8mslR16D", {base=60}),
    seq2 = eval("d8.^s,~f,s,m,8l,", {base=48}),
}

S = {
    {A, {1, 4}},
}

g = gest:new({tal = tal, conductor="[regget 0]"})

words = {}

tal.start(words)

g:create()
morpheme.articulate(path, tal, words, S)
g:compile(words)

lil("phasor 2 0; hold zz; regset zz 0")
g:swapper()
g:node("seq")
lil("mtof zz")
lil("blsaw zz; butlp zz 500; mul zz 0.3")

g:node("seq2")
lil("mtof zz")
lil("blsaw zz; butlp zz 500; mul zz 0.3")
lil("add zz zz")

lil("wavout zz test.wav")
lil("unhold [regget 0]")
lil("computes 10")
