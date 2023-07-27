(defn generate []
  (ww-open "a.db")
  (ww-add-page "gestleton" `@!(ref "upper_rings")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "gestleton")
  (ww-close))
