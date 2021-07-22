#!/bin/bash
# DKAFE by Jon Wilson
# Switch to fullscreen when wmctrl detects MAME window.
# Use this line in your settings.txt to enable it i.e.
#   EMU_ENTER = <ROOT>/w_enter.sh

for i in {1..20}
do
	# Keep focus on DKAFE until MAME starts
	wmctrl -Fa DKAFE
	if wmctrl -l | grep -q MAME:; then
		# Wait for MAME to start up then switch focus
		sleep 0.5
		wmctrl -a MAME: -b add,fullscreen
		exit
	fi
	sleep 0.2
done
exit
