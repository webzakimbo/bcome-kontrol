# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'bcome'
  spec.version       = '1.0.0'
  spec.authors       = ['Guillaume Roderick (Webzakimbo)']
  spec.email         = ['guillaume@webzakimbo.com']

  spec.summary       = 'Toolkit for managing machines - simplify your workflow.'
  spec.description   = 'Provides a console interface for traversing a hierarchy of platforms -> environment -> servers, and exposes common administration tools for the managemenent either of individual servers, or groups of servers. The system is driven from simple configuration and is extensible. It integrates with AWS EC2 for dynamic network discovery. Machines may be interacted with directly from the command line.'
  spec.homepage      = 'https://github.com/webzakimbo/bcome'
  spec.license       = 'MIT'

  spec.files = Dir.glob('{bin,lib,filters,patches}/**/*')
  spec.bindir = 'bin'
  spec.executables = ['bcome']
  spec.require_paths = ['lib', 'lib/stack']
  spec.add_dependency 'rainbow', '2.0.0'
  spec.add_dependency 'net-scp', '~> 1.2', '>= 1.2.1'
  spec.add_dependency 'rsync', '~> 1.0'
  spec.add_dependency 'fog-aws', '~> 0.12.0'
  spec.add_dependency 'require_all', '1.3.3'
  spec.add_dependency 'pmap', '1.1.1'
  spec.add_dependency 'activesupport', '5.1'
end
