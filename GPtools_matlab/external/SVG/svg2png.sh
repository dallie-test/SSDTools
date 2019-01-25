#!/bin/bash

#--------------------------------------------------------------------------------
# Zet svg om naar png met Inkscape
# A4/210 mm met 300 dpi wordt 2480 pixels breed
#--------------------------------------------------------------------------------

mkdir -p "../png"

for SVG in *.svg; do
	echo $SVG
	
	PNG="../png/${SVG%.*}.png"
	"/cygdrive/c/Users/Dalmeijer_W/Inkscape/inskape.com" -C --export-width=2480 "${SVG}" --export-png="${PNG}"
done