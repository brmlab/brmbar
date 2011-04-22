#include <stdio.h>
#include "itemio.h"

struct item items[ITEM_MAXNUM];

void fill_items()
{
    char buf[128];
    FILE *f = fopen("items.txt", "r");
    while (fgets(buf, 128, f)) {
        printf("%s\n", buf);
    }
    fclose(f);
}

