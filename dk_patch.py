from ips_util import Patch
from glob import glob
from dk_config import *

DKONG_ZIP = os.path.join(ROM_DIR, "dkong.zip")
if os.path.exists(DKONG_ZIP):
    ips_files = glob(os.path.join(ROOT_DIR, "patch", "*.ips"))
    if ips_files:
        # Read the original ZIP binary
        with open(DKONG_ZIP, 'rb') as f_in:
            dkong_binary = f_in.read()

        # Apply patch and write the resulting hack to a subfolder
        for ips in ips_files:
            hack_name = os.path.splitext(os.path.basename(ips))[0]
            hack_dir = os.path.join(ROM_DIR, hack_name)
            if not os.path.exists(hack_dir):
                os.mkdir(hack_dir)
            patch = Patch.load(ips)
            with open(os.path.join(hack_dir, "dkong.zip"), 'w+b') as f_out:
                f_out.write(patch.apply(dkong_binary))