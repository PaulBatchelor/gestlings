(def blipsqueak-assets @[
    "blipsqueak/words.b64" "blipsqueak/morphemes.b64"
    "blipsqueak/blipsqueak.lua"
    "blipsqueak/mechanism.b64"

    # these should be put in another array, as they are more general
    "asset/asset.lua"
    "diagraf/diagraf.lua"
    "sigrunes/sigrunes.lua"
    "tal/tal.lua"
    "gest/gest.lua"
    "morpheme/morpho.lua"
    "seq/seq.lua"
    "sig/sig.lua"
    "path/path.lua"
    "warble/warble.lua"
    "morpheme/morpheme.lua"
    "morpheme/mseq.lua"
])

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

    @[["seq/test_syms_tab.b64"
       "seq/test_syms.uf2"]
      ["seq/test_uf2.lua"]]

    @[["blipsqueak/morphemes.b64"
       "blipsqueak/words.b64"]
      ["blipsqueak/generate_morphemes.lua"]]

    @[["blipsqueak/mechanism.b64"]
      ["blipsqueak/mechanism.lua"]
      ["blipsqueak/morphemes.b64"
       "blipsqueak/words.b64"]]

    @[["res/protogestling.mp4"]
      ["protogestling/protogestling_mockup.lua"]
      blipsqueak-assets]
])
