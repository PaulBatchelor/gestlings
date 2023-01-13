function lilf(str)
    return function(eval)
        eval = eval or lil
        eval(str)
    end
end

function paramf(val)
    return lilf(string.format("param %g", val))
end
