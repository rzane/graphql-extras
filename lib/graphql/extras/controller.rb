module GraphQL
  module Extras
    module Controller
      def graphql(schema:, context: {}, debug: Rails.env.development?)
        query = params[:query]
        operation = params[:operationName]
        variables = cast_graphql_params(params[:variables])

        uploads = params.to_unsafe_h.select do |_, value|
          value.is_a?(ActionDispatch::Http::UploadedFile)
        end

        result = schema.execute(
          query,
          operation_name: operation,
          variables: variables,
          context: context.merge(uploads: uploads)
        )

        render(status: 200, json: result)
      rescue => error
        handle_error(error)
      end

      private

        def cast_graphql_params(param)
          case param
          when String
            return {} if param.blank?
            cast_graphql_params(JSON.parse(param))
          when Hash, ActionController::Parameters
            param
          when nil
            {}
          else
            raise ArgumentError, "Unexpected parameter: #{param}"
          end
        end

        def handle_error(error)
          raise error unless debug

          logger.error(error.message)
          logger.error(error.backtrace.join("\n"))

          render(
            status: 500,
            json: {
              data: {},
              error: {
                message: error.message,
                backtrace: error.backtrace
              }
            }
          )
        end
    end
  end
end
