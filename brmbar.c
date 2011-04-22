#include <stdio.h>
#include "defines.h"

struct item {
    char ean[EAN_MAXLEN];
    char name[NAME_MAXLEN];
    int price;
} items[ITEM_MAXNUM];

int items_count;

void fill_items()
{
    char buf[128];
    FILE *f = fopen("items.txt", "r");
    while (fgets(buf, 128, f)) {
        printf("%s\n", buf);
   }
    fclose(f);
}

int read_item() {
    char buf[128];
    int i;
    for (;;) {
        printf("i> ");
        if (fgets(buf, 128, stdin)) {
            for (i = 0; ; ++i) {
                if (!strncmp( buf, items[0].ean, strlen(items[0].ean) )) {
                    return i;
                }
            }
            printf("Unknown item %s\n", buf);
        }
    }
}

int read_action() {
    return 0;
}

int main()
{
    int i, a;
    fill_items();
    for (;;) {
        i = read_item();
        a = read_action();
    }
    return 0;
}

