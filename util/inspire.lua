#! ./cantor
core = require("util/core")
lilt = core.lilt
lilts = core.lilts
json = require("util/json")
mouth = require("avatar/mouth/mouth")
sdfdraw = require("avatar/sdfdraw")
avatar = require("avatar/avatar")

descript = require("descript/descript")

pprint = require("util/pprint")
asset = require("asset/asset")
asset = asset:new{
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
gest = require("gest/gest")
tal = require("tal/tal")
morpheme = require("morpheme/morpheme")
path = require("path/path")
monologue = require("monologue/monologue")
sigrunes = require("sigrunes/sigrunes")
sig = require("sig/sig")

-- import inspire after everything else
inspire = require("inspire/inspire")

mnorealloc(10, 16)

function main(script_txt, gestling_name)
    --events, character, phrases, phrasebook_name = parse_script(script_txt)
    -- setup_sound(gestling_name, character, phrases, phrasebook_name)
    local insp = inspire.init(script_txt, gestling_name)
    inspire.setup_sound(insp)
    -- first pass to get duration
    nframes = inspire.process_video(insp, -1)
    inspire.process_video(insp, nframes)
    inspire.close_video(gestling_name)
    inspire.generate_mp4(gestling_name)
    ::bye::
end

if #arg < 2 then
    error("Usage: inspire dialogue.txt name")
end

main(arg[1], arg[2])

