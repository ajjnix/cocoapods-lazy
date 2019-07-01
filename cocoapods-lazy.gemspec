
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cocoapods-lazy/version"

Gem::Specification.new do |spec|
  spec.name          = "cocoapods-lazy"
  spec.version       = CocoapodsLazy::VERSION
  spec.authors       = ["Artem Mylnikov"]
  spec.email         = ["ajjnix@gmail.com"]

  spec.summary       = %q{Gem for store and share pods}
  spec.description   = %q{Share pods dir to team}
  spec.homepage      = "https://github.com/ajjnix/cocoapods-lazy"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb"]
  spec.bindir        = "bin"
  spec.executables   << 'cocoapods-lazy'
  spec.require_paths = %w{ lib }
  
  spec.add_dependency "dotenv", ">= 2.6.0"
  spec.add_dependency "cocoapods", ">= 1.6"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
end
