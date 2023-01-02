pprint = require("util/pprint")
nodes = require("diagraf/nodes")
sig = require("sig/sig")

-- Kahn's Algorithm, from pseudocode taken from wikipedia
function topsort(edges)
    -- table that produces a set of pairs
    -- first item is the number of times it's used
    -- as an input. the second item indicates it is
    -- used as an input to another node

    local nodes = {}

    local s = {}

    local l = {}

    -- TODO: simplify to only use e[2]
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

    return l
end

Graph = {}

function Graph:new(o)
    o = o or {}
    o.nverts = 0
    o.edges = {}
    o.nodes = {}
    o.sig = o.sig or sig
    if o.debug then
        o.eval = print
    else
        o.eval = lil
    end
    setmetatable(o, self)
    self.__index = self
    return o
end

function Graph:vert()
    self.nverts = self.nverts + 1
    return self.nverts
end

function Graph:edge(v1, v2, edgetype)
    edgetype = edgetype or 0
    table.insert(self.edges, {v1, v2, edgetype})
end

function Graph:connect(node, input_id)
    local input = self.nodes[input_id]

    self.edge(self, node.data.id, input_id, 1)

    -- this input doesn't actually compute anything anymore
    input:disable()

    -- if a parameter precedes this one, make an edge
    -- to ensure the structure gets sorted properly
    -- also make sure the parameters of the new node
    -- explitely appear after previous parameter

    if input.data.param_id > 1 then
        local param_id = input.data.param_id
        local parent = self.nodes[input.data.parent]
        local params = parent.data.params
        local prev_param = params[param_id - 1]
        local prev_param_id = prev_param.data.id
        self.edge(self, prev_param_id, node.data.id)

        local node_params = node.data.params

        for _, p in pairs(node_params) do
            self.edge(self, prev_param_id, p.data.id)
        end
    end
end

function Graph:connector()
    return function(node, input_id)
        self.connect(self, node, input_id)
    end
end

function Graph:dot()
    print("digraph G {")
    print("rankdir=LR")
    print("layout=dot")

    for _,n in pairs(self.nodes) do
        if n:disabled() == false then
            if n.data.label ~= nil then
                print(string.format("%d [label=\"%s\"]",
                    n.data.id, n.data.label))
            elseif n:isconstant() then
                print(string.format("%d [label=%s]",
                    n.data.id, n.data.val))
            else
                print(string.format("%d [label=\"N%d\"]",
                    n.data.id, n.data.id))
            end
        end
    end
    for _, e in pairs(self.edges) do
        if e[3] == 1 then
            local n2 = self.nodes[e[2]]
            local n1 = self.nodes[e[1]]

            local incoming = e[1]
            local outgoing = e[2]
            if n2:disabled() then
                outgoing = n2.data.parent
            end

            if n1:disabled() == false then
                print(string.format("%d -> %d", incoming, outgoing))
            end
        end
    end
    print("}")
end

-- TODO come up with better name?
function Graph:process()
    local hm = {}
    local multi = {}

    for _,e in pairs(self.edges) do
        if e[3] == 1 then
            if hm[e[1]] == nil then
                --hm[e[1]] = {1, 0}
                hm[e[1]] = 1
            else
                --hm[e[1]][1] = hm[e[1]][1] + 1
                hm[e[1]] = hm[e[1]] + 1
            end

            -- if hm[e[2]] == nil then
            --     hm[e[2]] = {0, 1}
            -- else
            --     hm[e[2]][2] = hm[e[2]][2] + 1
            -- end
        end
    end
    --pprint(hm)
    for index, ninputs in pairs(hm) do
        if ninputs ~= nil then
            if ninputs > 1 then
                local node = self.nodes[index]

                -- TODO better naming
                -- node, nodes, etc... too confusing
                local setter_node = Node:generator(self, nodes.setter)
                local getter_node = Node:generator(self, nodes.getter)

                local node_id = node.data.id
                node.data.children = {}
                local setter = setter_node{sig=self.sig}
                local setter_id = setter.data.id

                for _, e in pairs(self.edges) do
                    if e[1] == node_id and e[3] == 1 then
                        local getter = getter_node {
                            cab=setter.cab
                        }
                        e[1] = getter.data.id
                        -- create edge to make sure setter
                        -- comes before the getter
                        self.edge(self, setter_id, getter.data.id)

                        -- create parent/child
                        table.insert(node.data.children,
                            getter.data.id)
                        getter.data.parent = node.data.id
                    end
                end
                -- connect original node to setter
                self.connect(self, node, setter.input)
            end
        end
    end
