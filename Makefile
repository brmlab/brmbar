CC=bcc
CFLAGS=-Md -W
LDFLAGS=-Md -W

brmbar.com: brmbar.o itemio.o
	$(CC) $(LDFLAGS) brmbar.o itemio.o -o brmbar.com

brmbar.o: brmbar.c defines.h itemio.h
	$(CC) $(CFLAGS) brmbar.c -c -o brmbar.o

itemio.o: itemio.c defines.h itemio.h
	$(CC) $(CFLAGS) itemio.c -c -o itemio.o

clean:
	rm -f brmbar.com
	rm -f *.o

run:
	dosbox brmbar.com
