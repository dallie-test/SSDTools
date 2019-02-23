#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Phase="$4"

wget -q -O - "${BaseURL}/index.php?url=phase-settings.tpl&p[_id]=${Phase}&username=${Username}&password=${Password}" |
  sed -n "/.*<select name=.compassrose/,/<\/select><\/td>/p" |
  sed -n "/.*selected/ s/<option value=.\([0-9][0-9]*\).*/\1/p"

# zoek naar het getal: <option value='123456789' selected>