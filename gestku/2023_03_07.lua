--[[
Doodle Daddle

-- <@>
dofile("gestku/2023_03_07.lua")
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
------------#---
##-##-##-##-#-#-
----------------
###-----###-#-#-
----#-#-#-###-#-
----------------
----------------
#-#-#-#-#-#-#-#-
]]
end
-- </@>

-- <@>
WT = {}
s16 = gestku.seq.seqfun(gestku.morpho)
gest16 = gestku.gest.gest16fun(gestku.sr, gestku.core)
json = require("util/json")
morpher = require("gestku/bits/morpher")
gen_vocab = require("gestku/bits/vocab_march_2023")
grid = monome_grid
quadL = {0, 0, 0, 0, 0, 0, 0, 0}
quadR = {0, 0, 0, 0, 0, 0, 0, 0}
grid_state = {0, 0, 0, 0, 0, 0, 0, 0}
grid_current_preset = "init"
grid_state_file = "gestku/2023_03_07.json"

grid_state_presets = {}
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

lil("valnew button")
load_state(grid_state_file)
parse_grid()
end
-- </@>
-- <@>

Sequence = "A2(B)C4(D)4[EF]2[G]2[H]"

function sequence_get()
	return Sequence
end

function sequence_set(s)
	Sequence = s
end

function articulate()
    G:start()

    morphemes = gen_vocab()
    G:articulate(gestku.mseq.parse(sequence_get(), morphemes))

    G:compile()
end
-- </@>

-- <@>
function gatenode(cnd, name)
    local gst = G.gest
    local nd = gestku.sr.node
    gate = gest16(gst, "gate" .. name, cnd, 0, 1)
    nd(gate){}
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

    lil("phasor 1.1 0")
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

    lil("thresh [val [grab button]] 0.5 2")
    btrig = sig:new()
    btrig:hold()

    btrig:get()
    lil("tgate zz 0.005")
    lil("envar zz 0.001 0.001")
    btrig:get()
    lil("trand zz 1000 3000")
    lil("sine zz 0.3")
    lil("mul zz zz")
    lil("add zz zz")
    btrig:unhold()

    lil([[
dup; dup
bigverb zz zz 0.8 4000
drop
mul zz [dblin -10]
dcblocker zz
add zz zz]])

-- FADE
    lil([[
tenv [tick] 0.01 8 0.99
mul zz zz]])

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

function load_state(statefile)
    if grid_state_presets[grid_current_preset] == nil then
        print("creating new preset " .. grid_current_preset)
        grid_state_presets[grid_current_preset] = {
            0, 0, 0, 0, 0, 0, 0, 0
        }
    end
    local fp = io.open(statefile, "r")
    --grid_state = json.decode(fp:read("*all"))
    grid_state_presets = json.decode(fp:read("*all"))
    grid_state = grid_state_presets[grid_current_preset]
    fp:close()
end

function run_grid()
    local m = grid.open("/dev/ttyUSB0")
    local running = true
    local buttog = 0

    print("starting grid")

    redraw_from_state()
    grid_current_preset = "init"
    --grid_current_preset = "testing"

    if grid_state_presets[grid_current_preset] == nil then
        print("creating new preset " .. grid_current_preset)
        grid_state_presets[grid_current_preset] = {
            0, 0, 0, 0, 0, 0, 0, 0
        }
    end
    grid_state = grid_state_presets[grid_current_preset]
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
                    parse_grid()
                    G:run()
                end
                if x == 14 then
                    lil("playtog")
                end

                if x == 0 then
                    running = false
                    break
                end

                if x == 1 then
                    print("saving")
                    local fp = io.open(grid_state_file, "w")
                    fp:write(json.encode(grid_state_presets))
                    fp:close()
                end
                if x == 2 then
                    print("loading")
                    load_state(grid_state_file)
                    -- local fp = io.open("state.json", "r")
                    -- --grid_state = json.decode(fp:read("*all"))
                    -- grid_state_presets = json.decode(fp:read("*all"))
                    -- grid_state = grid_state_presets[grid_current_preset]
                    -- fp:close()
                    redraw_from_state()
                    draw = true
                end
            end

            if y ~= 2 and y ~= 5 and s == 1 then
                y = y + 1
                if buttog == 1 then
                    buttog = 0
                else
                    buttog = 1
                end
                valutil.set("button", buttog)
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
            -- print("draw")
            grid.update(m, quadL, quadR)
        end

        grid.usleep(80)
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
})] = "2(A)"

vocab[table_to_number({
    1,
    1,
})] = "4(B)"

vocab[table_to_number({
    0,
    1,
})] = "3(C)"

vocab[table_to_number({
    1,
    0,
})] = "4(D)"

vocab[table_to_number({
    0, 0, 0,
    1, 1, 1
})] = "2[E]"

vocab[table_to_number({
    1, 1, 1,
    0, 0, 0,
})] = "2[F]"

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
})] = "2[I]"
-- </@>

-- <@>
function tokenize(gs, vocab)
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
    return table.concat(glyphs, "")
end

function parse_grid()
    print("tokenizing")
	local s = tokenize(grid_state, vocab)
    sequence_set(s)
    print(sequence_get())
end
-- </@>

-- <@>
return G
-- </@>
