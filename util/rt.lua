Realtime = {}

function Realtime.setup(nocrossfade)
    nocrossfade = nocrossfade or false
lil([[
hsnew hs
rtnew [grab hs] rt

func out {} {
    hsout [grab hs]
    hsswp [grab hs]
}

func playtog {} {
    hstog [grab hs]
}
]])

    -- I'm pretty sure you can't crossfade with gestlive
    if nocrossfade == true then
        lil("hscf [grab hs] 0")
    end
end

function Realtime.out()
    lil("out")
end

return Realtime
