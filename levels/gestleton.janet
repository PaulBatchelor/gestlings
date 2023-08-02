(defn generate-gestleton-page []
    (string
        "#+TITLE: Gestleton\n"
        "@!(ref \"upper_rings\")!@.\n"
        "@!(img \"/res/gestleton.png\")!@\n"))

(defn generate []
  (ww-open "a.db")
  (ww-add-page "gestleton" (generate-gestleton-page))
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "gestleton")
  (ww-close))
