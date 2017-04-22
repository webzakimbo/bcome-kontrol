require 'rainbow'
require 'aws-sdk'
require 'net/scp'
require 'net/ssh/proxy/command'
require 'fog/aws'
require 'require_all'
require 'pmap'

require_all "#{File.dirname(__FILE__)}/../patches"
require_all "#{File.dirname(__FILE__)}/../lib"
