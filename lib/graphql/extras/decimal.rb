require "graphql"
require "bigdecimal"

module GraphQL
  module Extras
    class Decimal < GraphQL::Schema::Scalar
      description "A decimal"

      def self.coerce_input(value, _context)
        BigDecimal(value.to_s)
      rescue ArgumentError
        nil
      end

      def self.coerce_result(value, _context)
        value.to_s("F")
      end
    end
  end
end
