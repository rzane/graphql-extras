class Query < GraphQL::Schema::Object
  field :hello, String, null: false
  field :hello_context, String, null: false

  def hello
    "world"
  end

  def hello_context
    context.fetch(:name)
  end
end

class Schema < GraphQL::Schema
  query(Query)
end
