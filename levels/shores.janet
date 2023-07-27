(defn generate []
  (ww-open "a.db")
  (ww-add-page "shores" `@!(ref "depths")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "shores")
  (ww-close))
