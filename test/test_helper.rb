# frozen_string_literal: true

# Configure Rails Envinronment
ENV['RAILS_ENV'] = 'test'

require File.expand_path('../dummy/config/environment.rb', __FILE__)
require 'rails/test_help'
require 'faker'
require 'pry'

Rails.backtrace_cleaner.remove_silencers!

# Run any available migration
ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate/', __FILE__)).migrate

# Load support files
# Add support to load paths so we can overwrite broken webrat setup
$LOAD_PATH.unshift File.expand_path('../support', __FILE__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
