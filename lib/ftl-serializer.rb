# frozen_string_literal: true

require "ftl/version"
require "ftl/serializer"
require "ftl/railtie" if defined?(Rails)
require "ftl/load_and_bootstrap"
require "ftl/errors"
require "ftl/configuration"
require "ftl/serializer/base"
require "ftl/serializer/dsl"
