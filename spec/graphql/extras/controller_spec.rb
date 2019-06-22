require "rails_helper"
require "graphql/extras/controller"
require "support/schema"

RSpec.describe GraphQL::Extras::Controller, type: :controller do
  let(:json) { JSON.parse(response.body) }

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
