#!/bin/bash

# Seizoenen 
# Obv GJ2014 maar wel met historische meteojaren
#TODO: Lees de begin en einddatum van de fases van het scenario in Daisy
WinterStart="1971-10-27"
WinterEnd="1972-03-29"
ZomerStart="1972-03-30"
ZomerEnd="1972-10-25"

rm "dates_1 winter.txt" "dates_2 zomer.txt"

#TODO: Onderstaande lusjes zijn eeeerrrrggggg traag, waar komt dit door???

for (( Year=0; Year<=41; Year++ )); do
	BaseDate=$WinterStart
	until [ "$BaseDate" \> "$WinterEnd" ]
	do
		Date=$(/bin/date --date "$BaseDate $Year year" +%Y-%m-%d)
		echo "$Date" >> "dates_1 winter.txt"
		
		BaseDate=$(/bin/date --date="$BaseDate 1 day" +%Y-%m-%d)
	done
	
	BaseDate=$ZomerStart
	until [ "$BaseDate" \> "$ZomerEnd" ]
	do
		Date=$(/bin/date --date "$BaseDate $Year year" +%Y-%m-%d)
		echo "$Date" >> "dates_2 zomer.txt"
		
		BaseDate=$(/bin/date --date="$BaseDate 1 day" +%Y-%m-%d)
	done
done
