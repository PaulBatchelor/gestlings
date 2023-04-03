gk = require("gestku/2023_01_29")

gk:patch()

chksm = "d8eccc7d0023ae9c94952b8ef8f90094"

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

