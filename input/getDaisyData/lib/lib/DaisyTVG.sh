#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Scenario="$4"
Module="$5"
Scale="$6"

wget -q -O - "${BaseURL}/index.php?url=tvg-overview.tpl&username=${Username}&password=${Password}&p[scenario]=${Scenario}&p[module]=${Module}&p[factor]=*${Scale}" |
sed -n 's/.*>\([0-9.]*\) dB(A).*/\1/p'

# De TVG-waarde is het getal voor ' dB(A)', in de vorm 99.99 dB(A)