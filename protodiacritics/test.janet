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
 (def canvas @[0 0 256 256])
 (def zoom 2)
 (def padding 1)
 (def main (btprnt/border bp canvas 8))

 (def glyphbox
   (btprnt/centerbox
     bp main (* 32 zoom) (* 32 zoom)))

 (def center
   (btprnt/centerbox
     bp glyphbox
     (* (+ 24 (* 2 padding)) zoom)
     (* (+ 24 (* 2 padding)) zoom)))

 #(btprnt/outline bp center 1)
 #(btprnt/outline bp glyphbox 1)
 #(btprnt/outline bp main 1)

 (defn draw-radical [bp reg rad pos &opt centerpad]
   (default centerpad 2) 
   (btprnt/tile
     bp tmap
     reg
     (* (+ (* pos 4) padding centerpad) zoom) (* padding zoom)
     (rad 0) (rad 1)
     4 4
     zoom 1))

 (defn draw-diacritic [bp glyph rads]
   (def centerpad (if (= (length rads) 5) 2 0))
   (for i 0 (length rads)
    (draw-radical bp glyph (rads i) i centerpad))
 )


 (def stroke @[5 0])
 (def lcap @[3 1])
 (def rcap @[4 1])
 (def dot @[1 0])
 (def empty @[0 0])
 (def rtee @[3 0])
 (def ltee @[4 0])
 (def box @[0 1])
 (def pipe @[5 1])
 (def lbrack @[1 1])
 (def rbrack @[2 1])

 (def diacritics
   (array 
     @[empty empty dot empty empty]
     @[lcap stroke stroke stroke stroke rcap]
     @[lcap stroke stroke stroke stroke rtee]
     @[ltee stroke stroke stroke stroke rtee]
     @[lcap rtee empty ltee rcap]
     @[dot empty dot empty dot]
     @[empty empty dot dot empty empty]
     @[empty empty box empty empty]
     @[lcap rtee dot ltee rcap]
     @[lbrack pipe pipe pipe pipe rbrack]

      ))

 # (draw-diacritic bp center (diacritics 0))

 (defn draw-dbox [d x y]
   (def dbox 
     (btprnt/centerbox
       bp
       (btprnt/grid bp main 4 4 x y)
       (* (+ 24 (* padding 2)) zoom)
       (* (+ 24 (* padding 2)) zoom)
       ))

   
   (draw-diacritic
     bp dbox (diacritics d))

   (btprnt/outline bp dbox 1))

 (draw-dbox 0 0 0)
 (draw-dbox 1 1 0)
 (draw-dbox 2 2 0)
 (draw-dbox 3 3 0)
 (draw-dbox 4 0 1)
 (draw-dbox 5 1 1)
 (draw-dbox 6 2 1)
 (draw-dbox 7 3 1)
 (draw-dbox 8 0 2)
 (draw-dbox 9 1 2)

 # (for i 1 5
 #   (draw-radical bp center @[5 0] i))

 # (draw-radical bp center @[3 1] 0)  
 # (draw-radical bp center @[4 1] 5)  

 # (btprnt/tile
 #   bp gmap center
 #   (* (+ 5 padding) zoom) (* (+ 5 padding) zoom)
 #   0 0
 #   7 7
 #   (* zoom 2) 1)

 # (btprnt/tile
 #   bp rmap center
 #   (* padding zoom) (* (+ 16 padding) zoom)
 #   1 1
 #   4 4
 #   zoom 1)

 # (btprnt/tile
 #   bp rmap center
 #   (* padding zoom) (* (+ 20 padding) zoom)
 #   5 0
 #   4 4
 #   zoom 1)

 # (btprnt/tile
 #   bp rmap center
 #   (* (+ 4 padding) zoom) (* (+ 20 padding) zoom)
 #   6 0
 #   4 4
 #   zoom 1)
 # 
 # (btprnt/tile
 #   bp rmap center
 #   (* (+ 20 padding) zoom) (* (+ 20 padding) zoom)
 #   1 0
 #   4 4
 #   zoom 1)

 # (btprnt/tile
 #   bp rmap center
 #   (* (+ 20 padding) zoom) (* (+ 16 padding) zoom)
 #   5 1
 #   4 4
 #   zoom 1)

 # (btprnt/tile
 #   bp rmap center
 #   (* (+ 16 padding) zoom) (* (+ 20 padding) zoom)
 #   0 2
 #   4 4
 #   zoom 1)

 (btprnt/write-pbm bp "protodiacritics.pbm")

 (btprnt/del bp)
 (btprnt/del gmap)
 (btprnt/del tmap)

 )
