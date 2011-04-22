CC=bcc
CFLAGS=-Md -W

all: brmbar.c defines.h
	gcc -Wall brmbar.c -o brmbar
	bcc -Md -W brmbar.c -o brmbar.com

clean:
	rm -f brmbar.com brmbar

dos:
	dosbox brmbar.com
