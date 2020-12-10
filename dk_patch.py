from ips_util import Patch
from zipfile import ZipFile
from glob import glob
from dk_config import *

SUPPLEMENTARY_FILES = {
    "dkongdk2":["d2k11.bin"],
    "dkongfoundry":["dk_f.5at","dk_f.5et","dk_f.5ct","dk_f.5bt"]
}

DKONG_ZIP = os.path.join(ROM_DIR, "dkong.zip")
DKONG_HACKS_DIR = os.path.join(ROM_DIR, "dkong_hacks")
if os.path.exists(DKONG_ZIP):
    ips_files = glob(os.path.join(ROOT_DIR, "patch", "*.ips"))
    if ips_files:
        # Create folder for storing all of the rom hack files
        if not os.path.exists(DKONG_HACKS_DIR):
            os.mkdir(DKONG_HACKS_DIR)

        # Read the original ZIP binary
        with open(DKONG_ZIP, 'rb') as f_in:
            dkong_binary = f_in.read()

        # Apply patch and write the resulting hack to a subfolder
        for ips in ips_files:
            name = os.path.splitext(os.path.basename(ips))[0]
            subfolder = os.path.join(DKONG_HACKS_DIR, name)
            target_zip = os.path.join(subfolder, "dkong.zip")
            if not os.path.exists(subfolder):
                os.mkdir(subfolder)
            patch = Patch.load(ips)
            with open(target_zip, 'w+b') as f_out:
                f_out.write(patch.apply(dkong_binary))

            # If there are supplementary files we will bundle them in the ZIP
            if name in SUPPLEMENTARY_FILES:
                for file in SUPPLEMENTARY_FILES[name]:
                    with ZipFile(target_zip, 'a') as zip:
                        zip.write(os.path.join(ROOT_DIR, "patch", "supplementary", file), file)