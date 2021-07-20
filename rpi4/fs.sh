#!/bin/bash
# DKAFE by Jon Wilson
# Switch to fullscreen when wmctrl detects MAME window.
# Use this line in your settings.txt to enable it i.e.
#   EMU_ENTER = <ROOT>/fs.sh

i=0
while [ $i -lt 20 ]
do
	# Keep focus on DKAFE until MAME starts
	wmctrl -Fa DKAFE
	if wmctrl -l | grep -q MAME:; then
		# Switch focus to MAME
		sleep 0.25
		wmctrl -a MAME: -b add,fullscreen
		break
	fi
	sleep 0.1
	i=$[$i+1]
done
