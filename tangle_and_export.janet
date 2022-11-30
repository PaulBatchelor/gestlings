(import programs)

(def args (dyn :args))

(defn get-id [pgname]
 (print pgname)
 (let (pg (programs/pages pgname))
  (pg :id)))

(defn get-id-from-file [file]
 (var pgname nil)
 (each p programs/pages
  (if (= (p :org) file) (set pgname (p :id))))
 pgname)

(if (>= (length args) 2)
  (do
    (def filename (args 1))
    (def program-id (get-id-from-file filename))

    (if (nil? program-id)
      (error (string "no program id for " filename)))

    (def cmd
      (array
        "/usr/local/bin/worgle"
        "-Werror"
        "-p" (string program-id)
        "-d" "a.db" filename))
    (os/execute cmd))
  (error "Please supply a valid filename"))
