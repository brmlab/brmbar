CC=bcc
CFLAGS=-Md -W

all: brmbar.c
#	gcc -Wall brmbar.c dataio.c -o brmbar
	bcc -Md -W brmbar.c dataio.c -o brmbar.com

clean:
	rm -f brmbar.com brmbar barcodes.svg

dos:
	dosbox brmbar.com
