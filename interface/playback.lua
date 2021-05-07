--[[
#      ___   ___                    .--.
#     (   ) (   )                  /    \
#   .-.| |   | |   ___     .---.   | .`. ;    .--.
#  /   \ |   | |  (   )   / .-, \  | |(___)  /    \
# |  .-. |   | |  ' /    (__) ; |  | |_     |  .-. ;
# | |  | |   | |,' /       .'`  | (   __)   |  | | |
# | |  | |   | .  '.      / .'| |  | |      |  |/  |
# | |  | |   | | `. \    | /  | |  | |      |  ' _.'
# | '  | |   | |   \ \   ; |  ; |  | |      |  .'.-.
# ' `-'  /   | |    \ .  ' `-'  |  | |      '  `-' /  Donkey Kong Arcade Frontend
#  `.__,'   (___ ) (___) `.__.'_. (___)      `.__.'   by Jon Wilson

 DKAFE Interface for Donkey Kong
-------------------------------------------------------------------------------------------------
 Quicker video conversion of input recording with progress and capture of highscore screenshot.
 
 Example playback to video batch file is:
 dkwolf -rompath <ROM_DIR> -video none -sound none -window -nomaximize -playback dkong_06052021-112405.inp -aviwrite dkong.avi -exit_after_playback -autoboot_script <ROOT_DIR>\interface\playback.lua dkong
 
 Shelving this because MAME -aviwrite output is uncompressed and generated AVI files are massive.
-------------------------------------------------------------------------------------------------
]]

if started == nil then
	machine = manager:machine()
	video = machine:video()
	cpu = machine.devices[":maincpu"]
	mem = cpu.spaces["program"]	

	last_level = 0
	last_stage = 0
	started = 1

end

emu.register_frame(function()
	level = mem:read_i8(0xc6229)
	stage = mem:read_i8(0xc6227)
	mode2 = mem:read_i8(0xc600a)  
	
	if level == 1 then
		video.throttled = false
		video.throttle_rate = 4
		video.frameskip = 8
	end

	if mode2 == 12 and level ~= last_level or stage ~= last_stage then
		if stage == 1 then
			stage_name = "Barrels"
		elseif stage == 2 then
			stage_name = "Pies"
		elseif stage == 3 then
			stage_name = "Elevators"
		elseif stage == 4 then
			stage_name = "Rivets"
		elseif stage == 5 then
			stage_name = "Bonus"
		else 
			stage_name = "Unknown"
		end
		print("Level: "..level.." ("..stage_name..")")
		last_level = level
		last_stage = stage
	end
end)
