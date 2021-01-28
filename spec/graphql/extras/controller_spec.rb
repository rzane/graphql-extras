require "support/rails"
require "support/schema"
require "graphql/extras/controller"

RSpec.describe GraphQL::Extras::Controller, type: :controller do
  let(:json)   { JSON.parse(response.body) }
  let(:upload) { build_upload("files/image.jpg") }

  controller ActionController::Base do
    include GraphQL::Extras::Controller

    def index
      graphql(schema: Schema)
    end
  end

  it "executes a query against the schema" do
    post :index, params: { query: "{ hello }" }
    expect(json).to eq("data" => { "hello" => "world" })
  end

  it "handles file uploads" do
    query = <<~GRAPHQL
    mutation UploadImage($image: Upload!) {
      uploadImage(image: $image)
    }
    GRAPHQL

    post :index, params: {
      query: query,
      example: upload,
      variables: {
        image: "example"
      }
    }

    expect(json).to eq("data" => { "uploadImage" => "image.jpg" })
  end
end
