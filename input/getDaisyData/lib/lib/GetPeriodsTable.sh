#!/bin/bash
# Download Periods table per fase als XLS
#
#--------------------------------------------------------------------------------
# Getest door EdG 20121205
#--------------------------------------------------------------------------------
BaseURL="$1"     # url van Daisy
Username="$2"    # username
Password="$3"    # wachtwoord
Scenario="$4"    # scenario id
OutDir="$5"      # directory voor de uitvoer
# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

# print header naar het scherm
printf      "\n\n           periods table\n"
printf "\e[01;30m           ------------------------------------------------------------------\e[00m\n"

# Uitvoer van alle fases of alleen een jaartotaal?
Phases=$(DaisyPhases.sh "$BaseURL" "$Username" "$Password" "$Scenario")
for Phase in $Phases; do
	PhaseTitle=$(DaisyPhaseTitle.sh "$BaseURL" "$Username" "$Password" "$Phase")
	FileName="periods ${PhaseTitle}.xls"
	
	Runway=$(DaisyRunway.sh  "$BaseURL" "$Username" "$Password" "$Phase") 
	PeriodsTable=$(DaisyPeriodsTable.sh  "$BaseURL" "$Username" "$Password" "$Phase" "$Runway")
	
	if [ -z ${PeriodsTable} ]; then
		printf "\e[01;31mfailed     %-54s%12s\n" "${FileName}"
		printf "\e[01;31m           --> OK if this an import traffic\e[00m\n" 
	else
		printf "           %-54s%12s\n" "${FileName}"
		wget -q -O - "${BaseURL}/index.php?url=extern/export-table.php&table=periodstable&_id=${PeriodsTable}&order[]=t_begin&username=${Username}&password=${Password}" > "${OutDir}/${FileName}"
	fi
done


printf "\e[01;30m           ----------------------------------------------------- ------------\e[00m\n"

# Runway
# http://daisy-1-8.frontier.nl/source/index.php?url=compassrose/settings.tpl&p[module]=1276314&p[phase]=1256353

# Periodstable
# http://daisy-1-8.frontier.nl/source/index.php?url=extern/export-table.php&table=periodstable&_id=1276449&order[]=t_begin
# http://daisy-1-8.frontier.nl/source/index.php?url=extern/export-table.php&table=periodstable&_id=1276450&order[]=t_begin