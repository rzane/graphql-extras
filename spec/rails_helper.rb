require "spec_helper"
require "active_support/all"
require "action_view"
require "action_controller"
require "action_dispatch"
require "rspec/rails"

module Rails
  # Stub out Rails in order to act like we're running a live Rails app.

  class Application
    def env_config
      {}
    end

    def routes
      ActionDispatch::Routing::RouteSet.new
    end
  end

  def self.application
    Application.new
  end

  def self.env
    ActiveSupport::StringInquirer.new('development')
  end
end
