#include <stdio.h>
#include <string.h>
#include "dataio.h"

int modify_credit(name, price)
    const char* name;
    int price;
{
    char filename[13];
    int i;
    int credit;
    FILE* person_data;

    strncpy(filename, name, 8);
    i = strlen(name);
    if (i > 8) i = 8;
    strcpy(&filename[i], ".txt");
    person_data = fopen(filename, "r");

    if (person_data == NULL) {
        printf("Warning: Filename %s does not exist!\n", filename);
        credit = 0;
    } else {
        fscanf(person_data, "%i", &credit);
        fclose(person_data);
    }

    // Write only if the price would change credit
    if (price != 0) {
        credit += price;
        person_data = fopen(filename, "w");
        if (person_data == NULL) {
            printf("ERROR: Filename %s could not be created or overwritten!\nCheck system integrity!\n", filename);
        } else {
            fprintf(person_data, "%i", credit);
            fclose(person_data);
        }
    }

    return credit;
}

