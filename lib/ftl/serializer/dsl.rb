# frozen_string_literal: true

require 'ftl/serializer/dsl/format'

module FTL::Serializer
  module DSL
    include FTL::Serializer::DSL::Format

    attr_reader :attribute_list, :object_merge

    def inherited(child)
      child.attributes(attribute_list) unless attribute_list.nil?
      child.merge_with(object_merge) unless object_merge.nil?
      child.root(root_name)

      FTL::Serializer.register_serializer(child)
    end

    def attribute_list
      @attribute_list ||= []
    end

    def object_merge
      @object_merge ||= []
    end

    def attributes(*attrs)
      attribute_list.push(attrs).flatten!.uniq!
    end

    def merge_with(*attrs)
      object_merge.push(attrs).flatten!.uniq!
    end

    def define_to_h
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def hashify
          hash = {
            #{
              attribute_list.reduce('') do |method_str, attr|
                if self.camel_case?
                  attr_name = attr.to_s.camelize(:lower)
                else
                  attr_name = attr
                end

                if instance_methods.include?(attr)
                  method_str + "\"#{attr_name}\" => #{attr},"
                else
                  method_str + "\"#{attr_name}\" => obj.#{attr},"
                end
              end
            }
          }

          merge!(hash)
        end
      METHOD
    end
  end
end
