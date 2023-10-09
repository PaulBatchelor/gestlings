#! ./cantor
local grid = monome_grid
local pprint = require("util/pprint")
local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
local klover = require("klover/klover")
local toni = require("physiology/phys_toni")
local sig = require("sig/sig")
local core = require("util/core")

function start_sound()
lil([[
regmrk 4
regmrk 3
regmrk 0

hsnew hs
rtnew [grab hs] rt

# tubularnew 17.0 -1
tubularnew 8.0 -1
regset zz 4

genvals [tabnew 1] "0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5"
regset zz 3

tabnew [tubularsz [regget 4] ]
regset zz 0

tractdrm [regget 0] [regget 3]
tubulardiams [regget 4] [regget 0]

regget 4
]])

-- lil([[
-- #glot [mtof 46] [param 0.7] [param 0.03] [param 0.001]
-- glot [mtof 67] [param 0.7] [param 0.03] [param 0.001]
-- ]])

local pitch, trig, gate = toni.tempwhistlesigs(sig)
toni.excitation(sig, core, pitch, trig, gate)
pitch:unhold()
trig:unhold()
gate:unhold()

lil([[
tubular zz zz zz
mul zz [dblin -5]
butlp zz 4000
hsout [grab hs]
hsswp [grab hs]
]])

end

TubeSculpt = {}

function add_keymap(keymap, key, fun)
    keymap[string.byte(key)] = fun
end

function stash_symbol(ts)
    local name = ts:symbol()
    local shape = {}

    print("stash: " .. name)
    -- pop shape table from sndkit
    -- TODO: add selected table option because there will
    -- be morphing in the future
    lil("regget 3")
    local tab = pop()
    local db = ts.db

    for i=1,8 do
        shape[i] = valutil.tabget(tab, i - 1)
    end

    local datastr = asset:encode(shape)

    local insert_stmt =
        assert(db:prepare(
        "INSERT INTO tubesculpt(name, data) " ..
        "VALUES(?1, ?2)"))

    -- TODO: handle name collisions
    insert_stmt:bind_values(name, datastr)
    ts.last_symbol_selected = name
    local rc = insert_stmt:step()
    if (rc ~= sqlite3.DONE) then
        print("SQLite3 error: " .. db:errmsg())
    else
        table.insert(ts.shapes, name)
        ts.redraw = true
        ts.draw_symbol = true
    end
    insert_stmt:reset()
end

