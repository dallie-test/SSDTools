#!/bin/bash

#--------------------------------------------------------------------------------
# Zet svg om naar pdf met Inkscape
#
#--------------------------------------------------------------------------------

mkdir -p "../pdf"

for SVG in *.svg; do
	echo "$SVG"
	
	PDF="../pdf/${SVG%.*}.pdf"
	/cygdrive/c/appl/Inkscape/inkscape.com --file="${SVG}" --export-area-page --export-dpi=600 --export-pdf="${PDF}"
done

    # -?, --help        
        # --usage       
    # -V, --version

    # -f, --file=FILENAME

    # -e, --export-png=FILENAME         
    # -a, --export-area=x0:y0:x1:y1     
    # -C, --export-area-page
    # -D, --export-area-drawing
        # --export-area-snap
    # -i, --export-id=ID     
    # -j, --export-id-only     
    # -t, --export-use-hints
    # -b, --export-background=COLOR     
    # -y, --export-background-opacity=VALUE     
    # -d, --export-dpi=DPI              
    # -w, --export-width=WIDTH          
    # -h, --export-height=HEIGHT

    # -P, --export-ps=FILENAME
    # -E, --export-eps=FILENAME
    # -A, --export-pdf=FILENAME
        # --export-latex

    # -T, --export-text-to-path
        # --export-ignore-filters

    # -l, --export-plain-svg=FILENAME

    # -p, --print=PRINTER

    # -I, --query-id=ID     
    # -X, --query-x
    # -Y, --query-y
    # -W, --query-width
    # -H, --query-height
    # -S, --query-all

    # -x, --extension-directory

        # --verb-list
        # --verb=VERB-ID
        # --select=OBJECT-ID

        # --shell

    # -g, --with-gui                    
    # -z, --without-gui

        # --vacuum-defs

        # --g-fatal-warnings