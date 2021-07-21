#!/bin/bash
# DKAFE by Jon Wilson
# Switch focus back to DKAFE.
# Use this line in your settings.txt to enable it i.e.
#   EMU_EXIT = <ROOT>/w_exit.sh

# Switch focus back to DKAFE
for i in {1..6}
do
  wmctrl -Fa DKAFE
  sleep 0.1
done
exit
