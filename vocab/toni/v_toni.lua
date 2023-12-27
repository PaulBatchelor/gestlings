local gest = require("gest/gest")
local asset = require("asset/asset")
asset = asset:new {
    msgpack = require("util/MessagePack"),
    base64 = require("util/base64")
}
local morpheme = require("morpheme/morpheme")

-- PAUL DEBUGGING
local json = require("util/json")

-- corresponds to how symbols are
-- arranged in tilemaker
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

function genmel(mel)
    local last_bhvr = 2 -- gliss_medium
    local base = 84

    local p = {}
    for _, m in pairs(mel) do
        local bhvr = last_behavior
        local pitch = m[1] + base
        local dur = m[2]

        if m[3] ~= nil then
            bhvr = m[3]
            last_behavior = bhvr
        end

        table.insert(p, {pitch, dur, bhvr})
    end

    return p
end

function clickpat (p)
    local gt = gest.behavior.gate_50
    assert(gt ~= nil)
    local o = {}

    for _,x in pairs(p) do
        table.insert(o, {1, x, gt})
    end

    return o
end

function tonepat (p)
    local gm = gest.behavior.gate_50
    local o = {}

    for _,x in pairs(p) do
        table.insert(o, {x[1], x[2], gm})
    end

    return o
end

function genvocab()
    local vocab = {}
    voc = function (x, y, w, doc, tok)
        addvocab(vocab, x, y, w, doc, tok)
    end

    local behavior = gest.behavior
    local stp = behavior.step
    local gm = behavior.gliss_medium
    local gl = behavior.gliss
    local lin = behavior.linear
    local gt = behavior.gate_50
    local exp = behavior.exp_convex_low
    local expcvhi = behavior.exp_convex_high
    local expcclo = behavior.exp_concave_low
    local expcchi = behavior.exp_concave_high


    local shA = "364f9c"
    local shB = "ebaa8f"
    local shC = "c72639"
    local shD = "14d545"
    local shE = "d5141b"

    local template = morpheme.template
    local merge = morpheme.merge

    pat_a = template({
        gate = {
            {1, 3, stp},
            {0, 1, stp},
        },
        pitch = {
            {84, 1, gm},
            {84 + 5, 1, gm},
        },
        -- TODO remove whistle trigger or make it sound better
        trig = {
            {0, 1, gt},
        },

        click_rate = {
            {8, 1, lin},
            {20, 1, gm},
            {4, 1, lin},
            {20, 1, lin},
        },

        whistle_amt = {
            {0, 3, gm},
            {8, 1, gm},
        },

        pulse_amt = {
            {0, 1, gm},
        },

        click_fmin = {
            {70, 1, gm},
        },

        click_fmax = {
            {92, 1, lin},
            {99, 1, lin},
        },

        amfreq = {
            {48, 1, lin},
            {96, 1, lin},
            {60, 1, gm},
        },

        tickmode = {
            {0, 1, gm},
            {1, 3, stp},
        },

        tickpat = {
            {1, 2, gt},
            {1, 1, gt},
            {1, 2, gt},
            {1, 1, gt},
            {1, 2, gt},
            {1, 2, gt},
            {1, 2, gt},
            {1, 1, gt},
            {1, 2, gt},
            {1, 1, gt},
            {1, 2, gt},
            {1, 2, gt},
        },

        shapes = {
            {shA, 1, lin},
            {shE, 1, lin},
            {shC, 1, lin}
        },

        sync = {
            {1, 1, gt}
        },

        amamt = {
            {0xFF, 3, stp},
            {0xFF, 1, gm},
        },

        atk = {
            {0x80, 3, stp},
            {0x80, 1, gm},
        },

        rel = {
            {0x80, 3, stp},
            {0x80, 1, gm},
        },
        mouth_x = {
            {"tri", 1, gm},
            {"close", 1, gm},
        },
        mouth_y = {
            {0xFF, 1, gm},
        }
    })

    p_sh_a = {
        shapes = {
            {shA, 1, gm},
        },
    }

    p_sh_b = {
        shapes = {
            {shA, 1, lin},
            {shB, 1, lin},
            {shA, 1, lin},
            {shB, 1, lin},
            {shC, 2, lin},
            {shE, 2, lin},
        },
    }

    local m_whistle_pitched = template(pat_a {
        whistle_amt = {
            {8, 3, stp},
            {8, 1, gm},
        },
        shapes = {
            {shB, 1, lin},
        },
        pitch = {
            {84, 1, stp},
            {84, 1, gm},
        },
    })

    local m_clicks = template(pat_a {
        whistle_amt = {
            {0, 3, stp},
            {0, 1, gm},
        },
        tickmode = {
            {0, 1, stp},
        },
        tickpat = {
            {1, 1, gt},
            {1, 1, gt},
            {1, 2, gt},
        },
        click_fmin = {
            {48, 1, gm},
            {60, 1, gm},
        },

        click_fmax = {
            {62, 3, lin},
            {78, 1, gm},
        },
        amfreq = {
            {40, 1, gm},
            {40 + 12, 1, gm},
            {80, 1, gm},
        },
        click_rate = {
            {4, 3, exp},
            {13, 1, lin},
        },
        pitch = {
            {60, 1, gm},
        },
        shapes = {
            {shC, 1, gm},
            {shA, 1, gm},
        },
        gate = {
            {1, 11, stp},
            {0, 1, stp},
        },
    })

    local m_clickpat = template(m_clicks {
        shapes = {
            {shE, 1, gm},
        },
        tickmode = {
            {1, 1, stp},
        },
        tickpat = {
            {1, 3, gt},
            {1, 1, gt},
            {1, 2, gt},

            {1, 2, gt},
            {1, 1, gt},
        },
        click_fmin = {
            {96, 1, gm},
        },

        click_fmax = {
            {48, 1, gm},
        },
        amfreq = {
            {60, 1, gm},
        },
        pitch = {
            {60, 1, gm},
        },
        shapes = {
            {shE, 1, gm},
            {shA, 1, gm},
        },
        amamt = {
            {0x00, 3, stp},
            {0x00, 1, gm},
        },
        atk = {
            {0x00, 3, stp},
            {0x00, 1, gm},
        },

        rel = {
            {0x00, 3, stp},
            {0x00, 1, gm},
        }
    })

    m_whistleclick = template (m_clickpat {
        whistle_amt = {
            {0, 4, exp},
            {8, 1, gm},
        },
        pitch = {
            {72, 2, exp},
            {72 + 12 + 7, 1, gm},
        },
        pulse_amt = {
            {8, 1, gm},
            {0, 1, gm},
            {8, 1, gm},
            {0, 1, gm},
        },
        tickpat = clickpat {
            2, 2, 3,
            2, 2, 3,
            2, 2, 3,
            2, 2, 3,
        },
        rel = {
            {0x80, 3, stp},
            {0x80, 1, gm},
        }
    })

    -- Vocab Words

    voc(2, 1, pat_a {
        mouth_x = {
            {"wide", 2, gm},
            {"close", 1, gm},
        },
        mouth_y = {
            {0xFF, 1, gm},
        }
    }, "test word.")

    voc(1, 1, pat_a {
        tickmode= {
            {1, 1, stp},
        },
        tickpat = {
            {0, 1, stp},
        },
        gate = {
            {0, 1, stp}
        },
        mouth_x = {
            {"close", 1, gm},
        },
        mouth_y = {
            {0x00, 1, gm},
        }
    }, "silence.")

    voc(3, 1,
        m_whistle_pitched {
            mouth_x = {
                {"smallcirc", 2, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        },
        "pitched whistle. flat")

    voc(4, 1,
        m_clickpat {
            mouth_x = {
                {"bigsqr", 2, gm},
                {"smallsqr", 2, gm},
                {"bigsqr", 2, gm},
                {"close", 2, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        },
        "clickpat A")


    voc(5, 1,
        m_clickpat {
            click_fmax = tonepat {
                {80, 1},
                {48, 2},
                {84, 1},
                {48, 2},
                {88, 1},
                {48, 2},
            },
            tickpat = clickpat {
                2, 2, 2,
                2, 2, 1, 1,
                6,
            },
            mouth_x = {
                {"bigsqr", 2, gm},
                {"smallsqr", 2, gm},
                {"bigsqr", 1, gm},
                {"smallsqr", 1, gm},
                {"bigsqr", 2, gm},
                {"close", 2, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        },
        "clickpat B")

    voc(6, 1,
        m_whistle_pitched {
            pitch = genmel {
                {0, 1, gl}, {9, 2}, {3, 2}
            },
            mouth_x = {
                {"smallcirc", 1, gl},
                {"bigcirc", 2, lin},
                {"smallcirc", 2, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        },
        "pitched whistle: melodic a")

    voc(7, 1,
        m_whistle_pitched {
            pitch = genmel {
                {9, 1, gl}, {7, 1, gl}, {0, 1, gl}, {5, 4, gl}
            },
            mouth_x = {
                {"bigcirc", 2, gm},
                {"smallcirc", 2, gm},
                {"bigcirc", 2, lin},
                {"smallcirc", 2, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        },
        "pitched whistle: melodic b")

    voc(8, 1,
        merge(m_whistle_pitched {
            pitch = genmel {
                {12, 1, gl}, {10, 2},
                {12, 1}, {10, 2},
                {12, 1}, {10, 2},
                {0, 3, exp}, {7, 6, gm},
            },
            mouth_x = {
                {"bigcirc", 2, lin},
                {"smallcirc", 1, exp},
                {"bigcirc", 1, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        }, p_sh_a),
        "pitched whistle: melodic c")

    voc(1, 2,
        merge(m_whistle_pitched {
            pitch = genmel {
                {0, 1, gm}, {9, 3, gm},
                {4, 2, gm}, {9, 6, gm},
                {2, 1, lin}, {0, 5, gm},
            },
            mouth_x = {
                {"bigcirc", 2, gm},
                {"smallcirc", 2, gm},
                {"bigcirc", 2, exp},
                {"smallcirc", 2, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        }, p_sh_a),
        "pitched whistle: melodic d")

    voc(2, 2,
        merge(m_whistle_pitched {
            pitch = genmel {
                {0, 1, gm}, {2, 1, gm},
                {4, 1, gm}, {0, 1, gm},
                {11, 8, gm},
            },
            mouth_x = {
                {"smallcirc", 1, stp},
                {"smallsqr", 1, stp},
                {"bigcirc", 1, stp},
                {"smallcirc", 1, gm},
                {"bigcirc", 4, lin},
                {"smallcirc", 3, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        }, p_sh_a),
        "pitched whistle: melodic e")

    voc(3, 2,
        merge(m_whistle_pitched {
            pitch = genmel {
                {0, 4, exp}, {7, 2, gm},
            },
            mouth_x = {
                {"smallcirc", 4, exp},
                {"bigcirc", 1, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        }, p_sh_a),
        "pitch rise")

    voc(4, 2, m_clicks {
            mouth_x = {
                {"triflip", 2, exp},
                {"tri", 2, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
    }, "upward clicks")
    voc(5, 2, m_clicks {
        click_rate = {
            {15, 3, exp},
            {4, 1, gm},
        },

        click_fmin = {
            {60, 1, gm},
            {48, 1, gm},
        },

        click_fmax = {
            {78, 3, lin},
            {62, 1, gm},
        },
        amfreq = {
            {80, 3, exp},
            {40, 1, gm},
        },
        shapes = {
            {shE, 3, exp},
            {shA, 1, gm},
        },
        mouth_x = {
            {"tri", 2, gm},
            {"triflip", 2, exp},
            {"close", 1, gm},
        },
        mouth_y = {
            {0xFF, 1, gm},
        }
    }, "downward clicks")

    voc(6, 2, m_clicks {
        click_rate = {
            {14, 1, lin},
            {18, 1, gm},
            {16, 1, lin},
        },

        click_fmin = {
            {60, 1, gm},
        },

        click_fmax = {
            {70, 3, expcvhi},
            {70 + 12, 1, gm},
            {70, 3, expcvhi},
            {70 + 14, 1, gm},
            {70, 3, expcvhi},
            {70 + 17, 1, gm},
        },
        amfreq = {
            {80 - 24, 3, exp},
            {80, 1, gm},
            {80 - 24, 3, exp},
            {85, 1, gm},
            {80 - 24, 3, exp},
            {86, 1, gm},
        },
        shapes = {
            {shE, 3, expcvlo},
            {shB, 1, gm},
        },
        gate = {
            {1, 7, stp},
            {0, 1, stp},
        },
        mouth_x = {
            {"open", 2, gm},
            {"upwider", 2, gm},
            {"wide", 1, gm},
            {"close", 1, gm},
        },
        mouth_y = {
            {0xFF, 1, gm},
        }
    }, "3 ascending click rolls")

    voc(7, 2, m_clicks {
        click_rate = {
            {14, 2, gm},
            {28, 1, gm},
            {10, 3, lin},
            {20, 1, gm},
        },

        click_fmin = {
            {60, 1, lin},
            {72, 1, gm},
        },

        click_fmax = {
            {70 + 12, 3, expcvhi},
            {70, 1, gm},
            {70 + 24, 3, lin},
            {60, 1, gm},
        },
        amfreq = {
            {80, 3, exp},
            {86 - 24, 1, gm},
        },
        shapes = {
            {shD, 1, gm},
            {shA, 1, gm},
            {shD, 1, gm},
            {shA, 1, gm},
        },
        gate = {
            {1, 7, stp},
            {0, 1, stp},
        },
        mouth_x = {
            {"tri", 2, gm},
            {"bigsqr", 2, gm},
            {"close", 1, gm},
        },
        mouth_y = {
            {0xFF, 1, gm},
        }
    }, "various chitters")

    voc(8, 2,
        m_clickpat {
            click_fmax = tonepat {
                {80, 1},
                {48, 2},
                {60, 1},
                {48, 2},
                {88, 1},
                {48, 2},
                {60, 1},
                {48, 2},
            },
            tickpat = clickpat {
                2, 4, 2,
                2, 4, 2,
                2, 4, 2,
                1, 1, 1, 1,
                1, 1, 1, 1,
            },
            mouth_x = {
                {"bigsqr", 2, gm},
                {"smallsqr", 2, gm},
                {"bigsqr", 2, gm},
                {"smallsqr", 1, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        },
        "clickpat C")

    voc(1, 3,
        m_whistleclick {
            mouth_x = {
                {"smallsqr", 2, gm},
                {"bigsqr", 2, gm},
                {"smallcirc", 2, lin},
                {"bigcirc", 1, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        },
        "whistleclick A")
    voc(2, 3,
        m_whistleclick {
            tickpat = clickpat {
                1, 1, 2, 3,
                1, 1, 2, 3,
                1, 1, 2, 3,
                2, 2, 3,
            },
            pitch = {
                {72 + 12 + 7, 3, exp},
                {72, 1, gm},
            },
            shapes = {
                {shD, 1, lin},
                {shA, 1, lin},
                {shD, 1, gm},
                {shA, 1, gm},
            },
            mouth_x = {
                {"bigsqr", 2, lin},
                {"smallcirc", 2, gm},
                {"close", 1, gm},
            },
            mouth_y = {
                {0xFF, 1, gm},
            }
        },
        "whistleclick B")
    voc(3, 3, {}, "word divider", "divider")
    voc(4, 3, {}, "duration 1", "dur1")
    voc(5, 3, {}, "duration 2", "dur2")
    voc(6, 3, {}, "duration 3", "dur3")
    return vocab
end

function write_vocab_asset(filename)
    local vocab = genvocab()
    asset:save(vocab, filename)
end

write_vocab_asset("vocab/toni/v_toni.b64")
