gest = require("gest/gest")
sr = require("sigrunes/sigrunes")
dg = require("diagraf/diagraf")
sig = require("sig/sig")
core = require("util/core")
tal = require("tal/tal")
path = require("path/path")
val = valutil

--- local gest = gestku.gest
--- local sr = gestku.sr
--- local dg = gestku.diagraf
--- local sig = gestku.sig
--- local core = gestku.core
--- local tal = gestku.tal
--- local path = gestku.path



gst = gest:new{tal=tal}
gst:create()
-- gst = G.gest

grf = dg.Graph:new{sig=sig}
ng = core.nodegen(dg.Node, grf)
pg = core.paramgen(ng)
pn = sr.paramnode

bhvr = gest.behavior

vx = path.vertex

freq_path = {
    vx({0, {1, 1}, bhvr.linear}),
    vx({0, {1, 1}, bhvr.linear}),
    vx({0, {2, 1}, bhvr.linear}),
    vx({0, {2, 1}, bhvr.linear})
}

words = {}
tal.start(words)
tal.label(words, "freq")
tal.interpolate(words, 0)
path.path(tal, words, freq_path)
tal.jump(words, "freq")

lil("genvals [tabnew 1] \"0 2 4 7 9 12 14 16\"")
lil("regset zz 0; regmrk 0")

lil([[
tabload "shapes/julia_ah.raw"
regset zz 1
regmrk 1

tabload "shapes/julia_oo.raw"
regset zz 3
regmrk 3

flipper [phasor [rline 1 3 1] 0]
hold
regset zz 5
regmrk 5


diphone [regget 1] [regget 3] [regget 5]
regset zz 4

tractnew
regset zz 2
regmrk 2
tractshape [regget 2] [regget 4]
]])


-- hook up shape movements to mouth signal
lil([[
valnew mouth
valset [grab mouth] [regget 5]
unhold [regget 5]
regclr 5

valnew pitch
]])

-- video setup
lil([[
blkset 49
gfxnew gfx 256 256
bpnew bp 256 256
bpset [grab bp] 0 0 0 256 256

grab gfx
dup
gfxopen test.h264

gfxclrset 1 1.0 1.0 1.0
gfxclrset 0 0.0 0.0 0.0
]])

gst:compile(words)
con = grf:connector()

cnd = ng(sr.phasor) {rate = 4}

freq_ctrl = ng(gst:node()) {name = "freq"}

con(cnd, freq_ctrl.conductor)

mtof = ng(sr.mtof) {}

-- con(freq_ctrl, scaler.input)
-- con(freq_ctrl, mtof.input)
-- con(scaler, mtof.input)

qgliss = ng(sr.qgliss) {
    tab = function(self) return "[regget 0]" end,
}

qglissrand = ng(sr.rline) {min=0.4, max=0.8, rate=2}

con(qglissrand, qgliss.gliss)

freqrand = ng(sr.rline) {min=0.1, max=2, rate=1.1}

LFO = ng(sr.sine) {freq = 1, amp = 1}

con(freqrand, LFO.freq)

LFO_scaler = ng(sr.biscale){min=0, max=1}
con(LFO, LFO_scaler.input)

con(LFO_scaler, qgliss.input)
con(freq_ctrl, qgliss.clock)

add1 = ng(sr.add){b=48 + 3}

pitchval = ng(sr.valset) {
    val = function(self)
    return "[grab pitch]" 
    end
}
con(qgliss, add1.a)

-- hook up pitch to "pitch" value channel
con(add1, pitchval.input)

-- send it on through to mtof (diagraf hack: all things must
-- have outputs currently)
con(pitchval, mtof.input)

glottis = ng(sr.glottis) {}
con(mtof, glottis.freq)
mul1 = ng(sr.mul){b = 0.5}
con(glottis, mul1.a)

tract = ng(sr.tract) {
    tract = function(self) return "[regget 2]" end
}

con(mul1, tract.input)

l = grf:generate_nodelist()
grf:compute(l)

lil([[
regclr 0
regclr 1
regclr 2
]])

lil([[
butlp zz 5000
butlp zz 5000

dup
dup
bigverb zz zz [rline 0.9 0.98 0.3] [param 8000]
add zz zz
mul zz [dblin [rline -15 -20 0.4] ]
dcblocker zz
add zz zz
]])

lil("wavout zz test.wav")

-- grab btprnt instance

lil("bpget [grab bp] 0")
bpreg = pop()

shape_ah = {0.9, 0.1}
shape_oh = {0.4, 0.5}

function lerp(curval, target)
    curval = curval + ((target - curval) * 0.3)
    return curval
end

-- animate
nframes = 60 * 30
radius = 0
fpos = 0
for i=1,nframes do
    if fpos == 0 then
        print(i)
        fpos = 60
    end
    fpos = fpos - 1
    lil([[
compute 15
]])
lil("grab gfx; gfxfill 1")

lil("bpfill [bpget [grab bp] 0] 0")
--radius = 0.1 + 0.7*val.get("mouth")
mouthpos = val.get("mouth")
shape = {
    (1 - mouthpos) * shape_ah[1] +
    mouthpos * shape_oh[1],
    (1 - mouthpos) * shape_ah[2] +
    mouthpos * shape_oh[2]
}
pitch = val.get("pitch")
pitch = (pitch - 48) / 19
if (pitch > 1) then
    pitch = 1
elseif (pitch < 0) then
    pitch = 0
end

--radius = radius * (0.6 + pitch * 0.4)

radius = lerp(radius, pitch)
radius2 = 0.8 * radius + 0.2
radius3 = 0.9 * radius + 0.1

protogestling.face(bpreg, shape[1]*radius2, shape[2]*radius2,
0.3, 0.9 * radius3,
0.3, 0.9 * radius3)
lil([[
bptr [grab bp] 0 0 256 256 0 0 0
]])

lil([[
grab gfx
dup
gfxtransfer
gfxappend
]])
end

-- close out h264, encapsulate into mp4
lil([[
grab gfx
gfxclose
gfxmp4 test.h264 test.mp4
]])

os.execute("ffmpeg -y -i test.mp4 -i test.wav -pix_fmt yuv420p -acodec aac combined.mp4")
