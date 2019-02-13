#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Module="$4"

wget -q -O - "${BaseURL}/index.php?url=noise/settings.tpl&p[module]=${Module}&username=${Username}&password=${Password}" |
sed -n '/Title:/ s/^.*value="\([^"]*\).*/\1/p'

# Zoek op de regel met de tekst "Title:" naar de tekst tussen dubbele quotes achter 'value='