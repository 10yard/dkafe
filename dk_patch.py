"""
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Generate roms from .ips patch files
-----------------------------------
"""
import os
from ips_util import Patch
from glob import glob
from pathlib import Path
import shutil
import hashlib
import zipfile
from dk_config import ROM_DIR, PATCH_DIR, DKONG_ZIP, DKONGJR_ZIP, DKONG3_ZIP, LOGGER_ZIP, LOGGERR2_ZIP, DKONG_MD5, FIX_MD5, ARCH, DISPLAY
from dk_system import is_pi, copy


def validate_rom():
    """Validate MD5 matches the expected value"""
    if os.path.exists(DKONG_ZIP):
        buffer = open(DKONG_ZIP, 'rb').read()
        md5 = hashlib.md5(buffer).hexdigest()
        if md5 == DKONG_MD5:
            # ZIP is verified
            return True
        elif md5 in FIX_MD5:
            # ZIP has a recognised MD5 and can be converted using a "fix" patch file
            alt_zip = os.path.join(ROM_DIR, f"dkong_{md5}.zip")
            shutil.copy(DKONG_ZIP, alt_zip)
            if os.path.exists(alt_zip):
                # Read the alternative ZIP binary
                with open(alt_zip, 'rb') as f_in:
                    alt_binary = f_in.read()
                ips = os.path.join(PATCH_DIR, f"fix_{md5}.ips")
                if os.path.exists(ips):
                    # Apply patch and write the fixed DKONG.ZIP to roms
                    patch = Patch.load(ips)
                    with open(DKONG_ZIP, 'w+b') as f_out:
                        f_out.write(patch.apply(alt_binary))
                    return True
            return False
        else:
            # ZIP not recognised - a patch file was not found.
            return False
            # 09/06/2024 Removed last resort code.  Trying to patch an unrecognisd ZIP is most likely going to fail
            ## Last resort. Check the ZIP contains all the required files
            #z = zipfile.ZipFile(DKONG_ZIP)
            #for filename in ROM_CONTENTS:
            #    if filename not in z.namelist():
            #        return False
            #return True
    else:
        # No rom file so a verification error is not returned
        return True


def apply_patches_and_addons():
    applied_patches_list = []
    addons = install_addons()

    if is_pi():
        # Look for DK roms on the /boot partition of Pi when not found in the roms folder
        # User may not have provided them at install time
        for rom in DKONG_ZIP, DKONGJR_ZIP, DKONG3_ZIP:
            if not os.path.exists(rom) and os.path.exists(f'/boot/{os.path.basename(rom)}'):
                copy(f'/boot/{os.path.basename(rom)}', ROM_DIR)
            if not os.path.exists(rom) and os.path.exists(f'/boot/dkafe_bin/{os.path.basename(rom)}'):
                copy(f'/boot/dkafe_bin/{os.path.basename(rom)}', ROM_DIR)

    if os.path.exists(DKONG_ZIP):
        # Proceed with the patching (ignoring the fix files)
        ips_files = glob(os.path.join(PATCH_DIR, "[!fix_]*.ips"))
        if ips_files:
            # Read the original ZIP binary
            with open(DKONG_ZIP, 'rb') as f_in:
                dkong_binary = f_in.read()

            # Apply patch and write the resulting hack to a subfolder
            for ips in ips_files:
                name = os.path.splitext(os.path.basename(ips))[0]
                subfolder = os.path.join(ROM_DIR, name)
                if not os.path.exists(subfolder):
                    if name.startswith("dkongjr"):
                        if os.path.exists(DKONGJR_ZIP):
                            # Copying DK Junior plugin hacks to subfolder. No patching - IPS is empty.
                            os.mkdir(subfolder)
                            shutil.copy(DKONGJR_ZIP, os.path.join(ROM_DIR, subfolder))
                            applied_patches_list.append(name)
                    elif name.startswith("dkong3"):
                        if os.path.exists(DKONG3_ZIP):
                            # Copying DK 3 plugin hacks to subfolder. No patching - IPS is empty.
                            os.mkdir(subfolder)
                            shutil.copy(DKONG3_ZIP, os.path.join(ROM_DIR, subfolder))
                            applied_patches_list.append(name)
                    elif name.startswith("loggerr2"):
                        if os.path.exists(LOGGERR2_ZIP):
                            # Copying Loggerr2 plugin hacks to subfolder. No patching - IPS is empty.
                            os.mkdir(subfolder)
                            shutil.copy(LOGGER_ZIP, os.path.join(ROM_DIR, subfolder))
                            shutil.copy(LOGGERR2_ZIP, os.path.join(ROM_DIR, subfolder))
                            applied_patches_list.append(name)
                    elif name.startswith("logger"):
                        if os.path.exists(LOGGER_ZIP):
                            # Copying Logger plugin hacks to subfolder. No patching - IPS is empty.
                            os.mkdir(subfolder)
                            shutil.copy(LOGGER_ZIP, os.path.join(ROM_DIR, subfolder))
                            applied_patches_list.append(name)
                    else:
                        # Patching DK rom and writing to subfolder
                        os.mkdir(subfolder)
                        patch = Patch.load(ips)
                        romfile = "dkong" if name.startswith("dkong") else name.split("_")[0]
                        with open(os.path.join(subfolder, f"{romfile}.zip"), 'w+b') as f_out:
                            f_out.write(patch.apply(dkong_binary))
                            applied_patches_list.append(name)
    return applied_patches_list, addons


