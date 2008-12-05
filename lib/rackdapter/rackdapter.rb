require 'rubygems'
require 'eventmachine'
require 'logger'

require 'rackdapter/config'
require 'rackdapter/spawner'

if $PROXY == 1
  require 'rackdapter/proxy'
else
  require 'rackdapter/master'
end
