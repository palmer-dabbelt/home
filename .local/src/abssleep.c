/* Copyright 2019 Palmer Dabbelt <palmerdabbelt@google.com> */
/* SPDX-License-Identifier: Apache-2.0 OR GPL-2.0+ OR BSD-3-Clause */

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char **argv)
{
    struct timespec amount;
    if (clock_gettime(CLOCK_REALTIME, &amount) != 0) {
	perror("clock_gettime(CLOCK_REALTIME) failed");
        return 1;
    }

    time_t offset = atoi(argv[1]);
    if (offset <= 0) {
        perror("atoi(argv[1]) failed");
        return 1;
    }
    amount.tv_sec += atoi(argv[1]);

    while (clock_nanosleep(CLOCK_REALTIME, TIMER_ABSTIME, &amount, &amount) != 0) {
        fprintf(stderr, "clock_nanosleep() returned early\n");
    }

    return 0;
}
