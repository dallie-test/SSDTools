#!/bin/bash
# ----------------------------------------
# Dit script haalt KNMI weerdata op van de KNMI-website.
# Mocht de website van de KNMI wijzigen, pas dan hieronder
# de definitie van 'knmifile' of 'url' aan.
#
# 'unzip' en 'wget' zijn niet standaard beschikbaar in cygwin,
# installeer deze bij de setup.
# ----------------------------------------
years="2011-2020"
station="240"
result="knmi_1971-2020.txt"
# ----------------------------------------
knmiFile="uurgeg_${station}_${years}"
url="http://cdn.knmi.nl/knmi/map/page/klimatologie/gegevens/uurgegevens/"

# Download file, unzip and reformat
wget -N ${url}/${knmiFile}.zip &&
unzip -o "${knmiFile}.zip" &&

tail -n +34 "${knmiFile}.txt" |
sed -e 's/,/\t/g' |
sed -e 's/ //g' > "knmi_temp.txt"

# Merge with previous years
cat knmi_1971-2010.txt "knmi_temp.txt" > "${result}"

# Add header to file
cat header.txt knmi_temp.txt > "knmi_${years}.txt"

# Clean up
rm knmi_temp.txt