font = {}
function add_to_font(sym)
    font[sym.id] = sym
end

lbrack = {
    id = 0x01,
    width = 4,
    name = "lbrack",
    shortcut = "",
    bits = {
        "-","-","-","-",

        "----",
        "----",
        "####",
        "####",
        "##--",
        "##--",
        "####",
        "####",
        "----",

        "-","-","-",
    }
}
add_to_font(lbrack)

rbrack = {
    id = 0x02,
    width = 4,
    name = "rbrack",
    shortcut = "",
    bits = {
        "-","-","-","-",

        "----",
        "----",
        "####",
        "####",
        "--##",
        "--##",
        "####",
        "####",
        "----",

        "-","-","-",
    }
}
add_to_font(rbrack)

ltee = {
    id = 0x03,
    width = 4,
    name = "ltee",
    shortcut = "",
    bits = {
        "-","-","-","-",

        "----",
        "----",
        "##--",
        "##--",
        "####",
        "####",
        "##--",
        "##--",
        "----",

        "-","-","-",
    }
}
add_to_font(ltee)

rtee = {
    id = 0x04,
    width = 4,
    name = "rtee",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "--##",
        "--##",
        "####",
        "####",
        "--##",
        "--##",

        "-", "-","-","-",
    }
}
add_to_font(rtee)


dash = {
    id = 0x05,
    width = 4,
    name = "dash",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "----",
        "----",
        "####",
        "####",
        "----",
        "----",

        "-", "-","-","-",
    }
}
add_to_font(dash)

parallel = {
    id = 0x06,
    width = 4,
    name = "parallel",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "####",
        "####",
        "----",
        "----",
        "####",
        "####",

        "-", "-","-","-",
    }
}
add_to_font(parallel)

lhook = {
    id = 0x08,
    width = 4,
    name = "lhook",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "####",
        "####",
        "##--",
        "##--",
        "##--",
        "##--",

        "-", "-","-","-",
    }
}
add_to_font(lhook)

rhook = {
    id = 0x09,
    width = 4,
    name = "rhook",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "####",
        "####",
        "--##",
        "--##",
        "--##",
        "--##",

        "-", "-","-","-",
    }
}
add_to_font(rhook)

sky = {
    id = 0x0a,
    width = 4,
    name = "sky",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "####",
        "####",
        "----",
        "----",
        "----",
        "----",

        "-", "-","-","-",
    }
}
add_to_font(sky)

ground = {
    id = 0x0b,
    width = 4,
    name = "ground",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "----",
        "----",
        "----",
        "----",
        "####",
        "####",

        "-", "-","-","-",
    }
}
add_to_font(ground)

dashground = {
    id = 0x0c,
    width = 4,
    name = "dashground",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "----",
        "----",
        "####",
        "####",
        "--##",
        "--##",

        "-", "-","-","-",
    }
}
add_to_font(dashground)

grounddash = {
    id = 0x0d,
    width = 4,
    name = "grounddash",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "----",
        "----",
        "--##",
        "--##",
        "####",
        "####",

        "-", "-","-","-",
    }
}
add_to_font(grounddash)

dashsky = {
    id = 0x0e,
    width = 4,
    name = "dashsky",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "--##",
        "--##",
        "####",
        "####",
        "----",
        "----",

        "-", "-","-","-",
    }
}
add_to_font(dashsky)

skydash = {
    id = 0x0f,
    width = 4,
    name = "skydash",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "##--",
        "##--",
        "####",
        "####",
        "----",
        "----",

        "-", "-","-","-",
    }
}
add_to_font(skydash)

groundsky = {
    id = 0x10,
    width = 4,
    name = "groundsky",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "--##",
        "--##",
        "--##",
        "--##",
        "####",
        "####",

        "-", "-","-","-",
    }
}
add_to_font(groundsky)

morph_begin = {
    id = 0x11,
    width = 6,
    name = "morph_begin",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "----#",
        "----#",
        "#####",
        "#####",
        "#---#",
        "#---#",

        "#---",
        "#---",
        "#---",
        "#---",
    }
}
add_to_font(morph_begin)

morph_line_begin = {
    id = 0x12,
    width = 3,
    name = "morph_line_begin",
    shortcut = "",
    bits = {
        "#-----",
        "#-----",
        "#-----",
        "#-----",
        "#-----",
        "#-----",

        "#----",
        "#----",
        "#----",
        "#----",
        "#----",
        "#----",

        "#---",
        "#---",
        "#---",
        "#---",
    }
}
add_to_font(morph_line_begin)

morph_end = {
    id = 0x13,
    width = 6,
    name = "morph_end",
    shortcut = "",
    bits = {
        "#","#","#","#",

        "#####",
        "#####",
        "-----",
        "-----",
        "-----",
        "-----",
        "-----",
        "-----",

        "----",
        "----",
        "----",
        "----",
    }
}
add_to_font(morph_end)

morph_define = {
    id = 0x14,
    width = 5,
    name = "morph_define",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "-------",
        "--#----",
        "-------",
        "-------",
        "--#----",
        "-------",

        "----",
        "----",
        "----",
        "----",
    }
}
add_to_font(morph_define)

morph_break = {
    id = 0x00,
    width = 0,
    name = "morph_break",
    shortcut = "",
    bits = {
        "-","-","-","-","-", "-",

        "-",
        "-",
        "-",
        "-",
        "-",
        "-",

        "-",
        "-",
        "-",
        "-",
    }
}
add_to_font(morph_break)

return font
