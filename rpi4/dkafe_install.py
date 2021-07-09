#
#       ___   ___                    .--.
#      (   ) (   )                  /    \
#    .-.| |   | |   ___     .---.   | .`. ;    .--.
#   /   \ |   | |  (   )   / .-, \  | |(___)  /    \
#  |  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ;
#  | |  | |   | |,' /       .'`  | (   __)   |  | | |
#  | |  | |   | .  '.      / .'| |  | |      |  |/  |
#  | |  | |   | | `. \    | /  | |  | |      |  ' _.'
#  | '  | |   | |   \ \   ; |  ; |  | |      |  .'.-.
#  ' `-'  /   | |    \ .  ' `-'  |  | |      '  `-' /  Donkey Kong Arcade Frontend
#   `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'   by Jon Wilson
#
# ----------------------------------------------------------------------------------------------
#  Install program for Raspberry Pi4
# ----------------------------------------------------------------------------------------------
#  Invoked from install_script.sh after installing binary files to /home/pi/dkafe_bin folder
#  This program handles optional setup items by prompting user.
#
#  The recommended setup is to answer "y" to the following questions:
#  1) Rotate the display
#  2) Launch DKAFE on boot
#  3) Hide startup messages
#  4) Hide the Pi taskbar
#  5) Hide the Pi desktop
#  6) Hide the Pi mouse cursor
#  7) Use headphone jack for audio
#  8) Force 640x480 mode on boot (for scan line generators)
#  9) Map GPIO to keyboard input controls
#  10) Install wmctrl to manage windows
#  11) Disable non-essential Services
#  12) Disable networking services (WiFi, SSH)
#  13) Reboot now
# ----------------------------------------------------------------------------------------------
import os
AUTOSTART_FILE = "/etc/xdg/lxsession/LXDE-pi/autostart"
AUTOSTART_FILE_BU = "/etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP"
AUTOSTART_FILE_BU2 = "/etc/xdg/lxsession/LXDE-pi/autostart_DKAFEBACKUP2"
PCMAN_CONFIG_FILE = "/etc/xdg/pcmanfm/LXDE-pi/desktop-items-0.conf"
PCMAN_CONFIG_FILE_BU = "/etc/xdg/pcmanfm/LXDE-pi/desktop-items-0-DKAFEBACKUP.conf"
DESKTOP_CONFIG_FILE = "/usr/share/lightdm/lightdm.conf.d/01_debian.conf"
DESKTOP_CONFIG_FILE_BU = "/usr/share/lightdm/lightdm.conf.d/01_debian_DKAFEBACKUP.conf"
CMDLINE_FILE = "/boot/cmdline.txt"
CMDLINE_FILE_BU = "/boot/cmdline_DKAFEBACKUP.txt"
CONFIG_FILE = "/boot/config.txt"
CONFIG_FILE_BU = "/boot/config_DKAFEBACKUP.txt"

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
    print("--------------------------------------------------")
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
     ___   ___                    .--.              
    (   ) (   )                  /    \\            
  .-.| |   | |   ___     .---.   | .`. ;    .--.   
 /   \\ |   | |  (   )   / .-, \\  | |(___)  /    \\  
|  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ; 
| |  | |   | |,' /       .'`  | (   __)   |  | | | 
| |  | |   | .  '.      / .'| |  | |      |  |/  | 
| |  | |   | | `. \\    | /  | |  | |      |  ' _.' 
| '  | |   | |   \\ \\   ; |  ; |  | |      |  .'.-. 
' `-'  /   | |    \\ .  ' `-'  |  | |      '  `-' / 
 `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'  
 
--------  I n s t a l l    O p t i o n s  --------
 
 """)
    changes_made = False

    # 1) Rotate the Display
    script = START_SCRIPT.replace("<SELECTION>", "--scale 1x1")
    answer = yesno("Rotate the display")
    if answer:
        answer = yesno("Rotate to the Left")
        if answer:
            changes_made = True
            # script = START_SCRIPT.replace("<SELECTION>", "--scale 1x0.875 --rotate left")
            # 0.8 looks crisper
            script = START_SCRIPT.replace("<SELECTION>", "--scale 1x0.8 --rotate left")
            os.system("xrandr --output HDMI-1 --rotate left")  # rotate now to assist install
        else:
            answer = yesno("Rotate to the Right")
            if answer:
                changes_made = True
                # script = START_SCRIPT.replace("<SELECTION>", "--scale 1x0.875 --rotate right")
                # 0.8 looks crisper
                script = START_SCRIPT.replace("<SELECTION>", "--scale 1x0.8 --rotate right")
                os.system("xrandr --output HDMI-1 --rotate right")  # rotate now to assist install
    if script:
        # Overwrite the default start script
        with open("/home/pi/dkafe_bin/dkafe_start.sh", "w") as f:
            f.write(script)

    if os.path.exists(AUTOSTART_FILE) and not os.path.exists(AUTOSTART_FILE_BU):
        os.system(f"sudo cp {AUTOSTART_FILE} {AUTOSTART_FILE_BU}")
        if os.path.exists(AUTOSTART_FILE_BU):
            # 2) Launch DKAFE on boot
            answer = yesno("Launch DKAFE on boot")
            if answer:
                # append DKAFE start script to autoboot file
                with open(AUTOSTART_FILE, "a") as f:
                    f.write("@/home/pi/dkafe_bin/dkafe_start.sh\n")

                if os.path.exists(CMDLINE_FILE) and not os.path.exists(CMDLINE_FILE_BU):
                    os.system(f"sudo cp {CMDLINE_FILE} {CMDLINE_FILE_BU}")
                    if os.path.exists(CMDLINE_FILE_BU):
                        # 3) Hide startup messages
                        answer = yesno("Hide system startup messages")
                        if answer:
                            # update /boot/cmdline.txt
                            with open(CMDLINE_FILE, "w") as f_out:
                                with open(CMDLINE_FILE_BU, "r") as f_in:
                                    cmd = f_in.readline()
                                    cmd = cmd.replace("loglevel=3", "loglevel=0")
                                    cmd = cmd.replace("console=tty1", "console=tty3")
                                    if " logo.nologo " not in cmd:
                                        cmd += " logo.nologo"
                                    if " quiet " not in cmd:
                                        cmd += " quiet"
                                    if "vt.global_cursor_default=0" not in cmd:
                                        cmd += " vt.global_cursor_default=0"
                                    f_out.write(cmd)
            # ----
            os.system(f"sudo cp {AUTOSTART_FILE} {AUTOSTART_FILE_BU2}")
            if os.path.exists(AUTOSTART_FILE_BU2):
                # 4) Hide the Raspberry Pi taskbar
                answer = yesno("Hide the Pi taskbar")
                if answer:
                    changes_made = True
                    # comment the "lxpanel" line in autoboot file
                    with open(AUTOSTART_FILE, "w") as f_out:
                        with open(AUTOSTART_FILE_BU2, "r") as f_in:
                            for line in f_in.readlines():
                                if "lxpanel" in line.lower():
                                    f_out.write("#" + line)
                                else:
                                    f_out.write(line)

    # 5) Hide the Raspberry Pi Desktop (Icon, background and welcome image)
    if os.path.exists(PCMAN_CONFIG_FILE) and not os.path.exists(PCMAN_CONFIG_FILE_BU):
        os.system(f"sudo cp {PCMAN_CONFIG_FILE} {PCMAN_CONFIG_FILE_BU}")
        if os.path.exists(PCMAN_CONFIG_FILE_BU):
            answer = yesno("Hide the Pi Desktop")
            if answer:
                changes_made = True
                # Blank out the desktop splash image
                os.system("sudo cp /home/pi/dkafe_bin/artwork/blank.png /usr/share/plymouth/themes/pix/splash.png")
                # Update desktop options
                with open(PCMAN_CONFIG_FILE, "w") as f_out:
                    with open(PCMAN_CONFIG_FILE_BU, "r") as f_in:
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

    # 6) Hide the Raspberry Pi mouse cursor
    if os.path.exists(DESKTOP_CONFIG_FILE) and not os.path.exists(DESKTOP_CONFIG_FILE_BU):
        os.system(f"sudo cp {DESKTOP_CONFIG_FILE} {DESKTOP_CONFIG_FILE_BU}")
        if os.path.exists(DESKTOP_CONFIG_FILE_BU):
            answer = yesno("Hide the Pi mouse cursor")
            if answer:
                changes_made = True
                # add no cursor command to end of desktop config file
                with open(DESKTOP_CONFIG_FILE, "a") as f:
                    f.write("xserver-command=X -nocursor\n")

    # 7) Use headphone jack for audio
    answer = yesno("Use headphone jack for audio")
    if answer:
        changes_made = True
        os.system("sudo raspi-config nonint do_audio 1")

    if os.path.exists(CONFIG_FILE) and not os.path.exists(CONFIG_FILE_BU):
        os.system(f"sudo cp {CONFIG_FILE} {CONFIG_FILE_BU}")
        if os.path.exists(CONFIG_FILE_BU):
            # 8) Force 640x480 mode on boot
            answer = yesno("Force 640x480 mode on boot (for scan line generators)")
            if answer:
                changes_made = True
                with open(CONFIG_FILE, "w") as f_out:
                    with open(CONFIG_FILE_BU, "r") as f_in:
                        for line in f_in.readlines():
                            if "disable_overscan=" in line.lower():
                                f_out.write("disable_overscan=1\n")
                            elif "hdmi_group=" in line.lower():
                                f_out.write("hdmi_group=1\n")
                            elif "hdmi_mode=" in line.lower():
                                f_out.write("hdmi_mode=1\n")
                            else:
                                f_out.write(line)
            # 9) Map GPIO to keyboard input controls
            answer = yesno("Map GPIO to keyboard input controls ?")
            if answer:
                changes_made = True
                # update /boot/config.txt
                with open(CONFIG_FILE, "a") as f_out:
                    f_out.write(GPIO_MAPPING)

            # disable the annoying splash screen while we're here
            with open(CONFIG_FILE, "a") as f_out:
                f_out.write("# Disable the rainbow splash screen\n")
                f_out.write("disable_splash=1\n")

    # 10) Install wmctrl to manage windows
    answer = yesno("Install wmctrl to manage windows")
    if answer:
        os.system("sudo apt-get install wmctrl")
        changes_made = True

    # 11) Disable non-essential services
    # and
    # 12) Disable networking services
    answer = yesno("Disable non-essential services")
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
        # ----
        answer = yesno("Disable network services (WiFi, SSH)")
        if answer:
            print("Disabling services, please wait...")
            os.system("sudo systemctl disable dhcpcd.service --quiet")
            os.system("sudo systemctl disable networking.service --quiet")
            os.system("sudo systemctl disable ssh.service --quiet")
            os.system("sudo systemctl disable wpa_supplicant.service --quiet")

    # 13) Reboot system
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
