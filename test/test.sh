runtest () {
    ./cantor test/t/$1.lua

    if [ ! "$?" -eq 0 ]
    then
        printf "fail"
        return
    fi
    printf "ok"
}

MAX_SPACES=41
NERR=0
check () {
    NSPACES=$(expr $MAX_SPACES - ${#1})
    STATUS=$(runtest $1)
    printf "%s:%"$NSPACES"s\n" $1 $STATUS

    if [ $STATUS == "fail" ]
    then
        NERR=$(echo "$NERR + 1" | bc)
    fi
}

check warble1
check warble2
check warble3
check whistle_antiphon
check paging_dr_distant
check excuse_me
check up_there
check internal_malfunction
check robogigue
check regina
check inquisitive_bird
check init
check goblin_nap
check goblin_deciding
check grumpy_goblin
check singing_goblin
check snoring_goblin
check shapes_and_voices
check nrt_duo
check morpheme_minimal
check path_grammar
check path_synth
check AST_to_data
check morpheme_grammar
check morpheme_symtest
check seq_symtest
check seq_grammar
check append_symbols
check seq_sound
check diagraf_intermediate
check blipsqueak_hello
check path_symbol_lookup
check shapemorf_tubesculpt
check descript_parser
check test_gestleton_map

if [ "$NERR" -gt 0 ]
then
    if [ "$NERR" -eq 1 ]
    then
        echo "Tests returned 1 error"
    else
        echo "Tests returned $NERR errors"
    fi
    exit 1
fi

echo "All tests pass successfully"
