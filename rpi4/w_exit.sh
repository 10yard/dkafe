#!/bin/bash
#  ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
#   888    88o  888  o88        888       888          888
#   888    888  888888         8  88      888ooo8      888ooo8
#   888    888  888  88o      8oooo88     888          888
#  o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
#                                          by Jon Wilson (10yard)
#
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
