DKAFE builds the default frontend using patches of the original "dkong.zip" (US Set 1) arcade rom. 

The .ips patches are included with the software.
The orginal Donkey Kong rom is not provided with the software and must be obtained and placed into the dkafe/roms folder as dkong.zip.  It is recommended but not essential for you to also place dkongjr.zip into the dkafe/roms folder too.  
DKAFE will then apply patches and generate the following hacked version of Donkey Kong automatically for you.  The hacked versions will be organised into subfolders of the roms folder.  Folder name shown in brackets below.

By Jon Wilson (me)
 - DK Who and the Daleks (dkongwho)
 - Donkey Kong Lava Panic (dkonglava)
 - DK Last Man Standing (dkonglastman)

By Paul Goes
 - Donkey Kong Crazy Barrels Edition (dkongcb)
 - Donkey Kong Championship Edition (dkongce)
 - Donkey Kong Randomized Edition (dkongrnd)
 - Donkey Kong Freerun Edition (dkongfr)
 - Donkey Kong Into The Dark (dkongitd)
 - Donkey Kong Skip Start (dkongl05)
 - Donkey Kong Reverse (dkongrev)
 - Donkey Kong On The Run (dkongotr)
 - Donkey Kong Twisted Jungle (dkongjungle)

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
 - Donkey Kong Kill Screen Fix (dkongksfix)

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

All completed hacks will be named dkong.zip and placed into a unique folder under /hacks
e.g. dkongspooky.ips will create "<ROM_DIR>/hacks/dkongspooky/dkong.zip"

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






