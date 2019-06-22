require "graphql/extras/decimal"

RSpec.describe GraphQL::Extras::Decimal do
  it "parses a decimal" do
    value = described_class.coerce_input("5.5", {})
    expect(value).to eq(BigDecimal("5.5"))
  end

  it "translates an invalid value to nil" do
    value = described_class.coerce_input("", {})
    expect(value).to eq(nil)
  end

  it "converts a decimal to a string" do
    value = described_class.coerce_result(BigDecimal("5.5"), {})
    expect(value).to eq("5.5")
  end
end
