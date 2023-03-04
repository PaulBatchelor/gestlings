--[[
dates worked on: 2/20, 2/21, 2/22, 2/28, 3/1, 3/4
GOAL:
monome grid control?
Eventually think about two melodies and duophony?
Move forward.
-- <@>
dofile("gestku/play.lua")
G:rtsetup()
G:setup()
-- </@>
--]]

-- <@>
pprint = require("util/pprint")
-- </@>

-- <@>
gestku = require("gestku/gestku")
G = gestku:new()

function G.symbol()
    return [[
----------
-####-----
------###-
----------
-----##---
-------##-
-####-----
----------
-###-###--
----------
]]
end
-- </@>

-- <@>
WT = {}
s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)
json = require("util/json")
grid = monome_grid
quadL = {0, 0, 0, 0, 0, 0, 0, 0}
quadR = {0, 0, 0, 0, 0, 0, 0, 0}
grid_state = {0, 0, 0, 0, 0, 0, 0, 0}
function set_led(x, y, s)
    local q = nil

    y = y + 1

    if (y < 1 or y > 8) then return end
    if (x < 0 or x > 15) then return end

    if (x >= 8) then
        q = quadR
        x = x - 8
    else
        q = quadL
    end

    if s == 1 then
        q[y] = q[y] | 1 << x
    else
        q[y] = q[y] & ~(1 << x)
    end
end

function G:init()
lil("opendb db /home/paul/proj/smp/a.db")
    lil([[ftlnew ftl
grab ftl
gensine [tabnew 8192 wt4]
param [ftladd zz]
]])

WT.sine = pop()

lil([[
crtwavk [grab db] wt1 gkkfjirki
grab wt1
param [ftladd zz]
]])

WT.wt1 = pop()

lil([[
crtwavk [grab db] wt2 gphqwqork
grab wt2
param [ftladd zz]
]])

WT.wt2 = pop()

lil([[
crtwavk [grab db] wt3 ghirdoqwr
grab wt3
param [ftladd zz]
]])

WT.wt4 = pop()

lil([[
gensinesum [tabnew 8192 wt5] "1 0 1 0 1 0 1 0 0" 1
param [ftladd zz]
]])

WT.sinesum = pop()

lil("drop")

end
-- </@>
-- <@>

function morpheme2voice(M, name)
    local out = {}

    for k,v in pairs(M) do
        out[k .. name] = v
    end

    return out
end

morphemes = {}

function construct_morphemes()

end

function morpheme_append_op(m, op, id)
    for k, v in pairs(op) do
        m[k .. id] = v
    end
end

