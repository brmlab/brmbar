#include "PS2Keyboard.h"

PS2Keyboard::PS2Keyboard() : _ps2clk(p12), _ps2din(p11) { }

unsigned char PS2Keyboard::read(void) {
    unsigned int buf = 0x00;
    _ps2clk = 0;
    _ps2clk.input();
    for (int i = 0; i < 11; i++) {
	while (_ps2clk);
	while (!_ps2clk);
	buf = buf >> 1;
	buf |= _ps2din ? 512 : 0;
    }
    _ps2clk.output();
    buf &= 0xFF;
    return ps2KeyMap[buf];
}
