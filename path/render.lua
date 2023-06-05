-- Lua version based off of render.c

pp = dofile("../util/pprint.lua")
width = 320
height = 200
margin = 10
lineheight = 12

lil("bufnew buf 256")
lil("grab buf")
buf = pop()
lil(string.format("bpnew bp %d %d", width, height))
lil("uf2load chicago chicago12.uf2")
lil("uf2load symbols test.uf2")
lil(string.format("bpset [grab bp] 0 %d %d %d %d",
    margin, margin, width - 2*margin, height - 2*margin))

lil("uf2txtln [bpget [grab bp] 0] [grab chicago] 0 0 'Notating a Linear Gesture Path'")

f = io.open("notation.hex")
hexstr = f:read("*all")
f:close()

function hex2num(str)
    sep = "%s"

    local t = {}

    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(t, tonumber(s, 16))
    end

    return t
end

bytes = hex2num(hexstr)

-- TODO: transfer bytes to buffer
mnobuf.clear(buf)
line = {}
for _,b in pairs(bytes) do
    if b == 0 then
        mnobuf.append(buf, line)
        lil(string.format(
            "uf2bytes [bpget [grab bp] 0] [grab symbols] [grab buf] 0 %d",
            lineheight
            ))
        break
    end
    table.insert(line, b)
end

-- TODO: write bytes using uf2bytes

lil("bppbm [grab bp] out.pbm")
