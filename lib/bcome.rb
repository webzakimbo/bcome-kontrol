require 'irb'
require 'irb/completion'
require 'rainbow'
require 'net/scp'
require 'net/ssh/proxy/command'
require 'fog/aws'
require 'require_all'
require 'pmap'
require 'singleton'
require 'active_support'
require 'active_support/core_ext'
require 'pp'
require 'awesome_print'
require 'io/console'

require_all "#{File.dirname(__FILE__)}/../patches"
require_all "#{File.dirname(__FILE__)}/../lib/objects"

# Load in any user defined orchestration
path_to_bcome_orchestration_configs = "#{Dir.getwd}/bcome/orchestration"
require_all path_to_bcome_orchestration_configs if File.directory?(path_to_bcome_orchestration_configs)
