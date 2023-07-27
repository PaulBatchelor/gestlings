(defn generate []
  (ww-open "a.db")
  (ww-add-page "enlightenment" `@!(ref "awaken")!@.
@!(ref "cauldron")!@
`)
  (ww-close))

(defn clear []
  (ww-open "a.db")
  (ww-del-page "enlightenment")
  (ww-close))
