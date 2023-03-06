# open and clear wiki db

(ww-open "a.db")
(ww-clear)

# unlinked pages

(ww-add-page "parsing_programs" `@!(wikipage "parsing_programs")!@`)
(ww-add-page "curated_lglyphs" `@!(wikipage "curated_lglyphs")!@`)
(ww-add-page "loadtiles" `@!(wikipage "loadtiles")!@`)
(ww-add-page "protosigils" `@!(wikipage "protosigils")!@`)
(ww-add-page "protodiacritics" `@!(wikipage "protodiacritics")!@`)
(ww-add-page "radicals" `@!(wikipage "radicals")!@`)
(ww-add-page "sigils" `@!(wikipage "sigils")!@`)
(ww-add-page "runes" `@!(wikipage "runes")!@`)
(ww-add-page "layout" `@!(wikipage "layout")!@`)
(ww-add-page "simple_path" `@!(wikipage "simple_path")!@`)
(ww-add-page "tal" `@!(wikipage "tal")!@`)
(ww-add-page "path" `@!(wikipage "path")!@`)
(ww-add-page "morpheme" `@!(wikipage "morpheme")!@`)
(ww-add-page "seq" `@!(wikipage "seq")!@`)
(ww-add-page "gest" `@!(wikipage "gest")!@`)
(ww-add-page "sig" `@!(wikipage "sig")!@`)
(ww-add-page "logs" `#+TITLE: logs
@!(zet/messages "logs")!@`)
(ww-add-page "whistle" `@!(wikipage "whistle")!@`)
(ww-add-page "diagraf" `@!(wikipage "diagraf")!@`)
(ww-add-page "sigrunes" `@!(wikipage "sigrunes")!@`)
(ww-add-page "nrt" `@!(wikipage "nrt")!@`)
(ww-add-page "mseq" `@!(wikipage "mseq")!@`)
(ww-add-page "gestku" `@!(wikipage "gestku")!@`)
(ww-add-page "warble" `@!(wikipage "warble")!@`)
(ww-add-page "morpho" `@!(wikipage "morpho")!@`)
(ww-add-page "beginning" `In the beginning, there @!(ref "was")!@.
`)
(ww-add-page "was" `Because there was, there had to @!(ref "be")!@.
`)
(ww-add-page "be" `Since there had to be, there was @!(ref "necessity")!@.
`)
(ww-add-page "necessity" `Out of necessity was born the @!(ref "universe" "Universe")!@.
`)
(ww-add-page "universe" `When the Universe was young, an energy known as @!(ref
"inspiration")!@ flowed through it like a river.`)
(ww-add-page "inspiration" `These veins of inspiration shaped and molded all matter
in our Universe. Countless galaxies, stars, and planets were
formed from inspiration, amongst many, many, other things.

One of those things, was a celestial body known as @!(ref
"cavernius" "Cavernius")!@.
`)
(ww-add-page "cavernius" `Cavernius was a massive asteroid, with a hollow core that
formed a giant cave.

Cavernius was lonely. It was too quiet for them, and they
longed for company.

Fortunately, the @!(ref "universe" "Universe")!@ during this age was
abundant with @!(ref "inspiration" "Inspiration")!@.

Deep inside the Cave of Cavernius, Inspiration gathered. A
warmth began to form, which turned into a great heat.

A transformation was about to occur.

Fortified with Inspiration, The Caves of Cavernius filled
with a molten core. Cavernius was so overwhelmed by the
change, they wept tears of joy. And those tears formed
the @!(ref "springs" "Great Springs")!@, which is where
life began to grow.

It was at this point that Cavernius
became @!(ref "cauldronia" "Cauldronia")!@.
`)
(ww-add-page "springs" `The Great Springs are the birthplace of all life on @!(ref
"cauldronia" "Cauldronia")!@.

The Springs are warmed by the molten core of Cauldronia,
which is sometimes referred to as the @!(ref
"cauldron" "Cauldron")!@.
`)
(ww-add-page "cauldronia" `Cauldronia, sometimes known as @!(ref "cavernius"
"Cavernius")!@, is the native home planet of the Gestlings.`)
(ww-add-page "cauldron" `Welcome to the Cauldron.

@!(zet/page-amalg "cauldron")!@`)

# linked pages

(ww-add-link "index" "index.org")
(ww-add-link "weight" "weight/weight.org")
(ww-add-link "goblins" "goblins/goblins.org")
(ww-add-link "goblin_vocal_warmups" "goblins/vocal_warmups.org")
(ww-add-link "goblin_laughing" "goblins/laughing.org")
(ww-add-link "goblin_waking_up" "goblins/waking_up.org")
(ww-add-link "goblin_deciding" "goblins/deciding.org")
(ww-add-link "goblin_remembering" "goblins/remembering.org")
(ww-add-link "goblin_snoring" "goblins/snoring.org")
(ww-add-link "goblin_grumpy" "goblins/grumpy.org")

# sync and close

(ww-sync)
(ww-close)
