
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ftl/version"

Gem::Specification.new do |spec|
  spec.name          = "ftl-serializer"
  spec.version       = FTL::VERSION
  spec.authors       = ["Fullscript"]
  spec.email         = ["devops@fullscript.com", ]

  spec.summary       = 'A ruby serializer that can make the kessel run in less than 12 parsecs.'
  spec.description   = 'FTL (Faster Than Light) is a ruby serializer that is optimized for simplicity and speed.'
  spec.homepage      = "https://fullscript.com"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/fullscript/ftl-serializer"
    # spec.metadata["changelog_uri"] = "https://github.com/fullscript/ftl-serializer/changelog.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.required_ruby_version = '>= 2.3'

  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5"
  spec.add_dependency "oj", '>= 2'

  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-byebug"
end
