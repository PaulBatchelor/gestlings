Nodes = {}

function Nodes.butlp(n, p)
    n:lil("butlp zz zz")
    n.input = n:param(0)
    n.cutoff = n:param(p.cutoff or 1000)
end

function Nodes.wavout(n, p)
    local file = p.file or "test.wav"
    n:lil(string.format("wavout zz %s", file))
    n.input = n:param(0)
end

function Nodes.blsaw(n, p)
    n:lil("blsaw zz")
    n.freq = n:param(p.freq or 440)
end

function Nodes.mul(n, p)
    n:lil("mul zz zz")
    n.a = n:param(p.a or 0)
    n.b = n:param(p.b or 0)
end

function Nodes.add(n, p)
    n:lil("add zz zz")
    n.a = n:param(p.a or 0)
    n.b = n:param(p.b or 0)
end

function Nodes.sine(n, p)
    n:lil("sine zz zz")
    n.freq = n:param(p.freq or 440)
    n.amp = n:param(p.amp or 0.5)
end

function Nodes.biscale(n, p)
    n:lil("biscale zz zz zz")
    n.input = n:param(0)
    n.min = n:param(p.min or 0)
    n.max = n:param(p.max or 1)
end

function Nodes.nodes(node, g, n)
    n.sine = node:generator(g, nodes.sine)
    n.add = node:generator(g, nodes.add)
    n.mul = node:generator(g, nodes.mul)
    n.blsaw = node:generator(g, nodes.blsaw)
    n.butlp = node:generator(g, nodes.butlp) 
    n.wavout = node:generator(g, nodes.wavout) 
    n.biscale = node:generator(g, nodes.biscale) 
end

return Nodes
