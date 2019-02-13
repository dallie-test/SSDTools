#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Phase="$4"
Runway="$5"

wget -q -O - "${BaseURL}/index.php?url=compassrose/settings.tpl&p[module]=${Runway}&p[phase]=${Phase}&username=${Username}&password=${Password}" |
  sed -n "/.*periodstable/ s/.*\[_id\]=\([0-9][0-9]*\).>view<.*/\1/p"

# zoek naar het getal tussen [_id]=  en '>view<