(import progparse)

(def md (progparse/open-metadata "foo.db" 0))

(def reslist (progparse/reslist md))

(each res reslist
  (cond
    (progparse/is-header? (res "type"))
    (do
      (def header (progparse/get-header md (res "id")))
      (print
        (string (header "section") " " (header "name"))))

    (progparse/is-content? (res "type"))
    (do
      (def content (progparse/get-content md (res "id")))
      (prin (content "content")))
    (progparse/is-blockref? (res "type"))
    (do
      (def blockref 
        (progparse/get-blockref md (res "id")))
      (def block 
        (progparse/get-block md (blockref "ref")))
      (pp blockref)
      (pp block)
      (print
        (string "<<Block Reference>>: " (res "id"))))))

(def block (progparse/get-block md 6))

(var seg-id (block "head_segment"))
(def block-segs (array/new (block "nsegs")))
(def nsegs (block "nsegs"))

(for n 0 nsegs 
  (var cur-seg (progparse/get-segment md seg-id))
  (set (block-segs n) cur-seg)
  (set seg-id (cur-seg "next_segment")))

(each b block-segs (print (b "str")))

(progparse/close-metadata md)
