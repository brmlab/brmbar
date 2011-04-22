#include <stdio.h>
#include <string.h>

#define EAN_MAXLEN 32
#define NAME_MAXLEN 128
#define PERSON_MAXLEN 16
#define ITEMS_MAXCOUNT 128
#define PEOPLE_MAXCOUNT 128
#define BUFSIZE 128

struct item {
    char ean[EAN_MAXLEN];
    char name[NAME_MAXLEN];
    int price;
};

struct item items[ITEMS_MAXCOUNT];
char people[PEOPLE_MAXCOUNT][PERSON_MAXLEN];

int items_count;
int people_count;

char buf[BUFSIZE];

void fill_items()
{
    FILE *f = fopen("items.txt", "r");

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
                begin = i + 1;
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

void fill_people()
{
    FILE *f = fopen("people.txt", "r");
    people_count = 0;
    while (fgets(people[people_count], PERSON_MAXLEN , f)) {
        char *c = strchr(people[people_count], '\n');
        if (c) *c = 0;
        people[people_count][PERSON_MAXLEN-1] = 0;
        ++people_count;
    }
    fclose(f);
}

int read_item() {
    int i;
    for (;;) {
        printf("i> ");
        if (fgets(buf, BUFSIZE, stdin)) {
            for (i = 0; i < items_count; ++i) {
                if (!strncmp( buf, items[i].ean, strlen(items[i].ean) )) {
                    if (items[i].price) {
                        printf("Item: %s (%d Kc)\n\n", items[i].name, items[i].price);
                    } else {
                        printf("Item: %s\n\n", items[i].name);
                    }
                    return i;
                }
            }
            printf("Unknown item: %s\n", buf);
        }
    }
}

int read_person() {
    int i;
    for (;;) {
        printf("p> ");
        if (fgets(buf, BUFSIZE, stdin)) {
            for (i = 0; i < people_count; ++i) {
                if (!strncmp( buf, people[i], strlen(people[i]) )) {
                    printf("Person: %s\n\n", people[i]);
                    return i;
                }
            }
            printf("Unknown person %s\n", buf);
        }
    }
}


void do_action(i, p) int i; int p; {
// TODO: perform action - person P selected item I
    if (!strcmp("BACK", people[p])) {
        printf("Going back ...\n\n");
        return;
    }
}


int main()
{
    int i, p;
    fill_items();
    fill_people();
    for (;;) {
        i = read_item();
        p = read_person();
        do_action(i, p);
    }
    return 0;
}
