# frozen_string_literal: true

require "active_support/configurable"

module FTL
  class Configuration
    include ActiveSupport::Configurable

    config_accessor(:serializer_paths) { [] }
  end
end
