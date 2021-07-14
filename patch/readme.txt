      ___   ___                    .--.
     (   ) (   )                  /    \
   .-.| |   | |   ___     .---.   | .`. ;    .--.
  /   \ |   | |  (   )   / .-, \  | |(___)  /    \
 |  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ;
 | |  | |   | |,' /       .'`  | (   __)   |  | | |
 | |  | |   | .  '.      / .'| |  | |      |  |/  |
 | |  | |   | | `. \    | /  | |  | |      |  ' _.'
 | '  | |   | |   \ \   ; |  ; |  | |      |  .'.-.
 ' `-'  /   | |    \ .  ' `-'  |  | |      '  `-' /  Donkey Kong Arcade Frontend
  `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'   by Jon Wilson

--------------------------------------------------------------------------------
 Notes on automatically generating roms from .ips patch files
--------------------------------------------------------------------------------

DKAFE builds the default frontend using patches of the original "dkong.zip" (US Set 1) arcade rom.

The .ips patches are included with the software.
The orginal Donkey Kong rom is not provided with the software and must be obtained and placed into the dkafe/roms folder as dkong.zip.  
DKAFE will then apply patches and generate the following hacked version of Donkey Kong automatically for you.  The hacked versions will be organised into subfolders of the roms folder.  Folder name shown in brackets below.

By Jon Wilson (me)
 - Donkey Kong Lava Panic! (dkonglava)
 - DK Who and the Daleks (dkongwho)
 - DK Pies Only (dkongpies)
 - DK Rivets Only (dkongrivets)
 - DK Barrels Only (dkongbarrels)

By Paul Goes
 - Donkey Kong Crazy Barrels Edition (dkongcb)
 - Donkey Kong Championship Edition (dkongce)
 - Donkey Kong Randomized Edition (dkongrnd)
 - Donkey Kong Freerun Edition (dkongfr)
 - Donkey Kong Into The Dark (dkongitd)
 - Donkey Kong Skip Start (dkongl05)
 - Donkey Kong Reverse (dkongrev)
 - Donkey Kong On The Run (dkongotr)
 - Donkey Kong Twisted Jungle (dkongtj)
 - Donkey Kong Barrelpalooza (dkongbp)
 - Donkey Kong 40th Anniversary Edition (dkong40)

By John Kowalski (Sock Master) 
 - Donkey Kong Spooky Remix (dkongspooky)
 - Donkey Kong Christmas Remix (dkongxmas)
 - Donkey Kong Springs Trainer (dkongst2)
 - Donkey Kong Trainer (dkongtrn)
 - Donkey Kong Pace (dkongpace)
 - Donkey Kong Rainbow (dkongrainbow)

By Jeff Kulczycki
 - Donkey Kong 2 Jumpman Returns (dkongdk2)
 - Donkey Kong Foundry (dkongf)
 - Donkey Kong Barrel Control Colouring (dkongbcc)

By Mike Mika and Clay Cowgill
 - Donkey Kong Pauline Edition (dkongpe)

By Don Hodges 
 - Donkey Kong Killscreen Fix (dkongksfix)

By Tim Appleton
 - Donkey Kong Pac-Man (dkongpac)

By Vic Twenty George
 - Donkey Kong Atari 2600 Graphics (dkong2600)

By Unknown
 - Donkey Kong Wild Barrel Hack (dkongwbh)
 - Donkey Kong Hard (dkonghrd)
 - Donkey Kong 2 Marios (dkong2m)
 - Donkey Kong Naked (dkongnad)


---- Creating patches

To make a complete patch file for a hack you need to:
 1. add/replace all files related to the hack into a copy of dkong.zip (you may need to rename some files so that they overwrite originals.  It should be obvious when the files are replacements.)
 2. use IPS patch tool to create a patch of the differences between original dkong.zip and the modified dkong.zip
 3. save the .ips file to patch folder

---- Converting old zips other than those already included

dkong.zip files from early versions of mame make use of different file names.  Archive filenames should be renamed as follows.  Filenames can differ for some hacks.

dk.3n to v_5h_b.bin
dk.3p to v_3pt.bin
dk.7c to l_4m_b.bin
dk.7d to l_4n_b.bin
dk.7e to l_4r_b.bin
dk.7f to l_4s_b.bin
dk.5a to c_5at_g.bin
dk.5b to c_5bt_g.bin
dk.5c to c_5ct_g.bin
dk.5e to c_5et_g.bin 
dk.3f to s_3j_b.bin
dk.3h to s_3i_b.bin

--------------------------------------------------------------------------------
 Notes on making the DK Pies Hack
--------------------------------------------------------------------------------

Changes made to regular dkong rom to make it pies only.

* Removed the RETURN at the end of pies stage logic which made program continue to end of rivets stage logic.
In file c_5ct_g.bin: Change offset 7B5 to "00" (NOP) from "C9" (RET)

* Add logic to increment level to conveyors stage replacing original logic which cleared the end of level count. 
In file c_5ct_g.bin: Copy offsets 951,952,953,954 to offsets 7a9,7aa,7ab,7ac. 

* Update the screen patterns table so it only contains pies board (value 02).  
In file c_5at_g.bin: Change values starting at offset A65 from 01 04 01 03 04 01 02 03 04 01 02 01 03 01 04 7F to 02 02 02 02 02 02 02 02 02 02 02 02 02 02 02 7F

* Prevent rivet cleared animation being drawn to screen.
In file c_5ct_g.bin: In the rivet code from offset 7B7 to 825 replace the values CD 26 18 and CD A7 0D with 00 00 00

* Change the high score text to "PIES ONLY".
In file c_5at_g.bin: Change values at offset 6B4 from 18 19 17 18 10 23 13 1F 22 15 to 20 19 15 23 10 1F 1E 1C 29 10

* Change "HOW HIGH CAN YOU GET" text to "HOW HIGH CAN YOU PIE?"
In file c_5at_g.bin: Change values at offset 6DF from 17 15 24 to 20 19 15

* Change attract mode to show pies level
In file c_5et_g.bin: Change value at offset 76C from 01 to 02

* Finally,  to prevent Kong from being drawn again before level increase, I created a block of 40 blank sprites in file c_5at_g.bin beginning from offset F30.  This blank sprite erases Kong.
In file c_5ct_g.bin: Change values starting at offset 804 from 5C 38 to 30 3F.  