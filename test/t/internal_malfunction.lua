gk = require("gestku/2022_12_18")

gk:patch()

chksm = "a4fb94b5adb2dbada45cd0bcbba5abae"

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
