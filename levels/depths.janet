(defn generate []
  (ww-open "a.db")
  (ww-add-page "depths" `@!(ref "door")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "depths")
  (ww-close))
