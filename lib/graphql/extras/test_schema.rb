require "securerandom"
require "active_support/core_ext/deep_transform_values"

class TestSchema
  def self.queries(*globs)
  end

  def self.extract_uploads(variables)
    uploads = {}

    variables = variables.deep_transform_values do |value|
      if value.respond_to? :tempfile
        key = SecureRandom.uuid
        uploads[key] = value
        key
      else
        value
      end
    end

    [variables, uploads]
  end

  def initialize(context = {})
    @context = context
  end

  def execute(name, **variables)
  end
end
