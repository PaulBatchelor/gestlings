(do 
  (def loadtiles-file (dofile "loadtiles/loadtiles.janet"))
  (def gen-tilemap ((loadtiles-file 'gen-tilemap) :value))
  (def tmap
    (gen-tilemap "protodiacritics/dsquares.txt" 4 4 6 6))

  (def gmap
    (gen-tilemap "protosigils/protosigils.txt" 7 7 3 4))

  (def rmap
    (gen-tilemap "curated_lglyphs/radicals.txt" 4 4 8 8))

  (def stripe @[5 0])
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
  (def tlknee @[0 2])
  (def trknee @[1 2])
  (def blknee @[2 2])
  (def brknee @[3 2])
  (def topline @[4 2])
  (def squig1 @[5 2])
  (def squig2 @[0 3])

  (def bp (btprnt/new 256 256))
  (def canvas @[0 0 256 256])
  (def zoom 2)
  (def padding 1)
  (def main (btprnt/border bp canvas 14))

  (def glyphbox
    (btprnt/centerbox
      bp main (* 32 zoom) (* 32 zoom)))

  (def center
    (btprnt/centerbox
      bp glyphbox
      (* (+ 24 (* 2 padding)) zoom)
      (* (+ 24 (* 2 padding)) zoom)))

  (defn draw-radical [bp reg rad pos &opt centerpad]
    (default centerpad 2) 
    (btprnt/tile
      bp tmap
      reg
      (* (+ (* pos 4) padding centerpad) zoom) (* padding zoom)
      (rad 0) (rad 1)
      4 4
      zoom 1))

  (defn draw-side-radical [bp reg rad pos]
    (btprnt/tile
      bp tmap
      reg
      (* (+ padding (* (pos 0) 20)) zoom)
      (* (+ padding (* (+ (pos 1) 1) 4)) zoom)
      (rad 0) (rad 1)
      4 4
      zoom 1))

  (defn draw-diacritic [bp glyph rads &opt side-rads]
    (default side-rads nil)
    (def centerpad (if (= (length rads) 5) 2 0))
    (for i 0 (length rads)
      (draw-radical bp glyph (rads i) i centerpad))

    (if-not (nil? side-rads)
      (do
        (if-not (nil? (side-rads 0))
          (draw-side-radical bp glyph (side-rads 0) @[0 0]))
        (if-not (nil? (side-rads 1))
          (draw-side-radical bp glyph (side-rads 1) @[0 1]))
        (if-not (nil? (side-rads 2))
          (draw-side-radical bp glyph (side-rads 2) @[1 0]))
        (if-not (nil? (side-rads 3))
          (draw-side-radical bp glyph (side-rads 3) @[1 1])))))



  (def diacritics
    (array 
      @[empty empty dot empty empty]
      @[lcap stripe stripe stripe stripe rcap]
      @[lcap stripe stripe stripe stripe rtee]
      @[ltee stripe stripe stripe stripe rtee]
      @[lcap rtee empty ltee rcap]
      @[dot empty dot empty dot]
      @[empty empty dot dot empty empty]
      @[empty empty box empty empty]
      @[lcap rtee dot ltee rcap]
      @[lbrack pipe pipe pipe pipe rbrack]
      @[tlknee stripe trknee tlknee stripe trknee]
      @[empty box empty box empty]
      @[empty tlknee box trknee empty]
      @[tlknee brknee lcap rcap blknee trknee]
      @[squig1 squig2 squig1 squig2 squig1 squig2]
      @[empty blknee stripe brknee empty]))

  (defn draw-dbox [d x y &opt side-rads]
    (default side-rads nil)
    (def dbox 
      (btprnt/centerbox
        bp
        (btprnt/grid bp main 4 4 x y)
        (* (+ 24 (* padding 2)) zoom)
        (* (+ 24 (* padding 2)) zoom)
        ))


    (draw-diacritic
      bp dbox (diacritics d) side-rads)

    (btprnt/outline bp dbox 1))

  (draw-dbox 0 0 0)
  (draw-dbox 1 1 0 @[dot nil dot nil])
  (draw-dbox 2 2 0)
  (draw-dbox 3 3 0 @[nil nil box stripe])
  (draw-dbox 4 0 1)
  (draw-dbox 5 1 1)
  (draw-dbox 6 2 1 @[tlknee blknee box rtee])
  (draw-dbox 7 3 1)
  (draw-dbox 8 0 2)
  (draw-dbox 9 1 2 @[dot nil dot nil])
  (draw-dbox 10 2 2)
  (draw-dbox 11 3 2)
  (draw-dbox 12 0 3)
  (draw-dbox 13 1 3 @[ltee dot rtee nil])
  (draw-dbox 14 2 3)
  (draw-dbox 15 3 3)

  (def chicago_12 (btprnt/macfont-load "fonts/chicago_12"))

  (btprnt/macfont-textbox
    bp chicago_12
    canvas 
    8 (- 256 17) "protodiacritics" 1)

  (btprnt/write-pbm bp "protodiacritics.pbm")

  (btprnt/del bp)
  (btprnt/del gmap)
  (btprnt/del tmap))
