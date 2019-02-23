#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Scenario="$4"

wget -q -O - "${BaseURL}/index.php?url=scenario-settings.tpl&p[_id]=${Scenario}&username=${Username}&password=${Password}" |
sed -n '/Title:/ s/^.*value="\([^"]*\).*/\1/p'

# Zoek op de regel met de tekst "Title:" naar de tekst tussen dubbele quotes achter 'value='