local gest = require("gest/gest")
local asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
local morpheme = require("morpheme/morpheme")

-- corresponds to how symbols are
-- arragened in tilemaker 
function coord(x, y)
    return (y - 1)*8 + x
end

function addvocab(vocab, x, y, w, doc, tok)
    local row = y
    local col = x
    local pos = coord(x, y)

    local v = {}
    v.doc = doc
    v.word = w
    v.tok = tok
    vocab[pos] = v
end

function genpartmorphs ()
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local stp = gest.behavior.step

    infl = {
        flat = {inflection = {{0x0, 3, lin}}},
        rise = {inflection = {{0x0, 3, lin}, {0x4, 1, stp}}},
        downup = {inflection = {{0x4, 1, gl}, {0x0, 1, gl}, {0x2, 1, stp}}},
        fall = {inflection = {{0x4, 3, lin}, {0x0, 1, stp}}}
    }

    crazy_vib = {
        vib = {{0x00, 1, gm}, {0xFF, 1, gm}},
    }

    med_vib = {
        vib = {{0x40, 1, gm}},
    }

    local pm = {
        flat = infl.flat,
        rise = infl.rise,
        downup = infl.downup,
        fall = infl.fall,
        crazy_vib = crazy_vib,
        med_vib = med_vib
    }

    return pm
end

