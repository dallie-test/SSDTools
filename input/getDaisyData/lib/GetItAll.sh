#!/bin/bash
# Download Daisydata
# Dit script wordt aangeroepen vanuit Master.sh De gewenste uitvoer wordt bepaald door de aanroep van:
# GetGrid.sh     Envira Noise grid als dat-file
# GetTVG.sh      TVG-waarde als tekstbestand
# GetTraffic.sh  Traffic als xls
#
#--------------------------------------------------------------------------------
# Getest door EdG 20121206
# Aanpassing voor aansturing vanuit Python door WhD 20180708
#--------------------------------------------------------------------------------
BaseURL="$1"    # url van Daisy
Username="$2"   # username
Password="$3"   # wachtwoord
Years="$4"      # jaren in de vorm: 1971-2011
BaseDir="$5"    # directory voor de uitvoer (in sub-directories)
Folder="$6"	 	# gewenste folder
Study="$7"		# gewenste study

# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------
#TODO Ik vermoed dat het lezen van read-only scenario's of tabellen niet goed gaat. Zie DaisyFolderTitle.sh, hier is dit
#     probleem vermeden door de tabel geforceerd read-only '&p[readOnly]=1' op te vragen en het filter daar op aan te passen.

# Sub-directory voor de uitvoer
mkdir -p "${BaseDir}" #TODO: check inbouwen of dit een geldige directorynaam is

bash ./lib/GetScenarios.sh "$BaseURL" "$Username" "$Password" "$Folder" "$Study"

# sub-directory met routines toevoegen
PATH=$PWD/lib:$PATH

DaisyVersion=$(DaisyVersion.sh "$BaseURL" "$Username" "$Password")
printf "Reading Scenarios from: ${Username}.txt\n\n"

printf "\e[01;30m=============================================================================\e[00m\n"
printf          "Daisy version ${DaisyVersion}\n\n"

while read Scenario EnDeRestNiet #Lees alleen tot het eerste scheidingsteken (white space)
do
	# Filter op lege regels en commentaar
	case $Scenario in ''|\#*) continue;; esac

	DaisyScenarioTitle=$(DaisyScenarioTitle.sh "$BaseURL" "$Username" "$Password" "$Scenario")
	printf        "\nid         Scenario                                                          \n"      
    printf "\e[01;30m---------- ------------------------------------------------------------------\e[00m\n"
	printf "%-10s %-50s\n\n" "$Scenario" "$DaisyScenarioTitle"                                             
	
	# Sub-directory voor de uitvoer
	OutDir="${BaseDir}/${DaisyScenarioTitle}/"
	LogDir="${OutDir}Log/"
	mkdir -p "${OutDir}"  #TODO: check inbouwen of dit een geldige directorynaam is
	mkdir -p "${LogDir}" 
	
	# Download Runway result
	#TODO: werk dit verder uit ...
	#      Zie de TODO's in de onderliggende bestanden
	# bash GetRunwayResults.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "$OutDir"

	# Download noise grids
	bash GetGrid.sh  "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "mm"    "$OutDir" 
	bash GetGrid.sh  "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "mean"  "$OutDir" 
	bash GetGrid.sh  "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "years" "$OutDir" 
	
	# Download TVG
	bash GetTVG.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$OutDir"
	
	# Download HG
	bash GetHG.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$OutDir"
	
	# Download traffic (zie onderaan deze file de groupby opties)
	# GetTraffic haalt een xls op, GetTextTraffic een tekstfile
	bash GetTextTraffic.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "d_lt d_runway d_route d_proc d_ac_cat d_den H" "total"  "$OutDir" " - mean"
	bash GetTextTraffic.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "d_combination d_den H"                         "total"  "$OutDir" " - pref"	
	bash GetTextTraffic.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "d_lt d_runway d_myear d_den d_period"          "total"  "$OutDir" " - years" 

	bash GetTextTraffic.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "d_lt d_den H i"                                "phases" "$OutDir" "" 

	# Download Periods tables
	bash GetPeriodsTable.sh "$BaseURL" "$Username" "$Password" "$Scenario" "$OutDir"
	
	# Download eppmy
	# bash GetEPPMY.sh  "$BaseURL" "$Username" "$Password" "$Scenario" "$Years" "$OutDir"
	# cp "${Username}_fases.txt" "$OutDir"
    
	# Download log files
	# TODO: werk dit verder uit...
	# bash GetJoblist.sh "$BaseURL" "$Username" "$Password" "$Scenario" "${LogDir}"
done < "${Username}.txt"

printf      "\n\nDone, please see results in folder: %-50s\n"  "${BaseDir}"
printf "\e[01;30m=============================================================================\e[00m\n"

# Hieronder de namen van de verschillen groupby opties:
#
# Filter op    groupby
# ------------ -------------
# Month        m
# Week         Y-W
# Day          m-d
# Hour         H
# Minute       i
# Direction    d_lt
# Runway       d_runway
# Routegroup   d_rg
# Route        d_r
# Proc         d_proc
# A/c cat      d_ac_cat
# A/c type     d_type
# Airline      d_airline
# Motor code   d_motor
# WTC          d_wtc
# MTOW         d_mtow
# Safety cat.  d_safety_cat
# Combination  d_combination
# Period       d_period
# Daylight     d_daylight
# Visibility   d_visibility
# Weekday      d_weekday
# DEN          d_den
# Meteo Year   d_myear
# ------------ -------------
