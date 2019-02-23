#!/bin/bash
# Download EPPMY-file (dat-file)
#
#--------------------------------------------------------------------------------
# EdG 20151029: Eerste versie
#--------------------------------------------------------------------------------
BaseURL="$1"     # url van Daisy
Username="$2"    # username
Password="$3"    # wachtwoord
Scenario="$4"    # scenario id
Year="$5"        # jaren in de vorm: 1971-2011
Agregation="$6"  # bepaalt de uitvoer: voor een heel jaar (total) of per fase (phasefile)
OutDir="$7"      # directory voor de uitvoer

Scale=1.000      # Geen schaling toepassen, doe dit bij voorkeur in Matlab bij de verdere verwerking
# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

# Print header naar het scherm
printf      "\n\n           eppmy             phase            current         id        meteo\n"
printf "\e[01;30m           ----------------- ---------------- ------- ---------- ------------\e[00m\n"

# Verkrijg modules (noises)
Modules=$(DaisyModules.sh "$BaseURL" "$Username" "$Password" "$Scenario")
for M in $Modules
do
	# Check of de noise current is
	DaisyNoiseStatus=$(DaisyNoiseStatus.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$M")
	if [ "$DaisyNoiseStatus" = "Current" ] 
	then
		StatusTxt="ok"
		StatusCol="\e[01;32m"
	else
		StatusTxt="no"
		StatusCol="\e[01;31m"
	fi
	
	# Eenheid Lden, Lnight, TVG of HG. Voor TVG en HG geen eppmy ophalen
	DaisyNoiseUnit=$(DaisyNoiseUnit.sh "$BaseURL" "$Username" "$Password" "$M")
	if [ $DaisyNoiseUnit != "TVG" ] && [  $DaisyNoiseUnit != "HG" ] 
	then
		# Verkrijg module name
		DaisyNoiseTitle=$(DaisyNoiseTitle.sh "$BaseURL" "$Username" "$Password" "$M")
		printf "           %-40s${StatusCol}%-2s\e[00m %10s %12s\n" "${DaisyNoiseTitle}" "${StatusTxt}" "${M}" "${Year}"

		# Uitvoer van alle fases of alleen een jaartotaal?
		case "$Agregation" in
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
				printf "           %34s\n" "${DateRangeText}"
				FileName="${DaisyNoiseTitle} eppmy ${Year} ${DateRangeText}.dat"

				wget -q -O - "${BaseURL}/index.php?url=export-eppmy.tpl&username=${Username}&password=${Password}&p[module]=${M}&p[scenario]=${Scenario}&p[mm]=N&p[myear]=${Year}&p[factor]=*${Scale}&p[from_date]=${FromDate}&p[upto_date]=${ToDate}" > "${OutDir}/${FileName}"
			done < "${phasefile}"
			
			printf "\e[01;30m           ----------------- ---------------- ------- ---------- ------------\e[00m\n"
			
			# Kopieer de file met de definitie van de fases	
			cp "${phasefile}" "$OutDir"
			;;
		"total" )	
			FileName="${DaisyNoiseTitle} eppmy ${Year}.dat"
			wget -q -O - "${BaseURL}/index.php?url=export-eppmy.tpl&username=${Username}&password=${Password}&p[module]=${M}&p[scenario]=${Scenario}&p[mm]=N&p[myear]=${Year}&p[factor]=*${Scale}" > "${OutDir}/${FileName}"
			printf "\e[01;30m           ----------------- ---------------- ------- ---------- ------------\e[00m\n"
		esac
	fi
done

