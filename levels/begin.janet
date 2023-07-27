(defn generate []
  (ww-open "a.db")
  (ww-add-page "begin" `@!(ref "awaken")!@.`)
  (ww-add-page "awaken" `@!(ref "train")!@.`)
  (ww-add-page "train" `@!(ref "arrival")!@.`)
  (ww-add-page "arrival" `@!(ref "gestleton")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "begin")
  (ww-del-page "awaken")
  (ww-del-page "train")
  (ww-del-page "arrival")
  (ww-close))
