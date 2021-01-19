# frozen_string_literal: true

require 'ftl/serializer/dsl'
require 'oj'

module FTL::Serializer
  class Base
    extend FTL::Serializer::DSL

    attr_accessor :obj
    attr_reader :collection

    def initialize(collection, args = {})
      @collection = collection
      @locals = args.dig(:locals)
    end

    def to_h
      if singular_object?
        rootify(singular_to_h)
      else
        rootify(multi_to_h)
      end
    end
    alias_method :to_hash, :to_h

    def to_json
      Oj.dump(to_hash, mode: :custom, use_to_json: false)   
    end

    def meta(hash)
      self.tap { @meta = hash }
    end

    def links(hash)
      self.tap { @links = hash }
    end

    def root(name)
      self.tap { @root = name }
    end

    def locals(*args)
      if args.size == 0
        return @_locals if defined? @_locals
        return nil if @locals.blank?
        @_locals = begin
          local_methods = @locals.keys.map(&:to_sym)
          values = @locals.values
          if local_methods.any?
            Struct.new(*local_methods).new(*values)
          end
        rescue
          raise FTL::Errors::LocalsError.new(self.class.name)
        end
      else
        self.tap { @locals = args[0] }
      end
    end

    private

      def singular_object?
        collection.is_a?(Hash) || collection.is_a?(Struct) || !collection.respond_to?(:map)
      end

      def singular_to_h
        self.obj = collection
        hashify
      end

      def multi_to_h
        collection.map do |object|
          self.obj = object
          hashify
        end
      end

      def rootify(hash)
        root_name = @root || self.class.root_name
        return hash if root_name == :disabled || root_name.nil?

        root_name = format_root_name(root_name)
        if singular_object?
          { root_name => hash }
        else
          { root_name.pluralize => hash }.tap do |h|
            meta_hash.map { |meta| h.merge!(meta) if meta }
          end
        end
      end

      def format_root_name(root_name)
        if self.class.camel_case?
          root_name.to_s.camelize(:lower)
        else
          root_name.to_s
        end
      end

      def meta_hash
        [{ "meta" => @meta, "links" => @links }.select { |_, value| !value.nil? }]
      end

      def merge!(hash)
        return hash if self.class.object_merge.empty?
        self.class.object_merge.reduce(hash) do |complete_hash, merge_object_method|
          new_hash = self.send(merge_object_method)
          complete_hash.merge(new_hash)
        end
      end
  end
end
