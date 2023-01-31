(def ww-dir "_site/gestlings")
(def webroot (if (ww-server?) "/wiki" "/gestlings"))
(def wiki-path "/wiki")

(defn pgexists? (name)
  (var db (ww-db))
  (var x
       (sqlite3/eval
        db (string
            "SELECT EXISTS(SELECT key from wiki "
            "where key is \""name"\") as doiexist;")))
  (= ((x 0) "doiexist") 1))

(defn pglink (page &opt target)
  (var link "")
  (if (nil? target)
    (set link page)
    (set link (string page "#" target)))
  (cond
    (= page "index")
    (string webroot "/")
    (pgexists? page)
    (string webroot "/" link) "#"))


(defn refstr (link &opt name)
  (if (nil? name)
    (string "[[" (pglink link) "][" link "]]")
    (string
     "[["
     (pglink link)
     "]["
     name
     "]]")))

(defn ref (link &opt name target)
  (default target nil)
  (if (nil? name)
    (org (string "[[" (pglink link) "][" link "]]"))
    (org
     (string
      "[["
      (pglink link target)
      "]["
      name
      "]]"))))

(defn img [path &opt alt srcset]
  (print
   (string
    "<img src=\""
    path "\""
    (if-not (nil? alt) (string " alt=\"" alt "\""))
    (if-not (nil? srcset)
      (string "srcset=\"" srcset "\""))
    ">")))

(defn img-link [path link &opt alt]
  (print
   (string
    "<a href=\"" link "\">"
    "<img src=\""
    path "\""
    (if-not (nil? alt) (string " alt=\"" alt "\""))
    "></a>")))

(defn html-header
  []
(print
(string/format ``<!DOCTYPE html>
<html lang="en">
<head>

<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="%s">

</head>
<body>
<div id="main">
`` (if (ww-server?) "/css/style.css" "/gestlings/css/style.css")))
)

(defn html-footer
  []
  (print
``
</div>
</body>
</html>
``
))

(defn marker [id &opt msg]
  (default msg "")
  (prin (string "<a id=\"" id "\">" msg "</a>")))


# TODO: create citation
(defn cite [keyword]
   (org (string "=" keyword "="))
)

# creates a reference to my main wiki
(defn wikiref [name]
  (org (string "[[" wiki-path "/" name "][" name "]]")))

(import ergo)
(import zet)
(import programs)
(import progparse)
(import layout/layout :as layout)
(import sigils/sigils :as sigils)

(defn wikipage [pgname]
  (progparse/wikipage (programs/pages pgname)))

(defn bpimg [bp alt]
  (print "<img src=\"data:image/png;base64,")
  (print (btprnt/write-png bp))
  (print (string/format
           "\" alt=\"%s\">" alt)))

(defn video [path &opt alt fallback]
  (print "<video controls>")
  (print
   (string
    "<source src=\""
    path "\""
    (if-not (nil? alt) (string " alt=\"" alt "\""))
    " type=\"video/mp4\">"))
  (if-not (nil? fallback) (img fallback alt))
  (print "</video>"))
