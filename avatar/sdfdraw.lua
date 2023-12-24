sdfdraw = {}

local function tokenize(s)
    local sep = lpeg.S(" \t\n")
    local elem = lpeg.C((1 - sep)^0)
    local p = lpeg.Ct(elem * (sep*elem)^0)
    return lpeg.match(p, s)
end

function sdfdraw.generate_bytecode(syms, script, bytebuf)
    local input_script = {}

    for _,line in pairs(script) do
        if (type(line) == "table") then
            table.insert(input_script, table.concat(line, " "))
        else
            table.insert(input_script, line)
        end
    end

    local program = tokenize(table.concat(input_script, "\n"))

    for _,p in pairs(program) do
        if #p == 0 then
            -- ignore
        elseif type(tonumber(p)) == "number" then
            mnobuf.append_float(bytebuf, tonumber(p))
        elseif type(p) == "string" then
            local opcode = syms[p]
            assert(opcode ~= nil, string.format("Invalid opcode: %s", p))
            mnobuf.append(bytebuf, opcode)
        else
            error("can't handle type " .. type(p))
        end
    end
end

function sdfdraw.load_symbols(json, lookup_table_path)
    lookup_table_path =
        lookup_table_path or
        "avatar/sdfvm_lookup_table.json"
    fp = io.open(lookup_table_path)
    assert(json ~= nil, "make sure json module is loaded")
    local syms = json.decode(fp:read("*all"))
    fp:close()
    return syms
end

local SDFRenderer = {}

function SDFRenderer:new(o)
    o = o or {}
    local bufsize = o.bufsize or 256
    local bufname = o.bufname or "sdfdraw_buf"
    local lilt = lilt or o.lilt
    o.bufname = bufname
    lilt {"bufnew", bufname, bufsize}
    lilt {"grab", bufname}
    o.bytebuf = pop()
    setmetatable(o, self)
    self.__index = self
    return o
end

function SDFRenderer:generate_bytecode(program)
    sdfdraw.generate_bytecode(self.syms, program, self.bytebuf)
end

function SDFRenderer:draw(bpreg, vm)
    local args = {
        "bpsdf",
        bpreg,
        vm,
        "[grab " .. self.bufname .. "]"
    }
    lil(table.concat(args, " "))
end

function sdfdraw.mkrenderer(syms, name, bufsize, lilt)
    return SDFRenderer:new {
        syms = syms,
        bufname = name,
        bufsize = bufsize,
        lilt = lilt
    }
end

return sdfdraw
