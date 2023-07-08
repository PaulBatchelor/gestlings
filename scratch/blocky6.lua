uf2 = require("path/uf2")
font = {}
function add_to_font(sym)
    font[sym.id] = sym
end

lbrack = {
    id = 0x01,
    width = 5,
    name = "lbrack",
    shortcut = "",
    bits = {

        "####",
        "####",
        "##--",
        "##--",
        "####",
        "####",
        "----",
        "----",
        "----",
        "-","-","-","-",
        "-","-","-",
    }
}
add_to_font(lbrack)

rbrack = {
    id = 0x02,
    width = 5,
    name = "rbrack",
    shortcut = "",
    bits = {

        "####",
        "####",
        "--##",
        "--##",
        "####",
        "####",
        "----",
        "----",
        "----",
        "-","-","-","-",
        "-","-","-",
    }
}
add_to_font(rbrack)

stick = {
    id = 0x03,
    width = 3,
    name = "stick",
    shortcut = "",
    bits = {

        "##",
        "##",
        "##",
        "##",
        "##",
        "##",

        "--",
        "--",
        "--",
        "-","-","-","-",
        "-","-","-",
    }
}
add_to_font(stick)

dot = {
    id = 0x04,
    width = 3,
    name = "dot",
    shortcut = "",
    bits = {

        "--",
        "--",
        "##",
        "##",
        "--",
        "--",

        "--",
        "--",
        "--",
        "-","-","-","-",
        "-","-","-",
    }
}
add_to_font(dot)

rtee = {
    id = 0x05,
    width = 6,
    name = "rtee",
    shortcut = "",
    bits = {

        "##---",
        "##---",
        "#####",
        "#####",
        "##---",
        "##---",

        "--",
        "--",
        "--",
        "-","-","-","-",
        "-","-","-",
    }
}
add_to_font(rtee)

uf2.generate(font, "scratch/blocky6.uf2")
