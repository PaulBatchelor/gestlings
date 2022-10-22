(import programs)

(defn tangle [janet-file org-file]
  (print (string "build " janet-file ": tangle " org-file)))

(defn tangler-var []
  (print "tangler = weewiki janet tangle_and_export.janet"))

(defn tangle-rule []
  (print "rule tangle\n    command = $tangler $in"))

(tangler-var)
(tangle-rule)

(each prog programs/pages
  (tangle (prog :janet) (prog :org)))
