(defn generate []
  (ww-open "a.db")
  (ww-add-page "lower_rings" `@!(ref "shores")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "lower_rings")
  (ww-close))
