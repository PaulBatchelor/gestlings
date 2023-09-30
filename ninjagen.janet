(import programs)

(def args (dyn :args))

(var use-monome false)
(var asset-files @[])
(var tangled-files @[])
(var resource-files @[])

(defn tangle [janet-file org-file]
  (print (string "build " janet-file ": tangle " org-file)))

(defn asset [outputs inputs &opt deps]
  (default deps nil)
  (print
    (string
      "build "
      (string/join outputs " ")
      ": asset "
      (string/join inputs " ")
      " | cantor"
      (if-not (= deps nil)
        (string " " (string/join deps " ")))
      " || cantor"

      )))

(defn tangler-var []
  (print "tangler = weewiki janet tangle_and_export.janet"))

(defn tangle-rule []
  (print "rule tangle\n    command = $tangler $in"))

(defn cc-rule [cflags]
  (print (string "cflags = " (string/join cflags " ")))
  (print "rule cc")
  (print "    command = gcc $cflags -c $in -o $out")
  (print "    description = cc $in"))

(defn link-rule []
  (print "ldflags = -L/opt/homebrew/lib -L/usr/local/lib")
  (def libs @["-lmnolth" "-lx264"])
  (if (= use-monome true) (array/push libs "-lmonome -ljack"))
  (print (string "libs = " (string/join libs " ")))
  (print "rule link")
  (print "    command = gcc $cflags $in -o $out $ldflags $libs")
  (print "    description = creating $out"))

(defn asset-rule []
  (print "rule asset")
  (print "    command = ./cantor $in")
  (print "    description = asset $in"))

(defn c64parse-rule []
  (print "rule c64parse")
  (print "    command = ./util/c64parse $in > $out")
  (print "    description = c64parse $in"))

(defn uf2gen-rule []
  (print "rule uf2gen")
  (print "    command = ./cantor util/uf2gen.lua $in $out")
  (print "    description = uf2gen $in $out"))

(defn inspire-rule []
  (print "rule inspire")
  (print "    command = ./util/inspire.lua $in $character")
  (print "    description = inspire $in $character ($out)"))

(defn mkscore-rule []
  (print "rule mkscore")
  (print "    command = ./util/mkscore.lua $in $character")
  (print "    description = mkscore $in $character ($out)"))

(defn build-cantor [obj]
  (each o obj
    (print
      (string/format
        "build %s.o: cc %s.c" o o)))
  (print "build cantor.o: cc cantor.c")
  (print
    (string
      "build cantor: link "
      (string (string/join
        (map (fn [x] (string x ".o")) obj) " ") " cantor.o"))))

(defn build-rt [obj]
 (print "build util/rt.o: cc util/rt.c")
 (print
  (string
   "build util/rt: link "
   (string
    (string/join
     (map
      (fn [x] (string x ".o")) obj) " ") " util/rt.o"))))

(defn build-program [program obj]
  (each o obj
    (print
      (string/format
        "build %s.o: cc %s.c" o o)))
  (print
    (string
      "build " program ": link "
      (string/join
        (map (fn [x] (string x ".o")) obj) " "))))

(each a args
  (if (= a "monome") (set use-monome true)))

(tangler-var)
(tangle-rule)
(def cflags
  @["-Wall"
    "-O3"
    "-pedantic"
    "-g"
    "-I/usr/local/include/mnolth/lua"
    "-I/usr/local/include/mnolth/"
    ])
(cc-rule cflags)
(link-rule)
(asset-rule)
(inspire-rule)
(mkscore-rule)
(def obj @[
    "protogestling/protogestling"
    "bitrune/bitrune"
    "bitrune/engine"
    "bitrune/ortho33"
    ])
(build-cantor obj)

(each prog programs/pages
  (if (array? (prog :tangled))
    (do
      (each f (prog :tangled) (array/push tangled-files f))
      (tangle (string/join (prog :tangled) " ") (prog :org)))
    (do
      (array/push tangled-files (prog :tangled))
      (tangle (prog :tangled) (prog :org)))))

(import config)
(each a config/assets
  (if (= (length a) 2)
      (asset (a 0) (a 1))
      (asset (a 0) (a 1) (a 2)))
  (each output (a 0) (array/push asset-files output)))

(each a config/resources
  (if (= (length a) 2)
      (asset (a 0) (a 1))
      (asset (a 0) (a 1) (a 2)))
  (each output (a 0) (array/push resource-files output)))

(build-program
    "util/c64parse"
    @["util/c64parse"])

(c64parse-rule)
(uf2gen-rule)

(defn asset-cprog [name cprog]
  (build-program cprog @[cprog])
  (print
   (string
      "build " name ": asset " cprog "\n"
      "    command = ./" cprog "\n"
      "    description = asset " name))
   (array/push asset-files name))

(defn uf2font [fontname]
 (print
  (string
   "build fonts/bitmaps/" fontname ".lua: "
   "c64parse fonts/bitmaps/" fontname ".png "
   "fonts/bitmaps/" fontname ".txt "
   "|| util/c64parse\n"))

 (print
  (string
   "build fonts/" fontname ".uf2: "
   "uf2gen fonts/bitmaps/" fontname ".lua "
   "|| cantor\n"))

 (array/push asset-files (string "fonts/" fontname ".uf2")))


(each fnt config/fonts (uf2font fnt))

(asset-cprog "res/mouthtests.png" "avatar/mouth/mouthtests")
(asset-cprog "avatar/sdfvm_lookup_table.json" "avatar/sdfvm_lookup_table")

(defn gestling [dialogue character]
 (def mp4 (string "res/" character ".mp4"))
 (def png (string "res/sco_" character ".png"))
 (print
  (string
   "build " mp4 ": inspire " dialogue " | cantor\n"
   "    character = " character))

 (print
  (string
   "build " png ": mkscore " dialogue " | cantor\n"
   "    character = " character))

  (array/push resource-files mp4)
  (array/push resource-files png))


(gestling "dialogue/junior_mushrooms.txt" "junior")

(print (string "build assets: phony " (string/join asset-files " ")))
(print (string "build tangled: phony " (string/join tangled-files " ")))
(print (string "build resources: phony " (string/join resource-files " ")))

(var default-targets @["tangled cantor assets"])
(if (= use-monome true)
    (do
      (build-rt obj)
      (array/push default-targets "util/rt")))

# (print "default tangled cantor")
(print "default " (string/join default-targets " "))
