require "bundler/setup"
require "graphql/extras"

module UploadHelpers
  def build_upload(fixture)
    path = File.join(__dir__, "fixtures", fixture)
    Rack::Test::UploadedFile.new(path)
  end
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include UploadHelpers
end
