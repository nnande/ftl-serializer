# frozen_string_literal: true

module FTL
  module Serializer
    def self.register_serializer(klass)
      @serializers ||= []
      return @serializers if @serializers.include?(klass)
      @serializers.push(klass)
    end

    def self.registered_serializers
      @serializers
    end

    def self.bootstrap!
      return nil unless @serializers
      @serializers.each do |klass|
        klass.define_to_h
      end
    end
  end
end
