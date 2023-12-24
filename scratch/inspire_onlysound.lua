local inspire = require("inspire/inspire")

local script = "dialogue/toni_test.txt"
local gestling_name = "toni"

mnorealloc(10, 16)

local modules = inspire.load_modules()
insp = inspire.init(script, gestling_name, modules)
inspire.setup(insp, modules)
inspire.setup_sound(insp, modules)
