# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sassconf/version'

Gem::Specification.new do |spec|
  spec.name = 'sassconf'
  spec.version = Sassconf::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = 'Marcel Schlegel'
  spec.homepage = 'http://sassconf.schlegel11.de'
  spec.email = 'develop@schlegel11.de'
  spec.licenses = 'MIT'

  spec.summary = %q{Adds configuration file to Sass converter.}
  spec.description = %q{With the Sassconf command tool you can use a config file for defining your Sass options.
                        If you liked the config file in any Compass environment then you'll like that one also because it's very similar.}

  spec.files = `git ls-files`.split("\n")
  spec.test_files = `git ls-files -- {test}/*`.split("\n")
  spec.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = 'lib'

  spec.required_ruby_version = '>= 1.9.2'
  spec.add_runtime_dependency 'sass', '>= 3.1.0'

  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '>= 5.6.0'
end
