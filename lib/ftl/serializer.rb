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

    def self.load_from_configured_paths
      FTL::Configuration.serializer_paths.map do |path|
        Dir.glob("#{path}/**/*.rb").each do |file|
          begin
            if defined?(Rails) && (Rails.env.development? || Rails.env.test?)
              load file
            else
              require file
            end
          rescue => e
            warn "can't load '#{file}' file (#{e.message})!"
          end
        end
      end
    end

    def self.bootstrap!
      return nil unless @serializers
      @serializers.each do |klass|
        klass.define_to_h
      end
    end
  end
end
