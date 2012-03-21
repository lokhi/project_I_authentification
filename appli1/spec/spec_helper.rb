require 'rspec'
require 'active_record'
require 'bundler'

Bundler.setup :default, :development, :test

require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end


