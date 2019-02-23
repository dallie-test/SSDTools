#!/bin/bash
# Aanpassing voor aansturing vanuit Python door WhD 20180708

BaseURL="$1"    # url van Daisy
Username="$2"   # username
Password="$3"   # wachtwoord
Folder="$4"     # gewenste folder
Study="$5"		# gewenste studie

# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

# sub-directory met routines toevoegen
PATH=$PWD/lib:$PATH
Folders=$(DaisyFolders.sh "$BaseURL" "$Username" "$Password")
 
echo "# Scenario list: ${Username}" > "${Username}.txt"
echo "#" >> "${Username}.txt"

# Print naar het scherm
printf "Creating: ${Username}.txt\n"
printf "Please edit this file and uncomment your scenario's\n\n"

printf          "id         Folder\n"      
printf "\e[01;30m---------- ------------------------------------------------------------------\e[00m\n"
  
for F in $Folders; do
	FolderTitle=$(DaisyFolderTitle.sh "$BaseURL" "$Username" "$Password" "$F")

	#if [ "$FolderTitle" = "$Folder" ]; then
		printf "%-10s %-50s\n" "$F" "$FolderTitle"                                             
		
		Scenario=$(
		  wget -q -O - "${BaseURL}/index.php?url=folder-settings.tpl&username=${Username}&password=${Password}&p[_id]=${F}" |
		  sed -e "s/<\/tr>/\n/g" |
		  sed -n "/scenario-settings/ s/.*&p\[_id\]=\([0-9][0-9]*\)'>\($Study\)<\/a><\/td>.*/\1\t\2/p" )	
		
		#Uitvoer naar file
		echo -e "#---------\t------------------------------------------------------------------" >> "${Username}.txt" 
		echo -e "# Folder\t${FolderTitle}" >> "${Username}.txt" 
		echo -e "#---------\t------------------------------------------------------------------" >> "${Username}.txt" 
		echo -e "$Scenario" >> "${Username}.txt"  
	#fi

done
