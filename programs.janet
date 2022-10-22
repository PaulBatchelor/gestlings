(def pages @{
 "curated_lglyphs"
 @{
 :id 0
 :org "curated_lglyphs/curated_lglyphs.org"
 :tangled "curated_lglyphs/curated_lglyphs.janet"
 :title "Curated L-Glyphs"
 }

 "parsing_programs"
 @{
 :id 1
 :org "parsing_programs/parsing_programs.org"
 :tangled "progparse.janet"
 :title "Parsing Programs"
 }

 "simple_path"
 @{
 :id 2
 :org "simple_path/simple_path.org"
 :tangled "simple_path/simple_path.lua"
 :title "Simple Path"
 }
})

(defn get-id [pgname]
 (print pgname)
 (let (pg (pages pgname))
  (pg :id)))

# Could this be done better?
(defn get-id-from-file [file]
 (var pgname nil)
 (each p pages
  (if (= (p :org) file) (set pgname (p :id))))
 pgname)

