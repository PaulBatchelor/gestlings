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

    @[["vocab/junior/v_junior.b64"]
      ["vocab/junior/v_junior.lua"]
      ["asset/asset.lua"
       "gest/gest.lua"]]

    @[["characters/junior.b64"]
      ["characters/junior.lua"]
      ["vocab/junior/p_junior.b64"
       "vocab/junior/p_junior_verses.b64"
       "vocab/junior/t_junior.b64"
       "vocab/junior/pb_junior.txt"
       "vocab/junior/pb_junior_verses.txt"
       "vocab/junior/v_junior.b64"
       "shapes/l_junior.b64"
       ]]

    @[["fonts/junior.uf2"
       "vocab/junior/k_junior.bin"
       "vocab/junior/f_junior.b64"
       # "vocab/junior/ref_junior.png"
       ]
      ["vocab/junior/uf2_junior.lua"]
      ["vocab/junior/t_junior.b64"]]

    @[["shapes/l_junior.b64"]
      ["shapes/l_junior.lua"]
      ["shapes/junior.b64"]]

    @[["prosody/prosody.b64"
       "fonts/prosody.uf2"
       "prosody/prosody_symlut.b64"]
      ["prosody/prosody.lua"]
      []]

    @[["fonts/protorunes.uf2"]
      ["runes/runemaker.lua"]
      ["runes/runes.txt"]]

    @[["avatar/mouth/mouthshapes1.b64"]
      ["avatar/mouth/mouthshapes1.lua"]
      ["asset/asset.lua"]]
])

(def resources @[
    @[["res/protogestling.mp4"]
      ["protogestling/protogestling_mockup.lua"]
      blipsqueak-assets]

    @[["res/klover_proofsheet.png"]
      ["klover/proofsheet.lua"]
      ["klover/klover.lua"]]

    @[["res/gestleton.png" "levels/gestleton/portals.json"]
      ["levels/gestleton/render.lua"]
      ["levels/gestleton/mapgen.lua"]]

    @[["res/sdfvm_mouth.png"]
      ["avatar/mouth/sdfvm_mouth.lua"]
      ["avatar/sdfvm_lookup_table.json"]]
    @[["res/mouthanim.mp4"]
      ["avatar/mouth/mouthanim.lua"]
      ["avatar/sdfvm_lookup_table.json"]]
    @[["res/mouthsounds.mp4"]
      ["avatar/mouth/mouthsounds.lua"]
      ["avatar/sdfvm_lookup_table.json"]]

    @[["res/hello_there_gestling.png"]
      # TODO: move outside scratch
      ["scratch/hello_there_gestling.lua"]
      ["avatar/sdfvm_lookup_table.json"]]

    @[["res/welcome_to_gestleton.mp4"]
      # TODO: move outside scratch
      ["scratch/welcome_to_gestleton.lua"]
      ["avatar/sdfvm_lookup_table.json"
      "scratch/welcome_to_gestleton.bin"
      "scratch/squad.lua"]]

    @[["res/ref_junior.png"]
      ["vocab/junior/ref_junior.lua"]
      ["asset/asset.lua"
       "vocab/junior/v_junior.b64"
       "vocab/junior/t_junior.b64"]]

    @[["res/sco_junior.png"]
      # TODO: move outside scratch
      ["scratch/junior_score.lua"]
      ["asset/asset.lua"
       "descript/descript.lua"
       "dialogue/junior.txt"]]

    @[["res/trailer2.mp4"]
      # TODO: move outside scratch
      ["scratch/trailer2.lua"]
      ["asset/asset.lua"
       "descript/descript.lua"
       "dialogue/junior.txt"]]

    @[["res/mouthshapes1.png"]
      ["avatar/mouth/mouthchart.lua"]
      ["asset/asset.lua"
       "avatar/mouth/mouth.lua"
       "avatar/sdfdraw.lua"
       "avatar/mouth/mouthshapes1.b64"]]
])

(def fonts @["cholo" "antik_1" "cursive_a" "fountain_joined" "fountain" "plotter"])
