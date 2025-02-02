module GraphQL
  module Extras
    module Test
      class Loader
        FragmentNotFoundError = Class.new(StandardError)

        attr_reader :fragments
        attr_reader :operations

        def initialize
          @fragments = {}
          @operations = {}
        end

        def load(path)
          document = ::GraphQL.parse_file(path)
          document.definitions.each do |node|
            case node
            when Nodes::FragmentDefinition
              fragments[node.name] = node
            when Nodes::OperationDefinition
              operations[node.name] = node
            end
          end
        end

        def print(operation)
          printer = ::GraphQL::Language::Printer.new
          nodes = [operation, *resolve_fragments(operation)]
          nodes.map { |node| printer.print(node) }.join("\n")
        end

        private

        Nodes = ::GraphQL::Language::Nodes

        # Recursively iterate through the node's fields and find
        # resolve all of the fragment definitions that are needed.
        def resolve_fragments(node)
          result = node.selections.flat_map do |selection|
            case selection
            when Nodes::FragmentSpread
              fragment = fetch_fragment!(selection.name)
              [fragment, *resolve_fragments(fragment)]
            else
              resolve_fragments(selection)
            end
          end

          result.uniq
        end

        def fetch_fragment!(name)
          fragments.fetch(name) do
            raise FragmentNotFoundError, "Fragment `#{name}` is not defined"
          end
        end
      end
    end
  end
end
