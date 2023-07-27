(defn generate []
  (ww-open "a.db")
  (ww-add-page "door" `@!(ref "hall")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "door")
  (ww-close))
