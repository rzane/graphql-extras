module GraphQL
  module Extras
    module Test
      class Response
        attr_reader :data
        attr_reader :errors

        def initialize(payload)
          @data = payload["data"]
          @errors = payload.fetch("errors", []).map do |error|
            Error.new(error)
          end
        end

        def successful?
          errors.empty?
        end

        class Error
          attr_reader :message
          attr_reader :extensions
          attr_reader :code
          attr_reader :path
          attr_reader :locations

          def initialize(payload)
            @message = payload["message"]
            @path = payload["path"]
            @locations = payload["locations"]
            @extensions = payload["extensions"]
            @code = payload.dig("extensions", "code")
          end
        end
      end
    end
  end
end
