#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Scenario="$4"

# grab first phase
FirstPhase=$(DaisyPhases.sh "$BaseURL" "$Username" "$Password" "$Scenario" | head -n1)

# verkrijg modules per fase
wget -q -O - "${BaseURL}/index.php?url=phase-settings.tpl&p[_id]=${FirstPhase}&username=${Username}&password=${Password}" |
sed -n "/Noise:/,$ s/<option value='\([0-9]*\)' selected>.*/\1/p"

# zoek naar het getal tussen enkele quotes in <option value='123456789' selected> van Noise: tot aan het einde van de file