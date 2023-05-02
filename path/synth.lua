msgpack = dofile("../util/MessagePack.lua")
base64 = dofile("../util/base64.lua")
pprint = dofile("../util/pprint.lua")
path = dofile("path.lua")
tal = dofile("../tal/tal.lua")
gest = dofile("../gest/gest.lua")
sigrunes = dofile("../sigrunes/sigrunes.lua")
core = dofile("../util/core.lua")
asset = dofile("../asset/asset.lua")
asset = asset:new()

gpath = path.load(asset, "path.b64")
words = {}

tal.start(words)
tal.label(words, "sequence")
path.path(tal, words, gpath)
tal.jump(words, "sequence")

G = gest:new({tal=tal})
G:create()
G:compile(words)
G:swapper()

sigrunes.node(sigrunes.phasor) {
    rate = 2.5
}
lil("hold zz; regset zz 0")

sigrunes.node(G:node()) {
    name="sequence",
    conductor=core.liln("regget 0")
}
lil("regget 0; unhold zz")
lil("mtof zz")
lil("blsaw zz")
lil("butlp zz 400")
lil("mul zz 0.5")
lil("wavout zz synth.wav")
lil("computes 10")
G:done()
