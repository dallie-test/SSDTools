#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Folder="$4"

wget -q -O - "${BaseURL}/index.php?url=folder-list.tpl&username=${Username}&password=${Password}" |
sed -e "s/<\/tr>/\n/g" |
sed -n "/folder-settings/ s/.*&p\[_id\]=\([0-9][0-9]*\).*/\1/p" 

# Zoek op de regel met de tekst "scenario-settings" naar het getal achter "&p[_id]=