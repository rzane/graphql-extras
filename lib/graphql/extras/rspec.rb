require "yaml"
require "active_support/inflector"
require "active_support/core_ext/hash"

module GraphQL
  module Extras
    module RSpec
      Result = Struct.new(:data, :errors)

      class TestSchema
        def initialize(schema, context: {})
          @schema = schema
          @context = context
        end

        def execute(query, variables = {})
          result = @schema.execute(query, variables: variables, context: @context)
          result = result.to_h.deep_symbolize_keys
          Result.new(result[:data], result[:errors])
        end

        private

        def deep_camelize_keys(data)
          data.deep_transform_keys { |key| key.to_s.camelize(:lower) }
        end
      end

      def graphql_fixture(filename)
        root = ::RSpec.configuration.graphql_fixture_path
        contents = File.read(File.join(root, filename))

        parts = contents.split(/^(?=fragment|query|mutation)/)
        queries, fragments = parts.partition { |query| query !~ /^fragment/ }

        result = queries.reduce({}) { |acc, query|
          name = query.split(/\W+/).at(1).underscore.to_sym
          acc.merge(name => [*fragments, query].join)
        }

        Struct.new(*result.keys).new(*result.values)
      end

      def use_schema(*args)
        TestSchema.new(*args)
      end
    end
  end
end

RSpec::Matchers.define :be_successful_query do
  match { |result| result.errors.nil? }

  failure_message do |result|
    errors = result.errors.map(&:deep_stringify_keys)
    message = "expected query to be successful, but encountered errors:\n"
    message + errors.to_yaml.lines.drop(1).join.indent(2)
  end
end

RSpec.configure do |config|
  config.add_setting :graphql_fixture_path, default: "spec/fixtures/graphql"
  config.include GraphQL::Extras::RSpec, type: :graphql
end
