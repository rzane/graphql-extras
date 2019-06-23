require "graphql/extras/types"

RSpec.describe GraphQL::Extras::Types do
  describe GraphQL::Extras::Types::Decimal do
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

  describe GraphQL::Extras::Types::Date do
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
end
