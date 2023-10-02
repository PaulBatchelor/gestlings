avatar = require("avatar/avatar")
mouth = require("avatar/mouth/mouth")
sdfdraw = require("avatar/sdfdraw")
json = require("util/json")
asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
pprint = require("util/pprint")
core = require("util/core")
lilt = core.lilt

function mkjunior(vm, syms, id)
    local scale = 0.6
    local sqrcirc = mouth:squirc()

    -- asset:save(shader, "tmp/a_junior.b64")
    shader = asset:load("scratch/a_junior.b64")
    local singer =
        avatar.mkavatar(sdfdraw, vm, syms, "junior", id, 512)(shader)

    singer.sqrcirc = sqrcirc

    return singer
end

lil("sdfvmnew vm")
lil("grab vm")
vm = pop()
syms = sdfdraw.load_symbols(json)
av_junior = mkjunior(vm, syms, 0)
mouthshapes = asset:load("avatar/mouth/mouthshapes1.b64")
av_junior.mouthshapes = mouth.mkmouthtab(mouthshapes)
av_junior.mouthlut = mouth.mkmouthlut(mouthshapes)
av_junior.mouthidx = mouth.mkmouthidx(mouthshapes)
lilt {"bpnew", "bp", 32, 32}
lilt {"bpset", "[grab bp]", 0, 0, 0, 32, 32}
sdfvm.scale(vm, 0.55, 0.55)
avatar.draw(vm,
    av_junior,
    nil,
    nil,
    nil,
    0
)

lil("bpget [grab bp] 0")
reg = pop()
xoff = 0
yoff = 0
tiles = {}

for yoff=1,4 do
    for xoff=1,4 do
        local rows = {}
        for y=1,8 do
            local r = 0
            for x=1,8 do
                c = btprnt.read(reg, (xoff - 1)*8 + x - 1, (yoff - 1)*8 + y - 1)
                r = r | (c << (x - 1)*2)
            end
            table.insert(rows, r)
        end
        table.insert(tiles, rows)
    end
end

function load_data(name)
    name = name or "default"
    local db = sqlite3.open("stash.db")

    local tilemap = nil
    local select_stmt =
        assert(db:prepare(
        "SELECT data from tilemaker " ..
        "WHERE name is '" .. name .. "' LIMIT 1"))

    for row in select_stmt:nrows() do
        tilemap = asset:decode(row.data)
    end

    -- if tilemap ~= nil then
    --     self.tilemap = tilemap
    --     print("loaded " .. name)
    -- end

    db:close()
    return tilemap
end

function save_data(name, tilemap)
    local datastr = asset:encode(tilemap)
    local db = sqlite3.open("stash.db")

    local insert_stmt =
        assert(db:prepare(
        "INSERT OR REPLACE INTO tilemaker(name, data) " ..
        "VALUES(?1, ?2)"))

    insert_stmt:bind_values(name, datastr)
    local rc = insert_stmt:step()
    if (rc ~= sqlite3.DONE) then
        print("SQLite3 error: " .. db:errmsg())
    end
    db:close()
end

tilemap = load_data("gestleton")

startpos = 14

for i=1,16 do
    tilemap[startpos + (i - 1)].data = tiles[i]
end

save_data("gestleton", tilemap)
lilt {"bppng", "[grab bp]", "scratch/junior_sprite.png"}
