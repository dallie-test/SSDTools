#!/bin/bash
# Download Daisydata
#
# In dit bestand wordt de invoer bepaald en wordt vervolgens het script
# 'GetItAll.sh' aangeroepen. In GetItAll kan de gewenste uitvoer worden
# opgegeven.
# De eerste keer dat dit script wordt gestart maakt het een tekstbestand aan:
# $Username.txt, hierin moeten vervolgens de scenario's worden geselecteerd.
#--------------------------------------------------------------------------------
# Getest door EdG 20121206
#--------------------------------------------------------------------------------
#BaseURL="http://daisy-1-8-4.frontier.nl/source/"    	# url van Daisy
#Username="GP2018def"                                  	# username
#Password="-P4s7!Hh"                                 	# wachtwoord
#Empirisch
#Years="1971-2010"                                   	# jaren in de vorm: 1971-2011
#Hybride
#Years="1971-2016"                                   	# jaren in de vorm: 1971-2011
#BaseDir="../../../prognose_def"                         # directory voor de uitvoer (in sub-directories)


BaseURL="http://daisy-1-8-4.frontier.nl/source/"    	# url van Daisy
Username="Onth2017"                                  		# username
Password="huD4S9UCP6"                                 	# wachtwoord
#Empirisch
#Years="1971-2010"                                   	# jaren in de vorm: 1971-2011
#Hybride
Years="2021"                                   	# jaren in de vorm: 1971-2011
BaseDir="../../../evaluatie"                         	# directory voor de uitvoer (in sub-directories)


# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

# Sub-directory voor de uitvoer
mkdir -p "${BaseDir}" #TODO: check inbouwen of dit een geldige directorynaam is
	
# Maak een log van deze sessie
LogFile="${BaseDir}/${Username}_log"
echo "Start: $(date +'%Y-%m-%d %H:%M')" > "${LogFile}.col"

# Start het echte script
if [ -r "${Username}.txt" ]
then
	bash GetItAll.sh  "$BaseURL" "$Username" "$Password"  "$Years" "$BaseDir" | tee -a "${LogFile}.col"
else
	# Maak het scenario-bestand aan
	bash ./lib/GetScenarios.sh "$BaseURL" "$Username" "$Password" | tee -a "${LogFile}.col"
fi

echo "Stop: $(date +'%Y-%-m-%d %H:%M')" >> "${LogFile}.col"

# Maak een log zonder de Unix-kleurcodes
cat "${LogFile}.col" | sed -r "s/\x1B\[[0-9;]*m//g" > "${LogFile}.txt"