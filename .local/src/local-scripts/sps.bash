#!/bin/bash

slock &

(
  sleep 10s
  sudo pm-suspend
) &

wait
