-- create a 4-bit FSM that complies with kufic rules
-- use it to procedurally generate small bit patterns that
-- can be used as identifiers for tract shapes


-- 2 bit kufic fsm
-- 00 -> 01, 10, 11
-- 01 -> 00, 01, 11
-- 10 -> 00, 10, 11
-- 11 -> 00, 01, 10

kuf2 = {}
kuf2[0] = {1, 2, 3}
kuf2[1] = {0, 1, 3}
kuf2[2] = {0, 2, 3}
kuf2[3] = {0, 1, 2}


-- splits a 4-bit row into 2 2-bit components x,y
function split4(row)
    local x = (row >> 2) & 3
    local y = row & 3
    return x, y
end

-- base 4 xy pair to row
function xy2row(x, y)
    x = x & 3;
    y = y & 3;
    return x << 2 | y
end

-- getter inner 2-bit shape in a 4-bit row
-- AKA bits 'bc' in row 'abcb'
function inner2(row)
    return (row >> 1) & 3
end

-- does a value x belong to set s?
function belongs(x, s)
    for _, v in pairs(s) do
        if x == v then return true end
    end
    return false
end

-- calculate possible states for a given 4-bit row

function pstates(row)
    local ir = inner2(row)
    local x, y = split4(row)
    -- local m = kuf2[x]
    -- local n = kuf2[y]
    local s = {}
    for _,m in pairs(kuf2[x]) do
        for _, n in pairs(kuf2[y]) do
            local mn = xy2row(m, n)
            if belongs(inner2(mn), kuf2[ir]) then
                table.insert(s, mn)
            end
        end
    end

    return s
end



-- stringify a row, for printing purposes
function row2str(row)
    local str = ""
    for i=1,4 do
        local x = "-"
        if (row & (1 << (4 - i))) > 0 then x = "#" end
        str = str .. x
    end

    return str
end
kuf4 = {}
for i=0,15 do
    kuf4[i] = pstates(i)
    --print(row2str(i))
end

math.randomseed(os.time())

function generate_symbol()
    -- 1 thru 15 avoids 0
    local symbol = {}
    table.insert(symbol, math.random(15))
    for i=1,5 do
        local possible = kuf4[symbol[i]]
        local next = 0
        while next == 0 do
            next = possible[math.random(#possible)]
        end
        table.insert(symbol, next)
    end
    return symbol
end

nrows = 6
ncols = 5
border = 4
lil ("bpnew bp " ..
    (ncols * (48 + border*2)) + (ncols - 1) * 8  + 2*8 ..
    " " ..
    (nrows * (32 + border*2)) + (nrows - 1) * 8  + 2*8
    )

-- symbol = generate_symbol()

function draw_symbol(symbol, xoff, yoff)
    lil("bpset [grab bp] 0 " ..
        8 + xoff * (48 + 8 + 2*border) .. " " ..
        8 + yoff * (32 + 8 + 2*border) .. " " ..
        48 + border*2 ..
        " " ..
        32+border*2)
    lil("bpoutline [bpget [grab bp] 0] 1")

    for y=1,4 do
        local rowstr = ""
        for x, row in pairs(symbol) do
            local bit = row & (1 << (y - 1))

            if bit > 0 then
                lil(string.format("bprectf [bpget [grab bp] 0] %d %d 8 8 1",
                (x - 1)*8 + border, (y - 1)*8 + border))
            end
        end
    end
end

for row=1,nrows do
    for col=1,ncols do
        draw_symbol(generate_symbol(), col - 1, row - 1)
    end
end

lil("bppbm [grab bp] proofsheet.pbm")
-- print(row2str(xy2row(3, 1)))
