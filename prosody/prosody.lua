local asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

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

    return pros
end

function write_prosody_asset(filename)
    local pros = genprosody()
    asset:save(pros, filename)
end

write_prosody_asset("prosody/prosody.b64")
