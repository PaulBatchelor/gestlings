(def bp (btprnt/new 256 256))
(def canvas @[0 0 256 256])
(def main (btprnt/border bp canvas 8))
(defn move-right [bp main sigil]
  (btprnt/rect-filled
    bp main
    (+ (- (sigil 0) (main 0)) 25)
    (+ (- (sigil 1) (main 1)) (- 12 3))
    6 7 1)

  (btprnt/rect-filled
    bp main
    (+ (+ (- (sigil 0) (main 0)) 25) 4)
    (+ (- (sigil 1) (main 1)) (- 12 6))
    2 13 1)
  (array
    (+ (sigil 0) 32)
    (sigil 1) 
    (sigil 2)
    (sigil 3)))

(defn move-up [bp main sigil]
  (btprnt/rect-filled
    bp main
    (+ (- (sigil 0) (main 0)) (- 12 3))
    (- (- (sigil 1) (main 1)) 7)
    7 6 1)

  (btprnt/rect-filled
    bp main
    (+ (- (sigil 0) (main 0)) (- 12 6))
    (- (- (sigil 1) (main 1)) 6)
    13 2 1)
  (array
    (sigil 0) 
    (- (sigil 1) 32)
    (sigil 2)
    (sigil 3)))

(defn move-left [bp main sigil]
  (btprnt/rect-filled
    bp main
    (- (- (sigil 0) (main 0)) 7)
    (+ (- (sigil 1) (main 1)) (- 12 3))
    6 7 1)

  (btprnt/rect-filled
    bp main
    (- (- (sigil 0) (main 0)) 6)
    (+ (- (sigil 1) (main 1)) (- 12 6))
    2 13 1)
  (array
    (- (sigil 0) 32)
    (sigil 1) 
    (sigil 2)
    (sigil 3)))

(defn move-down [bp main sigil]
  (btprnt/rect-filled
    bp main
    (+ (- (sigil 0) (main 0)) (- 12 3))
    (+ (- (sigil 1) (main 1)) 25)
    6 7 1)

  (btprnt/rect-filled
    bp main
    (+ (- (sigil 0) (main 0)) (- 12 6))
    (+ (+ (- (sigil 1) (main 1)) 25) 4)
    13 2 1)
  (array
    (sigil 0) 
    (+ (sigil 1) 32)
    (sigil 2)
    (sigil 3)))

(var sigil (btprnt/centerbox bp main 25 25))
(btprnt/outline bp sigil 1)
(set sigil (move-right bp main sigil))
(btprnt/outline bp sigil 1)
(set sigil (move-up bp main sigil))
(btprnt/outline bp sigil 1)
(set sigil (move-left bp main sigil))
(btprnt/outline bp sigil 1)
(set sigil (move-left bp main sigil))
(btprnt/outline bp sigil 1)
(set sigil (move-down bp main sigil))
(btprnt/outline bp sigil 1)
(set sigil (move-down bp main sigil))
(btprnt/outline bp sigil 1)
(set sigil (move-right bp main sigil))
(btprnt/outline bp sigil 1)
(set sigil (move-right bp main sigil))
(btprnt/outline bp sigil 1)

(btprnt/outline bp main 1)


(print "<img src=\"data:image/png;base64,")
(print (btprnt/write-png bp))
(print (string/format
       "\" alt=\"%s\">" "test image"))
(btprnt/write-pbm bp "out.pbm")

(btprnt/del bp)
