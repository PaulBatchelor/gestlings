local inspire = require("inspire/inspire")

local script = "dialogue/toni_test.txt"
local gestling_name = "toni_test"

pprint = require("util/pprint")

mnorealloc(10, 16)

local modules = inspire.load_modules()
insp = inspire.init(script, gestling_name, modules)
inspire.audio_only(insp)
inspire.setup(insp, modules)
inspire.setup_sound(insp, modules)
nframes = inspire.process_video(insp, -1, modules)
inspire.process_video(insp, nframes, modules)
--inspire.close_video(gestling_name, modules)
-- inspire.generate_mp4(gestling_name)
