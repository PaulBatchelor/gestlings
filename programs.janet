(def pages @{
 "curated_lglyphs"
 @{
 :id 0
 :org "curated_lglyphs/curated_lglyphs.org"
 :tangled "curated_lglyphs/curated_lglyphs.janet"
 }

 "parsing_programs"
 @{
 :id 1
 :org "parsing_programs/parsing_programs.org"
 :tangled "progparse.janet"
 }

 "simple_path"
 @{
 :id 2
 :org "simple_path/simple_path.org"
 :tangled "simple_path/simple_path.lua"
 }

 "loadtiles"
 @{
 :id 3
 :org "loadtiles/loadtiles.org"
 :tangled "loadtiles/loadtiles.janet"
 }

 "protosigils"
 @{
 :id 4
 :org "protosigils/protosigils.org"
 :tangled "protosigils/protosigils.janet"
 }

 "protodiacritics"
 @{
 :id 5
 :org "protodiacritics/protodiacritics.org"
 :tangled "protodiacritics/protodiacritics.janet"
 }

 "radicals"
 @{
 :id 6
 :org "radicals/radicals.org"
 :tangled @["radicals/radicals.txt" "radicals/radicals.janet"]
 }

 "sigils"
 @{
 :id 7
 :org "sigils/sigils.org"
 :tangled "sigils/sigils.janet" 
 }
 
 "runes"
 @{
 :id 8
 :org "runes/runes.org"
 :tangled @["runes/runes.txt" "runes/runes.janet"]
 }

 "layout"
 @{
 :id 9
 :org "layout/layout.org"
 :tangled @["layout/layout.janet"]
 }

 "tal"
 @{
 :id 10 
 :org "tal/tal.org"
 :tangled @["tal/tal.lua"]
 }
})

# TODO: move this out of this file.
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

