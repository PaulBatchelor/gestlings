gk = require("gestku/2023_01_18")

gk:patch()

chksm = "7928b42b85e0821fda313525a18e3c4b"
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


