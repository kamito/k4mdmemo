# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'k4mdmemo/version'

Gem::Specification.new do |spec|
  spec.name          = "k4mdmemo"
  spec.version       = Mymdmemo::VERSION
  spec.authors       = ["Shinichirow KAMITO"]
  spec.email         = ["updoor@gmail.com"]
  spec.summary       = %q{My memo by Markdown.}
  spec.description   = %q{My memo by Markdown.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'redcarpet'
  spec.add_dependency "rake"

  spec.add_development_dependency "bundler", "~> 1.5"
end
