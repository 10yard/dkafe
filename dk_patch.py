from ips_util import Patch
from glob import glob
from dk_config import *

DKONG_ZIP = os.path.join(ROM_DIR, "dkong.zip")
PATCH_DIR = os.path.join(ROOT_DIR, "patch")

if os.path.exists(DKONG_ZIP):
    ips_files = glob(os.path.join(PATCH_DIR, "*.ips"))
    if ips_files:
        # Create rom folder if it does not exist
        if not os.path.exists(ROM_DIR):
            os.mkdir(ROM_DIR)

        # Read the original ZIP binary
        with open(DKONG_ZIP, 'rb') as f_in:
            dkong_binary = f_in.read()

        # Apply patch and write the resulting hack to a subfolder
        for ips in ips_files:
            name = os.path.splitext(os.path.basename(ips))[0]
            subfolder = os.path.join(ROM_DIR, name)
            target_zip = os.path.join(subfolder, "dkong.zip")
            if not os.path.exists(subfolder):
                os.mkdir(subfolder)

                patch = Patch.load(ips)
                with open(target_zip, 'w+b') as f_out:
                    f_out.write(patch.apply(dkong_binary))
