#!/bin/bash

echo "Press ENTER to refresh gcert"
read
gcert || (echo "Error, press ENTER to continue" && read)
