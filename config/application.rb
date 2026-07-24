require_relative "boot"

require "rails/all"
require "csv"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Yapai
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Fallback for eager_load to avoid nil warning in some environments
    config.eager_load = true

    # Host authorization is configured in environment-specific files
    # Production hosts are configured in config/environments/production.rb
    config.hosts << ".railway.app"
    config.hosts << ".up.railway.app"
    config.hosts << "web-production-b39ae.up.railway.app"
    config.hosts << "web-production-c67ae.up.railway.app"

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.i18n.default_locale = :en
    config.i18n.load_path += Dir[Rails.root.join("config", "locales", "**", "*.{rb,yml}")]

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Beijing"
    # config.eager_load_paths << Rails.root.join("extras")
    config.active_storage.replace_on_assign_to_many = false
    config.active_storage.variant_processor = :vips
    config.active_job.queue_adapter = :inline
    config.middleware.use Rack::Attack unless Rails.env.test?
  end
end
