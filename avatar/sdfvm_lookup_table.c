#include <stdio.h>
#include <stdint.h>
#include "mathc/mathc.h"
#include "sdf2d/sdf.h"
#include "sdf2d/sdfvm.h"

int main(int argc, char *argv[])
{
    FILE *fp;
    fp = fopen("sdfvm_lookup_table.json", "w");
    sdfvm_print_lookup_table(fp);
    fclose(fp);
    return 0;
}
