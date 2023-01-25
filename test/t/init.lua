gk = require("gestku/2022_12_11")

gk:patch()

chksm = "7aee3da94de2e67c28bf69f60bedc83d"

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

