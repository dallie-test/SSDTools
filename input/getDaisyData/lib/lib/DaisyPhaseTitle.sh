#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Phase="$4"

wget -q -O - "${BaseURL}/index.php?url=phase-settings.tpl&p[_id]=${Phase}&username=${Username}&password=${Password}" |
sed -e 's/<\/tr>/\n/g' |
sed -n '/Title:/ s/^.*value="\([^"]*\).*/\1/p'

# 1) splits de HTML-table, regeleinde </tr>
# 2) zoek op de regel met de tekst "Title:" naar de tekst tussen dubbele quotes achter 'value='
