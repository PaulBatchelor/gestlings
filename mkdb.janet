# open and clear wiki db

(ww-open "a.db")
(ww-clear)

# unlinked pages

(ww-add-page "logs" `@!(zet/messages "logs")!@`)
(ww-add-page "parsing_programs" `@!(wikipage "parsing_programs")!@
`)
(ww-add-page "curated_lglyphs" `@!(wikipage "curated_lglyphs")!@
`)
(ww-add-page "simple_path" `@!(wikipage "simple_path")!@
`)
(ww-add-page "loadtiles" `@!(wikipage "loadtiles")!@
`)
(ww-add-page "protosigils" `@!(wikipage "protosigils")!@`)
(ww-add-page "protodiacritics" `@!(wikipage "protodiacritics")!@`)
(ww-add-page "radicals" `@!(wikipage "radicals")!@`)
(ww-add-page "sigils" `@!(wikipage "sigils")!@`)
(ww-add-page "runes" `@!(wikipage "runes")!@`)
(ww-add-page "layout" `@!(wikipage "layout")!@`)

# linked pages

(ww-add-link "index" "index.org")

# sync and close

(ww-sync)
(ww-close)
