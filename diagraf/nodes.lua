Nodes = {}

function Nodes.butlp(n, p)
    n:lil("butlp zz zz")
    n.input = n:param(0)
    n.cutoff = n:param(p.cutoff or 1000)
    n:label("butlp")
end

function Nodes.wavout(n, p)
    local file = p.file or "test.wav"
    n:lil(string.format("wavout zz %s", file))
    n.input = n:param(0)
    n:label("wavout")
end

function Nodes.blsaw(n, p)
    n:lil("blsaw zz")
    n.freq = n:param(p.freq or 440)
    n:label("blsaw")
end

function Nodes.mul(n, p)
    n:lil("mul zz zz")
    n.a = n:param(p.a or 0)
    n.b = n:param(p.b or 0)
    n:label("mul")
end

function Nodes.add(n, p)
    n:lil("add zz zz")
    n.a = n:param(p.a or 0)
    n.b = n:param(p.b or 0)
    n:label("add")
end

function Nodes.sine(n, p)
    n:lil("sine zz zz")
    n.freq = n:param(p.freq or 440)
    n.amp = n:param(p.amp or 0.5)
    n:label("sine")
end

function Nodes.biscale(n, p)
    n:lil("biscale zz zz zz")
    n.input = n:param(0)
    n.min = n:param(p.min or 0)
    n.max = n:param(p.max or 1)
    n:label("biscale")
end

function Nodes.getter(n, p)
    n.cab = p.cab
    
    n.data.gen = function(self)
        return self.cab:getstr()
    end

    n:label("getter")
end

function Nodes.setter(n, p)
    n.input = n:param(0)
    local sig = p.sig
    n.cab = sig:new()

    n.data.gen = function(self)
        return self.cab:hold(self.data.g.eval)
    end

    n:label("setter")
end

function Nodes.releaser(n, p)
    n.cab = p.cab

    n.data.gen = function(self)
        return self.cab:unhold(self.data.g.eval)
    end

    n:label("releaser")
end

function Nodes.nodes(node, g, n)
    n.sine = node:generator(g, nodes.sine)
    n.add = node:generator(g, nodes.add)
    n.mul = node:generator(g, nodes.mul)
    n.blsaw = node:generator(g, nodes.blsaw)
    n.butlp = node:generator(g, nodes.butlp) 
    n.wavout = node:generator(g, nodes.wavout) 
    n.biscale = node:generator(g, nodes.biscale) 
    n.getter = node:generator(g, nodes.getter) 
    n.setter = node:generator(g, nodes.setter) 
    n.releaser = node:generator(g, nodes.releaser) 
end

return Nodes
