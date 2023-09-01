core = require("util/core")
lilt = core.lilt

descript = require("descript/descript")

pprint = require("util/pprint")

script = [[You are finally awake.
hello there!
Welcome to Gestleton.
City of the Gestlings.]]

out = descript.parse(script)

textbuf = {}

for _, line in pairs(out[1]) do
    table.insert(textbuf, line)
end

lilt {"uf2load", "chicago", "fonts/chicago12.uf2"}
lilt {"bpnew", "bp", 200, 60}
padding = 4
lilt {
    "bpset",
    "[grab bp]", 0,
    padding, padding,
    200 - 2*padding,
    60 - 2*padding
}

function draw_textline(txt, ypos)
    lilt {
        "uf2txtln",
        "[bpget [grab bp] 0]",
        "[grab chicago]",
        0, ypos,
        "'" .. txt .. "'"
    }
end

for idx, line in pairs(textbuf) do
    draw_textline(line, (idx-1)*12)
end
-- draw_textline(textbuf[1], 0)
-- draw_textline(textbuf[2], 12)
lilt {"bppng", "[grab bp]", "scratch/messagebox.png"}
