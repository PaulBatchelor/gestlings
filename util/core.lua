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
    return Core.lilf(string.format("param %g", val))
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
    if lil_eval ~= lil then
        lil_eval(lstr)
    end
end

function Core.reggetstr(reg, lil_eval)
    lil_eval = lil_eval or lil
    local lstr = string.format("regget %d", reg)
    return lstr
end

return Core
