(defn generate []
  (ww-open "a.db")
  (ww-add-page "gardener" `@!(ref "enlightenment")!@.`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "gardener")
  (ww-close))
