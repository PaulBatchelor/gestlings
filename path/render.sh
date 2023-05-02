../cantor notate.lua > notation.hex
xxd -p -r notation.hex | ./render | convert -scale 200% - out.png
# ../cantor synth.lua
