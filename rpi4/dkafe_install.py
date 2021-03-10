# DKAFE - Install Script for RPi
# Invoked from install_script.sh after extracting binary files to /home/pi/dkafe_bin folder
# This program handles optional setup items by prompting user.
#
# The recommended setup is to answer "y" to the following questions:
# 1) Launch DKAFE on boot
# 2) Hide the Pi Taskbar
# 3) Hide the Pi Desktop
# 4) Hide the Pi Mouse Cursor
# 5) Rotate the Display
# 6) Reboot
import os
AUTOSTART_FILE = "/etc/xdg/lxsession/LXDE-pi/autostart"
AUTOSTART_FILE_BACKUP = "/etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP"
AUTOSTART_FILE_BACKUP2 = "/etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP2"
PCMAN_CONFIG_FILE = "/etc/xdg/pcmanfm/LXDE-pi/desktop-items-0.conf"
PCMAN_CONFIG_FILE_BACKUP = "/etc/xdg/pcmanfm/LXDE-pi/desktop-items-0-DKAFEBACKUP.conf"
DESKTOP_CONFIG_FILE = "/usr/share/lightdm/lightdm.conf.d/01_debian.conf"
DESKTOP_CONFIG_FILE_BACKUP = "/usr/share/lightdm/lightdm.conf.d/01_debian_DKAFEBACKUP.conf"

START_SCRIPT = """# Run this script to start DKAFE
#
# Set screen resolution and launch DKAFE
xrandr --output HDMI-1 --auto
xrandr --output HDMI-1 --mode 640x480 <SELECTION>

# Disable screen blanking
sudo xset s off
sudo xset -dpms
sudo xset s noblank

# Run the binary from dkafe_bin folder
cd /home/pi/dkafe_bin
./launch
"""


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
    print("""
----------------------------------
 
 ###    #  #    ##    ####   ####
 #  #   # #    #  #   #      #
 #  #   ##     ####   ###    ###
 #  #   # #    #  #   #      #
 ###    #  #   #  #   #      ####

-------- INSTALL OPTIONS ---------

""")

    # 1) Launch DKAFE on boot
    # and
    # 2) Hide the Raspberry Pi taskbar
    if os.path.exists(AUTOSTART_FILE) and not os.path.exists(AUTOSTART_FILE_BACKUP):
        os.system(f"sudo cp {AUTOSTART_FILE} {AUTOSTART_FILE_BACKUP}")
        if os.path.exists(AUTOSTART_FILE_BACKUP):
            answer = yesno("Launch DKAFE on boot")
            if answer:
                # append DKAFE start script to autoboot file
                with open(AUTOSTART_FILE, "a") as f:
                    f.write("@/home/pi/dkafe_bin/dkafe_start.sh\n")

            os.system(f"sudo cp {AUTOSTART_FILE} {AUTOSTART_FILE_BACKUP2}")
            if os.path.exists(AUTOSTART_FILE_BACKUP2):
                answer = yesno("Hide the Pi taskbar")
                if answer:
                    # comment the "lxpanel" line in autoboot file
                    with open(AUTOSTART_FILE, "w") as f_out:
                        with open(AUTOSTART_FILE_BACKUP2, "r") as f_in:
                            for line in f_in.readlines():
                                if "lxpanel" in line.lower():
                                    f_out.write("#" + line)
                                else:
                                    f_out.write(line)

    # 3) Hide the Raspberry Pi Desktop (Icon and background)
    if os.path.exists(PCMAN_CONFIG_FILE) and not os.path.exists(PCMAN_CONFIG_FILE_BACKUP):
        os.system(f"sudo cp {PCMAN_CONFIG_FILE} {PCMAN_CONFIG_FILE_BACKUP}")
        if os.path.exists(PCMAN_CONFIG_FILE_BACKUP):
            answer = yesno("Hide the Pi Desktop (Background and Icons)")
            if answer:
                with open(PCMAN_CONFIG_FILE, "w") as f_out:
                    with open(PCMAN_CONFIG_FILE_BACKUP, "r") as f_in:
                        for line in f_in.readlines():
                            if "wallpaper=" in line.lower():
                                f_out.write("wallpaper=/home/pi/dkafe_bin/artwork/blank.png\n")
                            elif "desktop_bg=" in line.lower():
                                f_out.write("desktop_bg=000000000000\n")
                            elif "show_trash=" in line.lower():
                                f_out.write("show_trash=0\n")
                            elif "show_mounts=" in line.lower():
                                f_out.write("show_mounts=0\n")
                            else:
                                f_out.write(line)

    # 4) Hide the Raspberry Pi mouse cursor
    if os.path.exists(DESKTOP_CONFIG_FILE) and not os.path.exists(DESKTOP_CONFIG_FILE_BACKUP):
        os.system(f"sudo cp {DESKTOP_CONFIG_FILE} {DESKTOP_CONFIG_FILE_BACKUP}")
        if os.path.exists(DESKTOP_CONFIG_FILE_BACKUP):
            answer = yesno("Hide the Pi mouse cursor")
            if answer:
                # add no cursor command to end of desktop config file
                with open(DESKTOP_CONFIG_FILE, "a") as f:
                    f.write("xserver-command=X -nocursor\n")

    # 5) Rotate the Display
    script = START_SCRIPT.replace("<SELECTION>", "--scale 1x1")
    answer = yesno("Rotate the display")
    if answer:
        answer = yesno("Rotate to the Left")
        if answer:
            script = START_SCRIPT.replace("<SELECTION>", "--scale 1x0.8 --rotate left")
        else:
            answer = yesno("Rotate to the Right")
            if answer:
                script = START_SCRIPT.replace("<SELECTION>", "--scale 1x0.8 --rotate right")
    if script:
        # Overwrite the default start script
        with open("/home/pi/dkafe_bin/dkafe_start.sh", "w") as f:
            f.write(script)

    # 6) Reboot
    answer = yesno("Reboot system")
    if answer:
        # os.system("sudo apt-get update")
        os.system("reboot")


if __name__ == '__main__':
    main()
