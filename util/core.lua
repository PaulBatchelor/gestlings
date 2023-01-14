Core = {}

function Core.lilf(str)
    return function(eval)
        eval = eval or lil
        eval(str)
    end
end

function Core.paramf(val)
    return Core.lilf(string.format("param %g", val))
end
    
function Core.nodegen(node, g)
    local ng = function(n) return node:generator(g, n) end
    return ng
end
    
function Core.paramgen(ng)
    -- param generator
    local pg = function(prm, label)
        label = label or "param"
        -- assumes input prm is a callback that evals
        -- lua code

        prm1 = prm
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

return Core
