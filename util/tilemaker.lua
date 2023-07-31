local grid = monome_grid
local pprint = require("util/pprint")
local asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

TileMaker = {}

function add_keymap(keymap, key, fun)
    keymap[string.byte(key)] = fun
end

function goback(ts)
    ts.back_to_bitrune = true
end

function saveit(ts)
    local name = ts.name
    local datastr = asset:encode(ts.tilemap)
    local db = ts.db

    local insert_stmt =
        assert(db:prepare(
        "INSERT OR REPLACE INTO tilemaker(name, data) " ..
        "VALUES(?1, ?2)"))

    insert_stmt:bind_values(name, datastr)
    local rc = insert_stmt:step()
    if (rc ~= sqlite3.DONE) then
        print("SQLite3 error: " .. db:errmsg())
    end
    print("saved " .. name)
end

function loadit(ts)
    ts:load(ts.name)
    ts.please_draw = true
end

function nexttile(ts)
    ts.tilepos = ts.tilepos + 1
    if ts.tilepos > 64 then
        ts.tilepos = 1
    end
    print(ts.tilepos)
    ts.please_draw = true
end

function prevtile(ts)
    ts.tilepos = ts.tilepos - 1
    if ts.tilepos < 1 then
        ts.tilepos = 64
    end
    print(ts.tilepos)
    ts.please_draw = true
end

function nextrow(ts)
    ts.tilepos = ts.tilepos + 8
    if ts.tilepos > 64 then
        ts.tilepos = ts.tilepos - 64
    end
    print(ts.tilepos)
    ts.please_draw = true
end

function prevrow(ts)
    ts.tilepos = ts.tilepos - 8
    if ts.tilepos > 64 then
        ts.tilepos = ts.tilepos + 64
    end
    print(ts.tilepos)
    ts.please_draw = true
end

function TileMaker:new(o)
    o = o or {}
    o.db = sqlite3.open("stash.db")
    o.keymap = {}

    o.db:exec([[
CREATE TABLE IF NOT EXISTS tilemaker(
id INTEGER PRIMARY KEY,
name TEXT UNIQUE,
data TEXT)
    ]])

    o.back_to_bitrune = false
    o.levelmap = {}
    o.tilepos = 1
    o.tilemap = {}

    for i=1,256 do
        o.levelmap[i] = 0x0
    end

    for _=1,64 do
        local tile = {}

        for i=1,8 do
            tile[i] = 0
        end
        table.insert(o.tilemap, tile)
    end

    o.please_draw = false

    add_keymap(o.keymap, '1', goback)
    add_keymap(o.keymap, '3', saveit)
    add_keymap(o.keymap, '9', loadit)
    add_keymap(o.keymap, '6', nexttile)
    add_keymap(o.keymap, '4', prevtile)
    add_keymap(o.keymap, '2', nextrow)
    add_keymap(o.keymap, '8', prevrow)

    -- add faded guides for 8x8 square
    -- might change this if other quandrants
    -- want to be used for other things
    local guide_led_level = 0x1
    for i = 1,9 do
        o.levelmap[16*8 + i] = guide_led_level
        o.levelmap[16*(i - 1) + 9] = guide_led_level
    end
    self.name = "default"
    setmetatable(o, self)
    self.__index = self
    return o
end

function TileMaker:load(name)
    name = name or "default"
    local db = self.db

    local tilemap = nil
    local select_stmt =
        assert(db:prepare(
        "SELECT data from tilemaker " ..
        "WHERE name is '" .. name .. "' LIMIT 1"))

    for row in select_stmt:nrows() do
        tilemap = asset:decode(row.data)
    end

    if tilemap ~= nil then
        self.tilemap = tilemap
        print("loaded " .. name)
    end

end

function TileMaker:press(x, y)
    local row = self.tilemap[self.tilepos][y + 1]

    local s = row & (1 << x)

    if s > 0 then
        row = row & ~(1 << x)
    else
        row = row | (1 << x)
    end
    self.tilemap[self.tilepos][y + 1] = row
    -- pos = y * 16 + (x + 1)
    -- v = self.levelmap[pos]

    -- if v > 0 then v = 0
    -- else v = 0xF
    -- end

    -- self.levelmap[pos] = v
    self.please_draw = true
end

function TileMaker:draw()
    local tilepos = self.tilepos
    for i=1,64 do
        local x = ((i - 1) % 8)
        local y = ((i - 1)// 8)
        local row = self.tilemap[tilepos][y + 1]

        local val = ((row & (1<<x)) >> x)
        if val > 0 then
            val = 0xFF
        else
            val = 0x0
        end
        self.levelmap[(y*16)+(x + 1)] = val
    end
end

function TileMaker:cleanup()
    self.db:close()
end

function main()
    -- use the grid zero instead of 128
    local zero_mode = true

    local m = nil
    local update = grid.update
    local zeroquad = {0, 0, 0, 0, 0, 0, 0, 0}

    m = grid.open("/dev/ttyACM0")
    update = grid.update_zero

    running = true

    press = 0
    local tm = TileMaker:new{}
    name = arg[1]
    tm:load(name)
    tm.name = name or nil

    local br = bitrune.new("scratch/blocky6.uf2",
                           "bitrune/shapes.bin",
                           "util/tilemaker.b64")

    bitrune.terminal_setup(br)

    local bitrune_mode = 0
    local tilemaker_mode = 1

    local mode = bitrune_mode

    while (bitrune.running(br)) do
        ::loop_top::
        local events = grid.get_input_events(m)
        for _,e in pairs(events) do
            if e[3] == 1 then
                if mode == bitrune_mode then
                    bitrune.monome_press(br, e[1], e[2])
                elseif mode == tilemaker_mode then
                    tm:press(e[1], e[2])
                end
            end
        end

        local chars = bitrune.getchar()

        for _,c in pairs(chars) do
            if mode == bitrune_mode then
                bitrune.process_input(br, c)
            elseif mode == tilemaker_mode then
                if tm.keymap[c] ~= nil then
                    tm.keymap[c](tm)
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

            print(msg)
            if syms[1] == 5 then
                if syms[2] == 2 then
                    mode = tilemaker_mode
                    tm.please_draw = true
                    goto loop_top
                end
            end
        end

        if mode == bitrune_mode then
            bitrune.update_display(br)

            if bitrune.please_draw(br) then
                bitrune.draw(br)
                local quadL, quadR = bitrune.quads(br)

                -- clears top quad LEDs on zero
                grid.update(m, zeroquad, zeroquad)
                update(m, quadL, quadR)
            end
        elseif mode == tilemaker_mode then
            if tm.back_to_bitrune == true then
                tm.back_to_bitrune = false
                mode = bitrune_mode
                tm.please_draw = true
                print("tilemaker mode")
                goto loop_top
            end

            if tm.please_draw == true then
                tm.please_draw = false
                tm:draw()
                grid.level_map(m, tm.levelmap)
            end
        end

        grid.usleep(80)
    end

    print("bye")
    tm:cleanup()
    bitrune.terminal_reset(br)
    bitrune.del(br)
    grid.close(m)
end

main()
