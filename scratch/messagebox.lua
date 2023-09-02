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

function messagebox.clear(buf)
    for i=1,4 do buf.lines[i] = "" end
    buf.linepos = 1
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
    lilt {"bpfill", "[bpget [grab bp] 0]", 0}
    for idx, line in pairs(buf.lines) do
        draw_textline(line, (idx-1)*lheight, buf.font)
    end
end

function messagebox.loadfont(fontname, filepath)
    lilt {"uf2load", fontname, filepath}
end


buf = messagebox.new()

messagebox.loadfont("chicago", "fonts/chicago12.uf2")
lilt {"bpnew", "bp", 240, 60}
lilt {"gfxnewz", "gfx", 320, 240, 2}
lil("grab gfx; dup")
lil("gfxopen scratch/messagebox.h264")
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

function new_event(t, name, data)
    return {t, name, data}
end

function append(events, t, ch)
    table.insert(events, new_event(t, "append", ch))
end

function newline(events)
    table.insert(events, new_event(t, "newline", nil))
end

function pause(events)
    table.insert(events, new_event(t, "pause", nil))
end

function clear(events)
    table.insert(events, new_event(t, "clear", nil))
end

events = {}

t = 1
rate = 3

script = [[@block
You're finally awake.
hello there!<PAUSE 3>
Welcome...<PAUSE 8> to Gestleton.<PAUSE 4>
City of the Gestlings.<PAUSE 4>

@block
You may be asking yourself<PAUSE 3>
\"how did I get here?\"<PAUSE 5>
Well,<PAUSE 3> it's a good thing
you are sitting down.
]]

dialogue = descript.parse(script)

function process_block(block)
    clear(events, t)
    for _,line in pairs(block) do
        local c = 1
        while c <= #line do
            local ch = string.char(string.byte(line, c))
            if ch == "<" then
                local cmdstr = ""
                c = c + 1
                ch = string.char(string.byte(line, c))
                while (ch ~= ">") do
                    cmdstr = cmdstr .. ch
                    c = c + 1
                    ch = string.char(string.byte(line, c))
                end
                local cmd = core.split(cmdstr, " ")

                if cmd[1] == "PAUSE" then
                    pause(events, t)
                    t = t + rate*tonumber(cmd[2])
                end

                c = c + 1
                ch = string.char(string.byte(line, c))
            end
            append(events, t, ch)
            t = t + rate
            c = c + 1
        end
        newline(events, t)
    end
end

table.remove(dialogue[1], 1)
process_block(dialogue[1])
table.remove(dialogue[2], 1)
process_block(dialogue[2])

event_handler = {
    append = function(mb, data)
        messagebox.append(mb, data)
    end,

    newline = function(mb, data)
        messagebox.newline(mb)
    end,

    pause = function(mb, data)
        -- kill time
    end,

    clear = function(mb, data)
        messagebox.clear(mb)
    end,
}

xoff = 320//2 - 200//2
yoff = 240//2 - 60//2
evpos = 1
last_event = events[evpos]
for n=1,60*15 do
    while (evpos <= #events) and (last_event[1] <= n) do
        local f = event_handler[last_event[2]]

        if f ~= nil then
            f(buf, last_event[3])
        else
            error("unknown event " .. last_event[2])
        end

        evpos = evpos + 1

        if evpos > #events then
            last_event = nil
            break
        end

        last_event = events[evpos]
    end
    messagebox.draw(buf, 12)
    lil("grab gfx; dup")
    lilt{"gfxrectf", xoff, yoff, 200, 60, 1}
    lil("dup")
    lilt{"bptr", "[grab bp]", xoff, yoff, 200, 60, 0, 0, 0}
    lil("gfxzoomit")
    lil("grab gfx; dup")
    lil("gfxtransferz; gfxappend")
end

lil([[
grab gfx
gfxclose
gfxmp4 scratch/messagebox.h264 scratch/messagebox_vid.mp4
]])

os.execute("ffmpeg -y -i scratch/messagebox_vid.mp4 -pix_fmt yuv420p scratch/messagebox.mp4")

-- lilt {"bppng", "[grab bp]", "scratch/messagebox.png"}
-- lil("gfxppm scratch/messagebox.ppm")
--
::bye::
