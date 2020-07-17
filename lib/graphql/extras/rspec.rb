require "yaml"
require "active_support/inflector"
require "active_support/core_ext/hash"

module GraphQL
  module Extras
    module RSpec
      class Queries
        def add(key, value)
          define_singleton_method(key) { value }
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
            data.map { |v| deep_transform_values(v, &block) }
          when Hash
            data.transform_values { |v| deep_transform_values(v, &block) }
          else
            yield data
          end
        end

        def upload?(value)
          value.respond_to?(:tempfile) && value.respond_to?(:original_filename)
        end
      end

      class Parser
        include ::GraphQL::Language

        def initialize(document)
          @operations = document.definitions
            .grep(Nodes::OperationDefinition)

          @fragments = document.definitions
            .grep(Nodes::FragmentDefinition)
            .reduce({}) { |acc, f| acc.merge(f.name => f) }
        end

        def parse
          queries = Queries.new
          printer = Printer.new

          @operations.each do |op|
            nodes = [op, *find_fragments(op)]
            nodes = nodes.map { |node| printer.print(node) }
            queries.add op.name.underscore, nodes.join
          end

          queries
        end

        private

        def find_fragments(node)
          node.selections.flat_map do |field|
            if field.is_a? Nodes::FragmentSpread
              fragment = @fragments.fetch(field.name)
              [fragment, *find_fragments(fragment)]
            else
              find_fragments(field)
            end
          end
        end
      end

      def graphql_fixture(filename)
        root = ::RSpec.configuration.graphql_fixture_path
        file = File.join(root, filename)
        document = ::GraphQL.parse_file(file)
        parser = Parser.new(document)
        parser.parse
      end

      def use_schema(*args, **opts)
        Schema.new(*args, **opts)
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
