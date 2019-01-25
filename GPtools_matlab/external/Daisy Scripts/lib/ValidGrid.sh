#!/bin/bash
# Is het een geldige dat-file?

DatFile="$1"

# Check: op regel 5 moet de eenheid staan, bijvoorbeeld: EENHEID Lden
Line5InDat=$(sed -n "5 s/ .*$//p" < "$DatFile")
if [ "$Line5InDat" != "EENHEID" ]; then
	echo -e "\e[01;31m    error! Invalid Noise Grid\e[00m\n"
	exit 1 # failt on test 1
fi

# Check: Is er geluidsdata aanwezig? Verwijder vanaf regel 24 alle nulwaarden; blijft er dan iets over?
NoZeros=$(sed -n "24,$ s/[ +-0.E]*//gp; /^$/d" < "$DatFile")
if [ -z "$NoZeros" ]; then
	echo -e "\e[01;31m    error! No noise data found\e[00m\n"
	exit 2 # failt on test 2
fi