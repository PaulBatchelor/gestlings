# open and clear wiki db

(ww-open "a.db")
(ww-clear)

# unlinked pages

(ww-add-page "parsing_programs" `@!(wikipage "parsing_programs")!@`)
(ww-add-page "curated_lglyphs" `@!(wikipage "curated_lglyphs")!@`)
(ww-add-page "loadtiles" `@!(wikipage "loadtiles")!@`)
(ww-add-page "protosigils" `@!(wikipage "protosigils")!@`)
(ww-add-page "protodiacritics" `@!(wikipage "protodiacritics")!@`)
(ww-add-page "radicals" `@!(wikipage "radicals")!@`)
(ww-add-page "sigils" `@!(wikipage "sigils")!@`)
(ww-add-page "runes" `@!(wikipage "runes")!@`)
(ww-add-page "layout" `@!(wikipage "layout")!@`)
(ww-add-page "simple_path" `@!(wikipage "simple_path")!@`)
(ww-add-page "tal" `@!(wikipage "tal")!@`)
(ww-add-page "path" `@!(wikipage "path")!@`)
(ww-add-page "morpheme" `@!(wikipage "morpheme")!@`)
(ww-add-page "seq" `@!(wikipage "seq")!@`)
(ww-add-page "gest" `@!(wikipage "gest")!@`)
(ww-add-page "sig" `@!(wikipage "sig")!@`)
(ww-add-page "logs" `#+TITLE: logs
@!(zet/messages "logs")!@`)
(ww-add-page "whistle" `@!(wikipage "whistle")!@`)
(ww-add-page "diagraf" `@!(wikipage "diagraf")!@`)
(ww-add-page "sigrunes" `@!(wikipage "sigrunes")!@`)
(ww-add-page "nrt" `@!(wikipage "nrt")!@`)
(ww-add-page "mseq" `@!(wikipage "mseq")!@`)
(ww-add-page "gestku" `@!(wikipage "gestku")!@`)
(ww-add-page "warble" `@!(wikipage "warble")!@`)
(ww-add-page "morpho" `@!(wikipage "morpho")!@`)
(ww-add-page "cantor" `@!(wikipage "cantor")!@`)
(ww-add-page "protogestling" `@!(wikipage "protogestling")!@`)
(ww-add-page "asset" `@!(wikipage "asset")!@`)
(ww-add-page "path_grammar" `@!(wikipage "path_grammar")!@`)
(ww-add-page "path_symbols" `@!(wikipage "path_symbols")!@`)
(ww-add-page "protogestling_mockup" `@!(wikipage "protogestling_mockup")!@`)
(ww-add-page "TODO" `#+TITLE: TODO
Tasks for Gestlings. Updated automatically using [[/wiki/zetdo][zetdo]].

@!(zet/zetdo-agenda)!@`)
(ww-add-page "klover" `@!(wikipage "klover")!@`)
(ww-add-page "descript" `@!(wikipage "descript")!@`)
(ww-add-page "mouthtests" `@!(wikipage "mouthtests")!@`)
(ww-add-page "sdfvm_mouth" `@!(wikipage "sdfvm_mouth")!@`)
(ww-add-page "mouthanim" `@!(wikipage "mouthanim")!@`)

# linked pages

(ww-add-link "index" "index.org")
(ww-add-link "weight" "weight/weight.org")
(ww-add-link "goblins" "goblins/goblins.org")
(ww-add-link "goblin_vocal_warmups" "goblins/vocal_warmups.org")
(ww-add-link "goblin_laughing" "goblins/laughing.org")
(ww-add-link "goblin_waking_up" "goblins/waking_up.org")
(ww-add-link "goblin_deciding" "goblins/deciding.org")
(ww-add-link "goblin_remembering" "goblins/remembering.org")
(ww-add-link "goblin_snoring" "goblins/snoring.org")
(ww-add-link "goblin_grumpy" "goblins/grumpy.org")
(ww-add-link "progress" "progress.org")

# sync and close

(ww-sync)
(ww-close)