def install_addons():
    import dk_global as _g
    import pygame
    # Install addon files when found
    if ARCH == "winxp":
        # Add-on not supported on XP
        return
    for addon in reversed(glob("dkafe_*_addon_*.zip")):
        # Installing message...
        from launch import write_text, update_screen, dk_font, pl_font, RED, GREY, MAGENTA, PINK, get_image
        write_text("EXTRACTING ADD-ON PACK", font=dk_font, y=0, fg=RED)
        write_text("The console add-on pack is being extracted and installed.", font=pl_font, y=14, fg=RED)
        _g.screen.blit(get_image("artwork/sprite/pauline.png"), (0, 215))
        write_text("Please wait...", x=22, y=218, bg=MAGENTA, fg=PINK, bubble=True)
        pygame.draw.rect(_g.screen, GREY, [0, 245, 224, 8], 0)
        update_screen()

        # Do Install
        try:
            with zipfile.ZipFile(addon) as zf:
                file_list = zf.namelist()
                for idx, file in enumerate(file_list):
                    if idx % 5 == 0:
                        _progress = round((idx / len(file_list)) * DISPLAY[0])
                        _percent = (idx / len(file_list)) * 100
                        _g.screen.blit(get_image("artwork/sprite/dkblank.png"), (167, 205))
                        if pygame.time.get_ticks() % 5000 < 2000:
                            _g.screen.blit(get_image("artwork/sprite/dk0.png"), (167, 205))
                        elif pygame.time.get_ticks() % 5000 < 3000:
                            _g.screen.blit(get_image("artwork/sprite/dk1.png"), (167, 205))
                        elif pygame.time.get_ticks() % 5000 < 4000:
                            _g.screen.blit(get_image("artwork/sprite/dk2.png"), (167, 205))
                        else:
                            _g.screen.blit(get_image("artwork/sprite/dk3.png"), (167, 205))
                        pygame.draw.rect(_g.screen, RED, [0, 245, _progress, 8], 0)
                        write_text(f'{_percent:.2f}' + "% installed", x=22, y=218, bg=MAGENTA, fg=PINK, bubble=True)
                        update_screen()
                    zf.extract(file)
                    update_screen()
                zf.close()
        except:
            pass

        if ARCH != "win64":
            # load states are pregenerated for Windows 64 and Pi only.
            # For other platforms,  they will be generated on first load of a game, so it's instant on next launch
            pathlist = Path(ROM_DIR).glob('**/*.state')
            for path in pathlist:
                os.remove(str(path))
        os.remove(addon)
        return addon  # restrict to install of 1 add-on for now


if __name__ == "__main__":
    apply_patches_and_addons()
