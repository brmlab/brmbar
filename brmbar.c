#include <stdio.h>

struct item {
    char *ean;
    char *name;
    int price;
} items[100];

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
