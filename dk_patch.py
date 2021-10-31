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
import hashlib
from dk_config import ROM_DIR, PATCH_DIR, DKONG_ZIP


def validate_rom():
    """Validate MD5 matches the expected value"""
    if os.path.exists(DKONG_ZIP):
        buffer = open(DKONG_ZIP, 'rb').read()
        return hashlib.md5(buffer).hexdigest() == "a13e81d6ef342d763dc897fe03893392"
    else:
        return True


def apply_patches():
    applied_patches_list = []
    if os.path.exists(DKONG_ZIP):
        ips_files = glob(os.path.join(PATCH_DIR, "*.ips"))
        if ips_files:
            # Read the original ZIP binary
            with open(DKONG_ZIP, 'rb') as f_in:
                dkong_binary = f_in.read()

            # Apply patch and write the resulting hack to a subfolder
            for ips in ips_files:
                name = os.path.splitext(os.path.basename(ips))[0]
                subfolder = os.path.join(ROM_DIR, name)
                if not os.path.exists(subfolder):
                    os.mkdir(subfolder)
                    patch = Patch.load(ips)
                    with open(os.path.join(subfolder, "dkong.zip"), 'w+b') as f_out:
                        f_out.write(patch.apply(dkong_binary))
                        applied_patches_list.append(name)
    return applied_patches_list


if __name__ == "__main__":
    apply_patches()
