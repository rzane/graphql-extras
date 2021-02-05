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
    loader.load "spec/fixtures/graphql/auth.graphql"
    expect(loader.operations).to have_key("CurrentUser")
  end

  it "loads a fragment" do
    loader = Loader.new
    loader.load "spec/fixtures/graphql/user.graphql"
    expect(loader.fragments).to have_key("User")
  end

  it "raises when a fragment is not found" do
    loader = Loader.new
    loader.load "spec/fixtures/graphql/auth.graphql"

    operation = loader.operations["CurrentUser"]
    expect { loader.print(operation) }.to raise_error(Loader::FragmentNotFoundError)
  end

  it "prints an operation, including fragments" do
    loader = Loader.new
    loader.load "spec/fixtures/graphql/user.graphql"
    loader.load "spec/fixtures/graphql/auth.graphql"

    operation = loader.operations["CurrentUser"]
    graphql = loader.print(operation)

    expect(graphql).to include("query CurrentUser")
    expect(graphql).to include("fragment User")
  end
end
