require "sqlite3"
require "active_support/all"
require "active_record"

module Database
  def self.setup(&block)
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    ActiveRecord::Migration.verbose = false
    ActiveRecord::Schema.define(&block)
  end

  def self.count_queries(matching)
    count = 0
    ActiveSupport::Notifications.subscribe('sql.active_record') do |_, _, _, _, values|
      count += 1 if values[:sql] && values[:sql] =~ matching
    end
    yield
    count
  end
end
