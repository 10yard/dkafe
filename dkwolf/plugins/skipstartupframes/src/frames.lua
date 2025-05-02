local ssf = require('skipstartupframes/src/skipstartupframes')

local default_frames_file = ssf.plugin_directory .. "/ssf.txt"
local custom_frames_file = ssf.plugin_directory .. "/ssf_custom.txt"

-- Load the frames file
local load_frames = function(file)
  local frames = {}

  -- If the filepath is not valid, return an empty table
  if not file then
    return frames
  end

  local frames_file = io.open(file, "r")

  -- If the file does not exist, return an empty table
  if not frames_file then
    return frames
  end

  -- Read in the file
  frames_file = frames_file:read("*a")

  -- Split lines
  for line in frames_file:gmatch("[^\r\n]+") do

    -- First look for the following pattern: rom,startFrame|resetFrame
    local rom, startFrame, resetFrame = line:match("^([%w_]+),([%d]+)|([%d]+)$")
    if rom ~= nil and startFrame ~= nil and resetFrame ~= nil then
      frames[rom] = {
        start = tonumber(startFrame),
        reset = tonumber(resetFrame)
      }
    else
      -- Second, look for the following pattern: rom,startFrame
      rom, startFrame = line:match("^([%w_]+),([%d]+)$")

      if rom ~= nil and startFrame ~= nil then
        frames[rom] = {
          start = tonumber(startFrame),
          reset = tonumber(startFrame)
        }
      end
    end

  end

  return frames
end

local frames = {}

-- Initialize the frames for a given ROM
function frames:load(rom)
  self.start_frame_target = 0
  self.reset_frame_target = 0

  -- Track when frames have been changed in the options menu
  self.dirty = false

  -- Load frames from files
  self.default = load_frames(default_frames_file)
  self.custom = load_frames(custom_frames_file)

  -- Determine if rom has a parent rom
  local parent = emu.driver_find(rom).parent
  if parent == "0" then
    parent = nil
  end

  -- Determine if parent ROM fallback is enabled
  local parent_fallback = ssf.options:get('parent_fallback')

  -- Determine which target frames to use
  if self.custom[rom] then
    -- Use custom frames if they exist
    self.start_frame_target = self.custom[rom].start
    self.reset_frame_target = self.custom[rom].reset

  elseif parent_fallback and self.custom[parent] then
    -- Use parent ROM custom frames if they exist
    self.start_frame_target = self.custom[parent].start
    self.reset_frame_target = self.custom[parent].reset

  elseif self.default[rom] then
    -- Use default frames if they exist
    self.start_frame_target = self.default[rom].start
    self.reset_frame_target = self.default[rom].reset

  elseif parent_fallback and self.default[parent] then
    -- Use parent ROM default frames if they exist
    self.start_frame_target = self.default[parent].start
    self.reset_frame_target = self.default[parent].reset
  end

  -- Ensure frame targets are not negative
  if self.start_frame_target < 0 then self.start_frame_target = 0 end
  if self.reset_frame_target < 0 then self.reset_frame_target = 0 end

  -- Switch to determine if the soft reset frame target menu option should be enabled
  if self.start_frame_target == self.reset_frame_target then
    ssf.enable_reset_frame_option = false
  else
    ssf.enable_reset_frame_option = true
  end
end

-- Save the custom frames to the file
function frames:save(rom)
  -- Don't save if the start or reset frames have not been changed in the options menu
  if not self.dirty then
    return
  end

  -- If the custom frames are the same as the default frames, remove the custom frames from the table
  if self.default[rom] and self.default[rom].start == self.start_frame_target and self.default[rom].reset == self.reset_frame_target then
    self.custom[rom] = nil
  else
    -- Otherwise, update the custom frames table with new custom start and reset frames
    self.custom[rom] = {
      start = self.start_frame_target,
      reset = self.reset_frame_target
    }
  end

  -- Sort the table keys
  local sorted_keys = {}
  for n in pairs(self.custom) do
    table.insert(sorted_keys, n)
  end
  table.sort(sorted_keys)

  -- Prep data output
  local data = ""
  for _,v in pairs(sorted_keys) do
    data = data .. v .. "," .. self.custom[v].start

    -- Only add reset frame if it is different from the start frame and the option is enabled
    if ssf.enable_reset_frame_option and self.reset_frame_target ~= self.start_frame_target then
      data = data .. "|" .. self.custom[v].reset
    end

    data = data .. "\n"
  end

  -- Write the frame data to the file
  local frames_file = io.open(custom_frames_file, "w")
  frames_file:write(data)
  frames_file:close()

end

ssf.frames = frames
