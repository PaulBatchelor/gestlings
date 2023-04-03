(import programs)

(defn tangle [janet-file org-file]
  (print (string "build " janet-file ": tangle " org-file)))

(defn tangler-var []
  (print "tangler = weewiki janet tangle_and_export.janet"))

(defn tangle-rule []
  (print "rule tangle\n    command = $tangler $in"))

(defn cc-rule []
  (print "cflags = -Wall -O3 -pedantic -g -I /usr/local/include/mnolth/lua")
  (print "rule cc")
  (print "    command = gcc $cflags -c $in -o $out")
  (print "    description = cc $in"))

(defn link-rule []
  (print "ldflags = -L/opt/homebrew/lib -L/usr/local/lib")
  (print "libs = -lmnolth -lx264")
  (print "rule link")
  (print "    command = gcc $cflags $in -o $out $ldflags $libs")
  (print "    description = creating $in"))


(defn build-cantor []
  (print "build cantor.o: cc cantor.c")
  (print "build cantor: link cantor.o")
)

(tangler-var)
(tangle-rule)
(cc-rule)
(link-rule)
(build-cantor)

(each prog programs/pages
  (if (array? (prog :tangled))
    (tangle (string/join (prog :tangled) " ") (prog :org))
    (tangle (prog :tangled) (prog :org))))
