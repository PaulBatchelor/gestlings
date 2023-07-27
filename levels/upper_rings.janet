(defn generate []
  (ww-open "a.db")
  (ww-add-page "upper_rings" `@!(ref "lower_rings")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "upper_rings")
  (ww-close))
