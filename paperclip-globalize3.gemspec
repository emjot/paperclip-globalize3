# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paperclip/globalize3/version'
require 'English'

Gem::Specification.new do |spec|
  spec.name          = 'paperclip-globalize3'
  spec.version       = Paperclip::Globalize3::VERSION
  spec.authors       = ['Maximilian Herold']
  spec.email         = ['herold@emjot.de']
  spec.description   = 'locale-specific attachments with paperclip and globalize'
  spec.summary       = 'locale-specific attachments with paperclip and globalize'
  spec.homepage      = 'https://github.com/emjot/paperclip-globalize3'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.4.6'

  spec.add_dependency 'activerecord', ['>= 4.2', '< 6.1']
  spec.add_dependency 'globalize', ['>= 5.3.0', '< 5.4.0']
  spec.add_dependency 'paperclip', ['>= 5.3', '< 6.2.0']

  spec.add_development_dependency 'appraisal', '~> 2.2'
  spec.add_development_dependency 'bundler', ['>= 1.16.6', '< 2.0.1']
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.7'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'sqlite3', '~> 1.3.6'
  spec.add_development_dependency 'wwtd', '~> 1.3'
  spec.add_development_dependency 'yard'
end
