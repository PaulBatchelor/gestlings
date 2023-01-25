gk = require("gestku/2022_12_12")

gk:patch()

chksm = "b6e365a921e5038ee1d0e7a7196d56c4"

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

