#!/bin/bash
BaseURL="$1"    # url van Daisy
Username="$2"   # username
Password="$3"   # wachtwoord
Scenario="$4"   # scenario id
OutDir="$5"     # directory voor de output 
# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

# -------------------------------
#   TODO: werk dit verder uit!
# -------------------------------

# sub-directory met routines toevoegen
PATH=$PWD/lib:$PATH

DaisyScenarioTitle=$(DaisyScenarioTitle.sh "$BaseURL" "$Username" "$Password" "$Scenario")

wget -q -O - "${BaseURL}/index.php?url=job/list.tpl&username=${Username}&password=${Password}" |
        sed -e "s/<\/tr>/\n/g" |
		sed -n "/COMPLETED.*scenario ${DaisyScenarioTitle}</ s/.*class=.maywrap.>\([^ ]*\).*/\1/p" > JobListType.txt

# http://daisy-1-8.frontier.nl/source/index.php?url=job/viewoutput.tpl&p[_id]=1370787
JobIDs=$(wget -q -O - "${BaseURL}/index.php?url=job/list.tpl&username=${Username}&password=${Password}" |
        sed -e "s/<\/tr>/\n/g" |
        sed -n "/COMPLETED.*scenario ${DaisyScenarioTitle}</ s/.*&p\[_id\]=\([0-9][0-9]*\)'>.*/\1/p")

for J in $JobIDs
do
	echo "JobID: ${J}"
	wget -q -O - "${BaseURL}/index.php?url=job/viewoutput.tpl&p[_id]=${J}&username=${Username}&password=${Password}" |
		sed -e "s/<[^>]*>//g" > "${OutDir}${J}.txt"
done