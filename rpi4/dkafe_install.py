"""
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Install program for Raspberry Pi4
---------------------------------

Invoked from install_script.sh after installing binary files to /home/pi/dkafe_bin folder
This program handles optional setup items by prompting user.
"""

import os
F_AUTOSTART = "/etc/xdg/lxsession/LXDE-pi/autostart"
F_AUTOSTART_BU = "/etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP"
F_AUTOSTART_BU2 = "/etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP2"
F_PCMAN_CONFIG = "/etc/xdg/pcmanfm/LXDE-pi/desktop-items-0.conf"
F_PCMAN_CONFIG_BU = "/etc/xdg/pcmanfm/LXDE-pi/desktop-items-0-DKAFEBACKUP.conf"
F_DESKTOP_CONFIG = "/usr/share/lightdm/lightdm.conf.d/01_debian.conf"
F_DESKTOP_CONFIG_BU = "/usr/share/lightdm/lightdm.conf.d/01_debian_DKAFEBACKUP.conf"
F_CONFIG = "/boot/config.txt"
F_CONFIG_BU = "/boot/config_DKAFEBACKUP.txt"
F_CONFIG_BU2 = "/boot/config_DKAFEBACKUP2.txt"

GPIO_MAPPING = '''
# GPIO to keyboard inputs
dtoverlay=gpio-key,gpio=17,keycode=105,label="KEY_LEFT"
dtoverlay=gpio-key,gpio=27,keycode=106,label="KEY_RIGHT"
dtoverlay=gpio-key,gpio=22,keycode=103,label="KEY_UP"
dtoverlay=gpio-key,gpio=23,keycode=108,label="KEY_DOWN"
dtoverlay=gpio-key,gpio=24,keycode=29,label="KEY_LEFTCTRL"
dtoverlay=gpio-key,gpio=25,keycode=56,label="KEY_LEFTALT"
dtoverlay=gpio-key,gpio=5,keycode=2,label="KEY_1"
dtoverlay=gpio-key,gpio=6,keycode=3,label="KEY_2"
dtoverlay=gpio-key,gpio=16,keycode=6,label="KEY_5"
dtoverlay=gpio-key,gpio=26,keycode=1,label="KEY_ESC"

'''


def yesno(question):
    print('')
    prompt = f'{question} ? (y/n): '
    ans = input(prompt).strip().lower()
    if ans not in ['y', 'n']:
        print(f'{ans} is invalid, please try again...')
        return yesno(question)
    if ans == 'y':
        return True
    return False


