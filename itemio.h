#ifndef _BRMBAR_ITEMIO_H_
#define _BRMBAR_ITEMIO_H_

#include "defines.h"

struct item {
    char ean[EAN_MAXLEN];
    char name[NAME_MAXLEN];
    int price;
};

extern struct item items[ITEM_MAXNUM];

extern void fill_items();

#endif

