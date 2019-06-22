require "graphql/extras/date"

RSpec.describe GraphQL::Extras::Date do
  it "parses a valid date" do
    value = described_class.coerce_input("2019-01-01", {})
    expect(value).to eq(Date.new(2019, 1, 1))
  end

  it "translates an invalid value to nil" do
    value = described_class.coerce_input("1/1/2019", {})
    expect(value).to eq(nil)
  end

  it "converts a date to a string" do
    value = described_class.coerce_result(Date.new(2019, 1, 1), {})
    expect(value).to eq("2019-01-01")
  end
end
