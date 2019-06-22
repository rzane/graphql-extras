require "rails_helper"
require "graphql/extras/controller"

RSpec.describe GraphQL::Extras::Controller, type: :controller do
  class Query < GraphQL::Schema::Object
    field :hello, String, null: false

    def hello
      "world"
    end
  end

  class Schema < GraphQL::Schema
    query(Query)
  end

  let(:json) {
    JSON.parse(response.body)
  }

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
end
