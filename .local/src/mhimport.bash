#!/bin/bash

b4 mbox --pipe-each-message `which mhng-pipe-fetch_stdin` "$@"
