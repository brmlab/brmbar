#include <stdio.h>
#include "defines.h"

struct item {
    char ean[EAN_MAXLEN];
    char name[NAME_MAXLEN];
    int price;
} items[ITEM_MAXNUM];

void fill_items()
{
    char buf[128];
    FILE *f = fopen("items.txt", "r");
    while (fgets(buf, 128, f)) {
        printf("%s\n", buf);
   }
    fclose(f);
}

int main()
{
    fill_items();
    return 0;
}

