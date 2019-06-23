require "graphql/extras/version"
require "graphql/extras/date"
require "graphql/extras/date_time"
require "graphql/extras/decimal"

begin
  require "graphql/extras/controller"
rescue LoadError
end

module GraphQL
  module Extras
    class Error < StandardError; end
    # Your code goes here...
  end
end
