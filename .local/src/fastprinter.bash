#!/bin/bash

set -x
browser -- 'http://192.168.3.1/set?code=M563%20S5'
browser -- http://192.168.3.1 &
