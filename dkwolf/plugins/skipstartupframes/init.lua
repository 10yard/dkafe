local ssf = require('skipstartupframes/src/skipstartupframes')

require('skipstartupframes/src/options')
require('skipstartupframes/src/frames')
require('skipstartupframes/src/menu')
require('skipstartupframes/src/startplugin')

local plugin = {}

function plugin.startplugin()
  ssf:startplugin()
end

return plugin
