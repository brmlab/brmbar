CC=bcc
CFLAGS=-Md

brmbar.com: brmbar.c
	$(CC) $(CFLAGS) brmbar.c -o brmbar.com

clean:
	rm -f brmbar.com

run:
	dosbox brmbar.com
