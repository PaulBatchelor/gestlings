Core = {}

function Core.lilf(str)
    return function(eval)
        eval = eval or lil
        eval(str)
    end
end

-- "parameter" lil eval. for use with diagraf parameters
function Core.plilf(str)
    return function(node, eval)
        eval = eval or lil
        --eval = eval or node.data.grf.eval
        eval(str)
    end
end

function Core.liln(str)
    return {
        lilnode = true,
        lilfun = Core.lilf(str),
        lilstr = str
    }
end

function Core.paramf(val)
    --return Core.lilf(string.format("param %g", val))
    return Core.lilf({"param", val})
end

function Core.nodegen(node, graph)
    local ng = function(n)
        return node:generator(graph, n)
    end
    return ng
end

function Core.paramgen(ng)
    -- param generator
    local pg = function(prm, label)
        label = label or "param"
        -- assumes input prm is a callback that evals
        -- lua code

        prm1 = prm

        -- if lilnode, update callbacks and label
        if type(prm) == "table" and prm1.lilnode then
            prm1 = prm.lilfun
            label = label .. ": " .. prm.lilstr
        end

        -- wrap callback into diagraf node generator,
        -- give it a label

        prm2 = ng(function(n, p)
            n.data.cb = prm1
            n.data.gen = function(self)
               return self.data.cb(self.data.g.eval)
            end
            n.data.constant = false
            n:label(label)
        end)

        -- call the generator to produce an instance
        prm3 = prm2()

        -- return the instance
        return prm3
    end

    return pg
end

function Core.reserve(lil_eval)
    lil_eval = lil_eval or lil
    local lstr = "param [regnxt 0]"
    lil(lstr)
    local reg = pop()
    if reg < 0 then
        error("invalid index")
    end
    local lstr =
        string.format("regset zz %d; regmrk %d", reg, reg)
    lil_eval(lstr)
    return reg
end

function Core.liberate(reg, lil_eval)
    lil_eval = lil_eval or lil
    local lstr = string.format("regclr %d", reg)
    lil_eval(lstr)
end

function Core.reggetstr(reg, lil_eval)
    lil_eval = lil_eval or lil
    local lstr = string.format("regget %d", reg)
    return lstr
end

function Core.apply_register_macros(patch, patch_data, free, ext)
    -- generate inverse lookup table for registers
    ilookup = {}
    extlookup = {}

    ext = ext or {}

    for k,v in pairs(patch_data.setters) do
        ilookup[v] = k
    end

    for k,v in pairs(ext) do
        extlookup[v] = k
    end

    newpatch = {}

    for _, oldline in pairs(patch) do
        line = {}

        for _, v in pairs(oldline) do
            table.insert(line, v)
        end

        if line[1] == "regget" and type(line[2]) == "table" then
            if line[2].macro == "reg" then
                line[2] = free[line[2].index]
            elseif line[2].macro == "extreg" then
                line[2] = ext[line[2].key]
            end
        elseif line[1] == "regset" and type(line[3]) == "table" then
            if line[3].macro == "reg" then
                line[3] = free[line[3].index]
            end
        elseif line[1] == "regclr" and type(line[2]) == "table" then
            if line[2].macro == "reg" then
                line[2] = free[line[2].index]
            end
        elseif line[1] == "regmrk" and type(line[2]) == "table" then
            if line[2].macro == "reg" then
                line[2] = free[line[2].index]
            end
        end
        table.insert(newpatch, line)
    end

    -- pprint(newpatch)
    return newpatch
end

function Core.insert_register_macros(patch, patch_data, ext)
    -- generate inverse lookup table for registers
    ilookup = {}
    extlookup = {}

    ext = ext or {}

    for k,v in pairs(patch_data.setters) do
        ilookup[v] = k
    end

    for k,v in pairs(ext) do
        extlookup[v] = k
    end

    for _, line in pairs(patch) do
        -- pprint(line)
        if line[1] == "regget" then
            -- local key = string.format("%d", line[2])
            -- getmap[tonumber(key)] = true
            if ilookup[line[2]] ~= nil then
                -- print(line[2] .. " is nil")
                line[2] = {macro="reg", index=ilookup[line[2]]}
            elseif extlookup[line[2]] ~= nil then
                line[2] = {macro="extreg", key=extlookup[line[2]]}
            end
        elseif line[1] == "regset" then
            -- local key = string.format("%d", line[3])
            -- setmap[tonumber(key)] = true
            if ilookup[line[3]] ~= nil then
                -- print(line[2] .. " is nil")
                line[3] = {macro="reg", index=ilookup[line[3]]}
            end
        elseif line[1] == "regclr" then
            if ilookup[line[2]] ~= nil then
                line[2] = {macro="reg", index=ilookup[line[2]]}
            end
        elseif line[1] == "regmrk" then
            if ilookup[line[2]] ~= nil then
                line[2] = {macro="reg", index=ilookup[line[2]]}
            end
        end
    end
end

function Core.analyze_patch(patch)
    local getmap = {}
    local setmap = {}

    for _, line in pairs(patch) do
        if line[1] == "regget" then
            local key = string.format("%d", line[2])
            getmap[tonumber(key)] = true
        elseif line[1] == "regset" then
            local key = string.format("%d", line[3])
            setmap[tonumber(key)] = true
        end
    end

    getter = {}
    setter = {}

    for k, _ in pairs(getmap) do
        table.insert(getter, k)
    end

    for k, _ in pairs(setmap) do
        table.insert(setter, k)
    end

    return {setters = setter, getters = getter}
end

function Core.lilt(tab)
    lil(table.concat(tab, " "))
end

function Core.lilts(lines)
    for _, line in pairs(lines) do
        Core.lilt(line)
    end
end

return Core
