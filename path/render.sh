# generate bitmap font (test.uf2) and symtab (symtab.b64)
../cantor generate_uf2.lua
xxd -r -p test.uf2.txt test.uf2

# Use symtab to create notation (notation.hex)
../cantor notate.lua > notation.hex

# notation hex plus uf2 font renders to PNG
xxd -p -r notation.hex | ./render | convert -scale 200% - out.png

# parse notation hex and produce path data (path.b64)
../cantor parse.lua

# ../cantor synth.lua
