# frozen_string_literal: true

module FTL
  module Errors
    class LocalsError < StandardError
      def initialize(serializer)
        super("#{serializer} is expecting your locals as a hash."\
          " You can do this by passing in a locals hash to your serializer like this:"\
          " #{serializer}.new(your_object, locals: { your_locals_object: obj })"\
          " or like this: #{serializer}.new(your_object).locals(your_locals_object: obj).")
      end
    end
  end
end
