#!/bin/bash

BaseURL="$1"
Username="$2"
Password="$3"
Scenario="$4"
Module="$5"
Scale="$6"
DEN="$7"

if [ "$DEN" == "N" ]
then
	DEN="&_den=N&_myear=1971,1973,1974,1975,1976,1977,1978,1979,1980,1981,1983,1984,1985,1986,1987,1988,1989,1991,1992,1993,1995,1997,1999,2001,2002,2003,2004,2005,2006,2007,2008,2009"
else
	DEN="&_myear=1971,1974,1975,1976,1977,1978,1979,1980,1981,1982,1984,1985,1986,1987,1988,1989,1990,1991,1992,1993,1996,1998,1999,2000,2001,2002,2003,2004,2005,2006,2008,2009"
fi

wget -q -O - "${BaseURL}/index.php?url=tvg-overview.tpl&username=${Username}&password=${Password}&p[scenario]=${Scenario}&p[module]=${Module}&p[factor]=*${Scale}${DEN}" |
sed -n 's/.*>\([0-9.]*\) dB(A).*/\1/p'

# De TVG-waarde is het getal voor ' dB(A)', in de vorm 99.99 dB(A)