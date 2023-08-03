CFLAGS="-g -I/usr/local/include/mnolth -O3 -std=c89 -Wall -pedantic"
gcc $CFLAGS mouthtests.c -o mouthtests -lmnolth
