#!/bin/bash
# Download HG; lees de waarde en schrijf deze weg in een tekstbestand: 'DaisyNoiseTitle'.txt
#
#
#--------------------------------------------------------------------------------
# Getest door EdG 20121203
#--------------------------------------------------------------------------------
BaseURL="$1"     # url van Daisy
Username="$2"    # username
Password="$3"    # wachtwoord
Scenario="$4"    # scenario id
OutDir="$5"      # directory voor de uitvoer

Scale=1.000 # Geen schaling toepassen, doe dit bij voorkeur in Matlab bij de verdere verwerking
# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

# print header naar het scherm
printf      "\n\n           HG                                 current         id        dB(A)\n"
printf "\e[01;30m           ---------------------------------- ------- ---------- ------------\e[00m\n"

# verkrijg modules (noises)
Modules=$(DaisyModules.sh "$BaseURL" "$Username" "$Password" "$Scenario")
for M in $Modules; do
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
	# Eenheid Lden, Lnight of HG. Voor HG geen grid ophalen
	DaisyNoiseUnit=$(DaisyNoiseUnit.sh "$BaseURL" "$Username" "$Password" "$M")
	if [ $DaisyNoiseUnit = "HG" ] 
	then
		echo "warning: HG hard coded based on selection of meteo years"
		# Verkrijg module name
		DaisyNoiseTitle=$(DaisyNoiseTitle.sh "$BaseURL" "$Username" "$Password" "$M")

		HG=$(DaisyHG.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$M" "$Scale" "DEN")
		printf "           %-40s${StatusCol}%-2s\e[00m %10s %12s\n" "${DaisyNoiseTitle} DEN" "${StatusTxt}" "${M}" "${HG}"
		echo "${HG}" > "${OutDir}/${DaisyNoiseTitle}_HG_DEN.txt"
		
		HG_NIGHT=$(DaisyHG.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$M" "$Scale" "N")
		printf "           %-40s${StatusCol}%-2s\e[00m %10s %12s\n" "${DaisyNoiseTitle} NIGHT" "${StatusTxt}" "${M}" "${HG_NIGHT}"
		echo "${HG_NIGHT}" > "${OutDir}/${DaisyNoiseTitle}_HG_NIGHT.txt"
	fi
done

printf "\e[01;30m           ---------------------------------- ------- ---------- ------------\e[00m\n"
