(import programs)

(def args (dyn :args))

(var use-monome false)

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
      " || cantor"
      (if-not (= deps nil)
        (string " " (string/join deps " ")))

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

(defn build-cantor [obj]
  (each o obj
    (print
      (string/format
        "build %s.o: cc %s.c" o o)))
  (print
    (string
      "build cantor: link "
      (string/join
        (map (fn [x] (string x ".o")) obj) " "))))

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
(def obj @[
    "cantor"
    "protogestling/protogestling"
    "bitrune/bitrune"
    "bitrune/engine"
    "bitrune/ortho33"
    ])
(build-cantor obj)

(each prog programs/pages
  (if (array? (prog :tangled))
    (tangle (string/join (prog :tangled) " ") (prog :org))
    (tangle (prog :tangled) (prog :org))))

(import config)
(each a config/assets
  (if (= (length a) 2)
      (asset (a 0) (a 1))
      (asset (a 0) (a 1) (a 2))))


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
      "    description = asset " name)))

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
   "|| cantor\n")))


(each fnt config/fonts (uf2font fnt))

(asset-cprog "res/mouthtests.png" "avatar/mouth/mouthtests")
(asset-cprog "avatar/sdfvm_lookup_table.json" "avatar/sdfvm_lookup_table")
