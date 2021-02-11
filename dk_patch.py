import os
from ips_util import Patch
from glob import glob
from dk_config import ROM_DIR, DKONG_ZIP, PATCH_DIR


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
                target_zip = os.path.join(subfolder, "dkong.zip")
                if not os.path.exists(subfolder):
                    os.mkdir(subfolder)
                    patch = Patch.load(ips)
                    with open(target_zip, 'w+b') as f_out:
                        f_out.write(patch.apply(dkong_binary))
                        applied_patches_list.append(name)
    return applied_patches_list


if __name__ == "__main__":
    apply_patches()
