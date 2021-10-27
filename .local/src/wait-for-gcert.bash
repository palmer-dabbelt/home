#!/bin/bash

echo "Press ENTER to refresh gcert"
echo "Be sure to remove your yubikey!"
read
gcert || (echo "Error, press ENTER to continue" && read)
ssh palmerdabbelt0.mtv.corp.google.com -A -t 'bash -l -c gcert'
ssh palmerdabbelt0.c.googlers.com -A -t 'bash -l -c gcert'
