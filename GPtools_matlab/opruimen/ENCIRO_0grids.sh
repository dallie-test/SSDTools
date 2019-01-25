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

echo "downloading grids..."

# Scenario
scen="$1"
base_folder="$2"
year="$3"
base_url="$4"
user_name="$5"
password="$6"

mkdir -p "./${base_folder}"

SCALE=1.00

# verkrijg titel van scenario
scenario_name=`wget -q -O - "${base_url}/index.php?url=scenario-settings.tpl&p[_id]=${scen}&username=${user_name}&password=${password}" | grep ${scen} | sed 's/^.*values\[table\]\[title\]//' | sed 's/^.*value="//' | cut -d '"' -f1 | head -n1`
echo "SCENARIO: ${scenario_name} (${scen})"
mkdir -p "./${base_folder}/${scenario_name}"

# grab first phase
first_phase=`wget -q -O - "${base_url}/index.php?url=scenario-settings.tpl&p[_id]=${scen}&username=${user_name}&password=${password}" | grep "<td class='perioddisplay" | sed "s/_id]=/&\n/;s/.*\n//;s/'>/\n&/;s/\n.*//" | head -n1`

# get modules for this phase
# verkrijg modules per fase
modules=`wget -q -O - "${base_url}/index.php?url=phase-settings.tpl&p[_id]=${first_phase}&username=${user_name}&password=${password}" | sed -n '/noise/,$p' | grep selected | grep -v "'-1'"  | cut -d"'" -f2`

for M in $modules; do
	#verkrijg combi van baan en route (die gebruikt worden)
	route_runway=`wget -q -O - "${base_url}/index.php?url=pr-traffic-tab-select.tpl&p[module]=${M}&p[phase]=${first_phase}&_groupby[]=t.d_route&_groupby[]=t.d_runway&username=${user_name}&password=${password}" | tail -n1 | sed 's/<\/tr>/\n/g' | grep "^<tr" | sed 's/^.*d_runway//' | tr "<" ">" | cut -d">" -f"2 12" | tr ">" " "`
	
	#verkrijg module name
	module_name=`wget -q -O - "${base_url}/index.php?url=noise-edit.tpl&p[_id]=${M}&username=${user_name}&password=${password}" | grep 'values\[table\]\[title\]' | sed 's/^.*values\[table\]\[title\]//' | sed 's/^.*value="//' | cut -d '"' -f1`
	#bepaal of het lden, lnight, tvg is
	module_type=`wget -q -O - "${base_url}/index.php?url=noise-edit.tpl&p[_id]=${M}&username=${user_name}&password=${password}" | grep 'Name:' | sed "s/^.*Name://" | cut -d">" -f5 | cut -d"<" -f1`
	mkdir -p "./${base_folder}/${scenario_name}/${module_name}"
	echo "MODULE: ${module_name} (${M}, in phase ${first_phase})"

	# gemiddeld weer excl. meteotoeslag
	MM=N
	
	echo "$route_runway" | while read line
	do
		runway=`echo $line | cut -d " " -f "1"`
		route=`echo $line | cut -d " " -f "2"`
		grid_name="S${scen}_M${M}_Y${year}_${route}_${runway}_excGA.dat"
		grid_link="${base_url}/index.php?url=export-envira.tpl&username=${user_name}&password=${password}&p[module]=${M}&p[scenario]=${scen}&p[mm]=${MM}&p[myear]=${year}&p[factor]=*${SCALE}&p[r]=${route}&p[rw]=${runway}"
		wget -q -O - "${grid_link}" > "./${base_folder}/${scenario_name}/${module_name}/${grid_name}"
		echo "${grid_link}"
	done
done	


echo "grids download complete"
