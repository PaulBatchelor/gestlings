gk = require("gestku/2023_01_15")

gk:patch()

chksm = "f212b99f8f9672edba7dc1d5c68e2185"

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

