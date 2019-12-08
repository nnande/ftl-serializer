# frozen_string_literal: true

module FTL::Serializer::DSL
  module Format
    attr_reader :root_name

    def root(root_name)
      @root_name = root_name
    end

    def format(format_type)
      @hash_format = format_type
    end

    def hash_format
      @hash_format ||= :underscore
    end

    def camel_case?
      hash_format == :camel
    end
  end
end
