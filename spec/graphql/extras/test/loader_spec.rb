require "graphql/extras/test/loader"

RSpec.describe GraphQL::Extras::Test::Loader do
  Loader = GraphQL::Extras::Test::Loader

  it "initializes" do
    loader = Loader.new
    expect(loader.fragments).to eq({})
    expect(loader.operations).to eq({})
  end

  it "loads a query" do
    loader = Loader.new
    loader.load "spec/fixtures/graphql/people.graphql"
    expect(loader.operations).to have_key("ListPeople")
  end

  it "loads a fragment" do
    loader = Loader.new
    loader.load "spec/fixtures/graphql/person.graphql"
    expect(loader.fragments).to have_key("Person")
  end

  it "raises when a fragment is not found" do
    loader = Loader.new
    loader.load "spec/fixtures/graphql/people.graphql"

    operation = loader.operations["ListPeople"]
    expect { loader.print(operation) }.to raise_error(Loader::FragmentNotFoundError)
  end

  it "prints an operation, including fragments" do
    loader = Loader.new
    loader.load "spec/fixtures/graphql/person.graphql"
    loader.load "spec/fixtures/graphql/people.graphql"

    operation = loader.operations["ListPeople"]
    graphql = loader.print(operation)

    expect(graphql).to include("query ListPeople")
    expect(graphql).to include("fragment Person")
  end
end
