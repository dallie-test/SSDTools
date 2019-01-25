#!/bin/bash
# Maak een lijst met jaren
# Syntax: 1971,1972, 1980-1985, 2000-2010
# ----------------------------------------------------------------------------------------------------------------------
Year="$1"
# ----------------------------------------------------------------------------------------------------------------------
# Start script
# ----------------------------------------------------------------------------------------------------------------------

YearList=""

for Yi in ${Year//,/ }   # komma als scheidingsteken
do
	FirstYear=${Yi%-*}   # eerste jaar, deel voor de '-'
	LastYear=${Yi#*-}    # laatste jaar, na de '-'

	for (( Yj=$FirstYear; Yj<=$LastYear; Yj++ )); do
		YearList="${YearList} ${Yj}"
	done
done

echo "$YearList"