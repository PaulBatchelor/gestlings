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

symbol = {}

math.randomseed(os.time())
table.insert(symbol, math.random(16) - 1)
for i=1,3 do
    local possible = kuf4[symbol[i]]
    local next = 0
    while next == 0 do
        next = possible[math.random(#possible)]
    end
    table.insert(symbol, next)
end

for _, row in pairs(symbol) do
    print(row2str(row))
end
-- print(row2str(xy2row(3, 1)))
