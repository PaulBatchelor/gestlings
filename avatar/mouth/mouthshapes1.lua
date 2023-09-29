local asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}

local function mkmouth(name)
    return function(shape)
        local mth = {}
        mth.name = name
        mth.shape = shape
        return mth
    end
end

function main()
    local shapes = {
        mkmouth("open") {
            circleness = 0.7,
            roundedge = 0.1,
            circrad = 0.35,
            points = {
                {-0.4, 0.4},
                {-0.05, -0.4},
                {0.05, -0.4},
                {0.4, 0.4},
            }
        },

        mkmouth("close") {
            circleness = 0.7,
            roundedge = 0.1,
            circrad = 0.1,
            points = {
               {-0.4, 0.4},
               {-0.05, -0.4},
               {0.05, -0.4},
               {0.4, 0.4},
        
            }
        },

        mkmouth("rest") {
            circleness = 0.1,
            roundedge = 0.03,
            circrad = 0.1,
            points = {
                {-0.8, 0.1},
                {-0.8, -0.1},
                {0.8, -0.1},
                {0.8, 0.1},
            }
        },

        mkmouth("tri") {
            circleness = 0.0,
            roundedge = 0.05,
            circrad = 0.35,
            points = {
                {-0.4, 0.4},
                {-0.05, -0.4},
                {0.05, -0.4},
                {0.4, 0.4},
            }
        },

        mkmouth("triflip") {
            circleness = 0.0,
            roundedge = 0.05,
            circrad = 0.35,
            points = {
                {-0.4, -0.4},
                {-0.05, 0.4},
                {0.05, 0.4},
                {0.4, -0.4},
            }
        },

        mkmouth("wide") {
            circleness = 0.5,
            roundedge = 0.1,
            circrad = 0.35,
            points = {
                {-0.6, -0.4},
                {-0.05, 0.4},
                {0.05, 0.4},
                {0.6, -0.4},
            }
        },
        
        mkmouth("upwider") {
            circleness = 0.3,
            roundedge = 0.09,
            circrad = 0.35,
            points = {
                {-1.1, 0.4},
                {-0.05, 0.1},
                {0.05, 0.1},
                {1.1, 0.4},
            }
        },

        mkmouth("smallcirc") {
            circleness = 1.0,
            roundedge = 0.09,
            circrad = 0.2,
            points = {
                {-0.2, 0.2},
                {-0.2, -0.2},
                {0.2, -0.2},
                {0.2, 0.2},
            }
        },

        mkmouth("bigcirc") {
            circleness = 1.0,
            roundedge = 0.09,
            circrad = 0.5,
            points = {
                {-0.2, 0.2},
                {-0.2, -0.2},
                {0.2, -0.2},
                {0.2, 0.2},
            }
        },

        mkmouth("smallsqr") {
            circleness = 0.0,
            roundedge = 0.01,
            circrad = 0.5,
            points = {
                {-0.2, 0.2},
                {-0.2, -0.2},
                {0.2, -0.2},
                {0.2, 0.2},
            }
        },

        mkmouth("bigsqr") {
            circleness = 0.0,
            roundedge = 0.01,
            circrad = 0.5,
            points = {
                {-0.4, 0.4},
                {-0.4, -0.4},
                {0.4, -0.4},
                {0.4, 0.4},
            }
        },
    }

    asset:save(shapes, "avatar/mouth/mouthshapes1.b64")
end

main()
