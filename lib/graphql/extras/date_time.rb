require "graphql"

module GraphQL
  module Extras
    class DateTime < GraphQL::Types::ISO8601DateTime
    end
  end
end
