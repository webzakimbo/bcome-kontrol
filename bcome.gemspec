# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'bcome'
  spec.version       = '1.3.4'
  spec.authors       = ['Guillaume Roderick (Webzakimbo)']
  spec.email         = ['guillaume@webzakimbo.com']
  spec.summary       = 'Organise your world, then integrate absolutely whatever you want in pure Ruby.'
  spec.description   = 'A cloud agnostic orchestration framework supporting AWS EC2 and GCP'
  spec.homepage      = 'https://bcome-kontrol.readthedocs.io/en/latest/'
  spec.license       = 'GPL-3.0'
  spec.files = Dir.glob('{bin,lib,filters,patches}/**/*')
  spec.bindir = 'bin'
  spec.executables = ['bcome']
  spec.require_paths = ['lib']
  spec.add_dependency 'activesupport', '5.2.3'
  spec.add_dependency 'awesome_print', '1.8.0'
  spec.add_dependency 'fog-aws', '~> 0.12.0'
  spec.add_dependency 'google-api-client', '0.29.1'
  spec.add_dependency 'launchy', '2.4.3'
  spec.add_dependency 'net-scp', '~> 1.2', '>= 1.2.1'
  spec.add_dependency 'net-ssh', '4.1.0'
  spec.add_dependency 'pmap', '1.1.1'
  spec.add_dependency 'rainbow', '~> 2.2'
  spec.add_dependency 'require_all', '1.3.3'
  spec.add_dependency 'pry', '~> 0.12.2'
end
