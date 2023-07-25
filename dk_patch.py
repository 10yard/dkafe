"""
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Automatically generate roms from .ips patch files
-------------------------------------------------
"""
import os
from ips_util import Patch
from glob import glob
import shutil
import hashlib
import zipfile
from dk_config import ROM_DIR, PATCH_DIR, ROM_CONTENTS, DKONG_ZIP, DKONGJR_ZIP, DKONG3_ZIP, CKONG_ZIP, CKONGPT2_ZIP, BIGKONG_ZIP
from dk_system import is_pi, copy


FIX_ALTERNATIVE_MD5 = "f116efa820a7cedd64bcc66513be389d", "d57b26931fc953933ee2458a9552541e", \
                      "aa282b72ac409793b36780c99b26d07b", "e883b4225a76a79f38cf1db7c340aa8e", \
                      "eb6571036ff25e8e5db5289f5524ab76", "5897e79286e19c91eb3eca657a8c574c", \
                      "480d0f113e8c7069b50ba807cf4b2a24", "394a7d367c9926c1d151dd87814c77f4"


def validate_rom():
    """Validate MD5 matches the expected value"""
    if os.path.exists(DKONG_ZIP):
        buffer = open(DKONG_ZIP, 'rb').read()
        md5 = hashlib.md5(buffer).hexdigest()
        if md5 == "a13e81d6ef342d763dc897fe03893392":
            # ZIP is verified
            return True
        elif md5 in FIX_ALTERNATIVE_MD5:
            # ZIP has a recognised MD5 and can be converted using patch file
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
            # Last resort:
            # Check the ZIP contains all of the required files
            z = zipfile.ZipFile(DKONG_ZIP)
            for filename in ROM_CONTENTS:
                if filename not in z.namelist():
                    return False
            return True
    else:
        # No rom file so a verification error not is returned
        return True


def apply_patches():
    applied_patches_list = []

    if is_pi():
        # Look for DK roms (and Crazy Kong) on the /boot partition of Pi when not found in the roms folder
        # User may not have provided them at install time
        for rom in DKONG_ZIP, DKONGJR_ZIP, DKONG3_ZIP, CKONG_ZIP, CKONGPT2_ZIP, BIGKONG_ZIP:
            if not os.path.exists(rom) and os.path.exists(f'/boot/{os.path.basename(rom)}'):
                copy(f'/boot/{os.path.basename(rom)}', ROM_DIR)
            if not os.path.exists(rom) and os.path.exists(f'/boot/dkafe_bin/{os.path.basename(rom)}'):
                copy(f'/boot/dkafe_bin/{os.path.basename(rom)}', ROM_DIR)

    if os.path.exists(DKONG_ZIP):
        # Proceed with the patching
        ips_files = glob(os.path.join(PATCH_DIR, "dkong*.ips"))
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
                    else:
                        # Patching DK rom and writing to subfolder
                        os.mkdir(subfolder)
                        patch = Patch.load(ips)
                        with open(os.path.join(subfolder, "dkong.zip"), 'w+b') as f_out:
                            f_out.write(patch.apply(dkong_binary))
                            applied_patches_list.append(name)

    return applied_patches_list


if __name__ == "__main__":
    apply_patches()
