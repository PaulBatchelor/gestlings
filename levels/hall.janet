(defn generate []
  (ww-open "a.db")
  (ww-add-page "hall" `@!(ref "gardener")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "hall")
  (ww-close))
