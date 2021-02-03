#!/bin/bash

set -x
curl 'http://192.168.2.7/set?code=M563 S5'
google-chrome http://192.168.2.7 &
