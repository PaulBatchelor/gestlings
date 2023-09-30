(defn generate-gestleton-page []
    (string
        "#+TITLE: Gestleton\n"
        "@!(imagemap"
        `"gestleton_map"`
        `"levels/gestleton/portals.json"`
        `"/tmp/gestleton_proto.png")!@`
    ))

(defn generate []
  (ww-open "a.db")
  (ww-add-page "gestleton" (generate-gestleton-page))
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "gestleton")
  (ww-close))
