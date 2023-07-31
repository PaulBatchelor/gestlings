re = require("util/re")
descript = require("descript/descript")
pprint = require("util/pprint")

test_str = [[@hello world
this is a text block
spanning many lines
@block
here is another block

with some empty spaces

@and here
# is a comment
the previous line is a comment

@single_command
@another_single_command
@block
here is another block
]]


t = descript.parse(test_str)

verbose = os.getenv("VERBOSE")
verbose = (verbose ~= nil and verbose == "1")

function testit(blocks, blocknum, pos, expected)
    local block = blocks[blocknum]
    if block[pos] ~= expected then
        if verbose == true then
            print(string.format("block %d, %d:", blocknum, pos))
            print("invalid line: " .. block[pos])
            print("expected: '" .. expected .. "'")
        end

        os.exit(1)
    end
end

testit(t, 1, 1, "hello world")
testit(t, 2, 1, "block")
testit(t, 3, 1, "and here")
testit(t, 3, 2, "the previous line is a comment")
testit(t, 4, 1, "single_command")
testit(t, 5, 1, "another_single_command")
