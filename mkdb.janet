# open and clear wiki db

(ww-open "a.db")
(ww-clear)

# unlinked pages

(ww-add-page "logs" `@!(zet/messages "logs")!@`)
(ww-add-page "curated_lglyphs" `@!(progparse/docgen 0 "Curated L Glyphs")!@`)

# linked pages

(ww-add-link "simple_path" "simple_path/simple_path.org")
(ww-add-link "index" "index.org")
(ww-add-link "protosigils" "protosigils/protosigils.org")

# sync and close

(ww-sync)
(ww-close)
