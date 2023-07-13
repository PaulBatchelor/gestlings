path = require("path/path")
tal = require("tal/tal")
pprint = require("util/pprint")

test_path = {
    {"apple", {1, 1}, 0},
    {"orange", {1, 1}, 0},
    {"grapefruit", {1, 1}, 0}
}

lookup = {
    apple=0x10,
    orange=0x11,
    grapefruit=0x33,
}

for k,v in pairs(test_path) do
    test_path[k] = path.vertex(v)
end

words = {}

path.path(tal, words, test_path, lookup)

function uxnhex(num)
    return string.format("#%02x", num)
end

verbose = os.getenv("VERBOSE")

function checksymbol(offset, name)
    rc = words[1 + 13*offset] == uxnhex(lookup[name])

    if rc ~= true then
        if verbose ~= nil and verbose == "1" then
            error("offset " .. offset .. ": expected '" .. name .. "'")
        end
        os.exit(1)
    end
end


checksymbol(0, "apple")
checksymbol(1, "orange")
checksymbol(2, "grapefruit")
