gk = require("gestku/2023_01_27")

gk:patch()

chksm = "1fcd1d189513942e9e582cb220270433"

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
