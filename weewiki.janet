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


(defn respath [path]
    (def root 
        (if (ww-server?) "" "/gestlings"))
    (string root path))

(defn img [path &opt alt srcset]
  (print
   (string
    "<img src=\""
    (respath path) "\""
    (if-not (nil? alt) (string " alt=\"" alt "\""))
    (if-not (nil? srcset)
      (string "srcset=\"" srcset "\""))
    ">")))

(defn img-link [path link &opt alt]
  (print
   (string
    "<a href=\"" (pglink link) "\">"
    "<img src=\""
    (respath path) "\""
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

(defn markerstr [id &opt msg]
  (default msg "")
  (string "<a id=\"" id "\">" msg "</a>"))

(defn marker [id &opt msg]
  (default msg "")
  (prin (markerstr id msg)))

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

(defn tocgen [pgname]
  (progparse/tocgen (programs/pages pgname) pgname))

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
    (respath path) "\""
    (if-not (nil? alt) (string " alt=\"" alt "\""))
    " type=\"video/mp4\">"))
  (if-not (nil? fallback) (img (respath fallback) alt))
  (print "</video>"))

(defn imagemap [name portalfile image]
  (def file (file/open portalfile :r))
  (def data (json/decode (file/read file :all)))
  (defn gen-area [area]
    (string 
      "<area shape=\"rect\" "
      "href=\"" (pglink (area "page")) "\" "
      "coords=\""
      (string/join
        [(string (area "x"))
         (string (area "y"))
         (string (+ (area "x") (area "w")))
         (string (+ (area "y") (area "h")))
         ] ",")
      "\" "
      "alt=\"" (area "description") "\" "
      ">")
    )

  (print (string "<map name=\"" name "\">"))
  (each area data (print (gen-area area)))
  (print "</map>")

  (print
    (string
      "<img src=\"" (respath image) "\" "
      "usemap=\"#" name "\""
      ">"
      ))
  (file/close file))

(defn gestlingpage [name]
    (def vid (string "/res/" name ".mp4"))
    (def sco (string "/res/sco_" name ".png"))
    (org (string "#+TITLE: " name "\n\n"))
    (video vid)
    (org "\n")
    (img sco)
)