function genvocab()
    local gm = gest.behavior.gliss_medium
    local gl = gest.behavior.gliss
    local lin = gest.behavior.linear
    local stp = gest.behavior.step

    -- vocal tract shapes from tubesculpt
    local A='b275f8'
    local B='51f271'
    local C='9c6c5d'
    local D='5d71be'
    local E='ab8d71'

    pat_a = morpheme.template({
        shapes = {
            {A, 2, lin},
            {B, 1, gl},
            {C, 1, lin},
            {D, 1, gm},
            {E, 2, gm}
        },

        aspiration = {
            {0xFF, 1, gm},
            {0x0, 5, stp},
        },

        inflection = {
            {0x0, 3, step},
        },

        gate = {
            {1, 5, stp},
            {0, 1, stp},
        },

        vib = {
            {0, 3, stp},
            {0, 1, gm},
        }
    })

    asp = {
        start = {
            {0xFF, 1, gm},
            {0x0, 5, stp},
        },

        second = {
            {0x0, 1, gm},
            {0xFF, 1, gm},
            {0x0, 4, stp},
        },

        mid = {
            {0x0, 1, gm},
            {0xFF, 1, gm},
            {0x0, 4, stp},
        },

        longstart = {
            {0xFF, 1, gm},
            {0x0, 1, stp},
        },

        longend = {
            {0x00, 1, gm},
            {0xFF, 1, stp},
        },

        none = {
            {0x00, 1, stp},
        },

        all = {
            {0xFF, 1, stp},
        },
        whisp = {
            {0x80, 1, gm},
            {0xff, 1, gm},
        }
    }


    pat_b = morpheme.template(pat_a {
        shapes = {
            {D, 1, lin},
            {A, 1, lin},
        },
        aspiration = asp.none,
    })

    pat_c = morpheme.template(pat_b {
        shapes = {
            {C, 1, gm},
            {E, 1, gm},
            {D, 1, lin},
            {B, 2, gl},
        },
        aspiration = asp.none,
    })

    pat_d = morpheme.template(pat_a {
        aspiration = asp.none,
        vib = {
            {0x80, 1, gm},
        },
        shapes = {
            {C, 1, gm},
        },
        inflection = {
            {0x4, 1, gm},
        },
    })

    local vocab = {}
    -- words
    vocab[1] = {}
    -- docstrings
    vocab[2] = {}
    voc = function (x, y, w, doc, tok)
        addvocab(vocab, x, y, w, doc, tok)
    end

    voc(1, 1, pat_a {
        gate = {
            {0, 1, stp},
        }
    }, "pause.")

    voc(2, 1, pat_a {}, "pattern a. 'halalayu'")
    voc(3, 1, pat_a {
        aspiration = asp.second,
        shapes = {
            {E, 2, lin},
            {D, 1, gl},
            {C, 1, lin},
        },
    }, "oohlay eddy")

    voc(4, 1, pat_a {
        shapes = {
            {E, 3, lin},
            {D, 1, gl},
            {A, 1, lin},
            {E, 1, gm},
            {A, 1, gm}
        },
        aspiration = asp.mid
    }, "oofla lowla")

    voc(5, 1, pat_a {
        aspiration = asp.longstart
    }, "ahpf! lay-oo")

    voc(6, 1, pat_a {
        shapes = {
            {A, 1, lin},
            {B, 1, lin},
            {A, 1, lin},
            {B, 1, lin},
            {A, 3, gl},
            {B, 3, gl},
        },
        aspiration = asp.longend,
    }, "ahlala")

    voc(7, 1, pat_a {
        shapes = {
            {C, 1, lin},
            {D, 1, lin},
        },
        aspiration = asp.none,
    }, "yi-eh")

    voc(8, 1, pat_b {}, "wah!")

    voc(1, 2, pat_b {
        aspiration = asp.longstart
    }, "hhhwah")

    voc(2, 2, pat_b {
        shapes = {
            {B, 1, gm},
            {A, 1, lin},
            {E, 1, gm},
            {A, 4, gm},
        },
        aspiration = asp.longend
    }, "wellwik-hhh")

    voc(3, 2, pat_c {}, "oomuleh-ya")
    voc(4, 2, pat_c {
        shapes = {
            {D, 1, lin},
            {E, 1, lin},
        },
        aspiration = asp.mid
    }, "echalon")
    voc(5, 2, pat_c {
        aspiration = asp.mid
    }, "ooflayah")
    voc(6, 2, pat_c {
        aspiration = asp.whisp
    }, "oovalef")

    local pm = genpartmorphs()

    voc(7, 2, pm.flat, "PM: flat")
    voc(8, 2, pm.rise, "PM: rise")
    voc(1, 3, pm.downup, "PM: downup")
    voc(2, 3, pm.fall, "PM: fall")
    voc(3, 3, pm.fall, "PM: crazy vibrato")
    voc(4, 3, pm.fall, "PM: medium vibrato")
    voc(5, 3, pat_a {
        shapes = {
            {A, 1, stp},
        },
        aspiration = asp.longstart
    }, "HA")
    voc(6, 3, pat_d {
        vib = {
            {0x80, 1, gm},
        },
        shapes = {
            {A, 1, gl},
        },
        inflection = {
            {0x0, 1, gm},
        },
    }, "music note 1")

    voc(7, 3, pat_d {
        vib = {
            {0x80, 1, gm},
        },
        shapes = {
            {B, 1, gl},
        },
        inflection = {
            {0x4, 1, gm},
        },
    }, "music note 2")

    voc(8, 3, pat_d {
        vib = {
            {0xf0, 1, gm},
        },
        shapes = {
            {C, 1, gl},
        },
        inflection = {
            {0x8, 1, gm},
        },
    }, "music note 3")

    voc(1, 4, pat_d {
        vib = {
            {0x88, 1, gm},
        },
        shapes = {
            {D, 1, gl},
        },
        inflection = {
            {0x2*7, 1, gm},
        },
    }, "music note 4")

    voc(2, 4, pat_d {
        vib = {
            {0x88, 1, gm},
        },
        shapes = {
            {E, 1, gl},
        },
        inflection = {
            {0x2*9, 1, gm},
        },
    }, "music note 5")

    voc(3, 4, pat_d {
        vib = {
            {0x88, 1, gm},
        },
        shapes = {
            {A, 1, gl},
        },
        inflection = {
            {0x2*12, 1, gm},
        },
    }, "music note 6")

    voc(4, 4, {}, "word divider", "divider")

    voc(5, 4, {}, "duration 1", "dur1")

    voc(6, 4, {}, "duration 2", "dur2")

    voc(7, 4, {}, "duration 3", "dur3")

    return vocab
end

function write_vocab_asset(filename)
    local vocab = genvocab()
    asset:save(vocab, filename)
end

write_vocab_asset("vocab/junior/v_junior.b64")
