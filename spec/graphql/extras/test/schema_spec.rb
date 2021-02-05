require "support/schema"
require "graphql/extras/test/schema"

class TestSchema < GraphQL::Extras::Test::Schema
  configure(
    schema: Support::Schema,
    queries: "spec/fixtures/graphql/*.graphql"
  )
end

RSpec.describe GraphQL::Extras::Test::Schema do
  let(:schema) { TestSchema.new }

  it "executes a query" do
    query = schema.hello_world

    expect(query).to be_successful
    expect(query.data["hello"]).to eq("Hello, world")
  end

  it "executes a query with variables" do
    query = schema.hello_name(name: "argument")

    expect(query).to be_successful
    expect(query.data["hello"]).to eq("Hello, argument")
  end

  it "executes a query with context" do
    schema = TestSchema.new(name: "context")
    query = schema.hello_context

    expect(query).to be_successful
    expect(query.data["hello"]).to eq("Hello, context")
  end

  it "executes a query with uploads" do
    upload = build_upload("files/image.jpg")
    query = schema.upload_image(image: upload)

    expect(query).to be_successful
    expect(query.data["image"]).to eq("image.jpg")
  end

  it "executes a query with errors" do
    query = schema.explode

    expect(query).not_to be_successful
    expect(query.errors[0].message).to eq("Boom!")
    expect(query.errors[0].code).to eq("BOOM")
  end
end