end

function Graph:postprocess(lst)
    -- find which nodes have children
    for _,n in pairs(self.nodes) do
        if n.data.children ~= nil then
            -- of those children, find the one closest to the end
            local last_child_id = -1
            for i=#lst,1,-1 do
                local curnode = self.nodes[lst[i]]
                if curnode.data.parent == n.data.id then
                    last_child_id = curnode.data.id
                    break
                end
            end

            if (last_child_id < 0) then
                error("could not find any children")
            end

            -- find node that takes this as a signal input
            -- at this point, it is assumed that the graph
            -- has been processed so there is exactly one

            local input_node_id = -1

            for _,e in pairs(self.edges) do
                if e[3] == 1 then
                    if e[1] == last_child_id then
                        input_node_id = e[2]
                        break
                    end
                end
            end

            if input_node_id < 0 then
                error("could not find input node")
            end

            local input_node = self.nodes[input_node_id]

            -- input_node is a parameter input, we want
            -- the processor, which is the parent
            input_node = self.nodes[input_node.data.parent]

            -- create releaser node
            -- and place it after the input node
            -- TODO shave off some time if we start at
            -- last child node list position? it should always
            -- come after it
            for i = 1, #lst do
                local node = self.nodes[lst[i]]
                if node.data.id == input_node.data.id then
                    -- create releaser node
                    local relnodegen =
                        Node:generator(self, nodes.releaser)
                    local cab = self.nodes[last_child_id].cab
                    local rel = relnodegen {cab = cab}
                    -- insert id at position i + 1 in lst
                    table.insert(lst, i + 1, rel.data.id)
                    -- add edge to ensure it appears in the right
                    -- place after another sort
                    self.edge(self, node.data.id, rel.data.id)
                    break
                end
            end
        end
    end
end

Node = {}

function Node:new(g)
    o = {}
    o.data = {}
    o.data.g = g
    o.data.id = g:vert()
    o.data.val = 1.0
    o.data.params = {}
    o.data.eval = g.eval
    o.data.gen = function(self)
        return string.format("param %g", self.data.val)
    end
    o.data.constant = true
    table.insert(g.nodes, o)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Node:constant(val)
    self.data.val = val
    self.data.constant = true
end

function Node:isconstant()
    return self.data.constant
end

function Node:lil(str)
    self.data.gen = function(self) return str end
    self.data.constant = false
end

function Node:disable()
    self.data.gen = nil
    self.data.constant = false
end

function Node:disabled()
    return self.data.gen == nil
end

function Node:param(val)
    local g = self.data.g
    local params = self.data.params
    local p = Node:new(g)
    p:constant(val)
    table.insert(params, p)
    p.data.param_id = #params

    if #params > 1 then
        pp = params[#params - 1]
        g:edge(pp.data.id, p.data.id)
    end

    g:edge(p.data.id, self.data.id, 1)
    -- TODO: is parent being overloaded in process()?
    p.data.parent = self.data.id
    return p.data.id
end

function Node:compute()
    if self.data.gen ~= nil then
        self.data.eval(self.data.gen(self))
    end
end

function Node:generator(g, f)
    return function(p)
        local n = self.new(self, g)
        p = p or {}
        f(n, p)
        return n
    end
end

function Node:label(label)
    self.data.label = label
end

g = Graph:new{debug=true}

n = {}
nodes.nodes(Node, g, n)
s1 = n.blsaw()
lfo = n.sine{freq=1.23, amp=1}
gain = n.mul{b=0.5}
lpf = n.butlp{cutoff=300}

con = g:connector()

bias = n.biscale{min=200, max=500}
con(lfo, bias.input)
con(bias, s1.freq)
con(s1, gain.a)

-- -- TODO: make this work
-- lpf_lfo = n.biscale{min=321, max=1234}
-- con(lfo, lpf_lfo.input)
-- con(lpf_lfo, lpf.cutoff)

lpf_lfo = n.sine{freq=4.56, amp=1}
lpf_biscale = n.biscale{min=321, max=1234}
lpf_biscale:label("LPF biscale")
con(lpf_lfo, lpf_biscale.input)
con(lpf_biscale, lpf.cutoff)

con(gain, lpf.input)

out = lpf
con(out, n.wavout().input)

g:process()
-- g:dot()

l = topsort(g.edges)

g:postprocess(l)

for _, i in pairs(l) do
    local n = g.nodes[i]
    local label = n.data.label
    if label ~= nil then
        g.eval(string.format("# %s", n.data.label))
    end
    n:compute()
end

g.eval("computes 10")