require "action_controller/metal/strong_parameters"

module GraphQL
  module Extras
    module Controller
      def graphql(schema:, context: {}, debug: Rails.env.development?)
        query = params[:query]
        operation = params[:operationName]
        variables = cast_graphql_params(params[:variables])

        result = schema.execute(
          query,
          context: context,
          operation_name: operation,
          variables: variables
        )

        render(status: 200, json: result)
      rescue => error
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

      private def cast_graphql_params(param)
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
    end
  end
end
