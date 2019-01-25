#!/bin/bash

#--------------------------------------------------------------------------------
#
#
#--------------------------------------------------------------------------------


base_url="http://daisy-1-7.frontier.nl/source"
user_name="gp2013"
password="g4fN9bcd"
scen="4020688"
base_folder=daisy_export_for_enciro_`date +'%Y%m%d%H%M%S'`
#year in format 
year='1971-2011'

#verkrijg titel van scenario
scenario_name=`wget -q -O - "${base_url}/index.php?url=scenario-settings.tpl&p[_id]=${scen}&username=${user_name}&password=${password}" | grep ${scen} | sed 's/^.*values\[table\]\[title\]//' | sed 's/^.*value="//' | cut -d '"' -f1 | head -n1`
echo "SCENARIO: ${scenario_name} (${scen})"
mkdir -p "./${base_folder}/${scenario_name}"

#download traffic
./Daisy_Traffic.sh "${scen}" "$base_folder" "$year" "d_lt d_runway d_route d_proc d_ac_cat d_type d_airline d_den" "traffic_enciro" "$base_url" "$user_name" "$password"

# grab first phase
first_phase=`wget -q -O - "${base_url}/index.php?url=scenario-settings.tpl&p[_id]=${scen}&username=${user_name}&password=${password}" | grep "<td class='perioddisplay" | sed "s/_id]=/&\n/;s/.*\n//;s/'>/\n&/;s/\n.*//" | head -n1`

# get modules for this phase
#verkrijg modules per fase
modules=`wget -q -O - "${base_url}/index.php?url=phase-settings.tpl&p[_id]=${first_phase}&username=${user_name}&password=${password}" | sed -n '/noise/,$p' | grep selected | grep -v "'-1'"  | cut -d"'" -f2`

for M in $modules; do
	#verkrijg module name
	module_name=`wget -q -O - "${base_url}/index.php?url=noise-edit.tpl&p[_id]=${M}&username=${user_name}&password=${password}" | grep 'values\[table\]\[title\]' | sed 's/^.*values\[table\]\[title\]//' | sed 's/^.*value="//' | cut -d '"' -f1`
	#bepaal of het lden, lnight, tvg is
	module_type=`wget -q -O - "${base_url}/index.php?url=noise-edit.tpl&p[_id]=${M}&username=${user_name}&password=${password}" | grep 'Name:' | sed "s/^.*Name://" | cut -d">" -f5 | cut -d"<" -f1`
	if [ "$module_type" == "Lden" ]
	then
		echo "lden found: ${module_name} (id: ${M})"
		lden_module_id=$M
	fi
done

#download runway excel
runway_info_id=`wget -q -O - "${base_url}/index.php?url=noise/settings.tpl&p[module]=${lden_module_id}&p[phase]=${first_phase}&username=${user_name}&password=${password}" | grep -m 100 "\[table\]\[runway_info\]" -A 100 | grep -m 1 'selected="selected"' | sed -n 's/^.*value="\([^"]*\).*$/\1/p'`

wget -q -O - "${base_url}/index.php?url=extern/export-table.php&table=runwayinfotable&_id=${runway_info_id}&username=${user_name}&password=${password}" > "./${base_folder}/${scenario_name}/runway_info_${runway_info_id}.xls"
echo "runway info downloaded"

#download route
route_id=`wget -q -O - "${base_url}/index.php?url=noise/settings.tpl&p[module]=${lden_module_id}&p[phase]=${first_phase}&username=${user_name}&password=${password}" | grep -m 100 "\[table\]\[route\]" -A 100 | grep -m 1 'selected="selected"' | sed -n 's/^.*value="\([^"]*\).*$/\1/p'`
#route download not available yet: will be implemented when daisy 1.8 is released

#download noise category
noise_category_id=`wget -q -O - "${base_url}/index.php?url=noise/settings.tpl&p[module]=${lden_module_id}&p[phase]=${first_phase}&username=${user_name}&password=${password}" | grep -m 100 "\[table\]\[noise_category\]" -A 100 | grep -m 1 'selected="selected"' | sed -n 's/^.*value="\([^"]*\).*$/\1/p'`

wget -q -O - "${base_url}/index.php?url=extern/export-table.php&table=noisecategoriestable&_id=${noise_category_id}&username=${user_name}&password=${password}" > "./${base_folder}/${scenario_name}/noise_category_${noise_category_id}.xls"
echo "noise category downloaded"

#download noise profile
noise_profile_id=`wget -q -O - "${base_url}/index.php?url=noise/settings.tpl&p[module]=${lden_module_id}&p[phase]=${first_phase}&username=${user_name}&password=${password}" | grep -m 100 "\[table\]\[noise_profile\]" -A 100 | grep -m 1 'selected="selected"' | sed -n 's/^.*value="\([^"]*\).*$/\1/p'`
#noise profile download not available yet: will be implemented when daisy 1.8 is released

#download flight profile
flight_profile_id=`wget -q -O - "${base_url}/index.php?url=noise/settings.tpl&p[module]=${lden_module_id}&p[phase]=${first_phase}&username=${user_name}&password=${password}" | grep -m 100 "\[table\]\[flight_profile\]" -A 100 | grep -m 1 'selected="selected"' | sed -n 's/^.*value="\([^"]*\).*$/\1/p'`

wget -q -O - "${base_url}/index.php?url=profile-export.tpl&p[table]=${flight_profile_id}&username=${user_name}&password=${password}" > "./${base_folder}/${scenario_name}/flight_profile_${flight_profile_id}.zip"
echo "flight profiles downloaded"

#0-grids
./ENCIRO_0grids.sh "${scen}" "$base_folder" "$year" "$base_url" "$user_name" "$password"

echo "done. pleas see results in folder $base_folder"