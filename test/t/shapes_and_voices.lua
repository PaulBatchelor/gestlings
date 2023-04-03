gk = require("gestku/2023_03_29")

gk:patch()

chksm = "3c4b4969e2ae811d2ccb981ee93563b2"

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
