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
      expect(queries.list_people).to include("query ListPeople {")
    end

    context "when parsing a subscription" do
      it "load query from file" do
        queries = graphql_fixture("hello.graphql")
        expect(queries.subscribe_hello).to include("subscription SubscribeHello {")
      end

      it "includes all fragments" do
        queries = graphql_fixture("fragments.graphql")
        expect(queries.subscribe_list_people).to include("fragment PersonFields")
        expect(queries.subscribe_list_people).to include("...PersonFields")
        expect(queries.subscribe_list_people).to include("subscription SubscribeListPeople {")
      end
    end
  end

  describe "#use_schema" do
    let(:context) { { name: "Ray" } }
    let(:schema)  { use_schema(Schema, context: context) }
    let(:queries) { graphql_fixture("hello.graphql") }
    let(:upload)  { build_upload("files/image.jpg") }

    it "allows easily executing queries" do
      result = schema.execute(queries.hello)

      expect(result).to be_successful_query
      expect(result['data']['hello']).to eq("world")
    end

    it "allows executing queries with context" do
      result = schema.execute(queries.hello_context)

      expect(result).to be_successful_query
      expect(result['data']['hello']).to eq("Ray")
    end

    it "executes queries with uploads" do
      allow(SecureRandom).to receive(:hex).and_return("meatloaf")
      expect(Schema).to receive(:execute).with(
        queries.hello,
        variables: { "data" => [{ "upload" => "meatloaf" }] },
        context: context.merge(uploads: { "meatloaf" =>  upload })
      )

      schema.execute(queries.hello, data: [{ upload: upload }])
    end
  end
end
