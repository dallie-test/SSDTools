#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Scenario="$4"
Module="$5"

# grab first phase
FirstPhase=$(DaisyPhases.sh "$BaseURL" "$Username" "$Password" "$Scenario" | head -n1)

wget -q -O - "${BaseURL}/index.php?url=noise/settings.tpl&p[module]=${Module}&p[phase]=${FirstPhase}&username=${Username}&password=${Password}" |
sed -e 's/<br>/\n/g' |
sed -e 's/<\/tr>/\n/g' |
sed -e 's/<[^>]*>//g' |
sed -n 's/^Status://p'

# 1) splits de HTML-table, regeleinde </tr> en <br>
# 2) verwijder HTML-tags <...>
# 3) de status van de noise is de tekst na Status:
