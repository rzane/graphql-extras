require "support/schema"
require "graphql/extras/rspec"

RSpec.describe GraphQL::Extras::RSpec, type: :graphql do
  describe "#graphql_fixture" do
    it "loads queries from a file" do
      queries = graphql_fixture("hello.graphql")
      expect(queries.hello).to include("query Hello {")
    end

    it "includes all fragments" do
      queries = graphql_fixture("fragments.graphql")
      expect(queries.list_people).to include("fragment PersonFields")
      expect(queries.list_people).to include("...PersonFields")
    end
  end

  describe "#use_schema" do
    it "allows easily executing queries" do
      schema = use_schema(Schema)
      queries = graphql_fixture("hello.graphql")
      result = schema.execute(queries.hello)
      expect(result).to be_successful_query
      expect(result[:data][:hello]).to eq("world")
    end
  end
end
