-- Refocus DKAFE on exit (Windows Only)
-- by Jon Wilson (10yard)
--
-----------------------------------------------------------------------------------------
local exports = {
	name = "refocus",
	version = "0.1",
	description = "Refocus DKAFE on exit",
	license = "GNU GPLv3",
	author = { name = "Jon Wilson (10yard)" } }

local refocus = exports

function refocus.startplugin()

	emu.register_stop(function()
		-- Attempt to regain focus of DKAFE on Windows Systems -- see issue at https://github.com/10yard/dkafe/issues/5
		focus = os.execute([[START /B Powershell -command "$wshell = New-Object -ComObject wscript.shell ; $wshell.AppActivate('DKAFE')" > nul 2>&1]])
	end)	

end
return exports