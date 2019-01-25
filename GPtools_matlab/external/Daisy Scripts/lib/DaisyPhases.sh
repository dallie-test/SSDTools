#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Scenario="$4"

wget -q -O - "${BaseURL}/index.php?url=scenario-settings.tpl&p[_id]=${Scenario}&username=${Username}&password=${Password}" |
sed -n "s/.*phase-settings.tpl&p\[_id\]=\([0-9]*\).*/\1/p"

# zoek naar het getal achter: 'phase-settings.tpl&p[_id]='