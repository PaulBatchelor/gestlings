(do 
 (def loadtiles-file (dofile "loadtiles/loadtiles.janet"))
 (def gen-tilemap ((loadtiles-file 'gen-tilemap) :value))
 (def tmap
   (gen-tilemap "protodiacritics/dsquares.txt" 4 4 6 6))

 (def gmap
   (gen-tilemap "protosigils/protosigils.txt" 7 7 3 4))

 (def rmap
   (gen-tilemap "curated_lglyphs/radicals.txt" 4 4 8 8))

 (def bp (btprnt/new 256 256))
 (def main @[0 0 256 256])
 (def zoom 2)
 (def padding 1)

 (def glyphbox
   (btprnt/centerbox
     bp main (* 32 zoom) (* 32 zoom)))

 (def center
   (btprnt/centerbox
     bp glyphbox
     (* (+ 24 (* 2 padding)) zoom)
     (* (+ 24 (* 2 padding)) zoom)))

 (btprnt/outline bp center 1)
 (btprnt/outline bp glyphbox 1)

 (for i 1 5
   (btprnt/tile
     bp tmap
     center
     (* (+ (* i 4) padding) zoom) (* padding zoom)
     5 0
     4 4
     zoom 1))

 (btprnt/tile
   bp gmap center
   (* (+ 5 padding) zoom) (* (+ 5 padding) zoom)
   0 0
   7 7
   (* zoom 2) 1)

 (btprnt/tile
   bp rmap center
   (* padding zoom) (* (+ 16 padding) zoom)
   1 1
   4 4
   zoom 1)

 (btprnt/tile
   bp rmap center
   (* padding zoom) (* (+ 20 padding) zoom)
   5 0
   4 4
   zoom 1)

 (btprnt/tile
   bp rmap center
   (* (+ 4 padding) zoom) (* (+ 20 padding) zoom)
   6 0
   4 4
   zoom 1)
 
 (btprnt/tile
   bp rmap center
   (* (+ 20 padding) zoom) (* (+ 20 padding) zoom)
   1 0
   4 4
   zoom 1)

 (btprnt/tile
   bp rmap center
   (* (+ 20 padding) zoom) (* (+ 16 padding) zoom)
   5 1
   4 4
   zoom 1)

 (btprnt/tile
   bp rmap center
   (* (+ 16 padding) zoom) (* (+ 20 padding) zoom)
   0 2
   4 4
   zoom 1)

 (btprnt/write-pbm bp "protodiacritics.pbm")

 (btprnt/del bp)
 (btprnt/del gmap)
 (btprnt/del tmap)

 )