def main():
    changes_made = False

    # Reinstate the default autostart file if necessary
    if not os.path.exists(F_AUTOSTART):
        if os.path.exists(F_AUTOSTART_BU):
            os.system(f"sudo cp {F_AUTOSTART_BU} {F_AUTOSTART}")
        elif os.path.exists(F_AUTOSTART_BU2):
            os.system(f"sudo cp {F_AUTOSTART_BU2} {F_AUTOSTART}")

    # Clean up DKAFE backup files ready for fresh install
    for f in F_AUTOSTART_BU, F_AUTOSTART_BU2, F_PCMAN_CONFIG_BU, F_DESKTOP_CONFIG_BU, F_CONFIG_BU, F_CONFIG_BU2:
        if os.path.exists(f):
            os.system(f"sudo rm -f {f}")

    # Proceed with install
    if os.path.exists(F_AUTOSTART):
        os.system(f"sudo cp {F_AUTOSTART} {F_AUTOSTART_BU}")
        if os.path.exists(F_AUTOSTART_BU):
            # -------- Launch DKAFE on boot --------
            # --------------------------------------
            answer = yesno("Launch DKAFE on boot (recommend)")
            if answer:
                # append DKAFE start script to autoboot file
                with open(F_AUTOSTART, "a") as f:
                    f.write("@/home/pi/dkafe_bin/dkafe_start.sh\n")

            os.system(f"sudo cp {F_AUTOSTART} {F_AUTOSTART_BU2}")
            if os.path.exists(F_AUTOSTART_BU2):
                # -------- Hide the Raspberry Pi taskbar --------
                # -----------------------------------------------
                answer = yesno("Hide the Pi taskbar (recommend)")
                if answer:
                    changes_made = True
                    # comment the "lxpanel" line in autoboot file
                    with open(F_AUTOSTART, "w") as f_out:
                        with open(F_AUTOSTART_BU2) as f_in:
                            for line in f_in.readlines():
                                if "lxpanel" in line.lower():
                                    f_out.write("#" + line)
                                else:
                                    f_out.write(line)

    # -------- Hide the Raspberry Pi Desktop (Icon, background and welcome image) --------
    # ------------------------------------------------------------------------------------
    if os.path.exists(F_PCMAN_CONFIG):
        os.system(f"sudo cp {F_PCMAN_CONFIG} {F_PCMAN_CONFIG_BU}")
        if os.path.exists(F_PCMAN_CONFIG_BU):
            answer = yesno("Hide the Pi Desktop (recommend)")
            if answer:
                changes_made = True
                # Blank out the desktop splash image
                os.system("sudo cp /home/pi/dkafe_bin/artwork/blank.png /usr/share/plymouth/themes/pix/splash.png")
                # Update desktop options
                with open(F_PCMAN_CONFIG, "w") as f_out:
                    with open(F_PCMAN_CONFIG_BU) as f_in:
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

    # -------- Hide the Raspberry Pi mouse cursor --------
    # ----------------------------------------------------
    if os.path.exists(F_DESKTOP_CONFIG):
        os.system(f"sudo cp {F_DESKTOP_CONFIG} {F_DESKTOP_CONFIG_BU}")
        if os.path.exists(F_DESKTOP_CONFIG_BU):
            answer = yesno("Hide the Pi mouse cursor (recommend)")
            if answer:
                changes_made = True
                # add no cursor command to end of desktop config file
                with open(F_DESKTOP_CONFIG, "a") as f:
                    f.write("xserver-command=X -nocursor\n")

    # -------- Use headphone jack for audio --------
    # ----------------------------------------------
    answer = yesno("Use headphone jack for audio")
    if answer:
        changes_made = True
        os.system("sudo raspi-config nonint do_audio 1")

    if os.path.exists(F_CONFIG):
        os.system(f"sudo cp {F_CONFIG} {F_CONFIG_BU}")
        if os.path.exists(F_CONFIG_BU):
            # -------- Rotate display --------
            # --------------------------------
            answer = yesno("Rotate display")
            if answer:
                answer = yesno("Rotate display to the left")
                if answer:
                    changes_made = True
                    with open(F_CONFIG, "a") as f_out:
                        f_out.write("\n# Rotate display\ndisplay_rotate=3\n")
                else:
                    answer = yesno("Rotate display to the right")
                    if answer:
                        changes_made = True
                        with open(F_CONFIG, "a") as f_out:
                            f_out.write("\n# Rotate display\ndisplay_rotate=1\n")

            # -------- Optimise framebuffer (recommended for HDMI output) --------
            # --------------------------------------------------------------------
            answer = yesno("Optimise framebuffer (recommend for HDMI and VGA displays)")
            if answer:
                os.system(f"sudo cp {F_CONFIG} {F_CONFIG_BU2}")
                changes_made = True
                with open(F_CONFIG, "w") as f_out:
                    with open(F_CONFIG_BU2) as f_in:
                        for line in f_in.readlines():
                            if "framebuffer_width=" in line.lower():
                                f_out.write("framebuffer_width=448\n")
                            elif "framebuffer_height=" in line.lower():
                                f_out.write("framebuffer_height=512\n")
                            else:
                                f_out.write(line)
            # -------- Force 640x480 mode on boot --------
            # --------------------------------------------
            answer = yesno("Force 640x480 mode on boot (recommend for performance)")
            if answer:
                os.system(f"sudo cp {F_CONFIG} {F_CONFIG_BU2}")
                changes_made = True
                with open(F_CONFIG, "w") as f_out:
                    with open(F_CONFIG_BU2) as f_in:
                        for line in f_in.readlines():
                            if "disable_overscan=" in line.lower():
                                f_out.write("disable_overscan=1\n")
                            elif "hdmi_group=" in line.lower():
                                f_out.write("hdmi_group=2\n")
                            elif "hdmi_mode=" in line.lower():
                                f_out.write("hdmi_mode=4\n")
                            else:
                                f_out.write(line)
            # -------- Map GPIO to keyboard input controls --------
            # -----------------------------------------------------
            answer = yesno("Map GPIO to keyboard input (for arcade controls)")
            if answer:
                changes_made = True
                # update /boot/config.txt
                with open(F_CONFIG, "a") as f_out:
                    f_out.write(GPIO_MAPPING)

    # -------- Disable non-essential services --------
    # ------------------------------------------------
    answer = yesno("Disable non-essential services (recommend)")
    if answer:
        changes_made = True
        print("Disabling services, please wait...")
        os.system("sudo systemctl disable dphys-swapfile.service --quiet")
        os.system("sudo systemctl disable keyboard-setup.service --quiet")
        os.system("sudo systemctl disable apt-daily.service --quiet")
        os.system("sudo systemctl disable hciuart.service --quiet")
        os.system("sudo systemctl disable avahi-daemon.service --quiet")
        os.system("sudo systemctl disable triggerhappy.service --quiet")
        os.system("sudo systemctl disable systemd-timesyncd.service --quiet")
        os.system("sudo systemctl disable gldriver-test.service --quiet")
        os.system("sudo systemctl disable systemd-rfkill.service --quiet")

        # -------- Disable networking services --------
        # ---------------------------------------------
        answer = yesno("Disable network services (WiFi, SSH)")
        if answer:
            print("Disabling services, please wait...")
            os.system("sudo systemctl disable dhcpcd.service --quiet")
            os.system("sudo systemctl disable networking.service --quiet")
            os.system("sudo systemctl disable ssh.service --quiet")
            os.system("sudo systemctl disable wpa_supplicant.service --quiet")

    # -------- Reboot system --------
    # -------------------------------
    answer = yesno("Reboot now")
    if answer:
        os.system("reboot")
    else:
        if changes_made:
            answer = yesno("Please confirm about reboot.\nSystem changes were made so reboot is recommended.\nReboot system")
            if answer:
                os.system("reboot")

    print("--------------------------------------------------")
    print("Installation was successful!")
    print("--------------------------------------------------")


if __name__ == '__main__':
    main()
