local grid = monome_grid
local pprint = require("util/pprint")

function start_sound()
lil([[
hsnew hs
rtnew [grab hs] rt

tubularnew 17.0 -1
regset zz 4

genvals [tabnew 1] "0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5"
regset zz 3

tabnew [tubularsz [regget 4] ]
regset zz 0

tractdrm [regget 0] [regget 3]
tubulardiams [regget 4] [regget 0]

regget 4
glot [mtof 46] [param 0.7] [param 0.03] [param 0.001]
tubular zz zz zz
mul zz [dblin -5]
butlp zz 4000
hsout [grab hs]
hsswp [grab hs]

]])

end

TubeSculpt = {}

function TubeSculpt:new(o)
    o = o or {}
    o.quadL = {0, 0, 0, 0, 0, 0, 0, 0}
    o.quadR = {0, 0, 0, 0, 0, 0, 0, 0}
    o.slidervals = { 0, 0, 0, 0, 0, 0, 0, 0 }
    o.scaledvals = { 0, 0, 0, 0, 0, 0, 0, 0 }
    o.selected_region = 0
    o.redraw = false
    if o.regions == nil then
        error("please set regions")
    end
    setmetatable(o, self)
    self.__index = self
    return o
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

local m = grid.open("/dev/ttyUSB0")


function TubeSculpt:clear()
    for i =1,8 do
        self.quadL[i] = 0
        self.quadR[i] = 0
    end
end

function TubeSculpt:press(x, y)
    self.redraw = true
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
        self.redraw = 1
    end
end

running = true

start_sound()
lil("regget 3")
regions = pop()
local ts = TubeSculpt:new{regions=regions}


grid.update(m, ts.quadL, ts.quadR)
print("press (0,0) 3 times to quit")

press = 0

local br = bitrune.new("scratch/blocky6.uf2",
                       "bitrune/shapes.bin",
                       "scratch/out.b64")

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

        if syms[1] == 4 and syms[2] == 4 then
            mode = tubesculpt_mode
            ts.redraw = true
            goto loop_top
        end
    end

    if mode == bitrune_mode then
        bitrune.update_display(br)

        if bitrune.please_draw(br) then
            bitrune.draw(br)
            local quadL, quadR = bitrune.quads(br)
            grid.update(m, quadL, quadR)
        end
    elseif mode == tubesculpt_mode then
        if (ts.redraw) then
            ts.redraw = false
            ts:clear()
            for pos, sv in pairs(ts.slidervals) do
                for x= 0, sv do
                    ts:set_led(x, pos - 1, 1)
                end
            end
            ts:set_led(15, ts.selected_region, 1)
            grid.update(m, ts.quadL, ts.quadR)
        end
    end

    grid.usleep(80)
end

print("bye")
bitrune.terminal_reset(br)
bitrune.del(br)
grid.close(m)