function load_symbol(ts)
    if (#ts.shapes == 0) then
        print("no shapes found.")
        return
    end

    if (ts.shapepos > #ts.shapes or ts.shapepos < 1) then
        ts.shapepos = 1
    end
    local name = ts.shapes[ts.shapepos]
    ts.shapepos = ts.shapepos + 1

    ts:load_symbol(name)
end

function load_prev_symbol(ts)
    ts.shapepos = ts.shapepos - 2
    -- roll backwards on a shapelist where shapes
    -- have already been loaded
    -- shapepos is initialized to be 1, so -1 occurs
    -- at startup. Otherwise, the position is always
    -- a minimum of 2 since load_symbol increments the
    -- shapepos by 1
    if ts.shapepos == 0 then
        ts.shapepos = #ts.shapes
    end
    load_symbol(ts)
end

function load_next_from_savelist(ts)
    ts.savepos = ts.savepos + 1
    if (ts.savepos > #ts.savelist) then
        ts.savepos = 1
    end
    local name = ts.savelist[ts.savepos]
    ts:load_symbol(name)
end

function load_prev_from_savelist(ts)
    ts.savepos = ts.savepos - 1
    if (ts.savepos <= 0) then
        ts.savepos = #ts.savelist
    end

    local name = ts.savelist[ts.savepos]
    ts:load_symbol(name)
end

function add_to_savelist(ts)
    if ts.last_symbol_selected == nil then return end
    -- use ID in case multiple lists are handled someday
    local list_id = 1
    local sym = ts.last_symbol_selected
    local shape_id = ts:symbol_to_id(sym)
    local db = ts.db

    if shape_id <= 0 then
        print("id could not be found for symbol '" .. sym .. "'")
        return
    end

    local insert_stmt =
        assert(db:prepare(
        "INSERT INTO tubesaves(shape_id, list_id) " ..
        "VALUES(?1, ?2)"))

    insert_stmt:bind_values(shape_id, list_id)
    local rc = insert_stmt:step()
    if (rc ~= sqlite3.DONE) then
        print("SQLite3 error: " .. db:errmsg())
        return
    end

    -- remembering which flags to set is starting to be a chore
    ts.draw_symbol = true
    ts.draw_savelist_added = true
    ts.redraw = true

    if ts.saveset[sym] == nil then
        ts.saveset[sym] = true
        table.insert(ts.savelist, sym)
    end

end

function remove_from_savelist(ts)
    if ts.last_symbol_selected == nil then return end
    -- use ID in case multiple lists are handled someday
    local list_id = 1
    local sym = ts.last_symbol_selected
    local shape_id = ts:symbol_to_id(sym)
    local db = ts.db

    if shape_id <= 0 then
        print("id could not be found for symbol '" .. sym .. "'")
        return
    end

    local insert_stmt =
        assert(db:prepare(
        "DELETE FROM tubesaves WHERE shape_id is ?1 " ..
        "AND list_id is ?2"
        ))

    insert_stmt:bind_values(shape_id, list_id)
    local rc = insert_stmt:step()
    if (rc ~= sqlite3.DONE) then
        print("SQLite3 error: " .. db:errmsg())
        return
    end

    -- remembering which flags to set is starting to be a chore
    ts.draw_symbol = true
    ts.draw_savelist_removed = true
    ts.redraw = true

    ts.saveset[sym] = nil
    for id,val in pairs(ts.savelist) do
        if val == sym then
            table.remove(ts.savelist, id)
        end
    end
end

function TubeSculpt:new(o)
    o = o or {}
    o.quadL = {0, 0, 0, 0, 0, 0, 0, 0}
    o.quadR = {0, 0, 0, 0, 0, 0, 0, 0}
    o.slidervals = { 0, 0, 0, 0, 0, 0, 0, 0 }
    o.scaledvals = { 0, 0, 0, 0, 0, 0, 0, 0 }
    o.selected_region = 0
    o.redraw = false
    o.keymap = {}
    o.db = sqlite3.open("stash.db")
    o.klover_fsm = klover.generate_fsm()

    o.db:exec([[
CREATE TABLE IF NOT EXISTS tubesculpt(
id INTEGER PRIMARY KEY,
name TEXT UNIQUE,
data TEXT)
    ]])

    o.db:exec([[
CREATE TABLE IF NOT EXISTS tubesaves(
id INTEGER PRIMARY KEY,
shape_id INTEGER,
list_id INTEGER)
    ]])

    add_keymap(o.keymap, '2', stash_symbol)
    add_keymap(o.keymap, '6', load_symbol)
    add_keymap(o.keymap, '4', load_prev_symbol)
    add_keymap(o.keymap, '3', add_to_savelist)
    add_keymap(o.keymap, '8', remove_from_savelist)
    add_keymap(o.keymap, '9', load_next_from_savelist)
    add_keymap(o.keymap, '7', load_prev_from_savelist)
    if o.regions == nil then
        error("please set regions")
    end
    -- cache name of symbol (hex string)
    o.last_symbol_selected = nil
    -- flag to draw last saved symbol on-screen
    o.draw_symbol = false
    -- draw save status when added to savelist
    o.draw_savelist_added = false
    o.draw_savelist_removed = false

    o.shapes = {}
    o.shapepos = 1

    for row in o.db:nrows("SELECT name from tubesculpt") do
        table.insert(o.shapes, row.name)
    end

    -- populate savelist and saveset
    -- savelist contains table of shape symbol names
    -- saveset is a structure that ensures the names
    -- are unique
    
    local savelist = {}
    local saveset = {}

    local select_stmt =
        assert(o.db:prepare(
        "SELECT shape_id, tubesculpt.name as name from tubesaves " ..
        "INNER JOIN tubesculpt on shape_id = tubesculpt.id " ..
        "WHERE list_id == 1"))

    for row in select_stmt:nrows() do
        local shape_sym = row.name
        if saveset[shape_sym] == nil then
            saveset[shape_sym] = true
            table.insert(savelist, shape_sym)
        end
    end

    o.savelist = savelist
    o.saveset = saveset
    o.savepos = 0

    setmetatable(o, self)
    self.__index = self
    return o
end

function TubeSculpt:symbol()
    local sym = klover.generate_symbol(self.klover_fsm, 6)
    local symstr = ""

    for _,num in pairs(sym) do
        symstr = symstr .. string.format("%x", num)
    end

    -- Note to self: lower bits on top. '1' draws a column
    -- at the top
    return symstr
end

function TubeSculpt:cleanup()
    self.db:close()
end

function TubeSculpt:set_led(x, y, s)
    local q = nil

    y = y + 1

    if (y < 1 or y > 8) then return end
    if (x < 0 or x > 15) then return end

    if (x >= 8) then
        q = self.quadR
        x = x - 8
    else
        q = self.quadL
    end

    if s == 1 then
        q[y] = q[y] | 1 << x
    else
        q[y] = q[y] & ~(1 << x)
    end
end

function TubeSculpt:clear()
    for i =1,8 do
        self.quadL[i] = 0
        self.quadR[i] = 0
    end
end

function TubeSculpt:press(x, y)
    self.redraw = true
    -- grid zero mode
    y = y - 8
    if x == 15 then
        self.selected_region = y
        return
    end


    local slider = y + 1
    local val = x
    self.slidervals[slider] = val
    scaled_val = ((val + 1) / 16)
    -- scaled_val = (1 - math.exp(scaled_val*3)) / (1 - math.exp(3))
    self.scaledvals[slider] = scaled_val
    valutil.tabset(self.regions, slider - 1, scaled_val)
end

function TubeSculpt:increment(amt)
    local selected = self.selected_region + 1
    local v = self.scaledvals[selected]
    v = v + amt
    valutil.tabset(self.regions, self.selected_region, v)

    self.scaledvals[selected] = v
    old_sliderval = self.slidervals[selected]
    new_sliderval = math.floor(v * 16) - 1
    if old_sliderval ~= new_sliderval then
        self.slidervals[selected] = new_sliderval
        self.redraw = true
    end
end

function TubeSculpt:symbol_to_id(sym)
    local db = self.db
    local select_stmt =
        assert(db:prepare(
        "SELECT id from tubesculpt " ..
        "WHERE name is '" .. sym .. "' LIMIT 1;"))

    local id = -1
    for row in select_stmt:nrows() do
        id = row.id
    end
    select_stmt:reset()

    return id
end

function TubeSculpt:get_shape(sym)
    local db = self.db
    local shape = {}
    local select_stmt =
        assert(db:prepare(
        "SELECT data from tubesculpt " ..
        "WHERE name is '" .. sym .. "'"))

    for row in select_stmt:nrows() do
        shape = asset:decode(row.data)
    end

    return shape
end

function TubeSculpt:load_symbol(sym)
    local shape = {}

    -- pop shape table from sndkit
    -- TODO: add selected table option because there will
    -- be morphing in the future
    lil("regget 3")
    local tab = pop()
    local db = self.db

    shape = self.get_shape(self, sym)
    -- local select_stmt =
    --     assert(db:prepare(
    --     "SELECT data from tubesculpt " ..
    --     "WHERE name is '" .. sym .. "'"))

    -- for row in select_stmt:nrows() do
    --     shape = asset:decode(row.data)
    -- end

    for i=1,8 do
        valutil.tabset(tab, i - 1, shape[i])
        local v = shape[i]
        new_sliderval = math.floor(v * 16) - 1
        self.scaledvals[i] = v
        self.slidervals[i] = new_sliderval
    end

    self.last_symbol_selected = sym
    self.redraw = true
    self.draw_symbol = true
end

function TubeSculpt:export_to_shapemorf(filename)
    local shapemorf = {}

    for _,sym in pairs(self.savelist) do
        local shape = self.get_shape(self, sym)
        for pos,_ in pairs(shape) do
            shape[pos] = math.floor(shape[pos] * 65536)
        end
        shapemorf[sym] = shape
    end

    asset:save(shapemorf, filename)
end

function main()
    -- use the grid zero instead of 128
    local zero_mode = true

    local m = nil
    local update = grid.update

    if zero_mode == true then
        m = grid.open("/dev/ttyACM0")
        update = grid.update_zero
    else
        m = grid.open("/dev/ttyUSB0")
    end

    running = true

    math.randomseed(os.time())
    start_sound()
    lil("regget 3")
    regions = pop()
    local ts = TubeSculpt:new{regions=regions}

    update(m, ts.quadL, ts.quadR)
    print("press (0,0) 3 times to quit")

    press = 0

    local br = bitrune.new("scratch/blocky6.uf2",
                           "bitrune/shapes.bin",
                           "util/tubesculpt.b64")

    bitrune.terminal_setup(br)

    local bitrune_mode = 0
    local tubesculpt_mode = 1

    local mode = bitrune_mode

    while (bitrune.running(br)) do
        ::loop_top::
        local events = grid.get_input_events(m)
        for _,e in pairs(events) do
            if e[3] == 1 then
                if mode == bitrune_mode then
                    bitrune.monome_press(br, e[1], e[2])
                elseif mode == tubesculpt_mode then
                    ts:press(e[1], e[2])
                end
            end
        end

        local chars = bitrune.getchar()

        for _,c in pairs(chars) do
            if c == string.byte('c') then
                print("toggle")
                lil("hstog [grab hs]")
            elseif mode == bitrune_mode then
                bitrune.process_input(br, c)
            elseif mode == tubesculpt_mode then
                if c == string.byte('1') then
                    mode = bitrune_mode
                    goto loop_top
                elseif c == string.byte('a') then
                    ts:increment(0.005)
                elseif c == string.byte('b') then
                    ts:increment(-0.005)
                elseif ts.keymap[c] ~= nil then
                    ts.keymap[c](ts)
                end
            end
        end

        if bitrune.message_available(br) then
            local msg = bitrune.message_pop(br)
            local syms = {}
            if msg ~= nil then
                for w in msg:gmatch("%S+") do
                    table.insert(syms, tonumber(w, 16))
                end
            end

            if syms[1] == 4 then
                if syms[2] == 4 then
                    mode = tubesculpt_mode
                    ts.redraw = true
                    goto loop_top
                elseif syms[2] == 5 then
                    local filename = "shapes.b64"
                    ts:export_to_shapemorf(filename)
                    print("wrote to " .. filename)
                else
                    print(msg)
                end
            else
                print(msg)
            end
        end

        if mode == bitrune_mode then
            bitrune.update_display(br)

            if bitrune.please_draw(br) then
                bitrune.draw(br)
                local quadL, quadR = bitrune.quads(br)
                update(m, quadL, quadR)
            end
        elseif mode == tubesculpt_mode then
            if (ts.redraw) then
                -- TODO this drawing routine should be abstracted away
                ts.redraw = false
                ts:clear()

                if ts.draw_symbol == true then
                    local symstr = ts.last_symbol_selected
                    ts.draw_symbol = false

                    local xoff = 8 - (#symstr//2)
                    if xoff < 0 then xoff = 0 end

                    for i=1,#symstr do
                        local col =
                            string.char(string.byte(symstr, i))
                        local col = tonumber(col, 16)

                        for y=1,4 do
                            local s = 0
                            if (col & (1 << (y - 1))) > 0 then
                                s = 1
                            end
                            ts:set_led(xoff + i - 1, 2 + y - 1, s)
                        end
                    end


                    -- there could be an edge case where
                    -- draw_symbol is false and this is true?
                    if ts.draw_savelist_added == true then
                        ts.draw_savelist_added = false

                        ts:set_led(13, 5, 1)
                        ts:set_led(14, 5, 1)
                        ts:set_led(15, 5, 1)

                        ts:set_led(13, 6, 1)
                        ts:set_led(15, 6, 1)

                        ts:set_led(13, 7, 1)
                        ts:set_led(14, 7, 1)
                        ts:set_led(15, 7, 1)
                    elseif ts.draw_savelist_removed == true then
                        ts.draw_savelist_removed = false
                        ts:set_led(13, 6, 1)
                        ts:set_led(14, 6, 1)
                        ts:set_led(15, 6, 1)
                    end
                else
                    for pos, sv in pairs(ts.slidervals) do
                        for x= 0, sv do
                            ts:set_led(x, pos - 1, 1)
                        end
                    end
                    ts:set_led(15, ts.selected_region, 1)
                end

                update(m, ts.quadL, ts.quadR)
            end
        end

        grid.usleep(80)
    end

    print("bye")
    ts:cleanup()
    bitrune.terminal_reset(br)
    bitrune.del(br)
    grid.close(m)
end

main()
