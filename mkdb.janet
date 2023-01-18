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

# linked pages

(ww-add-link "index" "index.org")
(ww-add-link "weight" "weight/weight.org")

# sync and close

(ww-sync)
(ww-close)
