function paramf(val)
    return function ()
        lil(string.format("param %g", val))
    end
end

function lilf(str)
    return function(eval)
        eval = eval or lil
        eval(str)
    end
end

