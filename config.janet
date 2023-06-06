(def assets @[
    @[["path/symtab.b64" "path/test.uf2"] ["path/test_uf2.lua"]]
    @[["path/notation.hex"] ["path/notate.lua"] ["path/symtab.b64"]]
    @[["path/path.b64"]
      ["path/parse.lua"]
      ["path/symtab.b64" "path/notation.hex" "path/grammar.out"]]
    @[["path/grammar.out"]
      ["path/generate_grammar.lua"]
      ["path/grammar.lua" "path/full_grammar.lua"]]
    @[["path/synth.wav"]
      ["path/synth.lua"]
      ["path/path.b64"]]

    @[["morpheme/test_syms_tab.b64"
       "morpheme/test_syms.uf2"]
      ["morpheme/test_uf2.lua"]]
])
