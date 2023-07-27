# called before weewiki dump in dump.sh
# needed in order to cull procedurally generated pages

(import creation)
(import levels/levels)

(creation/uncreate)
(levels/clear)
