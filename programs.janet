(def pages @{
 "curated_lglyphs"
 @{
 :id 0
 :org "curated_lglyphs/curated_lglyphs.org"
 :janet "curated_lglyphs/curated_lglyphs.janet"
 :title "Curated L-Glyphs"
 }
 "parsing_programs"
 @{
 :id 1
 :org "parsing_programs/parsing_programs.org"
 :janet "progparse.janet"
 }})

(defn get-id [pgname]
 (print pgname)
 (let (pg (pages pgname))
  (pg :id)))

(defn get-id-from-file [file]
 (var pgname nil)
 (each p pages
  (if (= (p :org) file) (set pgname (p :id))))
 pgname)


#(pp (get-pgname "curated_lglyphs/curated_lglyphs.org"))
