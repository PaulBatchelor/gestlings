MR = {}

MR.grid_current_preset = "init"
MR.grid_state_file = "state.json"
grid_state_presets = {}
grid_state = {0, 0, 0, 0, 0, 0, 0, 0}

grid = monome_grid

Sequence = "A2(B)C4(D)4[EF]2[G]2[H]"

function MR.sequence_get()
	return Sequence
end

function MR.sequence_set(s)
	Sequence = s
end

quadL = {0, 0, 0, 0, 0, 0, 0, 0}
quadR = {0, 0, 0, 0, 0, 0, 0, 0}
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

function redraw_from_state()
    for y, row in pairs(grid_state) do
        quadL[y] = row & 0xff
        quadR[y] = (row >> 8) & 0xff
    end
end

function MR.run_grid()
    local m = grid.open("/dev/ttyUSB0")
    local running = true
    local buttog = 0

    print("starting grid")

    redraw_from_state()
    MR.grid_current_preset = "init"
    --grid_current_preset = "testing"

    if grid_state_presets[MR.grid_current_preset] == nil then
        print("creating new preset " .. MR.grid_current_preset)
        grid_state_presets[grid_current_preset] = {
            0, 0, 0, 0, 0, 0, 0, 0
        }
    end
    grid_state = grid_state_presets[MR.grid_current_preset]
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
                    local fp = io.open(MR.grid_state_file, "w")
                    fp:write(json.encode(grid_state_presets))
                    fp:close()
                end
                if x == 2 then
                    print("loading")
                    load_state(MR.grid_state_file)
                    -- local fp = io.open("state.json", "r")
                    -- --grid_state = json.decode(fp:read("*all"))
                    -- grid_state_presets = json.decode(fp:read("*all"))
                    -- grid_state = grid_state_presets[MR.grid_current_preset]
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

MR.vocab = {}

function MR.parse_grid()
    print("tokenizing")
	local s = tokenize(grid_state, MR.vocab)
    mcr.sequence_set(s)
    print(mcr.sequence_get())
end

function MR.load_state_from_file(statefile)
    if grid_state_presets[MR.grid_current_preset] == nil then
        print("creating new preset " .. MR.grid_current_preset)
        grid_state_presets[MR.grid_current_preset] = {
            0, 0, 0, 0, 0, 0, 0, 0
        }
    end
    local fp = io.open(statefile, "r")
    --grid_state = json.decode(fp:read("*all"))
    grid_state_presets = json.decode(fp:read("*all"))
    grid_state = grid_state_presets[MR.grid_current_preset]
    fp:close()
end

function MR.load_state()
	MR.load_state_from_file(MR.grid_state_file)
end



return MR
