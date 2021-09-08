# **DK Coach** #

## A MAME plugin to assist with Donkey Kong gameplay 

Tested with latest MAME version 0.235
(Compatible with MAME and WolfMAME versions from 0.196 upwards)

At the moment,  the plugin helps you with the springs and barrels stages.  I plan to add help to all other stages.


## The Barrels Stage

The helper visualises safe zones in green - where Jumpman is safe from wild barrels.  Warnings appear when DK releases a wild barrel.  Other helpers provide you with real time information.

  - 4 fixed safe zones appear in green on the board
  - 4 "mostly" safe zones appear in amber on the board.  These zones are in uphill positions adjacent to a ladder.
  - Ladders are highlighted when steering is recommended - to divert barrels away from your current position.
  - An alert appears when DK releases a wild barrel.  Jumpman is also targetted with a crosshair to draw your immediate attention.
  - The barrel control probability is displayed (as a percentage)
  - A visible hammer countdown timer appears
  - Jumpman is repositioned on the 2nd girder as a starting point as it is easily reached.  Your coaching is focussed on the difficult girders.


![Screenshot](https://github.com/10yard/dkcoach/blob/master/screenshot2.png)


## The Springs/Elevators Stage

The helper visualises the safe zones and danger zones on DK's girder.  Information about generated springs helps you make quick decisions on when to make a run and when to sit tight or retreat back to safety.

 - 2 fixed safe zones appear in green on DK's girder
 - 3 variable danger zones appear in red on DK's girder.  These zones mark the location of the bouncing springs.
 - All generated springs are assigned a "spring type" of between 0 and 15 depending on their length.  The shortest spring has type 0,  the longest has type 15.
 - The spring type appears in the top-left of screen, close to where the springs are released.
 - An alert appears for short (0-5) and long (12-15) springs.  Helping you to identify these springs so you can react quickly.
 - Jumpman is repositioned at the top of the screen ready to climb the ladder up to DK's girder.  This ensures your coaching is focussed on the most difficult part of the stage.


![Screenshot](https://github.com/10yard/dkcoach/blob/master/screenshot.png)


### Tips for completing the Springs stage, level 4+

 - Navigate Jumpman to the first green safe spot on the far right of DK's girder.
 - Move to the left edge of the safe spot, ensuring that Jumpman's feet remain inside the box.
 - Wait for a short spring to come.  When you see it, move "slightly" to the left so you are closer to the 2nd safe spot,  ensuring the spring does not hit you.  When it goes over, you need to run quickly to the 2nd safe spot.
 - Breathe.  That's the first part done.
 - Move to the right edge of the 2nd safe spot, ensuring that Jumpman's feet remain inside the box.
 - Wait for a long spring to come.  When you see it,  make a run for the ladder,  keeping your eye on the next generated spring, it must be a short spring if you are to make it up the ladder.  If it is not short then you must retreat back to the safe spot quickly. 
 - Get used to watching the springs and recogising their types as they appear from the left.
 - As you become more confident on the springs stage,  you should reduce helpers by pressing "P2 Start" button.  See "Help Settings" below.
 

## Help Settings

Use "P2 Start" to toggle the helpfulness setting between 2 (Max Help), 1 (Min Help) and 0 (No Help)

The default setting is "Max Help".
  - Max Help: All of the available helpers are displayed.
  - Min Help: Only basic helpers are displayed
  - No Help: No help is displayed.

As you become more confident with your gameplay,  you should reduce help features by pressing "P2 Start" button.  Switching from "Max Help" to "Min Help" to "No Help".
   
 
## Installing and running
 
The Plugin is installed by copying the "dkcoach" folder into your MAME plugins folder.

The Plugin is run by adding `-plugin dkcoach` to your MAME arguments e.g.

```mame dkong -plugin dkcoach```  


## What's next?

Addition of rivets stage helper
 

## Thanks to

The Donkey Kong rom hacking resource
https://github.com/furrykef/dkdasm 

The MAMEdev team
https://docs.mamedev.org/


## Feedback

Please send feedback to jon123wilson@hotmail.com

Jon

