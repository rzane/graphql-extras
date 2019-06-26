require "date"
require "bigdecimal"
require "graphql"

module GraphQL
  module Extras
    module Types
      class DateTime < GraphQL::Types::ISO8601DateTime
        description <<~DESC
        The `DateTime` scalar type represents a date and time in the UTC
        timezone. The DateTime appears in a JSON response as an ISO8601 formatted
        string, including UTC timezone ("Z"). The parsed date and time string will
        be converted to UTC and any UTC offset other than 0 will be rejected.
        DESC
      end

      class Date < GraphQL::Schema::Scalar
        description <<~DESC
        The `Date` scalar type represents a date. The Date appears in a JSON
        response as an ISO8601 formatted string.
        DESC

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
        description <<~DESC
        The `Decimal` scalar type represents signed double-precision fractional
        values parsed by the `Decimal` library. The Decimal appears in a JSON
        response as a string to preserve precision.
        DESC

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
        description "Represents an uploaded file."

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
