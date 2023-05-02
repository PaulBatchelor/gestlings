# generate uf2 and symtab
../cantor generate_uf2.lua
xxd -r -p test.uf2.txt test.uf2
../cantor notate.lua > notation.hex
xxd -p -r notation.hex | ./render | convert -scale 200% - out.png
# ../cantor synth.lua
