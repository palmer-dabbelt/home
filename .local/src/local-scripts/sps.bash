#!/bin/bash

swaylock &

(
  sleep 10s
  sudo pm-suspend
) &

wait
