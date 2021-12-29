#!/bin/bash

set -x
curl 'http://192.168.3.1/set%3Fcode=M563%20S5'
browser -- http://192.168.3.1 &
