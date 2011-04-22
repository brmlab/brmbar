#include "gfx.h"

void init_graphics() {
#asm
    mov al, #0x13
    mov ah, #0x0
    int 0x10
#endasm
}

void put_pixel(x, y, color)
    int x;
    int y;
    char color;
{
    x = x + y*320;
#asm
    mov ax, #0xa000
    mov es, ax
    mov al, _put_pixel.color[bp]
    mov di, _put_pixel.x[bp]
    seg es
    mov [di], al
#endasm

}

void deinit_graphics() {
#asm
    mov al, #0x12
    mov ah, #0x0
    int 0x10
#endasm
}

