#!/bin/bash

echo "Press ENTER to refresh gcert"
echo "Be sure to remove your yubikey!"
read
gcert || (echo "Error, press ENTER to continue" && read)
ssh palmerdabbelt.mtv.corp.google.com -t 'bash -l -c prodaccess'
