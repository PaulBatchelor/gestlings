core = require("util/core")
lilt = core.lilt

descript = require("descript/descript")

pprint = require("util/pprint")

messagebox = {}
function messagebox.new()
    local buf = {}

    local lines = {}
    for i=1,4 do lines[i] = "" end

    buf.lines = lines
    buf.linepos = 1
    buf.font = "chicago"
    return buf
end

function messagebox.append(buf, ch)
    buf.lines[buf.linepos] =
        buf.lines[buf.linepos] .. ch
end
function messagebox.newline(buf)
    buf.linepos = buf.linepos + 1
end

function draw_textline(txt, ypos, font)
    lilt {
        "uf2txtln",
        "[bpget [grab bp] 0]",
        "[grab " .. font .. " ]",
        0, ypos,
        "\"" .. txt .. "\""
    }
end

function messagebox.draw(buf, lheight)
    for idx, line in pairs(buf.lines) do
        draw_textline(line, (idx-1)*lheight, buf.font)
    end
end

function messagebox.loadfont(fontname, filepath)
    lilt {"uf2load", fontname, filepath}
end

script = [[You're finally awake.
hello there!
Welcome to Gestleton.
City of the Gestlings.]]

out = descript.parse(script)

buf = messagebox.new()

messagebox.loadfont("chicago", "fonts/chicago12.uf2")
lilt {"bpnew", "bp", 240, 60}
lilt {"gfxnewz", "gfx", 320, 240, 2}
lil("grab gfx")
lil("gfxclrset 1 1.0 1.0 1.0")
lil("gfxclrset 0 0.0 0.0 0.0")

lil("drop")
padding = 4
lilt {
    "bpset",
    "[grab bp]", 0,
    padding, padding,
    200 - 2*padding,
    60 - 2*padding
}

-- messagebox.append(buf, "a")
-- messagebox.append(buf, "b")
-- messagebox.append(buf, "c")
-- messagebox.append(buf, "d")
-- messagebox.newline(buf)
-- messagebox.append(buf, "h")
-- messagebox.append(buf, "e")
-- messagebox.append(buf, "l")
-- messagebox.append(buf, "l")
-- messagebox.append(buf, "o")

function new_event(t, name, data)
    return {t, name, data}
end

function append(events, t, ch)
    table.insert(events, new_event(t, "append", ch))
end

function newline(events)
    table.insert(events, new_event(t, "newline", nil))
end

events = {}

t = 1
rate = 5
append(events, t, "a")
t = t + rate
append(events, t, "b")
t = t + rate
append(events, t, "c")
t = t + rate
append(events, t, "d")
t = t + rate
newline(events, t)
append(events, t, "h")
t = t + rate
append(events, t, "e")
t = t + rate
append(events, t, "l")
t = t + rate
append(events, t, "l")
t = t + rate
append(events, t, "o")

event_handler = {
    append = function(mb, data)
        messagebox.append(mb, data)
    end,
    newline = function(mb, data)
        messagebox.newline(mb, data)
    end,
}

for _,ev in pairs(events) do
    local f = event_handler[ev[2]]

    if f ~= nil then
        f(buf, ev[3])
    else
        error("unknown event " .. ev[2])
    end
end

messagebox.draw(buf, 12)

lilt {"bppng", "[grab bp]", "scratch/messagebox.png"}

lil("grab gfx; dup")
-- lil("gfxfill 1")
lil("dup")
xoff = 320//2 - 200//2
yoff = 240//2 - 60//2
lilt{"gfxrectf", xoff, yoff, 200, 60, 1}
lilt{"bptr", "[grab bp]", xoff, yoff, 200, 60, 0, 0, 0}
lil("dup; gfxzoomit")
lil("gfxppm scratch/messagebox.ppm")
