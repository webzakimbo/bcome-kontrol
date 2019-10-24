# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'bcome'
  spec.version       = '1.3.6'
  spec.authors       = ['Guillaume Roderick (Webzakimbo)']
  spec.email         = ['guillaume@webzakimbo.com']
  spec.summary       = 'A DevOps Application development framework'
  spec.description   = "Orchestration & Automation framework for the Cloud."
  spec.homepage      = "https://github.com/webzakimbo/bcome-kontrol"
  spec.metadata = {
    "documentation_uri" => "https://bcome-kontrol.readthedocs.io/en/latest/"
  }
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
  spec.post_install_message = "We'd love your feedack about this Gem: How can we improve?  Email guillaume@webzakimbo.com"
end
