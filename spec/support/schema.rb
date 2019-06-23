class TestQuery < GraphQL::Schema::Object
  field :hello, String, null: false
  field :hello_context, String, null: false

  def hello
    "world"
  end

  def hello_context
    context.fetch(:name)
  end
end

class TestMutation < GraphQL::Schema::Object
  include GraphQL::Extras::Types

  field :upload_image, String, null: false do
    argument :image, Upload, required: true
  end

  def upload_image(image:)
    image.original_filename
  end
end

class Schema < GraphQL::Schema
  query(TestQuery)
  mutation(TestMutation)
end
