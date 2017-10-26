NSD_OBJ=nd.o nsd.o nsd_main.o
MY_OOBJ=forkpipe.o
CC=gcc
CFLAGS=-g -Wall -Iinclude

bin: nsd forkpipe


start: bin
	./forkpipe


nsd: $(NSD_OBJ)
	$(CC) -o $@ $(NSD_OBJ)


forkpipe: $(MY_OOBJ)
	$(CC) -o $@ $(MY_OOBJ)


%.o: %.c
	$(CC) -o $@ -c $(CFLAGS) $<


nsd.o: nsd.c nsd.h
	$(CC) -o $@ -c $(CFLAGS) $<


nd.o: nd.c nd.h
	$(CC) -o $@ -c $(CFLAGS) $<


clean:
	rm -f $(NSD_OBJ)
	rm -f $(MY_OOBJ)
	rm -f nsd forkpipe


zip: bin
	make clean
	tar czf hw04.tgz Makefile *.c *.h
