gk = require("gestku/2023_01_26")

gk:patch()

chksm = "9332c375cd43dc880b3578f069a4be5f"


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
