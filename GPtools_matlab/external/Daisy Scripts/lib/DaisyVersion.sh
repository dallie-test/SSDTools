#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"

wget -q -O - "${BaseURL}/index.php?url=about.tpl&username=${Username}&password=${Password}" |
sed -n "s/.*version *\(.*\)<\/b>.*/\1/p"

# filter met sed tekst tussen 'version' (met daarna eventueel spaties) en '</b>'
# -n en de 'p' zorgen ervoor dat alleen de match wordt geprint, overige regels dus niet.