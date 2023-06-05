# remove procedurally generated wiki pages
weewiki janet predump.janet

# dump the rest
weewiki dump mkdb.janet

# zet and priority list split up into 5k line TSV files
weewiki zet export | split -a 3 -l 5000 - tsv/x
./zetdo lstexp > priority.tsv

# if split produced
fossil extras tsv
