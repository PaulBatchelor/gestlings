MR = {}

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

return MR
