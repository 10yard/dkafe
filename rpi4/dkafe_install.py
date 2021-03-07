# DKAFE - Raspberry Pi Install Script
# Invoked from install_script.sh after extracting binary files to /home/pi/dkafe_bin folder
# This program handles the optional setup items by prompting user.
#
# The recommended setup is to answer "y" to the following questions:
# 1) Adjust screen resolution to 640x480
# 2) Launch DKAFE on boot
# 3) Hide Raspberry Pi taskbar
# 4) Hide Raspberry Pi mouse cursor
# 5) Use a black Raspberry Pi desktop background
# 6) Update system and reboot
import os
AUTOSTART_FILE = "/etc/xdg/lxsession/LXDE-pi/autostart"
AUTOSTART_FILE_BACKUP = "/etc/xdg/lxsession/LXDE-pi/autostart_dkafebackup"
AUTOSTART_FILE_BACKUP2 = "/etc/xdg/lxsession/LXDE-pi/autostart_dkafebackup2"
DESKTOP_CONFIG_FILE = "/usr/share/lightdm/lightdm.conf.d/01_debian.conf"
DESKTOP_CONFIG_FILE_BACKUP = "/usr/share/lightdm/lightdm.conf.d/01_debian_dkafebackup.conf"


def yesno(question):
    prompt = f'{question} ? (y/n): '
    ans = input(prompt).strip().lower()
    if ans not in ['y', 'n']:
        print(f'{ans} is invalid, please try again...')
        return yesno(question)
    if ans == 'y':
        return True
    return False


def main():
    print('DKAFE: Raspberry Pi Setup Options')
    print('---------------------------------')
    print('')
    print('It is recommended to answer "y" to the following questions.')
    print('')

    # 1) Adjust screen resolution to 640x480
    answer = yesno("Adjust screen resolution to 640x480")
    if answer:
        os.system("xrandr --output HDMI-1 --mode 640x480")

    # 2) Launch DKAFE on boot
    # and
    # 3) Hide Raspberry Pi taskbar
    if os.path.exists(AUTOSTART_FILE):
        os.system(f"sudo cp {AUTOSTART_FILE} {AUTOSTART_FILE_BACKUP}")
        if os.path.exists(AUTOSTART_FILE_BACKUP):
            answer = yesno("Launch DKAFE on boot")
            if answer:
                # append DKAFE start script to autoboot file
                with open(AUTOSTART_FILE, "a") as f:
                    f.write("@/home/pi/dkafe_bin/dkafe_start.sh")

            os.system(f"sudo cp {AUTOSTART_FILE} {AUTOSTART_FILE_BACKUP2}")
            if os.path.exists(AUTOSTART_FILE_BACKUP2):
                answer = yesno("Hide the Raspberry Pi taskbar")
                if answer:
                    # comment the "lxpanel" line in autoboot file
                    with open(AUTOSTART_FILE, "w") as f_out:
                        with open(AUTOSTART_FILE_BACKUP2, "r") as f_in:
                            for line in f_in.readlines():
                                if "lxpanel" in line.lower():
                                    f_out.write("#" + line)
                                else:
                                    f_out.write(line)

    # 4) Hide the Raspberry Pi mouse cursor
    if os.path.exists(DESKTOP_CONFIG_FILE):
        os.system(f"sudo cp {DESKTOP_CONFIG_FILE} {DESKTOP_CONFIG_FILE_BACKUP}")
        answer = yesno("Hide the Raspberry Pi mouse cursor")
        if answer:
            # add no cursor command to end of desktop config file
            with open(DESKTOP_CONFIG_FILE, "a") as f:
                f.write("xserver-command=X -nocursor")

    # 5) Use a black Raspberry Pi desktop background
    answer = yesno("Use a black Raspberry Pi desktop background")
    if answer:
        os.system("pcmanfm --set-wallpaper /home/pi/dkafe_bin/artwork/blank.png")

    # 6) Update system and reboot
    answer = yesno("Update system and reboot")
    if answer:
        os.system("sudo apt-get update")
        os.system("reboot")


if __name__ == '__main__':
    main()
