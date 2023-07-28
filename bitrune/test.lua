local grid = monome_grid

devpath="/dev/ttyUSB0"
update = grid.update

zero_mode = true


if zero_mode == true then
    devpath="/dev/ttyACM0"
    update = grid.update_zero
end

m = grid.open(devpath)
print("press (0,0) to quit")
running = true

quadL = {0, 0, 0, 0, 0, 0, 0, 0}
quadR = {0, 0, 0, 0, 0, 0, 0, 0}

update(m, quadL, quadR)

br = bitrune.new("scratch/blocky6.uf2", "bitrune/shapes.bin", "bitrune/out.b64")

bitrune.terminal_setup(br)

while (bitrune.running(br)) do
    events = grid.get_input_events(m)
    local redraw = false
    for _,e in pairs(events) do
        if e[3] == 1 then
            bitrune.monome_press(br, e[1], e[2])
        end
    end

    -- TODO: getchar returns tables now, fix
    local chars = bitrune.getchar()
    for _,c in pairs(chars) do
        bitrune.process_input(br, c)
    end

    if bitrune.message_available(br) then
        local msg = bitrune.message_pop(br)
        if msg ~= nil then
            print(msg)
        end
    end

    bitrune.update_display(br)

    if bitrune.please_draw(br) then
        bitrune.draw(br)
        local quadL, quadR = bitrune.quads(br)
        update(m, quadL, quadR)
    end

    grid.usleep(10)
end
print("bye")

bitrune.terminal_reset(br)
bitrune.del(br)
grid.close(m)
