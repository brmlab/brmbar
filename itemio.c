#include <stdio.h>
#include <string.h>
#include "itemio.h"

struct item items[ITEM_MAXNUM];
int items_count;

void fill_items()
{
    //Add 32 characters for a safe margin
    #define BUFSIZE EAN_MAXLEN + NAME_MAXLEN + 32
    char buf[BUFSIZE];
    FILE *f = fopen("items.txt", "r");
    char c;

    items_count = 0;

    while (fgets(buf, BUFSIZE, f)) {
        int i = 0;
        int begin = 0;

        //Initialize the item
        items[items_count].ean[0] = 0;
        items[items_count].name[0] = 0;
        items[items_count].price = 0;

        //Read the item EAN
        while (i < BUFSIZE) {
            if (buf[i] == '\t') {
                buf[i] = 0;
                strcpy(items[items_count].ean, &buf[begin]);
                buf[i] = '\t';
                begin = i+1;
                break;
            }
            i++;
        }

        //Read the item name
        i = begin;
        while (i < BUFSIZE) {
            if (buf[i] == '\t') {
                buf[i] = 0;
                strcpy(items[items_count].name, &buf[begin]);
                buf[i] = '\t';
                begin = i+1;
                break;
            }
            i++;
        }

        //Use scanf to read the item price
        i = begin;
        if (i < BUFSIZE) {
            sscanf(&buf[i], "%d", &items[items_count].price);
        }

        items_count++;
    }
    fclose(f);
}

