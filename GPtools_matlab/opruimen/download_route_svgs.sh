#!/bin/bash
#this function automatically downloads all envira grids contained by a scenario.
#input: $1 a(n array of) scenario ID('s). 
#input: $2 target directory where files should be stored
#output: none (but .dat files are written in the target_directory)
# Url met User en Wachtwoord van de studie

#--------------------------------------------------------------------------------
#
#
#    - TODO: TVG grids hebben geen grids: voorkom output van dat-files
#--------------------------------------------------------------------------------

echo "downloading routes..."

# Scenario
scen="$1"
base_folder="$2"
base_url="$3"
user_name="$4"
password="$5"

mkdir -p "./${base_folder}"

# verkrijg titel van scenario
echo "${base_url}/index.php?url=scenario-settings.tpl&p[_id]=${scen}&username=${user_name}&password=${password}" 
scenario_name=`wget -q -O - "${base_url}/index.php?url=scenario-settings.tpl&p[_id]=${scen}&username=${user_name}&password=${password}" | grep ${scen} | sed 's/^.*values\[table\]\[title\]//' | sed 's/^.*value="//' | cut -d '"' -f1 | head -n1`

echo "SCENARIO: ${scenario_name} (${scen})"
mkdir -p "./${base_folder}/${scenario_name}"

# grab first phase
first_phase=`wget -q -O - "${base_url}/index.php?url=scenario-settings.tpl&p[_id]=${scen}&username=${user_name}&password=${password}" | grep "<td class='perioddisplay" | sed "s/_id]=/&\n/;s/.*\n//;s/'>/\n&/;s/\n.*//" | head -n1`
echo "modules: ${first_phase}"
# get modules for this phase
# verkrijg modules per fase
modules=`wget -q -O - "${base_url}/index.php?url=phase-settings.tpl&p[_id]=${first_phase}&username=${user_name}&password=${password}" | sed -n '/noise/,$p' | grep selected | grep -v "'-1'"  | cut -d"'" -f2`

for M in $modules; do
	echo "${base_url}/index.php?url=pr-traffic-tab-select.tpl&p[module]=${M}&p[phase]=${first_phase}&_groupby[]=t.d_route&_groupby[]=t.d_runway&username=${user_name}&password=${password}"
	#verkrijg module name
	module_name=`wget -q -O - "${base_url}/index.php?url=noise-edit.tpl&p[_id]=${M}&username=${user_name}&password=${password}" | grep 'values\[table\]\[title\]' | sed 's/^.*values\[table\]\[title\]//' | sed 's/^.*value="//' | cut -d '"' -f1`
	#bepaal of het lden, lnight, tvg is
	module_type=`wget -q -O - "${base_url}/index.php?url=noise-edit.tpl&p[_id]=${M}&username=${user_name}&password=${password}" | grep 'Name:' | sed "s/^.*Name://" | cut -d">" -f5 | cut -d"<" -f1`
	#verkrijg combi van baan en route (die gebruikt worden)
	if [ $module_type == "Lden" ]; then
		from_time="0600"
		upto_time="2300"
	else
		from_time="2300"
		upto_time="0600"
	fi
		
	route_runway=`wget -q -O - "${base_url}/index.php?url=pr-traffic-tab-select.tpl&_from_time=${from_time}&_upto_time=${upto_time}&p[module]=${M}&p[phase]=${first_phase}&_groupby[]=t.d_route&_groupby[]=t.d_runway&username=${user_name}&password=${password}" | tail -n1 | sed 's/<\/tr>/\n/g' | grep "^<tr" | sed 's/^.*d_runway//' | tr "<" ">" | cut -d">" -f"2 12 78" | tr ">" " "`
	if [[ $module_type != *TVG* ]]; then
		mkdir -p "./${base_folder}/${scenario_name}/routes/${module_name}"
		echo "MODULE: ${module_name} (${M}, in phase ${first_phase})"

		# gemiddeld weer excl. meteotoeslag
		MM=N
		
		#alle individuele routes maken
		echo "$route_runway" | while read line
		do
			runway=`echo $line | cut -d " " -f "1"`
			route=`echo $line | cut -d " " -f "2"`
			amount=`echo $line | cut -d " " -f "3" |  cut -d "." -f "1"`
			if [ "$amount" -gt 1 ]; then
				grid_name="S${scen}_M${M}_${route}_${runway}.svg"
				grid_link="${base_url}/index.php?url=rs-display.tpl&username=${user_name}&password=${password}&p[noise]=${M}&p[route]=${route}&p[runway]=${runway}&p[lt]=&p[map]=Default"
				echo $grid_link
				wget -q -O - "${grid_link}" > "./${base_folder}/${scenario_name}/routes/${module_name}/${grid_name}"
			fi
		done
		
		#gemeenschappelijke kaart maken
		all_routes=`ls "./${base_folder}/${scenario_name}/routes/${module_name}/"`
		cp ./route_departure.svgt "./${base_folder}/${scenario_name}/routes/${module_name}/route_departure.svg"
		cp ./Schiphol_30p.png "./${base_folder}/${scenario_name}/routes/${module_name}/Schiphol_30p.png"
		
		for route in $all_routes; do
			if [[ $route != *ARTIP* ]] && [[ $route != *SUGOL* ]] && [[ $route != *RIVER* ]] && [[ $route != *ARNEM1S* ]]; then
				echo "<!-- route -->" >> "./${base_folder}/${scenario_name}/routes/${module_name}/route_departure.svg"
				cat "./${base_folder}/${scenario_name}/routes/${module_name}/${route}" | grep -A10000 "id='route'" | head -n -1 | grep -v "stroke='grey'" | grep -v "stroke-dasharray" | sed "s/<\/g><g id='route'/<g id='route'/g" | sed "s/<\/g><g xmlns/<g xmlns/g" >> "./${base_folder}/${scenario_name}/routes/${module_name}/route_departure.svg"
			fi
		done
		echo "</svg>" >> "./${base_folder}/${scenario_name}/routes/${module_name}/route_departure.svg"
	fi
done

echo "route download complete"