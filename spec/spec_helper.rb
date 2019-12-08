# frozen_string_literal: true

require "bundler/setup"
require "ftl"
FTL::Configuration.serializer_paths = ["spec/ftl/test_examples"]
require 'ftl/test_examples/basic_serializer'
require 'active_support/testing/time_helpers'

begin
  require 'pry'
  require 'pry-byebug'
rescue LoadError
end

# Namespace holding all objects created during specs
module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  config.after do
    Test.remove_constants
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include ActiveSupport::Testing::TimeHelpers
end
