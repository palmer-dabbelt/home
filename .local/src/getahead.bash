#!/bin/bash

mhng-pipe-scan inbox | grep "Change in aosp/common" | cut -d' ' -f1 | xargs mhng-pipe-rmm inbox
mhng-pipe-scan inbox | grep "New Subscriber To" | cut -d' ' -f1 | xargs mhng-pipe-rmm inbox
mhng-pipe-scan inbox | grep "Subscription Approval Needed" | cut -d' ' -f1 | xargs mhng-pipe-rmm inbox
mhng-pipe-scan linux | cut -d' ' -f1 | xargs mhng-pipe-rmm linux
mhng-pipe-scan lists | cut -d' ' -f1 | xargs mhng-pipe-rmm lists
mhng-pipe-scan upstream | cut -d' ' -f1 | xargs mhng-pipe-rmm upstream
mhng-pipe-scan berkeley | cut -d' ' -f1 | xargs mhng-pipe-rmm berkeley
