#!/bin/bash
# ----------------------------------------
knmiFiles=(knmi_1971-1980.txt knmi_1981-1990.txt knmi_1991-2000.txt knmi_2001-2010.txt)
result="knmi_1971-2010.txt"
# ----------------------------------------

tail -q -n +2 knmi_header.txt "${knmiFiles[@]}" > "${result}"


