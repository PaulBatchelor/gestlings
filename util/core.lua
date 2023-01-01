function paramf(val)
    return function ()
        lil(string.format("param %g", val))
    end
end

function lilf(str)
    return function()
        lil(str)
    end
end

