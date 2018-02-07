# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paperclip/globalize3/version'

Gem::Specification.new do |spec|
  spec.name          = "paperclip-globalize3"
  spec.version       = Paperclip::Globalize3::VERSION
  spec.authors       = ["Maximilian Herold"]
  spec.email         = ["herold@emjot.de"]
  spec.description   = %q{locale-specific attachments with paperclip and globalize}
  spec.summary       = %q{locale-specific attachments with paperclip and globalize}
  spec.homepage      = "https://github.com/emjot/paperclip-globalize3"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ['>= 4.0', '< 5.1']
  spec.add_dependency "globalize", ">= 4.0.0"
  spec.add_dependency "paperclip", "~> 4.1"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "appraisal", "~> 0.5.1"
  spec.add_development_dependency "rspec-rails", ["~> 2.14.1", "< 2.99"]
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rake", '< 12'
  spec.add_development_dependency "wwtd", "~> 0.5"
end
