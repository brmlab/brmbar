#include <stdio.h>

void read_items()
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
    read_items();
    return 0;
}
