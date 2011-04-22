CC=bcc
CFLAGS=-Md -W

all: brmbar.c
#	gcc brmbar.c dataio.c -o brmbar
	bcc -Md -W brmbar.c dataio.c -o brmbar.com

clean:
	rm -f brmbar.com brmbar

dos:
	dosbox brmbar.com
