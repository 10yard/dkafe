local ssf = require('skipstartupframes/src/skipstartupframes')
local json = require('json')

-- Path to options file
local file = ssf.plugin_directory .. "/options.cfg"

-- Default options
local defaultoptions = {
  blackout = true,
  mute = true,
  parent_fallback = true,
  debug = false,
  debug_slow_motion = false
}

-- Load options from options.cfg
local function load()
  local options = {}

  -- Open options file for reading
  local options_file = io.open(file, "r")

  -- If options file doesn't exist, use default options
  if options_file == nil then
    options = defaultoptions
  else
    -- Parse options file
    options = json.parse(options_file:read("*a")) or {}
    options_file:close()

    -- Fix incorrect types and add missing options
    for k,v in pairs(defaultoptions) do
      if (options[k] == nil or type(options[k]) ~= type(v)) then
        options[k] = v
      end
    end
  end

  return options
end

-- Save options to options.cfg
local function save(options)
  local options_file = io.open(file, "w")
  options_file:write(json.stringify(options, {indent = true}))
  options_file:close()
end

-- Object to hold the option values
local optionValues = load()

-- Options object
local options = {
  -- Return an option's value
  get = function(self, key)
    return optionValues[key]
  end,

  -- Set an option's value
  set = function(self, key, value)
    -- Ignore if the key does not exist
    if not self:exists(key) then
      return
    end
    optionValues[key] = value
    save(optionValues)
  end,

  -- Toggle an option's value
  toggle = function(self, key)
    -- Ignore if option is not a boolean
    if (type(self:get(key)) ~= "boolean") then
      return
    end

    self:set(key, not self:get(key))
  end,

  -- Reset an option to its default value
  reset = function(self, key)
    self:set(key, defaultoptions[key])
  end,

  -- Check if an option exists
  exists = function(self, key)
    return optionValues[key] ~= nil
  end
}

ssf.options = options
