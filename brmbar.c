#include <stdio.h>
#include <string.h>
#include "defines.h"

struct item {
    char ean[EAN_MAXLEN];
    char name[NAME_MAXLEN];
    int price;
} items[ITEM_MAXNUM];

char *people[PERSON_MAXLEN];

int items_count;
int people_count;

void fill_items()
{
    char buf[128];
    FILE *f = fopen("items.txt", "r");
    while (fgets(buf, 128, f)) {
        printf("%s\n", buf);
    }
    fclose(f);
}

void fill_people()
{
    FILE *f = fopen("people.txt", "r");
    people_count = 0;
    while (fgets(people[people_count], PERSON_MAXLEN , f)) {
        ++people_count;
    }
    fclose(f);
}

int read_item() {
    char buf[128];
    int i;
    for (;;) {
        printf("i> ");
        if (fgets(buf, 128, stdin)) {
            for (i = 0; i < items_count; ++i) {
                if (!strncmp( buf, items[i].ean, strlen(items[i].ean) )) {
                    return i;
                }
            }
            printf("Unknown item %s\n", buf);
        }
    }
}

int read_person() {
    char buf[128];
    int i;
    for (;;) {
        printf("p> ");
        if (fgets(buf, 128, stdin)) {
            for (i = 0; i < people_count; ++i) {
                if (!strncmp( buf, people[0], strlen(people[0]) )) {
                    return i;
                }
            }
            printf("Unknown person %s\n", buf);
        }
    }
}

int main()
{
    int i, p;
    fill_items();
    for (;;) {
        i = read_item();
        p = read_person();
    }
    return 0;
}
