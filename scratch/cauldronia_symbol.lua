core = require("util/core")

cauldronia_symbol = {}

cauldronia_symbol_txt = {
"#######",
"---#---",
"-#####-",
"-#---#-",
"-#-#-#-",
"-#---#-",
"-#####-",
}

lilt = core.lilt

function cauldronia_symbol.new(reg)
    local o = {}

    local size = 32
    o.reg = reg
    o.size = size
    lilt {
        "bpset", "[grab bp]", reg,
        (640 //2) - ((size*7)//2),
        (480//2) - ((size*7)//2),
        size*7, size*7,
    }
    return o
end


function cauldronia_symbol.draw(o)
    local txt = cauldronia_symbol_txt
    local size = o.size
    for y=1, #txt do
        local row = txt[y]
        for x=1,#row do
            local color = 1
            local c = string.char(string.byte(row, x))

            if c == "#" then
                color = 1
            else
                color = 0
            end

            lilt {
                 "bprectf", "[bpget [grab bp] " .. o.reg .. "]",
                 (x - 1)*size, (y - 1)*size, size, size, color
             }
        end
    end
end

-- lilt {
--     "bpnew", "bp", 640, 480
-- }
-- o = cauldronia_symbol.new(6)
-- cauldronia_symbol.draw(o)
-- lilt {
--     "bppng", "[grab bp]", "scratch/cauldronia_symbol.png"
-- }

return cauldronia_symbol
