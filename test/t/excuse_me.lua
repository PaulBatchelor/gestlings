gk = require("gestku/2022_12_20")

gk:patch()

chksm = "b431ea778c31b305768f690d0a3064f5"

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


