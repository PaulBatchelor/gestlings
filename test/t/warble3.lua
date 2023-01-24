gk = require("gestku/2023_01_22")

gk:patch()

chksm = "46e1bd5216fd2baac01707d38df15d72"

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

