#ifndef __PS2KEYBOARD_H__
#define __PS2KEYBOARD_H__

#include "mbed.h"

class PS2Keyboard  {
    public:
	PS2Keyboard();
	unsigned char read(void);
    protected:
	DigitalInOut _ps2clk;
	DigitalIn _ps2din;
};

static const unsigned char ps2KeyMap[] =
"              ` "  // 0
"     Q1   ZSAW2 "  // 1
" CXDE43   VFTR5 "  // 2
" NBHGY6   MJU78 "  // 3
" ,KIO09  ./L;P- "  // 4
"  \' [=    !] \\  "  // 5
"         1 47  1"  // 6
"0.2568   +3-*9  "  // 7
"                "  // 8
"                "  // 9
"                "  // A
"                "  // B
"                "  // C
"                "  // D
"\xE0               "  // E
"\xF0               "  // F
;

#endif
