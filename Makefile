CC=bcc
CFLAGS=-Md -W

brmbar.com: brmbar.c
	$(CC) $(CFLAGS) brmbar.c -o brmbar.com

clean:
	rm -f brmbar.com

run:
	dosbox brmbar.com
