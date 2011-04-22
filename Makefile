CC=bcc
CFLAGS=-Md -W -O

all: brmbar.c
#	gcc -Wall brmbar.c dataio.c -o brmbar
	bcc $(CFLAGS) brmbar.c dataio.c gfx.c -o brmbar.com

clean:
	rm -f brmbar.com brmbar barcodes.svg

dos:
	dosbox brmbar.com
