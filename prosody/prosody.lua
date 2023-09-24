local asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

local uf2 = require("util/uf2")

function genprosody()
    local pros = {}

    local pros_flat = 0x80
    local pros_up = 0x80 + 0x40
    local pros_up_more = 0x80 + 0x70
    local pros_up_mild  = 0x80 + 0x30
    local pros_down_mild  = 0x80 - 0x04
    local pros_down = 0x80 - 0x40
    local pros_down_more = 0x00

    pros.question = {
        pitch = {
            {pros_flat, 3, stp},
            {pros_flat, 1, lin},
            {pros_up_mild, 1, stp},
        },
        intensity = {
            {0x80, 1, stp},
        }
    }

    pros.neutral = {
        pitch = {
            {pros_flat, 1, stp},
        },
        intensity = {
            {0x80, 1, stp},
        }
    }

    pros.whisper = {
        pitch = {
            {pros_flat, 1, stp},
        },
        intensity = {
            {0x20, 1, lin},
            {0x00, 1, stp},
        }
    }

    pros.some_jumps = {
        pitch = {
            {pros_flat, 1, lin},
            {pros_up, 1, lin},
            {pros_flat, 2, lin},
            {pros_down_mild, 1, stp},
        },
        intensity = {
            {0x80, 1, stp},
        }
    }

    pros.deflated = {
        pitch = {
            {pros_flat, 1, lin},
            {pros_down_mild, 2, gm},
            {pros_down, 4, lin},
            {pros_down_more, 4, stp},
        },
        intensity = {
            {0x80, 1, lin},
            {0x70, 1, stp},
        }
    }

    pros.excited = {
        pitch = {
            {pros_flat, 1, lin},
            {pros_up_more, 1, lin},
            {pros_flat, 1, lin},
            {pros_up_more, 1, lin},
            {pros_flat, 1, lin},
            {pros_up_more, 1, lin},
            {pros_down_mild, 1, lin},
            {pros_up_more, 2, stp},
        },
        intensity = {
            {0x80, 1, lin},
            {0xFF, 2, stp},
        }
    }

    pros.some_jumps_v2 = {
        pitch = {
            {pros_flat, 1, gl},
            {pros_up, 1, lin},
            {pros_flat, 1, lin},
            {pros_up, 1, lin},
            {pros_flat, 2, lin},
            {pros_up, 2, lin},
            {pros_flat, 2, stp},
        },
        intensity = {
            {0x80, 1, lin},
            {0x90, 1, lin},
            {0x80, 1, stp},
        }
    }

    return pros
end

function write_prosody_asset(filename)
    local pros = genprosody()
    asset:save(pros, filename)
end

function write_prosody_symbols(uf2_fname, lookup_fname)
    local symbols = {}
    local pos = 1

    -- divider
    symbols[pos] = {
        id = pos,
        name = "divider",
        width = 5,
        bits = {
            "--#-----",
            "--#-----",
            "--#-----",
            "--#-----",
            "--#-----",
            "--#-----",
        }
    }
    pos = pos + 1

    -- question
    symbols[pos] = {
        id = pos,
        name = "question",
        width = 12,
        bits = {
            "------------",
            "--------####",
            "--------#---",
            "--------#---",
            "#########---",
            "------------",
        }
    }
    pos = pos + 1

    -- neutral
    symbols[pos] = {
        id = pos,
        name = "neutral",
        width = 12,
        bits = {
            "------------",
            "------------",
            "------------",
            "############",
            "------------",
            "------------",
        }
    }
    pos = pos + 1

    -- whisper
    symbols[pos] = {
        id=pos,
        name="whisper",
        width=12,
        bits = {
            "------------",
            "------------",
            "------------",
            "------------",
            "#--#--#--#--",
            "############",
        }
    }
    pos = pos + 1

    -- some_jumps
    symbols[pos] = {
        id = pos,
        name = "some_jumps",
        width = 12,
        bits = {
            "###---------",
            "--#-------##",
            "--#--###--#-",
            "--####-#--#-",
            "-------#--#-",
            "-------####-",
        }
    }
    pos = pos + 1

    -- deflated
    symbols[pos] = {
        id = pos,
        name = "deflated",
        width = 12,
        bits = {
            "###---------",
            "--#---------",
            "--#---------",
            "--#---------",
            "--######----",
            "-------#####",
        }
    }
    pos = pos + 1

    -- excited
    symbols[pos] = {
        id = pos,
        name = "excited",
        width = 12,
        bits = {
            "##-###-###-#",
            "-###-###-###",
            "------------",
            "#--#--#--#--",
            "#--#--#--#--",
            "#--#--#--#--",
        }
    }
    pos = pos + 1

    -- some_jumps_v2
    symbols[pos] = {
        id = pos,
        name = "some_jumps_v2",
        width = 12,
        bits = {
            "---------###",
            "---------#--",
            "---------#--",
            "--####---#--",
            "--#--#####--",
            "###---------",
        }
    }
    pos = pos + 1

    local lookup = {}

    for _, sym in pairs(symbols) do
        lookup[sym.name] = sym.id
    end

    uf2.generate(symbols, uf2_fname)
    asset:save(lookup, lookup_fname)
end

write_prosody_asset("prosody/prosody.b64")
write_prosody_symbols("fonts/prosody.uf2", "prosody/prosody_symlut.b64")
