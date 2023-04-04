(import programs)

(defn tangle [janet-file org-file]
  (print (string "build " janet-file ": tangle " org-file)))

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
  (print "libs = -lmnolth -lx264")
  (print "rule link")
  (print "    command = gcc $cflags $in -o $out $ldflags $libs")
  (print "    description = creating $in"))

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
(def obj @["cantor" "protogestling/protogestling"])
(build-cantor obj)

(each prog programs/pages
  (if (array? (prog :tangled))
    (tangle (string/join (prog :tangled) " ") (prog :org))
    (tangle (prog :tangled) (prog :org))))

