# open and clear wiki db

(ww-open "a.db")
(ww-clear)

# unlinked pages

(ww-add-page "logs" `@!(zet/messages "logs")!@
`)

# linked pages

(ww-add-link "curated_lglyphs" "curated_lglyphs/curated_lglyphs.org")
(ww-add-link "simple_path" "simple_path/simple_path.org")
(ww-add-link "index" "index.org")
(ww-add-link "protosigils" "protosigils/protosigils.org")

# sync and close

(ww-sync)
(ww-close)
