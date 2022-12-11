
pprint = require("util/pprint")

name=arg[1]

gestku = require("gestku/" .. name)

gestku.patch()
lil(string.format(
        "dup; wavouts zz zz %s.wav; computes 11",
        name))

sym = gestku.symbol()

nl = string.byte("\n");
block = string.byte("#");
space = string.byte("-");

tmp = {}
lines = {}

for s in string.gmatch(sym, ".")
do
    if (string.byte(s) == nl) then
        if #tmp > 0 then
            table.insert(lines, tmp)
            tmp = {}
        end
    elseif string.byte(s) == block then
        table.insert(tmp, 1)
    elseif string.byte(s) == space then
        table.insert(tmp, 0)
    end
end

nrows = #lines
ncols = #lines[1]
sz = 16
border = 12
width = ncols * sz + border*2
height = nrows * sz + border*2

lil(string.format("bpnew bp %d %d", width, height))
lil(string.format("bpset [grab bp] 0 %d %d %d %d",
    border, border, width - 2*border, height - 2*border))

lil(string.format("bpset [grab bp] 1 0 0 %d %d", width, height))

for y,row in pairs(lines) do
    color = 1
    for x, color in pairs(row) do
        lil(string.format(
        "bprectf [bpget [grab bp] 0] %d %d %d %d %d",
        (x - 1)*sz, (y - 1)*sz, sz, sz, color
        ))
    end
end

pixspace = 4
lil(string.format("bprect [bpget [grab bp] 1] %d %d %d %d 1",
    border - pixspace, border - pixspace,
    width - 2*border + 2*pixspace,
    height - 2*border + 2*pixspace))

lil(string.format("bppbm [grab bp] %s.pbm", name))
