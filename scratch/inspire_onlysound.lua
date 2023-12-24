local inspire = require("inspire/inspire")

local script = "dialogue/toni.txt"
local gestling_name = "toni"

local modules = inspire.load_modules()
insp = inspire.init(script, gestling_name, modules)
inspire.setup(insp, modules)
