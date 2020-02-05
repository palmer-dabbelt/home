#include <stdio.h>
#include <stdlib.h>

int exitval = 1;

int gc(void) {
    int out = getchar();
    if (out == EOF)
        exit(exitval);
    return out;
}

int main(int argc, char **argv)
{
    for (size_t i = 0; i < 11; ++i)
        gc();

    for (size_t i = 0; i < 6; ++i)
        printf("%d", gc());
    printf("\n");

    return 0;
}
