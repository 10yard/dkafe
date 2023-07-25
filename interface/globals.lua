--[[
ooooooooo   oooo   oooo       o       ooooooooooo  ooooooooooo
 888    88o  888  o88        888       888          888
 888    888  888888         8  88      888ooo8      888ooo8
 888    888  888  88o      8oooo88     888          888
o888ooo88   o888o o888o  o88o  o888o  o888o        o888ooo8888
                                        by Jon Wilson (10yard)

Global variables
---------------------------------------------------------------
]]

-- Memory/state
---------------------------------------------------------------
mame_version = tonumber(emu.app_version())
if mame_version >= 0.227 then
	mac = manager.machine
	ports = mac.ioport.ports
	video = mac.video
elseif mame_version >= 0.196 then
	mac = manager:machine()
	ports = mac:ioport().ports
	video = mac:video()
else
	print("ERROR: The DKAFE system requires MAME version 0.196 or greater.")
end
if mac ~= nil then
	screen = mac.screens[":screen"]
	cpu = mac.devices[":maincpu"]
	mem = cpu.spaces["program"]
end

-- Options data
---------------------------------------------------------------
data_emulator = os.getenv("DATA_EMULATOR")
data_file = os.getenv("DATA_FILE")
data_subfolder = os.getenv("DATA_SUBFOLDER")
data_credits = os.getenv("DATA_CREDITS")
data_autostart = os.getenv("DATA_AUTOSTART")

--Award targets and progress data
---------------------------------------------------------------
data_show_award_targets = os.getenv("DATA_SHOW_AWARD_TARGETS")
data_show_award_progress = os.getenv("DATA_SHOW_AWARD_PROGRESS")
data_allow_skip_intro = os.getenv("DATA_ALLOW_SKIP_INTRO")
data_show_hud = os.getenv("DATA_SHOW_HUD")
data_toggle_hud = tonumber(data_show_hud)
data_last_toggle = 0

--1st, 2nd and 3rd target scores for prize awards data
---------------------------------------------------------------
data_score1 = tonumber(os.getenv("DATA_SCORE1"))
data_score1_k = os.getenv("DATA_SCORE1_K")
data_score1_award = os.getenv("DATA_SCORE1_AWARD")
data_score2 = tonumber(os.getenv("DATA_SCORE2"))
data_score2_k = os.getenv("DATA_SCORE2_K")
data_score2_award = os.getenv("DATA_SCORE2_AWARD")
data_score3 = tonumber(os.getenv("DATA_SCORE3"))
data_score3_k = os.getenv("DATA_SCORE3_K")
data_score3_award = os.getenv("DATA_SCORE3_AWARD")
