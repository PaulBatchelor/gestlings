gk = require("gestku/2022_12_14")

gk:patch()

chksm = "fe3458c7223ec23a25d25bdb81d3065e"

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

