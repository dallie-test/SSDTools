#!/bin/bash
# Download Daisy data: resutaten van de module 'Runway'
#
#--------------------------------------------------------------------------------
# Getest door EdG 20121206
#--------------------------------------------------------------------------------
BaseURL="$1"     # url van Daisy
Username="$2"    # username
Password="$3"    # wachtwoord
Scenario="$4"    # scenario id
Year="$5"        # jaren in de vorm: 1971-2011
OutDir="$6"      # directory voor de uitvoer
# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

Phases=$(DaisyPhases.sh "$BaseURL" "$Username" "$Password" "$Scenario")
for Phase in $Phases; do
	PhaseTitle=$(DaisyPhaseTitle.sh "$BaseURL" "$Username" "$Password" "$Phase")
	FileName="${PhaseTitle}.txt"
	echo "Date,Time,Period,Runways,Visibility,Daylight,WindDir,WindSpeed,Gust,Capacities" > "${FileName}"
	
	echo "Uitvoer naar: ${PhaseTitle}"
	
	#TODO: maak gebruik van de opgegeven jaren
	#YearList=$(YearList.sh "$Year")
	
	#TODO: de tussenstap met invoerbestanden aanmaken integreren
	#      zie SeasonDays.sh
	cat "dates_${PhaseTitle}.txt" | while read Date
	do
		echo ${Date}
		wget -q -O - "${BaseURL}/index.php?url=cr-conditions.tpl&p[module]=${Module}&p[phase]=${Phase}&_date=${Date}&username=${Username}&password=${Password}" |
			sed "s/day'/\n/g" | sed 's/</>/g' | cut -d'>' -f'2 6 10 14 18 22 26 30 34 38' | sed 's/>/,/g' | tail -n72 >> "${FileName}"
	done
done


