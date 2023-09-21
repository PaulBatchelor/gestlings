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
    buf.scale = 1
    buf.font = "chicago"
    buf.nphrases = 4
    return buf
end

function messagebox.append(buf, ch)
    if buf.lines[buf.linepos] == nil then
        error("NIL: " .. buf.linepos)
    end
    buf.lines[buf.linepos] =
        buf.lines[buf.linepos] .. ch
end

function messagebox.remove(buf)
    buf.lines[buf.linepos] =
        string.sub(buf.lines[buf.linepos], 1, -2)
end

function messagebox.newline(buf)
    buf.linepos = buf.linepos + 1
end

function messagebox.clear(buf)
    for i=1,4 do buf.lines[i] = "" end
    buf.linepos = 1
end

function draw_textline(txt, ypos, font, scale)
    lilt {
        "uf2txtln",
        "[bpget [grab bp] 0]",
        "[grab " .. font .. " ]",
        0, ypos,
        "\"" .. txt .. "\"",
        scale
    }
end

function messagebox.draw(buf, lheight)
    lilt {"bpfill", "[bpget [grab bp] 0]", 0}
    for idx, line in pairs(buf.lines) do
        draw_textline(line, (idx-1)*lheight*buf.scale, buf.font, buf.scale)
    end
end

function messagebox.loadfont(fontname, filepath)
    lilt {"uf2load", fontname, filepath}
end


buf = messagebox.new()

messagebox.loadfont("chicago", "fonts/chicago12.uf2")
messagebox.loadfont("fountain_joined", "fonts/fountain_joined.uf2")
messagebox.loadfont("fountain", "fonts/fountain.uf2")
buf.font = "fountain"
lilt {"bpnew", "bp", 240, 60}
lilt {"gfxnewz", "gfx", 320, 240, 2}
lil("grab gfx; dup")
lil("gfxopen tmp/trailer2.h264")
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

function remove(events, t, ch)
    table.insert(events, new_event(t, "remove"))
end

function newline(events, t)
    table.insert(events, new_event(t, "newline", nil))
end

function pause(events, t)
    table.insert(events, new_event(t, "pause", nil))
end

function clear(events, t)
    table.insert(events, new_event(t, "clear", nil))
end

function textscale(events, t, scale)
    table.insert(events, new_event(t, "scale", scale))
end

function nphrases(events, t, n)
    table.insert(events, new_event(t, "nphrases", n))
end

function blockdur(events, t, dur, pos)
    table.insert(events, pos, new_event(t, "blockdur", dur))
end

events = {}

fp = io.open("dialogue/junior.txt")
script = fp:read("*all")
fp:close()

function setup_sound()
    lil("blkset 49")
    lil("valnew msgscale")
    lil("phasor 60 0")
    lil("val [grab msgscale]")
    lilt{"rephasor", "zz", "zz"}
    lil("scale zz 330 440")
    lil("sine zz 0.5")
    lil("wavout zz tmp/trailer2.wav")
    valutil.set("msgscale", 1.0/30)
end


dialogue = descript.parse(script)

-- TODO don't use these as globals lol
-- t = 1
-- rate = 4

function process_block(block, t, rate)
    clear(events, t)
    for i =2,#block do
        line = block[i]
        local c = 1
        while c <= #line do
            ::top::
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
                elseif cmd[1] == "BACKSPACE" then
                    local ntimes = tonumber(cmd[2])

                    for i=1,ntimes do
                        remove(events, t)
                        t = t + rate
                    end
                elseif cmd[1] == "RATE" then
                    rate = tonumber(cmd[2])
                end

                c = c + 1
                -- ch = string.char(string.byte(line, c))
                goto top
            end
            append(events, t, ch)
            t = t + rate
            c = c + 1
        end
        newline(events, t)
    end
    return t, rate
end

t = 1
rate = 4
phrases = {}
phraseblock = {}
last_nphrases = -1
for _, block in pairs(dialogue) do
    if block[1] == "block" then
        local start_time = t
        local start_pos = #events + 1
        t, rate = process_block(block, t, rate)
        local end_time = t
        blockdur(events, start_time, end_time - start_time, start_pos)

        -- since the block has started, insert the phrase block
        -- also make sure there are enough phrases

        assert(#phraseblock == last_nphrases, 
            string.format("expected %d phrases, got %d",
                last_nphrases, #phraseblock))
        table.insert(phrases, phraseblock)

        -- clear phraseblock to be used with next message block
        phraseblock = {} 
    elseif string.match(block[1], "^scale") ~= nil then
        local cmd = core.split(block[1], " ")
        textscale(events, t, tonumber(cmd[2]))
    elseif string.match(block[1], "^nphrases") ~= nil then
        local cmd = core.split(block[1], " ")
        last_nphrases = tonumber(cmd[2])
        nphrases(events, t, last_nphrases)
    elseif string.match(block[1], "^phrase") ~= nil then
        local cmd = core.split(block[1], " ")
        table.insert(phraseblock, {cmd[2], cmd[3]})
    elseif string.match(block[1], "^character") ~= nil then
        local cmd = core.split(block[1], " ")
        local character = cmd[2]
        print("using character '" .. character .. "'")
    end
end

goto bye

local last = -1
for idx,e in pairs(events) do
    if e[1] < last then
        error(string.format("ruh-roh %d < %d", e[1], last))
    end
    last = e[1]
end

-- goto bye

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

    remove = function(mb, data)
        messagebox.remove(mb)
    end,

    scale = function(mb, data)
        mb.scale = data
    end,

    blockdur = function(mb, dur)
        valutil.set("msgscale", mb.nphrases / dur)
    end,

    nphrases = function(mb, n)
        mb.nphrases = n
    end,
}

xoff = 320//2 - 200//2
yoff = 240//2 - 60//2
evpos = 1
last_event = events[evpos]
setup_sound()
nframes = 60*(83)
for n=1,nframes do
    if (n % 60) == 0 then
        print(n, string.format("%02d%%", math.floor(n*100/nframes)))
    end
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
    lil("compute 15")
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
gfxmp4 tmp/trailer2.h264 tmp/trailer2_nosound.mp4
]])

ffmpeg_args = {
    "export AV_LOG_FORCE_NOCOLOR=1;",
    "ffmpeg",
    "-hide_banner", "-loglevel", "error", "-y",
    "-i", "tmp/trailer2_nosound.mp4",
    "-i", "tmp/trailer2.wav",
    "-pix_fmt", "yuv420p",
    "-acodec", "aac",
    "-b:a", "320k",
    "res/trailer2.mp4"
}
os.execute(table.concat(ffmpeg_args, " "))

::bye::
