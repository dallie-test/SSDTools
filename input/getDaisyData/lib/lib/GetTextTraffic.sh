#!/bin/bash
# Download Daisy traffic als tekstbestand
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
FileFlag="$9"    # tekst die wordt toegevoegd aan de traffic filenaam
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
		FileName="traffic ${PhaseTitle}${FileFlag}.txt"
    	printf "           %-54s%12s\n" "${FileName}" "${Years}"
		wget -q -O - "${BaseURL}/index.php?url=export-text-traffic.tpl&username=${Username}&password=${Password}&p[scenario]=${Scenario}&p[phase]=${Phase}&p[myear]=${Years}${Gtxt}" > "${OutDir}/${FileName}"
	done
	;;
"phasefile" )
	ScenarioTitle=$(DaisyScenarioTitle.sh "$BaseURL" "$Username" "$Password" "$Scenario")
	if [ -a "${ScenarioTitle}_phases.txt" ]; then
		phasefile="${ScenarioTitle}_phases.txt"
	else
		# TODO: Bestaat het bestand wel?
        phasefile="${Username}_phases.txt"
	fi
	printf "           phasefile: %-54s\n\n" "${phasefile}"
	
	while read FromDate ToDate EnDeRestNiet #Negeer alles na de tweede variabele
	do	
		# Filter op lege regels en commentaar
		case $FromDate in ''|\#*) continue;; esac

		DateRangeText="${FromDate//-/}-${ToDate//-/}"
		FileName="traffic ${Years} ${DateRangeText}${FileFlag}.txt"
		printf "           %-54s%12s\n" "${FileName}" "${Years}"
		wget -q -O - "${BaseURL}/index.php?url=export-text-traffic.tpl&username=${Username}&password=${Password}&p[scenario]=${Scenario}&p[myear]=${Years}${Gtxt}&p[begin]=${FromDate}&p[end]=${ToDate}" > "${OutDir}/${FileName}"
	done < "${phasefile}"
	
	# Kopieer de file met de definitie van de fases	
	cp "${phasefile}" "$OutDir"
	;;
"total" )	
	FileName="traffic ${Years}${FileFlag}.txt"
	printf "           %-54s%12s\n" "${FileName}" "${Years}"
	wget -q -O - "${BaseURL}/index.php?url=export-text-traffic.tpl&username=${Username}&password=${Password}&p[scenario]=${Scenario}&p[myear]=${Years}${Gtxt}" > "${OutDir}/${FileName}"
esac

printf "\e[01;30m           ----------------------------------------------------- ------------\e[00m\n"
