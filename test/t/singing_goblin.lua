gk = require("gestku/2023_01_28")

gk:patch()

chksm = "6f1046ef02a256f5fdc6d0aa90c4817f"


rc, msg = pcall(lil, "verify " .. chksm)

verbose = os.getenv("VERBOSE")
if rc == false then
    if verbose ~= nil and verbose == "1" then
        print(msg)
    end
    os.exit(1)
else
    os.exit(0)
end
