#!/bin/bash
# ----------------------------------------
years="2001-2010"
# ----------------------------------------
knmiFile="uurgeg_240_${years}"
result="knmi_${years}.txt"

unzip "${knmiFile}.zip"

tail -n +32 "${knmiFile}.txt" |
sed -e '/1/ s/#//g' |
sed -e '/^$/d' |
sed -e 's/,/\t/g' |
sed -e 's/ //g' > "${result}"
