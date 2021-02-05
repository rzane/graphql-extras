module Support
  class Person < GraphQL::Schema::Object
    field :name, String, null: false
  end

  class Query < GraphQL::Schema::Object
    field :hello_world, String, null: false
    field :hello_context, String, null: false
    field :hello_name, String, null: false do
      argument :name, String, required: true
    end

    field :explode, String, null: false
    field :people, [Person], null: false

    def hello_world
      "Hello, world"
    end

    def hello_name(name:)
      "Hello, #{name}"
    end

    def hello_context
      "Hello, #{context[:name]}"
    end

    def explode
      raise GraphQL::ExecutionError.new("Boom!", extensions: {code: "BOOM"})
    end

    def people
      [{name: "Rick"}]
    end
  end

  class Mutation < GraphQL::Schema::Object
    include GraphQL::Extras::Types

    field :upload_image, String, null: false do
      argument :image, Upload, required: true
    end

    def upload_image(image:)
      image.original_filename
    end
  end

  class Schema < GraphQL::Schema
    query(Query)
    mutation(Mutation)
  end
end
