import os

INTERFACE_IN = "c:\\dkafe\\interface\\working\\in.txt"
INTERFACE_OUT = "c:\\dkafe\\interface\\working\\out.txt"

DK_CHARMAP = [
    ('10', ' '),
    ('11', 'A'),
    ('12', 'B'),
    ('13', 'C'),
    ('14', 'D'),
    ('15', 'E'),
    ('16', 'F'),
    ('17', 'G'),
    ('18', 'H'),
    ('19', 'I'),
    ('1A', 'J'),
    ('1B', 'K'),
    ('1C', 'L'),
    ('1D', 'M'),
    ('1E', 'N'),
    ('1F', 'O'),
    ('20', 'P'),
    ('21', 'Q'),
    ('22', 'R'),
    ('23', 'S'),
    ('24', 'T'),
    ('25', 'U'),
    ('26', 'V'),
    ('27', 'W'),
    ('28', 'X'),
    ('29', 'Y'),
    ('2A', 'Z'),
    ('2B', '.'),
    ('2C', '-'),
    ('30', '<'),
    ('31', '>'),
    ('34', '='),
    ('35', '-'),
    ('38', '!'),
    ('3A', "'"),
    ('43', ','),
    ('80', '0'),
    ('81', '1'),
    ('82', '2'),
    ('83', '3'),
    ('84', '4'),
    ('85', '5'),
    ('86', '6'),
    ('87', '7'),
    ('88', '8'),
    ('89', '9'),
    ('FB', '?')]

# Export environmental variables for LUA
os.environ["DKAFE_LUA_INTERFACE_IN"] = INTERFACE_IN
os.environ["DKAFE_LUA_INTERFACE_OUT"] = INTERFACE_OUT


def outbound_interface(score="000000", name="DKF"):
    # Process outbound interface
    if os.path.exists(INTERFACE_OUT):
        os.remove(INTERFACE_OUT)

    with open(INTERFACE_OUT, 'w') as f:
        for char in score:
            f.write(char + "\n")
        for char in name:
            for dk_char, regular_char in DK_CHARMAP:
                if char == regular_char:
                    f.write(str(int(dk_char,16)) + "\n")
                    continue



# test
from time import sleep
outbound_interface("330011", "DK?")
os.chdir('c:\\emus\\mame')
os.system("mame64 -window -rompath c:\\emus\\roms -noconsole -autoboot_script c:\\dkafe\\interface\\dkong.lua dkong")

#with open(version_file, 'r') as f:
#  data = f.readlines()

