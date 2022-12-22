whistle = require("whistle/whistle")

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

whistle.osc {
    freq = lilf("rline 200 350 10"),
    timbre = paramf(0.5),
    amp = paramf(0.5)
}

lil("wavout zz test.wav")
lil("computes 6")
