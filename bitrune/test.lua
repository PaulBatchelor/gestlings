local grid = monome_grid

m = grid.open("/dev/ttyUSB0")

print("press (0,0) to quit")
running = true

quadL = {0, 0, 0, 0, 0, 0, 0, 0}
quadR = {0, 0, 0, 0, 0, 0, 0, 0}

grid.update(m, quadL, quadR)

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

    local c = bitrune.getchar()

    bitrune.process_input(br, c)

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
        grid.update(m, quadL, quadR)
    end

    grid.usleep(10)
end
print("bye")

bitrune.terminal_reset(br)
bitrune.del(br)
grid.close(m)
