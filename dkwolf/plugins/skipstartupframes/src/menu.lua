local ssf = require('skipstartupframes/src/skipstartupframes')

-- Default menu selection index
local menuSelection = 3

local indices = {}

-- Option menu creation/population
function ssf:menu_populate(rom)
  local result = {}

  table.insert(result, { 'Skip Startup Frames', '', 'off' })

  table.insert(result, { '---', '', '' })

  table.insert(result, {_p("plugin-skipstartupframes", "Black out screen during startup"), self.options:get('blackout') and 'Yes' or 'No', 'lr' })
  indices.blackout = #result

  table.insert(result, { _p("plugin-skipstartupframes", "Mute audio during startup"), self.options:get('mute') and 'Yes' or 'No', 'lr' })
  indices.mute = #result

  table.insert(result, { _p("plugin-skipstartupframes", "Fallback to parent rom frames"), self.options:get('parent_fallback') and 'Yes' or 'No', 'lr' })
  indices.parent_fallback = #result

  local debug_title = "Debug Mode"
  if not self.started_in_debug then
    debug_title = debug_title .. " (requires reset)"
  end

  table.insert(result, { _p("plugin-skipstartupframes", debug_title), self.options:get('debug') and 'Yes' or 'No', 'lr' })
  indices.debug = #result

  table.insert(result, { _p("plugin-skipstartupframes", "Slow Motion during Debug Mode"), self.options:get('debug_slow_motion') and 'Yes' or 'No', 'lr' })
  indices.debug_slow_motion = #result

  table.insert(result, { '---', '', '' })
  table.insert(result, { 'Frames to skip for ' .. rom, '', 'off' })

  table.insert(result, { _p("plugin-skipstartupframes", "Normal startup frames"), self.frames.start_frame_target, self.frames.start_frame_target > 0 and 'lr' or 'r' })
  indices.start_frame_target = #result

  table.insert(result, { _p("plugin-skipstartupframes", "Use alternate frames for a soft reset"), ssf.enable_reset_frame_option and 'Yes' or 'No', 'lr' })
  indices.enable_reset_frame_option = #result

  if ssf.enable_reset_frame_option then
    table.insert(result, { _p("plugin-skipstartupframes", "Soft reset frames"), self.frames.reset_frame_target, self.frames.reset_frame_target > 0 and 'lr' or 'r' })
    indices.reset_frame_target = #result
  end

  return result, menuSelection
end

-- Option menu event callback
function ssf:menu_callback(index, event)
  -- Add escape event to close menu
  if event == 'back' then
    return false
  end

  menuSelection = index

  -- Blackout Screen Option
  if index == indices.blackout then
    if event == 'left' or event == 'right' then
      self.options:toggle('blackout')
    end
    return true

  -- Mute Audio Option
  elseif index == indices.mute then
    if event == 'left' or event == 'right' then
      self.options:toggle('mute')
    end
    return true

  -- Parent ROM Fallback Option
  elseif index == indices.parent_fallback then
    if event == 'left' or event == 'right' then
      self.options:toggle('parent_fallback')
    end
    return true

  -- Debug Mode Option
  elseif index == indices.debug then
    if event == 'left' or event == 'right' then
      self.options:toggle('debug')
    end
    return true

  -- Debug Slow Motion Option
  elseif index == indices.debug_slow_motion then
    if event == 'left' or event == 'right' then
      self.options:toggle('debug_slow_motion')
    end
    return true

  -- Adjust start frame target for current game
  elseif index == indices.start_frame_target then
    if event == 'left' then
      self.frames.start_frame_target = self.frames.start_frame_target - 1
    elseif event == 'right' then
      self.frames.start_frame_target = self.frames.start_frame_target + 1
    end
    self.frames.dirty = true
    return true

  -- Option to toggle showing the soft reset frame target option
  elseif index == indices.enable_reset_frame_option then
    if event == 'left' or event == 'right' then
      ssf.enable_reset_frame_option = not ssf.enable_reset_frame_option
    end
    return true

  -- Adjust reset frame target for current game
  elseif index == indices.reset_frame_target then
    if event == 'left' then
      self.frames.reset_frame_target = self.frames.reset_frame_target - 1
    elseif event == 'right' then
      self.frames.reset_frame_target = self.frames.reset_frame_target + 1
    end
    self.frames.dirty = true
    return true

  end
end
