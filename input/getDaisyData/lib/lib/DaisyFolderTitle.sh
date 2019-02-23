#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Folder="$4"

wget -q -O - "${BaseURL}/index.php?url=folder-settings.tpl&p[readOnly]=1&username=${Username}&password=${Password}&p[_id]=${Folder}"  |
sed -e "s/<\/tr>/\n/g" |
sed -n "/Title:/ s/.*>//p"

# Zoek op de regel met de tekst "Title:" naar de tekst achter de laatste > tot het einde van de regel