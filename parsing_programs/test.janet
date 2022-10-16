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

# (defn codeblock-string [md id &opt block-handler]
#   (default block-handler
#     (fn [md b] (string "<<" (b "str") ">>")))
# 
#   (def block (progparse/get-block md id))
# 
#   (var seg-id (block "head_segment"))
#   (def block-segs (array/new (block "nsegs")))
#   (def nsegs (block "nsegs"))
#   (var lines @[])
# 
#   (array/push lines (string "#+NAME: " (block "name")))
#   (array/push lines "#+BEGIN_SRC")
#   (for n 0 nsegs 
#     (var cur-seg (progparse/get-segment md seg-id))
#     (set (block-segs n) cur-seg)
#     (set seg-id (cur-seg "next_segment")))
# 
#   (each b block-segs
#     (cond
#       (= (b "type") 1)
#       (array/push lines (block-handler md b))
#       (= (b "type") 0)
#       (array/push lines (b "str"))))
# 
#   (progparse/close-metadata md)
#   (string (string/join lines "\n") "#+END_SRC"))

# TODO how to render specific block?
(print (progparse/codeblock-string md 18))
