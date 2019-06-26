require "yaml"
require "active_support/inflector"
require "active_support/core_ext/hash"

module GraphQL
  module Extras
    module RSpec
      class Queries
        def initialize(values)
          values.each do |key, value|
            define_singleton_method(key) { value }
          end
        end
      end

      class Schema
        def initialize(schema, context: {})
          @schema = schema
          @context = context
        end

        def execute(query, variables = {})
          variables = deep_camelize_keys(variables)
          variables, uploads = extract_uploads(variables)
          context = @context.merge(uploads: uploads)

          result = @schema.execute(query, variables: variables, context: context)
          result.to_h
        end

        private

        def extract_uploads(variables)
          uploads = {}
          variables = deep_transform_values(variables) { |value|
            if upload?(value)
              SecureRandom.hex.tap { |key| uploads.merge!(key => value) }
            else
              value
            end
          }

          [variables, uploads]
        end

        def deep_camelize_keys(variables)
          variables.deep_transform_keys { |key| key.to_s.camelize(:lower) }
        end

        def deep_transform_values(data, &block)
          case data
          when Array
            data.map { |v| deep_transform(v, &block) }
          when Hash
            data.transform_values { |v| deep_transform(v, &block) }
          else
            yield data
          end
        end

        def upload?(value)
          value.kind_of?(Rack::Test::UploadedFile) ||
            value.kind_of?(ActionController::TestUploadedFile) ||
            value.kind_of?(ActionDispatch::Http::UploadedFile)
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

        Queries.new(result)
      end

      def use_schema(*args)
        Schema.new(*args)
      end
    end
  end
end

RSpec::Matchers.define :be_successful_query do
  match do |result|
    result['errors'].nil?
  end

  failure_message do |result|
    errors = result['errors'].map(&:deep_stringify_keys)
    message = "expected query to be successful, but encountered errors:\n"
    message + errors.to_yaml.lines.drop(1).join.indent(2)
  end
end

RSpec.configure do |config|
  config.add_setting :graphql_fixture_path, default: "spec/fixtures/graphql"
  config.include GraphQL::Extras::RSpec, type: :graphql
end
