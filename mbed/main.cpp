#include "mbed.h"
#include "EthernetNetIf.h"
#include "KS0108.h"
#include "SystemFont5x7.h"
#include "PS2Keyboard.h"
#include "request.h"

KS0108 display (p18,p20, p22, p21, p19, p17, p23, p24, p25, p26, p27, p28, p29, p30);
EthernetNetIf eth;
Serial pc(USBTX, USBRX);
PS2Keyboard kbd;

int main() {

    display.ClearScreen();
    display.SelectFont(System5x7, BLACK, ReadData);
    display.PutString(0, 0, "BrmBar");

    eth.setup();
    display.PutString(0, 35, "online");

    int i = 0;
    unsigned char symbol;
    static char code[17] = "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";
    static char response[128];

    while (1) {

	symbol = kbd.read();
	if (symbol == 0xE0 || symbol == 0xF0) {
	    symbol = kbd.read();
	    if (symbol == 0xF0) {
		symbol = kbd.read();
	    }
	    continue;
	}

	if ( i < 16 && ( (symbol >= 'A' && symbol <= 'Z') || (symbol >= '0' && symbol <= '9') ) ) {
	    code[i++] = symbol;
	    code[i] = 0;
	    display.PutString(7, 0, code);
	} else if (symbol == '!') {
	    switch (code[0]) {
		case 'U':       // user
		    if (request(code, response)) {
			display.PutString(2, 0, response);
		    }
		    break;
		case 'C':       // credit
		    if (request(code, response)) {
			display.PutString(4, 0, response);
		    }
		    break;
		case 'R':       // reset
		    if (request(code, response)) {
			display.PutString(4, 0, response);
		    }
		    break;
		default:        // item
		    if (request(code, response)) {
			display.PutString(4, 0, response);
		    }
		    break;
	    }
	    code[0] = 0;
	    i = 0;
	    display.PutString(7, 0, "                ");
	}

    }
}

