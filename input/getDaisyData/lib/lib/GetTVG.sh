#!/bin/bash
# Download TVG; lees de waarde en schrijf deze weg in een tekstbestand: 'DaisyNoiseTitle'.txt
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
printf      "\n\n           TVG                                current         id        dB(A)\n"
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
	# Eenheid Lden, Lnight of TVG. Voor TVG geen grid ophalen
	DaisyNoiseUnit=$(DaisyNoiseUnit.sh "$BaseURL" "$Username" "$Password" "$M")
	if [ $DaisyNoiseUnit = "TVG" ] 
	then
		# Verkrijg module name
		DaisyNoiseTitle=$(DaisyNoiseTitle.sh "$BaseURL" "$Username" "$Password" "$M")

		TVG=$(DaisyTVG.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$M" "$Scale")
		printf "           %-40s${StatusCol}%-2s\e[00m %10s %12s\n" "${DaisyNoiseTitle}" "${StatusTxt}" "${M}" "${TVG}"
		
		# Output naar een bestand
		echo "${TVG}" > "${OutDir}/${DaisyNoiseTitle}.txt"
	fi
done

printf "\e[01;30m           ---------------------------------- ------- ---------- ------------\e[00m\n"