function articulate()
    G:start()
    local b = gestku.gest.behavior
    local gm = b.gliss_medium
    local lin = b.linear
    local stp = b.step

    op3 = {
        wtpos = {
            {WT.sine, 2, gm},
            {WT.wt4, 2, gm},
        },
        modamt = {
            {1, 1, stp},
        },
        frqmul = {
            {1, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
    }

    op2 = {
        wtpos = {
            {WT.sine, 1, gm},
        },
        modamt = {
            {1, 1, stp},
        },
        frqmul = {
            {1, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
    }
    
    op1 = {
        wtpos = {
            {WT.sine, 1, gm},
        },
        frqmul = {
            {4, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
        modamt = {
            {1, 1, stp},
        },
    }

    op0 = {
        wtpos = {
            {WT.sine, 1, gm},
        },
        frqmul = {
            {4, 1, stp},
        },
        fdbk = {
            {0, 1, stp},
        },
        modamt = {
            {1, 1, stp},
        },
    }

    local M = {
        seq = gestku.nrt.eval("d1", {base=54}),
        gate = s16("p_"),
    }
    morpheme_append_op(M, op3, 3)
    morpheme_append_op(M, op2, 2)
    morpheme_append_op(M, op1, 1)
    morpheme_append_op(M, op0, 0)

    morphemes = {}

    morphemes.A = morpheme2voice(M, "a")

    G:articulate(gestku.mseq.parse("A", morphemes))

    G:compile()
end
-- </@>

-- <@>
function gmorphfmnew(gst, ftl, wtpos, algo)
    lil("gmorphfmnew " ..  gst:get() ..
        " " .. ftl .. " " ..
        "[" .. gst:gmemsymstr(wtpos[1]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[2]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[3]) .. "] " ..
        "[" .. gst:gmemsymstr(wtpos[4]) .. "] " ..
        algo)
end
-- </@>

-- <@>
function gmorphfmparam(gst, op, param, sig)
    local cmd = string.format("gmorphfmparam %s %s %s %s",
        gst, op, param, sig)
    lil(cmd)
end

function wtpos_values(name)
    local wtpos = {"wtpos0", "wtpos1", "wtpos2", "wtpos3"}

    for k, v in pairs(wtpos) do
        wtpos[k] = v .. name
    end

    return wtpos
end

function gfmparamnode(cnd, op, param, name)
    local ln = gestku.core.liln
    gestku.sr.node(G.gest:node()) {
        name = param .. op .. name,
        conductor = ln(cnd:getstr())
    }
end

function seqnode(cnd, name)
    local ln = gestku.core.liln
    gestku.sr.node(G.gest:node()) {
        name = "seq" .. name,
        conductor = ln(cnd:getstr())
    }
end

function gatenode(cnd, name)
    local gst = G.gest
    local nd = gestku.sr.node
    gate = gest16(gst, "gate" .. name, cnd, 0, 1)
    nd(gate){}
end
-- </@>

-- <@>
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
    gmorphfmparam(gfmstr, 0, "frqmul", 8)
    gmorphfmparam(gfmstr, 0, "fdbk", 0)
    gmorphfmparam(gfmstr, 0, "modamt", 0)

    gmorphfmparam(gfmstr, 1, "frqmul", 4)
    gmorphfmparam(gfmstr, 1, "fdbk", 0)
    gmorphfmparam(gfmstr, 1, "modamt", 1)

    gfmgestparam(cnd, 2, "frqmul", name)
    gfmgestparam(cnd, 2, "fdbk", name)
    gfmgestparam(cnd, 2, "modamt", name)

    gfmgestparam(cnd, 3, "frqmul", name)
    gfmgestparam(cnd, 3, "fdbk", name)
    gfmgestparam(cnd, 3, "modamt", name)

    lil(string.format("gmorphfm %s %s %s",
        gfmstr,
        "[" .. cnd:getstr() .. "]",
        "[" .. pitch:getstr() .. "]"
        ))
    pitch:unhold()
    core.liberate(gfm)
end
-- </@>

-- <@>
function G:sound()
    local gst = G.gest
    local core = G.core
    local nd = gestku.sr.node
    local ln = gestku.core.liln

    articulate()
    gst:swapper()

    membuf = "[grab " .. G.gest.bufname .. "]"

    lil("phasor 1 0")
    local sig = gestku.sig
    local cnd = sig:new()
    cnd:hold()

    morpher(cnd, "a")

    lil("mul zz 0.6")
    lil([[
# attempts to make it sound less harsh
butlp zz 4000
peakeq zz 3000 3000 0.1]])

    gatenode(cnd, "a")

    lil("envar zz 0.01 0.2")
    lil("mul zz zz")

    lil([[
dup; dup
bigverb zz zz 0.6 4000
drop
mul zz [dblin -10]
dcblocker zz
add zz zz]])

--     lil([[
-- tenv [tick] 0.1 9 1
-- mul zz zz]])

    gst:done()
    cnd:unhold()
end
-- </@>

-- <@>
function redraw_from_state()
    for y, row in pairs(grid_state) do
        quadL[y] = row & 0xff
        quadR[y] = (row >> 8) & 0xff
    end
end

function run_grid()
    local m = grid.open("/dev/ttyUSB0")
    local running = true

    print("starting grid")

    redraw_from_state()
    grid.update(m, quadL, quadR)

    while (running) do
        local events = grid.get_input_events(m)
        local draw = false
        for _,e in pairs(events) do
            local x = e[1]
            local y = e[2]
            local s = e[3]

            if s == 1 and y == 5 then
                if x == 15 then
                    tokenize()
                    G:run()
                end

                if x == 0 then
                    running = false
                    break
                end

                if x == 1 then
                    print("saving")
                    local fp = io.open("state.json", "w")
                    fp:write(json.encode(grid_state))
                    fp:close()
                end
                if x == 2 then
                    print("loading")
                    local fp = io.open("state.json", "r")
                    grid_state = json.decode(fp:read("*all"))
                    fp:close()
                    redraw_from_state()
                    draw = true
                end
            end

            if y ~= 2 and y ~= 5 and s == 1 then
                y = y + 1
                state = (grid_state[y] & (1 << x)) > 0

                if state then
                    grid_state[y] =
                        grid_state[y] & ~(1 << x)
                    state = 0
                else
                    grid_state[y] =
                        grid_state[y] | (1 << x)
                    state = 1
                end

                set_led(x, y - 1, state)
                draw = true
            end
        end

        if draw then
            print("draw")
            grid.update(m, quadL, quadR)
        end

        grid.usleep(100)
    end
    print("closing grid")
    grid.close(m)
end
-- </@>


-- <@>
function run()
    G:run()
    --run_grid()
end
function altrun()
    --G:run()
    run_grid()
end
-- </@>

-- <@>
function table_to_number(tab)
    local len = #tab / 2
    local r1 = 0
    local r2 = 0
    for i = 1, len do
        local shift = 1 << (i - 1)
        r1 = r1 | (shift * tab[i])
        r2 = r2 | (shift * tab[i + len])
    end
    local n = r1 | (r2 << len) | (1 << (len * 2))
    return n
end
-- </@>
-- <@>
vocab = {}
vocab[table_to_number({
    1, 1,
    1, 1,
})] = "A"

vocab[table_to_number({
    1,
    1,
})] = "B"

vocab[table_to_number({
    0,
    1,
})] = "C"

vocab[table_to_number({
    1,
    0,
})] = "D"

vocab[table_to_number({
    0, 0, 0,
    1, 1, 1
})] = "E"

vocab[table_to_number({
    1, 1, 1,
    0, 0, 0,
})] = "F"

vocab[table_to_number({
    0, 0,
    1, 1,
})] = "G"

vocab[table_to_number({
    1, 1, 1, 0, 1,
    1, 0, 1, 1, 1,
})] = "H"

vocab[table_to_number({
    1, 0, 1,
    1, 1, 1,
})] = "I"
-- </@>

-- <@>
function tokenize()
    print("tokenizing")
    local gs = grid_state
    local glyphs = {}
    for y = 1, 3 do
        local ypos = ((y - 1) * 3) + 1
        local row1 = gs[ypos]
        local row2 = gs[ypos + 1]
        local tmp1 = 0
        local tmp2 = 0
        local len = 0
        for x = 1, 16 do
            local shift = x - 1
            local b1 = (row1 & (1 << shift)) >> shift
            local b2 = (row2 & (1 << shift)) >> shift

            if (b1 | b2) == 1 then
                tmp1 = tmp1 | (1 << len) * b1
                tmp2 = tmp2 | (1 << len) * b2
                len = len + 1
            else
                if len > 0 then
                    val = tmp1 | (tmp2  << len) | (1 << (len*2))
                    val = tmp1 | (tmp2  << len) | (1 << (len*2))
                    if vocab[val] ~= nil then
                        table.insert(glyphs, vocab[val])
                    end
                end
                len = 0
                tmp1 = 0
                tmp2 = 0
            end
        end

        if len > 0 then
            val = tmp1 | (tmp2  << len) | (1 << (len*2))
            if vocab[val] ~= nil then
                table.insert(glyphs, vocab[val])
            end
        end
    end
    -- pprint(glyphs)
    print(table.concat(glyphs, ""))
end
-- </@>

-- <@>
return G
-- </@>

