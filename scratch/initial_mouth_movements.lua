-- program demonstrating rendering a video where an LFO scales a circle
-- Run this program with "mnolth lua video.lua"
-- This should generate "test.mp4" and "test.wav"
-- Run this ffmpeg command to combine them:
-- ffmpeg -i test.mp4 -i test.wav -pix_fmt yuv420p -acodec aac combined.mp4
val = valutil

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

lil([[
valnew LFO
sine 1 1
biscale zz 0 1
hold zz
regset zz 0

valset [grab LFO] [regget 0]

regget 0
scale zz 300 600
blsaw zz
butlp zz 500
butlp zz 500
wavout zz test.wav
]])

lil("bpget [grab bp] 0")
bpreg = pop()

for i=1,300 do
    lil([[
compute 15
grab gfx
gfxfill 1
]])


lil("bpfill [bpget [grab bp] 0] 0")
-- radius = 32 + val.get("LFO") * 32
-- lil(string.format("bpcirc [bpget [grab bp] 0] 128 128 %g 1", radius))
radius = 0.1 + 0.7*val.get("LFO")
protogestling.face(bpreg, 0.9, radius, 0.3, 0.9, 0.3, 0.9)
lil([[
bptr [grab bp] 0 0 256 256 0 0 0
]])
-- lil(string.format("gfxcirc 128 128 %g 0", radius))

lil([[
grab gfx
dup
gfxtransfer
gfxappend
]])
end

lil([[
unhold [regget 0]
grab gfx
gfxclose
gfxmp4 test.h264 test.mp4
]])
