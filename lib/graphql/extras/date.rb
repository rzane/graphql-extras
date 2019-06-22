require "graphql"
require "date"

module GraphQL
  module Extras
    class Date < GraphQL::Schema::Scalar
      description "An ISO 8601-encoded date"

      def self.coerce_input(value, _context)
        ::Date.iso8601(value)
      rescue ArgumentError
        nil
      end

      def self.coerce_result(value, _context)
        value.iso8601
      end
    end
  end
end
