runtest () {
    mnolth lua test/t/$1.lua

    if [ ! "$?" -eq 0 ]
    then
        printf "fail"
        return
    fi
    printf "ok"
}

MAX_SPACES=40
check () {
    NSPACES=$(expr $MAX_SPACES - ${#1})
    printf "%s:%"$NSPACES"s\n" $1 $(runtest $1)
}

check warble1
check warble2
check warble3
check whistle_antiphon
