gk = require("gestku/2023_01_24")

gk:patch()

chksm = "5b77f0f2b96c605d20413e3c33548391"
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

