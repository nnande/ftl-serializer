# frozen_string_literal: true

module FTL::TestExamples
  class BasicSerializer < FTL::Serializer::Base
    attributes :first_name

    class Inherited < BasicSerializer
      attributes :last_name
    end

    class WithCamelCase < BasicSerializer
      format :camel
    end

    class WithRoot < BasicSerializer
      root :my_root
    end

    class WithMerge < BasicSerializer
      merge_with :last_name

      def last_name
        BasicSerializer::Inherited.new(obj).to_h
      end
    end

    class WithLocals < BasicSerializer
      attributes :store_name

      def store_name
        locals.current_store.name
      end
    end
  end
end

FTL::Serializer.bootstrap!
