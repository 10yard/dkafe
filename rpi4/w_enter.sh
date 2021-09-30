#!/bin/bash
#  ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
#   888    88o  888  o88        888       888          888
#   888    888  888888         8  88      888ooo8      888ooo8
#   888    888  888  88o      8oooo88     888          888
#  o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
#                                          by Jon Wilson (10yard)
#
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
