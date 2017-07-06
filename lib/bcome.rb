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
require 'ruby-prof'

require_all "#{File.dirname(__FILE__)}/../patches"
require_all "#{File.dirname(__FILE__)}/../lib/objects"
