#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Module="$4"

wget -q -O - "${BaseURL}/index.php?url=noise/settings.tpl&p[module]=${Module}&username=${Username}&password=${Password}" |
sed -e 's/<\/tr>/\n/g' |
sed -e 's/<[^>]*>//g' |
sed -n 's/^Name://p'

# 1) splits de HTML-table, regeleinde </tr>
# 2) verwijder HTML-tags <...>
# 3) de noise unit is de tekst na Name:
