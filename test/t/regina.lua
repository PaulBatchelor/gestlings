gk = require("gestku/2022_12_13")

gk:patch()

chksm = "ba5654ff7bb15a2f323fbc49b7ee6bf5"

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

