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

function maskdraw_toggle(ts)
    if ts.maskdraw == false then
        ts.maskdraw = true
    else
        ts.maskdraw = false
    end
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
    o.widths = {}
    o.heights= {}
    o.shapes = {}

    for i=1,256 do
        o.levelmap[i] = 0x0
    end


    -- horizontal bar: 000 111 000
    local default_shape = 0x7 << 3
    for _=1,64 do
        local tile = {}

        for i=1,8 do
            tile[i] = 0
        end
        table.insert(o.tilemap, tile)
        table.insert(o.widths, 8)
        table.insert(o.heights, 8)
        table.insert(o.shapes, default_shape)
    end

    o.please_draw = false

    add_keymap(o.keymap, '1', goback)
    add_keymap(o.keymap, '3', saveit)
    add_keymap(o.keymap, '9', loadit)
    add_keymap(o.keymap, '6', nexttile)
    add_keymap(o.keymap, '4', prevtile)
    add_keymap(o.keymap, '2', nextrow)
    add_keymap(o.keymap, '8', prevrow)
    add_keymap(o.keymap, '7', maskdraw_toggle)

    o.maskdraw = false

    -- add faded guides for 8x8 square
    -- might change this if other quandrants
    -- want to be used for other things
    local guide_led_level = 0x1
    for i = 1,9 do
        o.levelmap[16*8 + i] = guide_led_level
        o.levelmap[16*(i - 1) + 9] = guide_led_level
    end

    o.name = "default"
    -- o.tilemap[1][1] = 0x2 | (1 << 2)
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
    if (y >= 8 and y <= 10) and (x>=13 and x <= 16) then
        local shapey = y - 8
        local shapex = x - 13
        print(shapex, shapey)
        local bitpos = shapey*3 + shapex
        local keyshape = self.shapes[self.tilepos]
        local s = keyshape & (1 << bitpos)

        if s > 0 then
            keyshape = keyshape & ~(1 << bitpos)
        else
            keyshape = keyshape | (1 << bitpos)
        end

        self.shapes[self.tilepos] = keyshape
        self.please_draw = true
        return
    end

    if y > 8 then
        if x < 8 then
            self.tilepos = (y - 9)*8 + (x + 1)
            self.please_draw = true
        elseif x >= 14 and y >= 12 then
            -- set current tile dimensions
            local bitpos = 3 - (y - 12)
            if x == 14 then -- width
                local tilewidth = self.widths[self.tilepos]
                local s = ((1 << bitpos) & tilewidth) > 0

                if s then
                    tilewidth = tilewidth & ~(1 << bitpos)
                else
                    tilewidth = tilewidth | (1<<bitpos)
                end

                self.widths[self.tilepos] = tilewidth
            elseif x == 15 then --height
                local tileheight = self.heights[self.tilepos]
                local s = ((1 << bitpos) & tileheight) > 0

                if s then
                    tileheight = tileheight & ~(1 << bitpos)
                else
                    tileheight = tileheight | (1<<bitpos)
                end

                self.heights[self.tilepos] = tileheight
            end
            self.please_draw = true
        end
        return
    end

    local row = self.tilemap[self.tilepos][y + 1]

    local mask = (1 << (2*x)) | (1 << (2*x + 1))
    local s = row & mask

    if s > 0 then
        row = row & ~(mask)
    else
        bits = 0x1
        if (self.maskdraw == true) then
            bits = 0x2
        end
        row = row & ~(mask)
        row = row | (mask & (bits << (2*x)))
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

        local mask = (1 << (2*x)) | (1 << (2*x + 1))
        local val = ((row & mask) >> 2*x) & 0x3
        if val > 0 then
            if (val == 1) then
                val = 0xFF
            elseif (val == 2) then
                val = 0x4
            end
        else
            val = 0x0
        end
        self.levelmap[(y*16)+(x + 1)] = val
    end
    for y=1,7 do
        for x=1,8 do
            self.levelmap[((y + 8)*16)+x]=0x00
        end
    end

    -- draw tile position

    local tile_xpos = ((tilepos - 1)% 8)
    local tile_ypos = ((tilepos - 1)// 8)
    self.levelmap[((tile_ypos + 9)*16)+(tile_xpos + 1)]=0xFF

    local tile_width = self.widths[tilepos]
    local tile_height = self.heights[tilepos]
    -- draw tile dimensions
    for i=1,4 do
        self.levelmap[(11 + (5 - i))*16+15]=
            0xFF*((tile_width & 1 << (i - 1)) >> (i - 1))
        self.levelmap[(11 + (5 - i))*16+16]=
            0xFF*((tile_height & 1 << (i - 1)) >> (i - 1))
    end


    -- draw keyshape
    local keyshape = self.shapes[tilepos]

    for i=1,3 do
        local keyrow = (keyshape >> (i-1)*3) & 0x7
        for b=1,3 do
            if (keyrow & 1<<(b-1)) > 0 then
                self.levelmap[(7 + i)*16+13+b] = 0xFF
            else
                self.levelmap[(7 + i)*16+13+b] = 0x00
            end
        end
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
    if name ~= nil then
        tm.name = name
    end

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
