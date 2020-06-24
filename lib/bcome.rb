# frozen_string_literal: true

require 'irb'
require 'active_support'
require 'active_support/core_ext'
require 'pmap'
require 'singleton'
require 'require_all'
require 'tty-cursor'
require 'pry'

require_all "#{File.dirname(__FILE__)}/../patches"
require_all "#{File.dirname(__FILE__)}/../lib/objects"

# Load in any user defined orchestration
path_to_bcome_orchestration_configs = "#{Dir.getwd}/bcome/orchestration"
require_all path_to_bcome_orchestration_configs if File.directory?(path_to_bcome_orchestration_configs)

# Load in any patches
# Note: previously patches could have (and were placed) anywhere in the orchestration directory above. This just makes it more explicit, and keeps
# things tidier.
path_to_user_monkey_patches = "#{Dir.getwd}/bcome/patches"
require_all path_to_user_monkey_patches if File.directory?(path_to_user_monkey_patches)
