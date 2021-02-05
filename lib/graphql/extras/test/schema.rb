require "securerandom"
require "active_support/inflector"
require "active_support/core_ext/hash"
require "graphql/extras/test/loader"
require "graphql/extras/test/response"

module GraphQL
  module Extras
    module Test
      class Schema
        def self.configure(schema:, queries:)
          loader = Loader.new

          Dir.glob(queries) do |path|
            loader.load(path)
          end

          loader.operations.each do |name, operation|
            query = loader.print(operation)

            define_method(name.underscore) do |variables = {}|
              __execute(schema, query, variables)
            end
          end
        end

        def initialize(context = {})
          @context = context
        end

        private

        def __execute(schema, query, variables)
          uploads = {}

          variables = variables.deep_transform_keys do |key|
            key.to_s.camelize(:lower)
          end

          variables = variables.deep_transform_values do |value|
            if value.respond_to? :tempfile
              id = SecureRandom.uuid
              uploads[id] = value
              id
            else
              value
            end
          end

          context = @context.merge(uploads: uploads)
          result = schema.execute(query, variables: variables, context: context)
          Response.new(result.to_h)
        end
      end
    end
  end
end
