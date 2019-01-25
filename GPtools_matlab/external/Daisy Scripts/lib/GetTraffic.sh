#!/bin/bash
# Download Daisy traffic als XLS
#
#--------------------------------------------------------------------------------
# Getest door EdG 20121205
#--------------------------------------------------------------------------------
BaseURL="$1"     # url van Daisy
Username="$2"    # username
Password="$3"    # wachtwoord
Scenario="$4"    # scenario id
Years="$5"       # jaren in de vorm: 1971-2011
Group="$6"       # selectie van uit te voeren velden (zie onder aan deze file)
Agregation="$7"  # bepaalt de uitvoer: voor een heel jaar (total) of per fase (phases of phasefile)
OutDir="$8"      # directory voor de uitvoer
FileFlag="$9"    # tekst die wordt toegevoegd aan de standaard filenaam van de xls
# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

# print header naar het scherm
printf      "\n\n           traffic                                                      meteo\n"
printf "\e[01;30m           ----------------------------------------------------- ------------\e[00m\n"

# Maak groupby url
Gtxt=""
for G in $Group; do
	Gtxt=${Gtxt}"&p[groupby][]=${G}"
done

# Uitvoer van alle fases of alleen een jaartotaal?
case "$Agregation" in
"phases" )	
	Phases=$(DaisyPhases.sh "$BaseURL" "$Username" "$Password" "$Scenario")
	for Phase in $Phases; do
		PhaseTitle=$(DaisyPhaseTitle.sh "$BaseURL" "$Username" "$Password" "$Phase")
		FileName="traffic ${PhaseTitle}${FileFlag}.xls"
    	printf "           %-54s%12s\n" "${FileName}" "${Years}"
		wget -q -O - "${BaseURL}/index.php?url=export-traffic.tpl&username=${Username}&password=${Password}&p[scenario]=${Scenario}&p[phase]=${Phase}&p[myear]=${Years}${Gtxt}" > "${OutDir}/${FileName}"
	done
	;;
"phasefile" )
	# TODO: Bestaat het bestand wel?
	while read FromDate ToDate EnDeRestNiet #Negeer alles na de tweede variabele
	do	
		# Filter op lege regels en commentaar
		case $FromDate in ''|\#*) continue;; esac

		DateRangeText="${FromDate//-/}-${ToDate//-/}"
		FileName="traffic ${Years} ${DateRangeText}${FileFlag}.xls"
		printf "           %-54s%12s\n" "${FileName}" "${Years}"
		wget -q -O - "${BaseURL}/index.php?url=export-traffic.tpl&username=${Username}&password=${Password}&p[scenario]=${Scenario}&p[myear]=${Years}${Gtxt}&p[begin]=${FromDate}&p[end]=${ToDate}" > "${OutDir}/${FileName}"
	done < "${Username}_phases.txt"
	
	# Kopieer de file met de definitie van de fases	
	cp "${Username}_phases.txt" "$OutDir"
	;;
"total" )	
	FileName="traffic ${Years}${FileFlag}.xls"
	printf "           %-54s%12s\n" "${FileName}" "${Years}"
	wget -q -O - "${BaseURL}/index.php?url=export-traffic.tpl&username=${Username}&password=${Password}&p[scenario]=${Scenario}&p[myear]=${Years}${Gtxt}" > "${OutDir}/${FileName}"
esac

printf "\e[01;30m           ----------------------------------------------------- ------------\e[00m\n"
