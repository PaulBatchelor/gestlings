msgpack = require("util/MessagePack")
pprint = require("util/pprint")

-- make sure to generate msgpack data beforehand from XM
-- file with:
-- mnolth xmt -d scratch/welcome_to_gestleton.xm scratch/welcome_to_gestleton.bin
fp = io.open("scratch/welcome_to_gestleton.bin", "r")
mpbytes = fp:read("*all")
fp:close()
module_data = msgpack.unpack(mpbytes)

patterns = module_data.patterns

patdata = patterns[1].data

function getbyte(data, pos)
    local b = data[pos]
    pos = pos + 1
    return b, pos
end

function getcell(patdata, pos)
    b, pos = getbyte(patdata, pos)
    cell = {}

    if (b & 0x80) then
        if ((b & 0x01) > 0) then
            cell.note, pos = getbyte(patdata, pos)
        end
        if ((b & 0x02) > 0) then
            cell.instr, pos = getbyte(patdata, pos)
        end
        if ((b & 0x04) > 0) then
            cell.vol, pos = getbyte(patdata, pos)
        end
        if ((b & 0x08) > 0) then
            cell.effect, pos = getbyte(patdata, pos)
        end
        if ((b & 0x10) > 0) then
            cell.param, pos = getbyte(patdata, pos)
        end
    else
        cell.note = b
    end

    return cell, pos
end

cells = {}

pos = 1
nchans = module_data.header.nchannels
currow = {}
while (pos <= #patdata) do
    cell, pos = getcell(patdata, pos)
    table.insert(currow, cell)
    if (#currow == nchans) then
        table.insert(cells, currow)
        currow = {}
    end
end

for rowpos,row in pairs(cells) do
    --pprint(row[1])
    local nt = row[1].note
    if nt ~= nil then
        if nt == 97 then
            print("OFF")
        else
            print(nt)
        end
    else
        print("-")
    end
end
