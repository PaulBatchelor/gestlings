weewiki dump mkdb.janet
weewiki zet export | split -a 3 -l 5000 - tsv/x
./zetdo lstexp > priority.tsv
fossil extras tsv
