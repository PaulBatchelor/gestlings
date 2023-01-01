pprint = require("util/pprint")

edges = {
    {1, 5},
    {4, 5},
    {2, 1},
    {6, 1},
    {3, 4},
    {3, 1},
    {3, 5},
}

-- Kahn's Algorithm, from pseudocode taken from wikipedia
function topsort(edges)
    -- table that produces a set of pairs
    -- first item is the number of times it's used
    -- as an input. the second item indicates it is
    -- used as an input to another node

    local nodes = {}

    local s = {}

    local l = {}

    for _,e in pairs(edges) do
        if nodes[e[1]] == nil then
            nodes[e[1]] = {1, 0}
        else
            nodes[e[1]][1] = nodes[e[1]][1] + 1
        end

        if nodes[e[2]] == nil then
            nodes[e[2]] = {0, 1}
        else
            nodes[e[2]][2] = nodes[e[2]][2] + 1
        end
    end

    for k, v in pairs(nodes) do
        if v[2] == 0 then
            table.insert(s, k)
        end
    end

    -- table.remove(), does funny things, so
    -- keep track of which edges have been removed in
    -- a separate table
    local removed = {}
    while #s > 0 do
        local n = table.remove(s)
        table.insert(l, n)
        local incoming_nodes = {}
        for i,e in pairs(edges) do
            if removed[i] == nil then
                if e[1] == n then
                    table.insert(incoming_nodes, e[2])
                    removed[i] = true
                end
            end
        end

        for _,m in pairs(incoming_nodes) do
            local no_incoming_edges = true
            for i, e in pairs(edges) do
                if removed[i] == nil then
                    if e[2] == m then
                        no_incoming_edges = false
                    end
                end
            end

            if no_incoming_edges == true then
                table.insert(s, m)
            end
        end
    end
    return l, nodes
end

pprint(topsort(edges))
