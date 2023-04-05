V = {}

function V.verify(chksm)
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
end


return V
