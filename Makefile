CC=bcc
CFLAGS=-Md -W

all: brmbar.c
	gcc -Wall brmbar.c -o brmbar
	bcc -Md -W brmbar.c -o brmbar.com

clean:
	rm -f brmbar.com

dos:
	dosbox brmbar.com
