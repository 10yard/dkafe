local ssf = require("skipstartupframes/src/skipstartupframes")

-- Notifiers
local startNotifier = nil
local stopNotifier = nil
local menuNotifier = nil

local slow_motion_rate = 0.3

-- Variable to help differentiate between hard and soft resets
local running = false

function ssf:startplugin()
  -- Initialize frame processing function to do nothing
  local process_frame = function() end

  -- Variable references
  local rom = nil
  local target = nil

  -- Create ssf_custom.txt if it does not exist
  local custom_frames_file = ssf.plugin_directory .. "/ssf_custom.txt"
  local custom_frames = io.open(custom_frames_file, "a")
  custom_frames:close()

  -- Run when MAME begins emulation
  local start = function()
    rom = emu.romname()

    -- If no rom is loaded, don"t do anything
    if not rom or rom == "___empty" then
      return
    end

    self.started_in_debug = self.options:get("debug")

    -- Soft reset detected
    if running then
      -- If the frame targets have not been changed in the options menu, reload the frames from the files
      if not self.frames.dirty then
        self.frames:load(rom)
      end

      -- Set the frame target to the reset frame target
      target = self.frames.reset_frame_target
    else
      -- Start or Hard reset detected
      running = true

      -- Load the frames from the files
      self.frames:load(rom)

      -- Set the frame target to the start frame target
      target = self.frames.start_frame_target
    end

    -- If there is no frame target and you are not debugging, don"t do anything
    if target == 0 and not self.options:get("debug") then
      return
    end

    -- Variable references
    local screens = manager.machine.screens
    local screens_exist = #screens > 0
    local video = manager.machine.video
    local sound = manager.machine.sound

    -- Starting frame
    local frame = 0

    -- Debug mode
    if self.options:get("debug") then
      -- Process each frame
      process_frame = function()
        -- Slow-Motion Debug Mode
        if self.options:get("debug") and self.options:get("debug_slow_motion") then
          video.throttle_rate = slow_motion_rate
        else
          video.throttle_rate = 1
        end

        -- Draw debug frame text
        if self.options:get("debug") and screens_exist then
          for _,screen in pairs(screens) do
            screen:draw_text(0, 0, "ROM: "..rom.." Frame: "..frame, 0xffffffff, 0xff000000)
          end
        end

        -- Iterate frame count when not paused
        if not manager.machine.paused then
          frame = frame + 1
        end
      end

    else
      -- Non-Debug mode

      -- Disable throttling
      video.throttled = false

      -- Mute sound
      if self.options:get("mute") then
        sound.system_mute = true
      end

      -- Process each frame
      process_frame = function()

        -- Black out screen
        if self.options:get("blackout") and screens_exist then
          for _,screen in pairs(screens) do
            screen:draw_box(0, 0, screen.width, screen.height, 0x00000000, 0xff000000)
          end
        end
        video.frameskip = 11

        -- Iterate frame count when not paused
        if not manager.machine.paused then
          frame = frame + 1
        end

        -- Frame target reached
        if frame >= target then

          -- Re-enable throttling
          video.throttled = true

          -- Unmute sound
          sound.system_mute = false

          -- Reset throttle and frameskip
          video.throttle_rate = 1
          video.frameskip = 0

          -- Reset frame processing function to do nothing when frame target is reached
          process_frame = function() end
        end
      end

    end

  end

  -- Run when MAME stops emulation or a hard reset occurs
  local stop = function()
    -- Reset the frame processing function
    process_frame = function() end

    -- Save any custom frame changes made in options menu
    self.frames:save(rom)

    -- Reset variables
    running = false
    rom = nil
    target = 0
  end

  local menu_callback = function(index, event)
    return self:menu_callback(index, event)
  end

  local menu_populate = function()
    return self:menu_populate(rom)
  end

  -- Function to process each frame
  emu.register_frame_done(function()
    process_frame()
  end)

  -- MAME 0.254 and newer compatibility check
  if emu.add_machine_reset_notifier ~= nil and emu.add_machine_stop_notifier ~= nil then
    startNotifier = emu.add_machine_reset_notifier(start)
    stopNotifier = emu.add_machine_stop_notifier(stop)
    menuNotifier = emu.register_menu(menu_callback, menu_populate, _p("plugin-skipstartupframes", "Skip Startup Frames"))

  -- otherwise MAME 0.227 and newer compatibility check
  elseif emu.app_version() >= "0.227" then
   	emu.register_start(function()
		startNotifier = True
        start()
	end)
   	emu.register_stop(function()
		stopNotifier = True
        stop()
	end)
    menuNotifier = emu.register_menu(menu_callback, menu_populate, "Skip Startup Frames")

  else
    ---- MAME version not compatible (probably can"t even load LUA plugins anyways)
    print("Skip Startup Frames plugin requires at least MAME 0.227")
    return
  end

end
