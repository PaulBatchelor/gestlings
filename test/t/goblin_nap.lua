gk = require("gestku/2023_01_25")

gk:patch()

chksm = "132060e0afca42a723afe9ac4941dd1a"

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


