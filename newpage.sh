if [ "$#" -lt 1 ]
then
    echo "Usage: $0 page_name"
    exit 1
fi

PGNAME=$1


weewiki add $PGNAME
weewiki set $PGNAME "@!(wikipage \"$PGNAME\")!@"
