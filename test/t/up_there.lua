gk = require("gestku/2022_12_19")

gk:patch()

chksm = "6c70a083beef5b0e56eed762758698c2"

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



