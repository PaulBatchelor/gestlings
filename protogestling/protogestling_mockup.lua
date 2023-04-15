lil([[
bpnew bp 200 320
# face
bpset [grab bp] 0 0 0 200 240
# text
bpset [grab bp] 1 0 240 200 80
# main
bpset [grab bp] 2 0 0 200 320

# bpoutline [bpget [grab bp] 0] 1
# bpoutline [bpget [grab bp] 1] 1
bpline [bpget [grab bp] 1] 0 0 200 0 1
bproundrect [bpget [grab bp] 2] 0 0 200 320 16 1
]])

lil("bpget [grab bp] 0")
face_reg = pop()
protogestling.face(face_reg, 0.9, 0.3, 0.3, 0.9, 0.3, 0.9)

lil("bpfnt_default font")
lil("bpget [grab bp] 1")
msgbox_reg = pop()
lil("grab font")
font = pop()
lines = {
    "Hello!",
    "I am a Proto-Gestling.",
    "Pleased to meet you.",
}

for pos, ln in pairs(lines) do
    protogestling.textline(msgbox_reg, font, 4, 4 + 17*(pos -1), ln, 1, 1)
end
-- lil("bptxtbox [bpget [grab bp] 1]  [grab font] 4 4 " ..
--     "\"" .. text .. "\"")
-- lil("bpchar [bpget [grab bp] 1]  [grab font] 4 4 H 1 1")


lil("bppbm [grab bp] out.pbm")
