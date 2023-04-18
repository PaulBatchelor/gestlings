lil("gfxnew gfx 200 320")
lil("grab gfx; gfxopen out.h264")
lil([[
grab gfx
gfxclrset 1 0.0 0.0 0.0
gfxclrset 0 1.0 1.0 1.0
]])
lil([[
bpnew bp 200 320
# face
bpset [grab bp] 0 0 0 200 260
# text
bpset [grab bp] 1 0 260 200 60
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
    "Why Hello there!",
    "I am a Proto-Gestling.",
    "Pleased to meet you.",
    "Welcome to Cauldronia!",
}

total_length = 0

for _,ln in pairs(lines) do
    total_length = total_length + #ln
end

function draw_textblock(lines, textpos)
    for pos, ln in pairs(lines) do
        local lnsz = #ln
        if textpos < lnsz then
            lnsz = textpos
        end
        protogestling.textline(msgbox_reg, font, 10, 10 + 10*(pos -1), ln, 1, 1, lnsz)
        textpos = textpos - lnsz
        if textpos <= 0 then
            return pos, lnsz
        end
    end
end

function get_next_char(lines, lpos, cpos)
    cpos = cpos + 1
    if cpos > #lines[lpos] then
        lpos = lpos + 1
        cpos = 1
    end

    if lpos > #lines then
        return nil
    end

    return string.char(string.byte(lines[lpos], cpos))
end

speed = 5
pause = 30
timer = speed

txtpos = 0
nframes = 60 * 10
for n=1,nframes do
    local lpos, cpos = draw_textblock(lines, txtpos)
    lil("grab gfx")
    lil("gfxfill 0")
    lil("bptr [grab bp] 0 0 200 320 0 0 1")
    lil("grab gfx")
    lil("gfxtransfer; dup")
    lil("gfxappend")

    timer = timer - 1

    if timer <= 0 then
        local nc = get_next_char(lines, lpos, cpos)
        if nc == '!' or nc == '.' then
            timer = pause
        else
            timer = speed
        end
        txtpos = txtpos + 1
        if txtpos > total_length then
            txtpos = total_length
        end
    end
end

lil("gfxclose")
lil("gfxmp4 out.h264 out.mp4")
--os.system("ffmpeg -i test.mp4 -i test.wav -pix_fmt yuv420p -acodec aac combined.mp4")
os.execute("ffmpeg -y -i out.mp4 -pix_fmt yuv420p -acodec aac combined.mp4")
-- lil("gfxppm out.ppm")
-- lil("bppbm [grab bp] out.pbm")
