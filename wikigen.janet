(import creation)
(import levels/levels :as levels)

(dofile "mkdb.janet")
(creation/create)
(levels/generate)
