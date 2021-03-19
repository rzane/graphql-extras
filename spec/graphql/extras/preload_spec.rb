require "support/database"

RSpec.describe GraphQL::Extras::Preload do
  class Foo < ActiveRecord::Base
  end

  class Bar < ActiveRecord::Base
    belongs_to :foo
  end

  class BaseField < GraphQL::Schema::Field
    prepend GraphQL::Extras::Preload
  end

  class BaseObject < GraphQL::Schema::Object
    field_class BaseField
    field :id, ID, null: false
  end

  class BarType < BaseObject
    field :foo, BaseObject, null: false
  end

  class BatchedBarType < BaseObject
    field :foo, BaseObject, null: false, preload: :foo
  end

  class BatchQueryType < BaseObject
    field :bars, [BarType], null: false
    field :bars_batched, [BatchedBarType], null: false
    def bars; Bar.all; end
    def bars_batched; Bar.all; end
  end

  class BatchSchema < GraphQL::Schema
    query BatchQueryType
    use GraphQL::Dataloader
  end

  before :all do
    Database.setup do
      create_table(:foos, force: true)
      create_table(:bars, force: true) do |t|
        t.belongs_to :foo
      end
    end
  end

  before do
    5.times { Bar.create!(foo: Foo.create!) }
  end

  it "fires N+1 queries without batching" do
    query = <<~GRAPHQL
      query {
        bars {
          id
          foo { id }
        }
      }
    GRAPHQL

    count = Database.count_queries(/SELECT.*foos/i) do
      BatchSchema.execute(query)
    end

    expect(count).to eq(5)
  end

  it "fires 1 query with batching" do
    query = <<~GRAPHQL
      query {
        barsBatched {
          id
          foo { id }
        }
      }
    GRAPHQL

    count = Database.count_queries(/SELECT.*foos/i) do
      BatchSchema.execute(query)
    end

    expect(count).to eq(1)
  end
end
