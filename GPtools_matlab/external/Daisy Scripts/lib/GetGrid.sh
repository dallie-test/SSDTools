#!/bin/bash
# Download Envira noise grid (dat-file)
#
#--------------------------------------------------------------------------------
# EdG 20121205: Eerste versie
# EdG 20121221: Check ingebouwd of de dat file in orde is.
#               Scenario's met een import traffic gaan vaak de eerste keer fout
#               Code opgeschoond
#--------------------------------------------------------------------------------
BaseURL="$1"     # url van Daisy
Username="$2"    # username
Password="$3"    # wachtwoord
Scenario="$4"    # scenario id
Year="$5"        # jaren in de vorm: 1971-2011
Output="$6"      # bepaalt de uitvoer: incl. meteotoeslag (mm) of niet (mean) of zonder meteotoeslag per meteojaar (years)
OutDir="$7"      # directory voor de uitvoer

Scale=1.000      # Geen schaling toepassen, doe dit bij voorkeur in Matlab bij de verdere verwerking
# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

# Print header naar het scherm
printf      "\n\n           noise grid                         current         id        meteo\n"
printf "\e[01;30m           ---------------------------------- ------- ---------- ------------\e[00m\n"

# Welke Output is gewenst?
case "$Output" in
"mm" )		
	MM="Y"
	MMtext="mm"
	Ytext=""
	YearList="$Year"
	;;
"mean" )
	MM="N"
	MMtext=""
	Ytext=""
	YearList="$Year"
	;;
"years" )
	MM="N"
	MMtext=""
	Ytext="y"
	YearList=$(YearList.sh "$Year")
	;;
esac

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
	
	# Eenheid Lden, Lnight of TVG. Voor TVG geen grid ophalen
	DaisyNoiseUnit=$(DaisyNoiseUnit.sh "$BaseURL" "$Username" "$Password" "$M")
	if [ $DaisyNoiseUnit != "TVG" ] && [  $DaisyNoiseUnit != "HG" ] 
	then
		# Verkrijg module name
		DaisyNoiseTitle=$(DaisyNoiseTitle.sh "$BaseURL" "$Username" "$Password" "$M")
		for Y in $YearList
		do
			printf "           %-40s${StatusCol}%-2s\e[00m %10s %12s\n" "${DaisyNoiseTitle}" "${StatusTxt}" "${M}" "${Y}${MMtext}"
			FileName="${DaisyNoiseTitle} ${Ytext}${Y}${MMtext}.dat"
			
			for i in {1..4} # Download het bestand desnoods nog een keer
			do
				wget -q -O - "${BaseURL}/index.php?url=export-envira.tpl&username=${Username}&password=${Password}&p[module]=${M}&p[scenario]=${Scenario}&p[mm]=${MM}&p[myear]=${Y}&p[factor]=*${Scale}" > "${OutDir}/${FileName}"

				# Is de dat file ok? Anders nog een keer proberen
				bash ValidGrid.sh "${OutDir}/${FileName}" "$DaisyNoiseUnit" 
				if [ $? != "0" ]; then
					echo "try again..."
				else				
					if [ $i -ge "2" ]; then # En is de dat file de tweede keer wel ok?
						echo "try ${i} was succesful"
					fi
					break
				fi
			done
		done
	fi
done		

printf "\e[01;30m           ---------------------------------- ------- ---------- ------------\e[00m\n"
