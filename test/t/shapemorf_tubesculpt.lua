gk = require("gestku/2023_07_21")

gk:patch()

chksm = "60f768a034c88a57faebe9d75a304ce2"

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
