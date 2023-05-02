function generate_chunk(files)
    local chunk = {}

    for _, file in pairs(files) do
        chunk[#chunk + 1] = assert(loadfile(file))
    end

    if #chunk == 1 then
        chunk = chunk[1]
    else
        for i, func in ipairs(chunk) do
            chunk[i] = ("%sload%q(...);"):format(
                i==#chunk and "return " or " ",
                string.dump(func))
        end
        chunk = assert(load(table.concat(chunk)))
    end

    return chunk
end

chunk = generate_chunk({"grammar.lua", "full_grammar.lua"})
out = io.open("grammar.out", "wb")
out:write(string.dump(chunk))
out:close()
