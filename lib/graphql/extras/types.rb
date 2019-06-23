require "date"
require "bigdecimal"
require "graphql"

module GraphQL
  module Extras
    module Types
      class DateTime < GraphQL::Types::ISO8601DateTime
      end

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

      class Upload < GraphQL::Schema::Scalar
        def self.coerce_input(value, context)
          return nil if value.nil?

          uploads = context.fetch(:uploads) {
            raise "Expected context to include a hash of uploads."
          }

          uploads.fetch(value) do
            raise GraphQL::CoercionError, "No upload named `#{value}` provided."
          end
        end
      end
    end
  end
end
