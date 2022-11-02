(import programs)

(def args (dyn :args))

(if (>= (length args) 2)
  (do
    (def filename (args 1))
    (def program-id (programs/get-id-from-file filename))

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
