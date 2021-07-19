#!/bin/bash
# DKAFE by Jon Wilson
# Switch to fullscreen when wmctrl detects MAME window.
# Use this line in your settings.txt to enable it i.e.
#   EMU_ENTER = nohup ./fs.sh 

DELAY=0.2
REPEATS=10

i=0
while [ $i -lt $REPEATS ]
do
	sleep $DELAY
	wmctrl -a MAME: -b add,fullscreen
	i=$[$i+1]
done
